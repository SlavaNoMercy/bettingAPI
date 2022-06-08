@RestResource(urlMapping='/bettingAPI/v1.1')
global without sharing class BettingAPI {
    @HttpPost
    global static void createOpportunity() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        Map<String,List<String>> parsedReq = (Map<String,List<String>>)JSON.deserializeUntyped(req.requestBody.toString());
        if(parsedReq.get('dateTime')[0]!=''){
            Datetime betTIME = DateTime.parse(parsedReq.get('dateTime')[0]);
        } else { res.statusCode = 400; }
        if(parsedReq.get('playerID')[0]!=''){
            Id playerId = (Id)parsedReq.get('playerId')[0];

        } else { res.statusCode = 400; }
        if (parsedReq.get('betUnitits').size()<=15) {
            for (String unitNameAndAmount : parsedReq.get('betUnits')) {
                List<String> parts = unitNameAndAmount.split(':,',2);
                String unitName = parts[0];
                Double unitAmount = Double.valueOf(parts[1]);
                res.responseBody = Blob.valueOf(unitName);
            }
        }
        //String jsonString = EncodingUtil.base64Encode(req.requestBody);
        //res.headers = req.headers;
        //res.statusCode = 200;
        //res.responseBody = req.requestBody;
    }
}