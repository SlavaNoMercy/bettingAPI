trigger CoefficientsChangeTrigger on Change_Betting_Coefficients__e (after insert) {
    for(Change_Betting_Coefficients__e event : Trigger.new){
        Cache.Org.put('local.BettingCoefficients.' + event.Product_Name__c + event.Bet_Unit_Name__c, event.Coefficient__c);
    }
}