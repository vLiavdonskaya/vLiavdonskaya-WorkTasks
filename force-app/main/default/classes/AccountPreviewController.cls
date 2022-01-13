public with sharing class AccountPreviewController {
    
    private static List<Id> getAccessibleAccounts() {
        List<Id> accountIds = new List<Id>(new Map<Id, Account>([SELECT Id FROM Account]).keySet());
        List<Id> accessibleAccountsIds = new List<Id>();
        for(UserRecordAccess record : [SELECT RecordId, HasAllAccess 
                                       FROM UserRecordAccess
                                       WHERE UserId =: UserInfo.getUserId() AND
                                       RecordId IN : accountIds]) {
                                           if(record.HasAllAccess) {
                                               accessibleAccountsIds.add(record.RecordId);
                                           }
                                       }
        return accessibleAccountsIds;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        return [SELECT Name, Type, Industry, CreatedDate, Contacts_Count__c
                FROM Account 
                WHERE Id IN : getAccessibleAccounts()];
    }
}