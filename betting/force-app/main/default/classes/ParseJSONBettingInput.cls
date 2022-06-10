public without sharing class ParseJSONBettingInput {
	public String matchID {get;set;} 
	public String playerID {get;set;} 
	public BetUnits betUnits {get;set;} 

	public ParseJSONBettingInput(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'matchID') {
						matchID = parser.getText();
					} else if (text == 'playerID') {
						playerID = parser.getText();
					} else if (text == 'betUnits') {
						betUnits = new BetUnits(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'ParseJSONBettingInput consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class BetUnits { 
        public List<UnitInstance> parsedBetUnits = new List<UnitInstance>();
        public String errorMessege = ''; 
        Set<String> unitNamesParsed = new Set<String>();

		public BetUnits(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text != '' && !unitNamesParsed.contains(text)) {
						// 	unitInstance0 = new UnitInstance(parser);
						// } else if (text == 'unitInstance1') {
						// 	unitInstance1 = new UnitInstance(parser); 
                            unitNamesParsed.add(text);
                            UnitInstance unitInstance = new UnitInstance(parser);
                            parsedBetUnits.add(unitInstance);
                        } else {
							System.debug(LoggingLevel.WARN, 'BetUnits consuming unrecognized property: '+text);
                            errorMessege = 'Unavailable Bet Unit or 2 Units have the same name property: '+text;
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class UnitInstance {
		public String Name {get;set;} 
		public Double Coefficient {get;set;} 
		public Double Amount {get;set;} 

		public UnitInstance(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'Name') {
							Name = parser.getText();
						} else if (text == 'Coefficient') {
							Coefficient = Double.valueOf(parser.getText());
						} else if (text == 'Amount') {
							Amount = Double.valueOf(parser.getText());
						} else {
							System.debug(LoggingLevel.WARN, 'UnitInstance consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static ParseJSONBettingInput parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new ParseJSONBettingInput(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
}
