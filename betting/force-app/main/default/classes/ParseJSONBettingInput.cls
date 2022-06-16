public class ParseJSONBettingInput {
  public String matchID;
  public String playerID;
  public List<BetUnit> betUnits;

  public class BetUnit {
    public String Name;
    public String Coefficient;
    public String Amount;
  }

  public static ParseJSONBettingInput parseJsonString(String json) {
    return (ParseJSONBettingInput) System.JSON.deserializeStrict(
      json,
      ParseJSONBettingInput.class
    );
  }
}
