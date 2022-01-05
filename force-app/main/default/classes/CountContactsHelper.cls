public class CountContactsHelper {
    public static List<Id> getAccounts(object[] triggerData){
        List<Id> accounts = new List<Id>(); 
        for(Contact contact: (List<Contact>)triggerData){
            accounts.add(contact.AccountId);
        }
        return accounts;
    }
    private static List <AggregateResult> countContacts(List<Id> accounts){
        List <AggregateResult> contactsCount = [select count(Id)contacts, AccountId account 
                                                from Contact
                                                where AccountId in : accounts 
                                                group by AccountId];
        return contactsCount;
    }
    public static void updateAccounts(List<Id> accounts){
        List<Account> accsToUpdate = new List<Account>();
        List <AggregateResult> contacts = countContacts(accounts);
        if(contacts.size() == 0){
            for(Id accId : accounts){
                accsToUpdate.add(new Account(Id = accId, 
                                             Contacts_Count__c = 0));
            }
        }else{
            for(AggregateResult contact : contacts){
                accsToUpdate.add(new Account(Id = (Id)contact.get('account'), 
                                             Contacts_Count__c = (Decimal)contact.get('contacts')));
            } 
        }
        update accsToUpdate;
    }
}