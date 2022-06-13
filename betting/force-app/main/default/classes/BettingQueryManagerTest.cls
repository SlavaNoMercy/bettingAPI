@isTest
public without sharing class BettingQueryManagerTest {
    @TestSetup
    static void createTestData(){
        Lead testLead = new Lead(LastName='testLead',Players_Fund__c=250);
        Contact testContact = new Contact(Name='testContact',Players_Fund__c=250);
        Product2 testEvent = new Product2(Name='testMatch', Multiplier__c=1.00,Event_Date__c='06/20/2022');
        Opportunity testOpportunity = new Opportunity(Name='testOpportunity',CloseDate='06/20/2022',StageName='Prospecting');
    }
}
