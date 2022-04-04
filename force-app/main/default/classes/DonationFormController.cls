public class DonationFormController {
    @AuraEnabled (cacheable=true)
    public static List<Campaign> getCampaignList() {
        String langLocaleKey = [SELECT LanguageLocaleKey 
                                FROM User 
                                WHERE Id =: UserInfo.getUserId()].LanguageLocaleKey;
        return [SELECT Id, Name FROM Campaign WHERE EnabledForVolunteerLanguage__c INCLUDES(:langLocaleKey)];
    }
    
    @AuraEnabled (cacheable=true)
    public static Map<String, String> getSalutationList() {
        Map<String, String> salutations = new Map<String, String>();
        for(Schema.PicklistEntry salutation : Contact.Salutation.getDescribe().getPicklistValues()) {
            salutations.put(salutation.getLabel(), salutation.getValue());
        }
        return salutations;
    }
    
    @AuraEnabled (cacheable=true)
    public static Map<String, String> getCountryList() {
        Map<String, String> countries = new Map<String, String>();
        for(Schema.PicklistEntry country : Contact.MailingCountryCode.getDescribe().getPicklistValues()) {
            countries.put(country.getValue(), country.getLabel());
        }
        return countries;
    }
    
    @AuraEnabled (cacheable=true)
    public static Map<String, String> getLanguageList() {
        Map<String, String> languages = new Map<String, String>();
        for(Schema.PicklistEntry language : User.LanguageLocaleKey.getDescribe().getPicklistValues()) {
            String label = language.getValue().substringBefore('_').toUpperCase();
            languages.put(label, language.getValue());            
        }
        return languages;
    }
}