trigger BellNotificationTrigger on Opportunity (after insert) {
    // используй хэндлер
    CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName='Bell_Notification_for_Chief_Betting_Manager'];
    List<User> recipients = [SELECT Id FROM User WHERE UserRole.Name =:'Chief Betting Manager' LIMIT 10];
    Set<String> recipientIDs = new Set<String>();
    for (User recipient : recipients) {
        recipientIDs.add(recipient.Id);
    }
    for(Opportunity opportunity: Trigger.new){
        if (opportunity.Units_Amount__c>=10000) {
            //изменить на без использования флу ЛИБО!!!!!! использовать record triggered flow в связке с 30 минутным условием \\ 30 минут условие не для Opportunity 
            // Flow.Interview flow = new Flow.Interview.AutolaunchedFlow_Bell_Notification(new map<String,Object> 
            //                                     {'OpportunityRecord' => opportunity});     
            // flow.start();
             
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
 
        // Set the contents for the notification
        notification.setTitle('It\'s over 10000');
        notification.setBody('Bet amount: '+opportunity.Units_Amount__c);
 
        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(opportunity.Id);
        
        // Actually send the notification
        try {
            notification.send(recipientIDs);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
        }
    }
}
