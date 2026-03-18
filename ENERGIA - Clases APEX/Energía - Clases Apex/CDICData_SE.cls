public with sharing class CDICData_SE {
    public CDICData_Description exchangeName;
    public EC exchangeCountry;
    public String tickerName;
    public Boolean isPrimary;

    public class EC{
        public String isoAlpha2Code;
    }
}