trigger BellNotificationTrigger on Opportunity (after insert) {
    // используй хэндлер
    for(Opportunity opportunity: Trigger.new){
        if (opportunity.Units_Amount__c>=10000) {
            //изменить на без использования флу ЛИБО!!!!!! использовать record triggered flow в связке с 30 минутным условием 
            Flow.Interview flow = new Flow.Interview.AutolaunchedFlow_Bell_Notification(new map<String,Object> 
                                                {'OpportunityRecord' => opportunity});     
            flow.start();
        }
    }
}
