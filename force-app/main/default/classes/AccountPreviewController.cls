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
        return [SELECT Id, Name, Type, Industry, CreatedDate, Contacts_Count__c
                FROM Account 
                WHERE Id IN : getAccessibleAccounts()];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Account> findAccounts(String query) {
        List<Account> accounts = (List<Account>)[FIND :query
                                                 RETURNING Account(Id, Name, Type, Industry, Contacts_Count__c, CreatedDate
                                                                   WHERE Id IN : getAccessibleAccounts())][0];
        return accounts;
    }
    
    @AuraEnabled
    public static List<Account> updateAccounts(List<Account> accounts) {
        update accounts;
        return getAccounts();
    }
    
    @AuraEnabled
    public static Integer sendAccounts(String accId) {
        String accountName = [SELECT Name FROM Account WHERE Id =: accId].Name;
        return ReqResIntegration.createAccounts(new Map<String, String>{'name' => accountName});
    }
}