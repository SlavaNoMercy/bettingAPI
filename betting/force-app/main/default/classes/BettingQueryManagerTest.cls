@isTest
public without sharing class BettingQueryManagerTest {
  @isTest
  static void testQueryManager() {
    Lead testLead = new Lead(
      LastName = 'testLead',
      Company = 'none',
      Players_Fund__c = 250
    );
    Contact testContact = new Contact(
      LastName = 'testContact',
      Players_Fund__c = 250
    );
    Product2 testEvent = new Product2(
      Name = 'testMatch',
      Multiplier__c = 1.00,
      Event_Date__c = Date.today()
    );
    Opportunity testOpportunity = new Opportunity(
      Name = 'testOpportunity',
      CloseDate = Date.today(),
      StageName = 'Prospecting'
    );
    insert testLead;
    insert testContact;
    insert testEvent;
    insert testOpportunity;
    List<Bet_Unit__c> testBetUnits = new List<Bet_Unit__c>();
    for (Integer i = 0; i < 5; i++) {
      Bet_Unit__c testUnit = new Bet_Unit__c(
        Name = 'test' + i,
        Coefficient__c = 1.45,
        Bet_Amount__c = 200,
        Opportunity__c = testOpportunity.Id
      );
      testBetUnits.add(testUnit);
    }
    insert testBetUnits;

    Lead existingLeadRecord = BettingQueryManager.getLeadPlayer(testLead.Id);
    Lead notExistingLeadRecord = BettingQueryManager.getLeadPlayer(
      '00Q5j00000CEtIjEAL'
    );
    Contact existingContactRecord = BettingQueryManager.getContactPlayer(
      testContact.Id
    );
    Contact notExistingContactRecord = BettingQueryManager.getContactPlayer(
      '00Q5j00000CEtIjEAL'
    );
    Product2 existingEventRecord = BettingQueryManager.getBetEvent(
      testEvent.Id
    );
    Product2 notExistingEventRecord = BettingQueryManager.getBetEvent(
      '00Q5j00000CEtIjEAL'
    );
    Opportunity existingBetRecord = BettingQueryManager.getExistingOpportunity(
      'testOpportunity'
    );
    Opportunity notExistingBetRecord = BettingQueryManager.getExistingOpportunity(
      'qwwwwe'
    );
    List<Bet_Unit__c> existingUnitRecords = BettingQueryManager.getExistingUnits(
      testOpportunity.Id
    );
    List<Bet_Unit__c> notExistingUnitRecords = BettingQueryManager.getExistingUnits(
      '00Q5j00000CEtIjEAL'
    );

    System.assertEquals('testLead', existingLeadRecord.LastName);
    System.assertEquals('testContact', existingContactRecord.Name);
    System.assertEquals('testMatch', existingEventRecord.Name);
    System.assertEquals('testOpportunity', existingBetRecord.Name);
    System.assertEquals(5, existingUnitRecords.size());
    System.assertEquals(null, notExistingLeadRecord);
    System.assertEquals(null, notExistingContactRecord);
    System.assertEquals(null, notExistingEventRecord);
    System.assertEquals(null, notExistingBetRecord);
    System.assertEquals(0, notExistingUnitRecords.size());
  }
}
