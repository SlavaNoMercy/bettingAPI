@RestResource(urlMapping='/bettingAPI/new/opportunity') //имеющий смысл урл
global without sharing class BettingAPI {
  @HttpPost
  global static void createOpportunity() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    //res.statusCode = 200;//не нужен, только в конце
    //Объявления по месту использования ✓
    try {
      ParseJSONBettingInput bettingInput = ParseJSONBettingInput.parseJsonString(
        (req.requestBody).toString()
      ); // заменить на стандартный парсинг либо стрикт парсинг ✓
      Opportunity opportunity = new Opportunity();
      if (
        (bettingInput.playerID.length() == 18 ||
        bettingInput.playerID.length() == 15) &&
        (bettingInput.matchID.length() == 18 ||
        bettingInput.matchID.length() == 15)
      ) {
        opportunity = setBetPlayer(res, opportunity, bettingInput.playerID);
        opportunity = setBetEvent(res, opportunity, bettingInput.matchID);
      } else {
        setErrorToResponse(
          res,
          'Wrong Identifier of Player or Event (internal ID  must be 15 or 18 symbols lenth)!'
        ); //custom label
        return;
      }
      List<Bet_unit__c> betUnitsOnEvent = new List<Bet_Unit__c>();
      Set<String> existingBetUnitNames = new Set<String>();
      try {
        opportunity = BettingQueryManager.getExistingOpportunity(
          (Id) bettingInput.playerID
        );
        betUnitsOnEvent = BettingQueryManager.getExistingUnits(opportunity.Id);
        for (Bet_Unit__c existingBetUnit : betUnitsOnEvent) {
          existingBetUnitNames.add(existingBetUnit.Name);
        }
      } catch (Exception e) {
      } //opp doesn't exist yet
      Double currentBetAmount = 0;
      for (ParseJSONBettingInput.BetUnit newUnit : bettingInput.betUnits) {
        Bet_Unit__c betUnit = new Bet_Unit__c();
        if (existingBetUnitNames.contains(newUnit.Name)) {
          setErrorToResponse(res, 'Cannot create 2 same bet Units!'); //custom label
          return;
        }
        betUnit.Name = newUnit.Name;
        if (opportunity.Players_Fund_Before_Bet__c < currentBetAmount) {
          setErrorToResponse(res, 'Not enought money to make a bet!'); //custom label
          return;
        }
        betUnit.Bet_Amount__c = newUnit.Amount;
        betUnit.Coefficient__c = newUnit.Coefficient;
        //betUnit.Opportunity__c = opportunity.Id;
        betUnit.Bet_Event__c = BettingQueryManager.getBetEvent(
            (Id) bettingInput.matchID
          )
          .Id;
        if (betUnitsOnEvent.size() > 15) {
          setErrorToResponse(res, 'Too much bet units on the event (max 15).'); //custom label
          return;
        }
        betUnitsOnEvent.add(betUnit);
      }
      upsert opportunity;
      for (Bet_Unit__c betUnit : betUnitsOnEvent) {
        betUnit.Opportunity__c = opportunity.Id;
      }
      upsert betUnitsOnEvent;
      setDataToResponse(res, opportunity, betUnitsOnEvent);
      return;
    } catch (Exception e) {
      setErrorToResponse(res, e.getStackTraceString());
      return;
    }
  }

  public static void setErrorToResponse(RestResponse res, String message) {
    if (res.responseBody != null) {
      return;
    }
    res.statusCode = 400;

    JSONGenerator generator = JSON.createGenerator(true);
    generator.writeStartObject();
    generator.writeStringField('error', message);
    generator.writeEndObject();

    res.responseBody = Blob.valueOf(generator.getAsString());
  }
  public static void setDataToResponse(
    RestResponse res,
    Opportunity opportunity,
    List<Bet_Unit__c> betUnits
  ) {
    if(res.statusCode==400){
      return;
    }
    res.statusCode = 200;
    JSONGenerator generator = JSON.createGenerator(true);

    generator.writeStartObject();
    generator.writeObject(opportunity);
    generator.writeFieldName('betUnits');
    generator.writeStartArray();
    for (Bet_Unit__c unit : betUnits) {
      generator.writeStartObject();
      generator.writeStringField('unitName', unit.Name);
      generator.writeNumberField('unitAmount', unit.Bet_Amount__c);
      generator.writeEndObject();
    }
    generator.writeEndArray();
    generator.writeDateTimeField('dateTime', Datetime.now());
    generator.writeEndObject();
    res.responseBody = Blob.valueOf(generator.getAsString());
  }

  public static Opportunity setBetPlayer(
    RestResponse res,
    Opportunity opportunity,
    String stringPlayerID
  ) {
    Id playerId = (Id) stringPlayerID;
    Lead playerLead = BettingQueryManager.getLeadPlayer(playerId);
    // условие и только иначе вторая кверя ✓
    if (playerLead == null) {
      Contact playerContact = BettingQueryManager.getContactPlayer(playerId);
      opportunity.Contact_Player__c = playerContact.Id;
      opportunity.Name = playerContact.Name;
      opportunity.Players_Fund_Before_Bet__c = playerContact.Players_Fund__c;
    }
    opportunity.Lead_Player__c = playerLead.Id;
    opportunity.Name = playerLead.LastName;
    opportunity.Players_Fund_Before_Bet__c = playerLead.Players_Fund__c;
    if (
      opportunity.Lead_Player__c == null &&
      opportunity.Contact_Player__c == null
    ) {
      setErrorToResponse(res, 'Authorization failure!');
    }
    return opportunity;
  }
  public static Opportunity setBetEvent(
    RestResponse res,
    Opportunity opportunity,
    String stringEventId
  ) {
    Id matchId = (Id) stringEventId;
    Product2 betEvent = BettingQueryManager.getBetEvent(matchId);
    if (betEvent != null) {
      opportunity.Name += ' ' + betEvent.Name;

      if (Date.today() <= betEvent.Event_Date__c) {
        opportunity.Bet_Time__c = Datetime.now();
        opportunity.CloseDate = betEvent.Event_Date__c;
        opportunity.StageName = BettingAPIConstants.DEFAULT_OPPORTUNITY_STAGE_NAME; //константа ✓
      } else {
        setErrorToResponse(res, 'The chosen Event has already happened!');
      }
    } else {
      setErrorToResponse(res, 'Event not available.');
    }
    return opportunity;
  }
}
