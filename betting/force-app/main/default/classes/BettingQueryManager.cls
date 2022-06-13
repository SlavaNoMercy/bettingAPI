public with sharing class BettingQueryManager {
    public static Boolean checkIfRelatedOppExists(String Name){
        Boolean isOpportunityExists;
        try {
            Opportunity betOpportunity = [SELECT Id,Name FROM Opportunity WHERE Name=:Name LIMIT 1];
            isOpportunityExists = true;
        } catch (System.QueryException e) {
            isOpportunityExists = false;
        }
        return isOpportunityExists;
    }

    public static Lead getLeadPlayer (Id playerId){
        try{
            return [SELECT Id,LastName FROM Lead WHERE Id=:playerId LIMIT 1];
        } catch(System.QueryException e){
            return null;
        }
    }
    public static Contact getContactPlayer (Id playerId){
        try{
            return [SELECT Id,Name FROM Contact WHERE Id=:playerId LIMIT 1];
        } catch(System.QueryException e){
            return null;
        }
    }
    public static Product2 getBetEvent (Id matchId){
        try{
            return [SELECT Id, Name, Multiplier__c,Event_Date__c FROM Product2 WHERE Id =:matchId LIMIT 1];
        } catch(System.QueryException e){
            return null;
        }
    }
}
