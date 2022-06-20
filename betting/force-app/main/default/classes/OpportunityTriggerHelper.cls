public without sharing class OpportunityTriggerHelper {
  public void notifyChiefBetManager(
    List<Opportunity> opportunities,
    String title
  ) {
    List<User> recipients = [// Выглядит как отдельный метод для мэнеджера
      SELECT Id
      FROM User
      WHERE UserRole.Name = :'Chief Betting Manager'
      LIMIT 10// Почему?!
    ];

    List<Task> tasks = new List<Task>();
    for (Opportunity opportunity : opportunities) {
      if (opportunity.Units_Amount__c >= 10000) {
        sendCustomNotification(opportunity, recipients, title);// упадем в лимиты
      } else if (
        opportunity.Units_Amount__c >= 5000 &&
        opportunity.StageName == BettingAPIConstants.LOCK_OPPORTUNITY_STAGE_NAME
      ) {
        Id playerId;
        if (opportunity.Lead_Player__c != null) {
          playerId = opportunity.Lead_Player__c;
        } else {
          playerId = opportunity.Contact_Player__c;
        }
        Task newReview = new Task();
        newReview.OwnerId = recipients[0].Id;
        newReview.WhatId = opportunity.Id;
        newReview.WhoId = playerId;
        newReview.Type = BettingAPIConstants.DEFAULT_TASK_TYPE;
        newReview.Description = 'Closed Won bet, amount:' + opportunity.Units_Amount__c;
        tasks.add(newReview);
        sendCustomNotification(opportunity, recipients, title);//Упадем в лимиты
      }
    }
    insert tasks;// ТОлько в after триггере
  }

  public void sendCustomNotification(Opportunity opportunity, List<User> recipients, String title) {
    CustomNotificationType notificationType = [//Выносится в менеджер
      SELECT Id, DeveloperName
      FROM CustomNotificationType
      WHERE DeveloperName = 'Bell_Notification_for_Chief_Betting_Manager'
    ];

    Set<String> recipientIDs = new Set<String>();
    for (User recipient : recipients) {
      recipientIDs.add(recipient.Id);
    }
    Messaging.CustomNotification notification = new Messaging.CustomNotification();

    notification.setTitle(title);
    notification.setBody('Bet amount: ' + opportunity.Units_Amount__c);

    notification.setNotificationTypeId(notificationType.Id);
    notification.setTargetId(opportunity.Id);

    try {
      notification.send(recipientIDs);
    } catch (Exception e) {
      System.debug('Problem sending notification: ' + e.getMessage());
    }
  }
}
