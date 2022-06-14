trigger BellNotificationTrigger on Opportunity (after insert, after update) {
    
    for(Opportunity opportunity: Trigger.new){
        if (opportunity.Units_Amount__c>=10000) {
            Flow.Interview flow = new Flow.Interview.AutolaunchedFlow_Bell_Notification(new map<String,Object> 
                                                {'OpportunityRecord' => opportunity});     
            flow.start();
        }
    }
}



 //if (opportunity.Amount>=10000) {
            // CustomNotificationType notificationType = 
            //     [SELECT Id, DeveloperName 
            //     FROM CustomNotificationType 
            //     WHERE DeveloperName='Bell_Notification_for_Chief_Betting_Manager'
            //     LIMIT 1];    

            // Messaging.CustomNotification notification = new Messaging.CustomNotification();
    
            // notification.setTitle('IT\'S OVER 10000!');
            // notification.setBody('Someone bet $10000 or more:'+'https://senla8-dev-ed.lightning.force.com/lightning/r/Opportunity/' + opportunity.Id + '/view');
            // notification.setNotificationTypeId(notificationType.Id);
            
            // User target = [SELECT Id FROM User WHERE UserRole.Name = 'Chief_Betting_Manager' LIMIT 1];
            // notification.setTargetId(opportunity.Id);
            
            // try {
            //     notification.send(target.Id);
            // }
            // catch (Exception e) {
            //     System.debug('Problem sending notification: ' + e.getMessage());
            // }            
        //}