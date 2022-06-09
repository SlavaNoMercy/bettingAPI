@RestResource(urlMapping='/bettingAPI/v1.1')
global without sharing class BettingAPI {
    @HttpPost
    global static void createOpportunity() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Opportunity opportunity = new Opportunity();
        Product2 betEvent;
        List<Bet_unit__c> betUnits = new List<Bet_unit__c>();

        Map<String,List<String>> parsedReq = (Map<String,List<String>>)JSON.deserializeUntyped(req.requestBody.toString());
        if(parsedReq.get('dateTime')[0]!=''){
            Datetime betTime = DateTime.parse(parsedReq.get('dateTime')[0]);
            opportunity.Name += betTime + ' ';
        } else { 
            res.statusCode = 400; // dateTime format error
        }
        if(parsedReq.get('playerID')[0]!=''||
        parsedReq.get('playerID')[0].length()<15 ){
            Id playerId = '%'+(Id)parsedReq.get('playerId')[0] + '%';
            Lead playerLead = [SELECT Id,LastName FROM Lead WHERE Id=:playerId LIMIT 1];
            Contact playerContact = [SELECT Id,Name FROM Contact WHERE Id=:playerId LIMIT 1];
            if (playerLead !=null) {
                opportunity.Name += playerLead.LastName;
                opportunity.Lead_Player__c = playerLead.Id;
            } 
            if (playerContact !=null) {
                opportunity.Name += playerContact.Name;
                opportunity.Contact_Player__c = playerContact.Id;
            } else {
                res.statusCode = 400;
                // Auth error 
            } 
        } else { 
            res.statusCode = 400; // Wrong Id input
        }
        if(parsedReq.get('macthID')[0]!=''){
            Id matchId = '%' + (Id)parsedReq.get('matchId')[0] + '%';
            betEvent = [SELECT Id,Name FROM Product2 WHERE Id=:matchId LIMIT 1];
        } else { 
            res.statusCode = 400; // Product error
        }
        if (parsedReq.get('betUnitits').size()<=15) {
            for (String unitNameAndAmount : parsedReq.get('betUnits')) {
                List<String> parts = unitNameAndAmount.split(':,',2);
                String unitName = parts[0];
                Double unitAmount = Double.valueOf(parts[1]);
                Double unitCoefficient = 1.38;
                if(Cache.Org.get('local.BettingCoefficients.'+betEvent.Name+unitName)!=null){
                    unitCoefficient = Double.valueOf(Cache.Org.get('local.BettingCoefficients.'+betEvent.Name+unitName));
                }
                Bet_Unit__c betUnit = new Bet_Unit__c(Name=unitName, Bet_Amount__c=unitAmount,
                 Coefficient__c=unitCoefficient, Opportunity__c=opportunity.Id);
                betUnits.add(betUnit);
                //res.responseBody = Blob.valueOf(unitName);
            }
        } else { 
            res.statusCode = 400; // Wrong bets
        }
        

        //String jsonString = EncodingUtil.base64Encode(req.requestBody);
        //res.headers = req.headers;
        //res.statusCode = 200;
        //res.responseBody = req.requestBody;
    }
}