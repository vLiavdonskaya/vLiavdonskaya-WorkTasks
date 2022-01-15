trigger Contact on Contact (after insert, after delete, after update) {
    ContactTriggerHandler.updateAccounts(Trigger.New, Trigger.Old);
}