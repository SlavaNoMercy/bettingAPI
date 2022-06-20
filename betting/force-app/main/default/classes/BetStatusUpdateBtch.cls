global class BetStatusUpdateBtch implements Database.Batchable<SObject>, Database.Stateful {
  //Батч не имеет смысла от слова совсем. Больше похож на future метод. Этот батч должен был обрабатывать ВСЕ возможные Opportunity под определенное событие
  public Opportunity opportunity;
  public BetStatusUpdateBtch(Opportunity opportunity) {
    this.opportunity = opportunity;
  }

  global Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      'SELECT Id,Name,Bet_Amount__c,Recalculated_coefficient__c,Win_Unit__c'+
      'FROM Bet_Unit__c'+
      'WHERE Opportunity__c : opportunity.Id'+
      'LIMIT 15'
    );
  }

  global void execute(
    Database.BatchableContext bc,
    List<Bet_Unit__c> betUnits
  ) {
    opportunity.Total_Winning__c = 0;
    for (Bet_Unit__c unit : betUnits) {
        if(unit.Name.contains('Win')||unit.Name.contains('score')||unit.Name.contains('point')){
            unit.Win_Unit__c = true;
            opportunity.Total_Winning__c += unit.Bet_Amount__c * unit.Recalculated_coefficient__c;
        }
    }
    opportunity.StageName = BettingAPIConstants.LOCK_OPPORTUNITY_STAGE_NAME;
    update betUnits;
    update opportunity;
  }

  global void finish(Database.BatchableContext bc) {
  }
}
