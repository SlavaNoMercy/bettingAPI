trigger BellNotificationTrigger on Opportunity (after insert) {
    
    for(Opportunity opportunity: Trigger.new){
        CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName='Bell_Notification_for_Chief_Betting_Manager'
             LIMIT 1];    

        Messaging.CustomNotification notification = new Messaging.CustomNotification();
 
        notification.setTitle('IT\'S OVER 10000!');
        notification.setBody('Someone bet $10000 or more:'+opportunity.id);

        notification.setNotificationTypeId(notificationType.Id);
        //notification.setTargetId(targetId);
        
        try {
            //notification.send(recipientsIds);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }            
    }
}