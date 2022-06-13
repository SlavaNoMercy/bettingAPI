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
}
