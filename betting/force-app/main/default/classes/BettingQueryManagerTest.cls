@isTest
public without sharing class BettingQueryManagerTest {
    @TestSetup
    static void createTestData(){
        Lead testLead = new Lead(LastName='testLead',Players_Fund__c=250);
        Contact testContact = new Contact(Name='testContact',Players_Fund__c=250);
        Product2 testEvent = new Product2();
        Opportunity testOpportunity = new Opportunity(Name='testOpportunity');
    }
}
