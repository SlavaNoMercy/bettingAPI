public with sharing class BettingQueryManager {
  //Форматирование, убрать ненужные зануления, добавить проверку входящих параметров, убрать излишки переменных
  public static Lead getLeadPlayer(Id playerId) {
    try {
      return [
        SELECT 
            Id,
            LastName,
            Players_Fund__c
        FROM Lead
        WHERE Id = :playerId
        LIMIT 1
      ];
    } catch (System.QueryException e) {
      return null;
    }
  }
  public static Contact getContactPlayer(Id playerId) {
    try {
      return [
        SELECT 
            Id,
            Name,
            Players_Fund__c
        FROM Contact
        WHERE Id = :playerId
        LIMIT 1
      ];
    } catch (System.QueryException e) {
      return null;
    }
  }
  public static Product2 getBetEvent(Id matchId) {
    try {
      return [
        SELECT 
            Id,
            Name,
            Multiplier__c,
            Event_Date__c
        FROM Product2
        WHERE Id = :matchId
        LIMIT 1
      ];
    } catch (System.QueryException e) {
      return null;
    }
  }
  public static List<Bet_Unit__c> getExistingUnits(Id opportunityId) {
    try {
      return [
        SELECT 
            Name,
            Coefficient__c,
            Bet_Amount__c
        FROM Bet_Unit__c
        WHERE Opportunity__c = :opportunityId
      ];
    } catch (System.QueryException e) {
      return null;
    }
  }
  public static Opportunity getExistingOpportunity(Id playerId) {
    try {
      return [
        SELECT
            Id,
            Name,
            Bet_Time__c,
            CloseDate,
            StageName,
            Players_Fund_After_Bet__c,
            Players_Fund_Before_Bet__c
        FROM Opportunity
        WHERE 
            Lead_Player__c =:playerId OR
            Contact_Player__c =:playerId
        LIMIT 1
      ];
    } catch (System.QueryException e) {
      return null;
    }
  }
}
