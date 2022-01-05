trigger CountContacts on Contact (after insert, after update, after delete) {
    List<Id> accounts = new List<Id>();
    List<Id> oldAccounts = new List<Id>();
    if(Trigger.isInsert)
    {
        accounts = CountContactsHelper.getAccounts(Trigger.New);
    }else if(Trigger.isUpdate){
        accounts = CountContactsHelper.getAccounts(Trigger.New);
        oldAccounts = CountContactsHelper.getAccounts(Trigger.Old);
        CountContactsHelper.updateAccounts(oldAccounts);
    }
    else if(Trigger.isDelete){
        accounts = CountContactsHelper.getAccounts(Trigger.Old);
    }
    CountContactsHelper.updateAccounts(accounts);
}