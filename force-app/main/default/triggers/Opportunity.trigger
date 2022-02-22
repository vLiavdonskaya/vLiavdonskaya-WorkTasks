trigger Opportunity on Opportunity(after insert) {
  new OpportunityTriggerHelper().run();
}
