public class OpportunityTriggerHelper extends TriggerHandler {
  public override void afterInsert() {
    system.debug('OPPORTUNITY');
    for (Opportunity opp : (List<Opportunity>) Trigger.New) {
      system.debug(opp);
    }
  }
}
