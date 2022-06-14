trigger LockOpportunityWithHighAmount on Opportunity (before update) {
    //Один тригер на объект
    //Хэндлер
    Map<String, Id> typeMap = new Map<String,Id>();
    for(RecordType recordType: [SELECT ID, DeveloperName FROM RecordType WHERE sObjectType = 'Opportunity']) {
        typeMap.put(recordType.DeveloperName, recordType.id);
    }

    for (Opportunity opp : Trigger.new)  {        
        if (opp.StageName == 'Closed Won'&&opp.Units_Amount__c >=5000) {//константа
            opp.RecordTypeID = typeMap.get('ReadOnly');
            opp.Important__c = true;

            User user = [SELECT Id FROM User WHERE UserRole.Name='Chief Betting Manager' LIMIT 1]; // МЫ В ЦИКЛЕ!!!!!
            Id playerId;
            if (opp.Lead_Player__c!=null) {
                playerId = opp.Lead_Player__c;
            } else {
                playerId = opp.Contact_Player__c;
            }
            Task newReview = new Task(OwnerId=user.Id, WhatId=opp.Id, 
            WhoId=playerId, Description='Closed Won bet, amount:'+opp.Units_Amount__c);// лэйбла без перевода
            // инсертай  и тип проставь + нотификейшн



            /// Добавь валидации/!!!!!!!
            
        }         
    }
}