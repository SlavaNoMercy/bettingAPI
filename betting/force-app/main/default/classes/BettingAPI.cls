@RestResource(urlMapping='/bettingAPI/')//имеющий смысл урл
global without sharing class BettingAPI {
    @HttpPost
    global static void createOpportunity() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.statusCode = 200;//не нужен, только в конце
        //Объявления по месту использования
        Lead playerLead = null;
        Contact playerContact = null;
        Opportunity opportunity = new Opportunity();
        Product2 betEvent = null;
        List<Bet_unit__c> betUnitsOnEvent = new List<Bet_unit__c>();

        ParseJSONBettingInput bettingInput = ParseJSONBettingInput.parse((req.requestBody).toString()); // заменить на стандартный парсинг либо стрикт парсинг

        if(bettingInput.errorMessage==''){ // инвертируй
                if(bettingInput.playerID.length()==18||
                bettingInput.playerID.length()==15){
                    Id playerId = (Id)bettingInput.playerID;
                    playerLead = BettingQueryManager.getLeadPlayer(playerId);
                    // условие и только иначе вторая кверя
                    playerContact = BettingQueryManager.getContactPlayer(playerId);

                    if (playerLead !=null) {
                        opportunity.Name = playerLead.LastName;//тренарка
                        opportunity.Lead_Player__c = playerLead.Id;
                    } 
                    else if (playerContact !=null) {
                        opportunity.Name = playerContact.Name;
                        opportunity.Contact_Player__c = playerContact.Id;
                    } else { 
                        res.statusCode = 400;
                        // Auth error
                        res.responseBody = Blob.valueOf('Authentication Error'); // в json и лэйбл 
                        //return
                        
                    } 
                } 

                if(bettingInput.matchID.length()==18||
                bettingInput.matchID.length()==15){
                    Id matchId = (Id)bettingInput.matchID;
                    betEvent = BettingQueryManager.getBetEvent(matchId);
                    if (betEvent==null) {
                        res.statusCode = 400;
                        res.responseBody = Blob.valueOf('Bet Event doesn\'t exist');
                    }
                    else {
                        opportunity.Name += ' ' + betEvent.Name;
                    }
                } else {
                    res.statusCode = 400;
                    res.responseBody = Blob.valueOf('ID field must be 15 or 18 symbols');
                }

            if (BettingQueryManager.checkIfRelatedOppExists(opportunity.Name)) { // ищем по айдишкам не по имени
                opportunity = BettingQueryManager.getExistingOpportunity(opportunity.Name);
            }

            if (bettingInput.betUnits.errorMessage=='') {// заменить на нормальное условие
                Double summary = 0;//имя
                for(ParseJSONBettingInput.UnitInstance newUnit: bettingInput.betUnits.parsedBetUnits){
                    if(newUnit.errorMessage==''){ // инвертируй
                        Double calculatedCoefficient = newUnit.Coefficient;//коэф по другому пишется
                        if (betEvent!=null&&betEvent.Multiplier__c>=0) {//инвертируй
                            calculatedCoefficient = newUnit.Coefficient * betEvent.Multiplier__c;
                        }
                        if(res.statusCode!=400){// убрать везде
                            Bet_Unit__c betUnit = new Bet_Unit__c(Name = newUnit.Name,Bet_Amount__c = newUnit.Amount,
                                                                Coefficient__c = calculatedCoefficient,Bet_Event__c = betEvent.Id);// пустой конструктор и присвоения
                            
                            summary += betUnit.Bet_Amount__c;
                            if(playerLead.Players_Fund__c>=summary||playerContact.Players_Fund__c>=summary){
                                betUnitsOnEvent.add(betUnit);
                            }
                            else {
                                res.statusCode = 400;//уже говорили
                                res.responseBody = Blob.valueOf('Players fund is not enought');
                            }
                        }
                    } else {
                        res.statusCode = 400;
                        res.responseBody = Blob.valueOf(newUnit.errorMessage);
                        break;//переделать что бы не было так много условий
                    }
                }
            }
            else {
                //++++
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(bettingInput.betUnits.errorMessage);
            }

            if(res.statusCode!=400 && betEvent!=null){
                if (Date.today() <= betEvent.Event_Date__c) {
                    opportunity.Bet_Time__c = Datetime.now();
                    opportunity.CloseDate = betEvent.Event_Date__c;
                    opportunity.StageName = 'Prospecting';//константа
                }
                else {
                    res.statusCode = 400;
                    res.responseBody = Blob.valueOf('Too late to make bets on this Event');
                }
            }

            if (res.statusCode != 400) {
                upsert opportunity;// разделить на условия 
                List<Bet_Unit__c> existingUnits = BettingQueryManager.getExistingUnits(opportunity.Id);//same 
                Set<String> unitNames = new Set<String>();
                if (existingUnits.size()>0) {
                    for (Bet_Unit__c checkNameOfUnit : existingUnits) {
                        unitNames.add(checkNameOfUnit.Name);
                    }   
                }
                if (betUnitsOnEvent.size()>15) { // проверка на суммарное количество а не только на которые пришли
                    res.statusCode = 400;
                    res.responseBody = Blob.valueOf('Too much bet units on Event');//!!!!!!!!!!!!!!!
                }else {
                    for (Bet_Unit__c betUnit : betUnitsOnEvent) {
                        if (unitNames.contains(betUnit.Name)) {
                            res.statusCode = 400;
                            res.responseBody = Blob.valueOf('Attempt to make same bet on event!');
                            break;
                        } 
                        else {
                            betUnit.Opportunity__c = opportunity.Id;
                            res.statusCode = 200;
                            res.responseBody = Blob.valueOf('The bet was successfully registered');
                        }
                    }
                    if (res.statusCode==200) {
                        insert betUnitsOnEvent;
                    }
                }
            }
        } else {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(bettingInput.errorMessage);
        }
    }
}
        // Map<String,List<String>> parsedReq = (Map<String,List<String>>)JSON.deserializeUntyped(req.requestBody.toString());

        // // if(parsedReq.get('dateTime')[0]!=''){
        // //     Datetime betTime = DateTime.parse(parsedReq.get('dateTime')[0]);
        // //     opportunity.Name += betTime + ' ';
        // // } else { 
        // //     res.statusCode = 400; // dateTime format error
        // // }
        // if(parsedReq.get('playerID')[0].length()==18||
        //    parsedReq.get('playerID')[0].length()==15){
        //     Id playerId = '%'+(Id)parsedReq.get('playerId')[0] + '%';
        //     Lead playerLead = [SELECT Id,LastName FROM Lead WHERE Id=:playerId LIMIT 1];
        //     Contact playerContact = [SELECT Id,Name FROM Contact WHERE Id=:playerId LIMIT 1];
        //     if (playerLead !=null) {
        //         opportunity.Name += playerLead.LastName;
        //         opportunity.Lead_Player__c = playerLead.Id;
        //     } 
        //     if (playerContact !=null) {
        //         opportunity.Name += playerContact.Name;
        //         opportunity.Contact_Player__c = playerContact.Id;
        //     } else {
        //         res.statusCode = 400;
        //         // Auth error 
        //     } 
        // } else { 
        //     res.statusCode = 400; // Wrong Id input
        // }
        // if(parsedReq.get('macthID')[0]!=''){
        //     Id matchId = '%' + (Id)parsedReq.get('matchId')[0] + '%';
        //     betEvent = [SELECT Id,Name,Multiplier__c FROM Product2 WHERE Id=:matchId LIMIT 1];
        // } else { 
        //     res.statusCode = 400; // Product error
        // }
        // if (parsedReq.get('betUnits').size()<=15) {
        //     for (String unitNameAndAmount : parsedReq.get('betUnits')) {
        //         List<String> parts = unitNameAndAmount.split(':,',2);
        //         String unitName = parts[0];
        //         Double unitAmount = Double.valueOf(parts[1]);
        //         Double unitCoefficient = 1.38;
                
        //         Bet_Unit__c betUnit = new Bet_Unit__c(Name=unitName, Bet_Amount__c=unitAmount,
        //          Coefficient__c=unitCoefficient, Opportunity__c=opportunity.Id);
        //         betUnits.add(betUnit);
        //         //res.responseBody = Blob.valueOf(unitName);
        //     }
        // } else { 
        //     res.statusCode = 400; // Wrong bets
        // }
        

        //String jsonString = EncodingUtil.base64Encode(req.requestBody);
        //res.headers = req.headers;
        //res.statusCode = 200;
        //res.responseBody = req.requestBody;
//     }
// }