public class ConvertDonationService {
    
    static final String AMOUNT_API_NAME = 'Amount__c';
    static final String STATUS_NEW = 'New';
    static final String STATUS_CONVERTED = 'Converted';
    static final String STATUS_FAILED = 'Failed';
    
    static final String CONVERTED_ACCOUNT_API_NAME = 'ConvertedAccount__c';
    static final String CONVERTED_CONTACT_API_NAME = 'ConvertedContact__c';
    static final String CONVERTED_OPPORTUNITY_API_NAME = 'ConvertedDonation__c';
    
    static final Id SYSTEM_ADMINISTRATOR = [SELECT Id FROM User WHERE profile.Name = 'System Administrator' AND user.isActive = true].Id;
    
    public class ConvertDonationFinalizer implements Finalizer {
        List<CommunityDonation__c> convertedDonations = new List<CommunityDonation__c>();
        
        public ConvertDonationFinalizer(List<CommunityDonation__c> convertedDonations) {
            this.convertedDonations = convertedDonations;
        }
        
        public void execute(FinalizerContext context) {
            String jobStatus = [SELECT Status FROM AsyncApexJob WHERE Id =: context.getAsyncApexJobId()].Status;
            ConvertDonationService.updateDonationStatus(jobStatus, convertedDonations);
        }
    }
    
    public class ConvertDonation implements Queueable {  
        List<CommunityDonation__c> donationsToConvert = new List<CommunityDonation__c>();
        
        public ConvertDonation(List<CommunityDonation__c> donationsToConvert) {
            this.donationsToConvert = donationsToConvert;
        }
        
        public void execute(QueueableContext context) {
            ConvertDonationFinalizer finalizer = new ConvertDonationFinalizer(this.donationsToConvert);
            System.attachFinalizer(finalizer);
            ConvertDonationService.convertDonations(this.donationsToConvert);
        }
    }
    
    public class ConvertCommunityDonationException extends Exception {}
    
    public static void createDonations(List<CommunityDonation__c> donationsToConvert) {
        List<Database.SaveResult> resultList = Database.insert(donationsToConvert);
        
        for (Database.SaveResult result : resultList) {
            if(!result.isSuccess()) {
                for(Database.Error err : result.getErrors()) {
                    throw new ConvertCommunityDonationException(err.getMessage());
                }
            }
        }
        system.enqueueJob(new ConvertDonation(donationsToConvert));
    }
    
    public static CommunityDonation__c createCommunityDonation(String donation) {
        Map<String, Object> dnt = (Map<String, Object>)JSON.deserializeUntyped(donation);
        CommunityDonation__c donationToConvert = new CommunityDonation__c();
        for(String key : dnt.keySet()) {
            if(key == AMOUNT_API_NAME) {
                donationToConvert.put(key, Decimal.valueOf(dnt.get(key).toString()));
            } else {
                donationToConvert.put(key, dnt.get(key));
            }
        }
        donationToConvert.Status__c = STATUS_NEW;
        return donationToConvert;
    }
    
    public static void convertDonations(List<CommunityDonation__c> donationsToConvert) { 
        List<CommunityDonation__c> donations = [SELECT Id
                                                FROM CommunityDonation__c WHERE Id IN : donationsToConvert
                                                AND (NOT(Status__c IN ('Failed', 'Converted'))) 
                                                AND ConvertedDonation__c = null FOR UPDATE];
        SavePoint communityDonationCreated = Database.setSavepoint();
        
        List<Account> accounts = new List<Account>();
        List<Contact> contacts = new List<Contact>();
        List<Opportunity> opportunities = new List<Opportunity>();
        
        try {
            createAccount(donationsToConvert);
            createContact(donationsToConvert);
            createOpportunity(donationsToConvert);
        } catch(Exception error) {
            Database.rollback(communityDonationCreated);
            throw error;
        }
    }
    
