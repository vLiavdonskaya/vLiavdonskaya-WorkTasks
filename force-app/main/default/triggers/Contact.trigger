trigger Contact on Contact (after insert) {
    ReqResIntegration.createContacts(Trigger.New);
}