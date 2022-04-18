public class DonationFormController {

    @AuraEnabled (cacheable=true)
    public static List<Campaign> getCampaignList() {
        String langLocaleKey = [SELECT LanguageLocaleKey 
                                FROM User 
                                WHERE Id =: UserInfo.getUserId()].LanguageLocaleKey;
        return [SELECT Id, Name FROM Campaign WHERE EnabledForVolunteerLanguage__c INCLUDES(:langLocaleKey)];
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
    
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getMapOfLabelsPerObject(String objectAPIName){
        Map<String, String> labelByFieldApiName = new Map<String, String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        
        if (objectAPIName != null){
            Schema.SObjectType objectSchema = schemaMap.get(objectAPIName);
            Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
            
            for (String fieldName: fieldMap.keySet()){
                labelByFieldApiName.put(fieldName, fieldMap.get(fieldName).getDescribe().getLabel());
            }
        }
        return labelByFieldApiName;
    }
    
    @AuraEnabled
    public static void createCommunityDonation(String donation) {
        ConvertDonationService.createDonations(new List<CommunityDonation__c>{ConvertDonationService.createCommunityDonation(donation)});
    }
}