    private static void createRecord(List<sObject> records, String idField, List<CommunityDonation__c> donationsToConvert) {        
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        
        List<Database.SaveResult> resultList = Database.insert(records, dml);
        List<Id> idList = new List<Id>();
        for(Database.SaveResult result : resultList) {
            if(!result.isSuccess()) {
                for(Database.Error err : result.getErrors()) {
                    throw new ConvertCommunityDonationException(err.getMessage());
                }
            } else {
                idList.add(result.getId());
            }
        }
        putConvertedIds(idList, donationsToConvert, idField);
    }
    
    private static void putConvertedIds(List<Id> idList, List<CommunityDonation__c> donationsToConvert, String idField) {
        Integer idIndex = 0;
        Integer dntIndex = 0;
        while(idIndex < idList.size() && dntIndex < donationsToConvert.size()) {
            if(String.isNotBlank(donationsToConvert[dntIndex].CompanyName__c) && idField == CONVERTED_ACCOUNT_API_NAME) {
                donationsToConvert[dntIndex].put(idField, idList[idIndex]);
                idIndex++;
            } else if(idField != CONVERTED_ACCOUNT_API_NAME) {
                donationsToConvert[dntIndex].put(idField, idList[idIndex]); 
                idIndex++;
            }
            dntIndex++;
        }
    }
    
    private static void createAccount(List<CommunityDonation__c> donationsToConvert) {
        List<Account> accounts = new List<Account>();
        for(CommunityDonation__c donation : donationsToConvert) {
            if(String.isNotBlank(donation.CompanyName__c)) {
                accounts.add(new Account (
                    Name = donation.CompanyName__c,
                    BillingCity = donation.City__c,
                    BillingCountry = getCountry(donation.Country__c),
                    BillingPostalCode = donation.PostalCode__c,
                    BillingStreet = donation.Street__c,
                    Phone = donation.Phone__c,
                    OwnerId = SYSTEM_ADMINISTRATOR
                ));
            }
        }
        createRecord(accounts, CONVERTED_ACCOUNT_API_NAME, donationsToConvert);
    }
    
    private static void createContact(List<CommunityDonation__c> donationsToConvert) {
        List<Contact> contacts = new List<Contact>();
        for(CommunityDonation__c donation : donationsToConvert) {
            contacts.add(new Contact(
                FirstName = donation.FirstName__c,
                LastName = donation.LastName__c,
                AccountId = donation.convertedAccount__c,
                Phone = donation.Phone__c,
                Email = donation.Email__c,
                Language__c = donation.Language__c
            ));
        }
        createRecord(contacts, CONVERTED_CONTACT_API_NAME, donationsToConvert);
    }
    
    private static void createOpportunity(List<CommunityDonation__c> donationsToConvert) {
        List<Opportunity> opportunities = new List<Opportunity>();
        Formula.recalculateFormulas(donationsToConvert);
        for(CommunityDonation__c donation : donationsToConvert) {
            opportunities.add(new Opportunity(
                Name = donation.DonationName__c,
                Amount = donation.Amount__c,
                AccountId = donation.ConvertedAccount__c,
                StageName = 'Prospecting',
                CloseDate =  Date.today().addDays(30)
            ));
        }
        createRecord(opportunities, CONVERTED_OPPORTUNITY_API_NAME, donationsToConvert);
    }
    
    private static String getCountry(String countryCode) {
        for(Schema.PicklistEntry country : Contact.MailingCountryCode.getDescribe().getPicklistValues()) {
            if(country.getValue() == countryCode) return country.getLabel();
        }
        return '';
    }
    
    public static void updateDonationStatus(String jobStatus, List<CommunityDonation__c> convertedDonations) {
        for(CommunityDonation__c donation : convertedDonations) {
            donation.Status__c = jobStatus == 'Completed' ? STATUS_CONVERTED : STATUS_FAILED;
        }
        update convertedDonations;
    }
}
