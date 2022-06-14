public without sharing class ParseJSONBettingInput {
	//Убрать нафиг
	public String matchID {get;set;} 
	public String playerID {get;set;} 
	public BetUnits betUnits {get;set;}
	//public String errorMessage = ''; 

	//public ParseJSONBettingInput(String parser) {
		//ParseJSONBettingInput i = JSON.deserializeStrict(jsonString, ParseJSONBettingInput.class);

		// try{
		// 	while (parser.nextToken() != System.JSONToken.END_OBJECT) {
		// 		if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
		// 			String text = parser.getText();
		// 			if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
		// 				if (text == 'matchID') {
		// 					matchID = parser.getText();
		// 				} else if (text == 'playerID') {
		// 					playerID = parser.getText();
		// 				} else if (text == 'betUnits') {
		// 					betUnits = new BetUnits(parser);
		// 				} else {
		// 					System.debug(LoggingLevel.WARN, 'ParseJSONBettingInput consuming unrecognized property: '+text);
		// 					errorMessage = 'Parser consuming unrecognized property: '+text;
		// 					consumeObject(parser);
		// 				}
		// 			}
		// 		}
		// 	}
		// } catch(System.JSONException e){
		// 	errorMessage = e.getMessage();
		// }
	//}
	
	public class BetUnits { 
        public List<UnitInstance> parsedBetUnits = new List<UnitInstance>();
        //public String errorMessage = ''; 
        Set<String> unitNamesParsed = new Set<String>();

		// public BetUnits(JSONParser parser) {
		// 	try{
		// 		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
		// 			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
		// 				String text = parser.getText();
		// 				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
		// 					if (text != '' && !unitNamesParsed.contains(text)) {
		// 						unitNamesParsed.add(text);
		// 						UnitInstance unitInstance = new UnitInstance(parser);
		// 						parsedBetUnits.add(unitInstance);
		// 					} else {
		// 						System.debug(LoggingLevel.WARN, 'BetUnits consuming unrecognized property: '+text);
		// 						errorMessage = 'Unavailable Bet Unit or 2 Units have the same name property: '+text;
		// 						consumeObject(parser);
		// 					}
		// 				}
		// 			}
		// 		}
		// 	} 
		// 	catch(System.JSONException e){ throw e;}
		// }
	}
	
	public class UnitInstance {
		public String Name {get;set;} 
		public Double Coefficient {get;set;} 
		public Double Amount {get;set;} 
		//public String errorMessage = '';

		// public UnitInstance(JSONParser parser) {
		// 	try{
		// 		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
		// 			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
		// 				String text = parser.getText();
		// 				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
		// 					if (text == 'Name') {
		// 						Name = parser.getText();
		// 					} else if (text == 'Coefficient') {
		// 						Coefficient = Double.valueOf(parser.getText());
		// 					} else if (text == 'Amount') {
		// 						Amount = Double.valueOf(parser.getText());
		// 					} else {
		// 						System.debug(LoggingLevel.WARN, 'UnitInstance consuming unrecognized property: '+text);
		// 						errorMessage = 'UnitInstance consuming unrecognized property: '+text;
		// 						consumeObject(parser);
		// 					}
		// 				}
		// 			}
		// 		}
		// 	}
		// 	catch(System.JSONException e){
		// 		throw e;
		// 	}
		// }
	}
	
	
	public static ParseJSONBettingInput parse(String jsonString) {
		// System.JSONParser parser = System.JSON.createParser(json);
		// return new ParseJSONBettingInput(parser);
		return JSONParser.deserializeStrict(jsonString, ParseJSONBettingInput.class); 
	}
	
	// public static void consumeObject(System.JSONParser parser) {
	// 	Integer depth = 0;
	// 	do {
	// 		System.JSONToken curr = parser.getCurrentToken();
	// 		if (curr == System.JSONToken.START_OBJECT || 
	// 			curr == System.JSONToken.START_ARRAY) {
	// 			depth++;
	// 		} else if (curr == System.JSONToken.END_OBJECT ||
	// 			curr == System.JSONToken.END_ARRAY) {
	// 			depth--;
	// 		}
	// 	} while (depth > 0 && parser.nextToken() != null);
	// }
}
