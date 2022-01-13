public class ContactTriggerHandler {
    private static List<Id> getAccountIds(List<Contact> contacts) {
        List<Id> accountIds = new List<Id>();
        for(Contact contact : contacts){
            accountIds.add(contact.AccountId);
        }
        return accountIds;
    }
    
    public static void updateAccounts(List<Contact> newContactsList, List<Contact> oldContactsList) {
        if(newContactsList != null) {
            update getNewAccount(newContactsList);
        } 
        if(oldContactsList != null) {
            update getNewAccount(oldContactsList);
        }
    } 
    
    private static List<Account> getNewAccount(List<Contact> contacts) {
        List<AggregateResult> contactsCount = [SELECT count(Id)contacts, AccountId account 
                                               FROM Contact
                                               WHERE AccountId IN : getAccountIds(contacts) 
                                               GROUP BY AccountId];
        List<Account> accounts = new List<Account>();
        if (contactsCount.size() != 0) {
            for(AggregateResult result : contactsCount) {
                accounts.add(new Account(
                    Id = (Id)result.get('account'),
                    Contacts_Count__c = (Decimal)result.get('contacts')));
            }
        } else {
            for(Contact contact : contacts) {
                accounts.add(new Account(
                    Id = contact.AccountId,
                    Contacts_Count__c = 0));
            }
        }
        return accounts;
    }
}