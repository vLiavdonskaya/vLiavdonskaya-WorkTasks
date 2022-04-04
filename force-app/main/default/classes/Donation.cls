public class Donation {
    public class DonationWrapper {
        String CompanyName;
        String Salutation;
        String FirstName;
        String LastName;
        String Language;
        String Street;
        String PostalCode;
        String City;
        String PostalCodeComplement;
        String Country;
        Boolean SubscribeToNewsletter;
        String Phone;
        Decimal Amount;
        Id Campaign;
    }
    
    public class ConvertCommunityDonationException extends Exception {}
    
    @AuraEnabled
    public static Map<String, String> createDonation(String donation) {        
        DonationWrapper dnt = (DonationWrapper)JSON.deserialize(donation, DonationWrapper.class);
        CommunityDonation__c donationToConvert = new CommunityDonation__c(
            CompanyName__c = dnt.CompanyName,
            Salutation__c = dnt.Salutation,
            FirstName__c = dnt.FirstName,
            LastName__c = dnt.LastName,
            Language__c = dnt.Language,
            Street__c = dnt.Street,
            PostalCode__c = dnt.PostalCode,
            City__c = dnt.City,
            PostalCodeComplement__c = dnt.PostalCodeComplement,
            Country__c = dnt.Country,
            SubscribeToNewsletter__c = dnt.SubscribeToNewsletter,
            Phone__c = dnt.Phone, 
            Amount__c = dnt.Amount,
            Campaign__c = dnt.Campaign,
            Status__c = 'Pending'
        );
        Database.SaveResult result = Database.insert(donationToConvert);
        String jobId = '';
        if(result.isSuccess()) {
            jobId = system.enqueueJob(new ConvertDonation(donationToConvert));
        } else {
            for(Database.Error err : result.getErrors()) {
                throw new ConvertCommunityDonationException(err.getMessage());
            }
        }
        return new Map<String, String>{'donationId' => result.getId(), 'jobId' => jobId};
            }
    
    public static void convertDonation(CommunityDonation__c donationToConvert) {        
        if(String.isNotBlank(donationToConvert.Id)) {
            CommunityDonation__c donation = [SELECT Id
                                             FROM CommunityDonation__c WHERE Id =: donationToConvert.Id 
                                             AND (NOT(Status__c IN ('Failed', 'Converted'))) 
                                             AND ConvertedDonation__c = null FOR UPDATE];
            SavePoint communityDonationCreated = Database.setSavepoint();
            
            Account account = new Account();
            Contact contact = new Contact();
            Opportunity opportunity = new Opportunity();
            
            try {
                if(String.isNotBlank(donationToConvert.CompanyName__c)) createAccount(donationToConvert, account);
                createContact(donationToConvert, contact, account.Id);
                createOpportunity(donationToConvert, opportunity, account.Id);
            } catch(Exception error) {
                Database.rollback(communityDonationCreated);
                throw error;
            }
        }
    }
    
    private static void createRecord(sObject record) {        
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        
        Database.SaveResult result = Database.insert(record, dml);
        if(!result.isSuccess()) {
            for(Database.Error err : result.getErrors()) {
                throw new ConvertCommunityDonationException(err.getMessage());
            }
        }
    }
    
    private static void createAccount(CommunityDonation__c donation, Account account) {
        account.Name = donation.CompanyName__c;
        account.BillingCity = donation.City__c;
        account.BillingCountry = DonationFormController.getCountryList().get(donation.Country__c);
        account.BillingPostalCode = donation.PostalCode__c;
        account.BillingStreet = donation.Street__c;
        account.Phone = donation.Phone__c;
        createRecord(account);
    }
    
    private static void createContact(CommunityDonation__c donation, Contact contact, Id accountId) {
        contact.FirstName = donation.FirstName__c;
        contact.LastName = donation.LastName__c;
        contact.AccountId = accountId;
        contact.Phone = donation.Phone__c;
        contact.Email = donation.Email__c;
        contact.Language__c = donation.Language__c;
        createRecord(contact);
    }
    
    private static void createOpportunity(CommunityDonation__c donation, Opportunity opportunity, Id accountId) {
        opportunity.Name = [SELECT DonationName__c FROM CommunityDonation__c WHERE Id =: donation.Id].DonationName__c;
        opportunity.Amount = donation.Amount__c;
        opportunity.AccountId = accountId;
        opportunity.StageName = 'Prospecting';
        opportunity.CloseDate =  Date.today().addDays(30);
        createRecord(opportunity);
    }
    
    @AuraEnabled
    (cacheable=true)
    public static List<AsyncApexJob> checkJobStatus(String jobId) {
        return [SELECT Status, ExtendedStatus FROM AsyncApexJob WHERE Id =: jobId];
    }
    
    @AuraEnabled
    public static CommunityDonation__c setCommunityDonationStatus(String donationId, String status) {
        CommunityDonation__c communityDonation = [SELECT Status__c FROM CommunityDonation__c WHERE Id =: donationId];
        communityDonation.Status__c = status; 
        update communityDonation;
        return communityDonation;
    }
}