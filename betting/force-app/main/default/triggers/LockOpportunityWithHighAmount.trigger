trigger LockOpportunityWithHighAmount on Opportunity (after update) {
    Map<String, Id> typeMap = new Map<String,Id>();
    for(RecordType recordType: [SELECT ID, DeveloperName FROM RecordType WHERE sObjectType = 'Opportunity']) {
        typeMap.put(recordType.DeveloperName, recordType.id);
    }
    for(RecordType recordType: [SELECT ID, DeveloperName FROM RecordType WHERE sObjectType = 'Bet_Unit__c']) {
        typeMap.put(recordType.DeveloperName, recordType.id);
    }

    for (Opportunity opp : Trigger.new)  {        
        if (opp.StageName == 'Closed Won'&&opp.Units_Amount__c >=5000) {
            opp.RecordTypeID = typeMap.get('ReadOnly');
            opp.Important__c = true;
            Flow.Interview flow = new Flow.Interview.AutolaunchedFlow_Bell_Notification(new map<String,Object> 
                                                {'OpportunityRecord' => opp});     
            flow.start();
            User user = [SELECT Id FROM User WHERE UserRole.Name='Chief Betting Manager' LIMIT 1];
            Id playerId;
            if (opp.Lead_Player__c!=null) {
                playerId = opp.Lead_Player__c;
            } else {
                playerId = opp.Contact_Player__c;
            }
            Task newReview = new Task(OwnerId=user.Id, WhatId=opp.Id, 
            WhoId=playerId, Description='Closed Won bet, amount:'+opp.Units_Amount__c);
            for (Bet_Unit__c relatedUnit : [SELECT Id FROM Bet_Unit__c WHERE Opportunity__c=:opp.Id]) {
                relatedUnit.RecordTypeID = typeMap.get('Read_Only_Record');
            } 
        }         
    }
}