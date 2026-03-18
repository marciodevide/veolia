public with sharing class CDICData_SSE {
    public CDICData_Description exchangeName;
    public List<SN> sectionNames;
    public String tickerName;
    public String listingDate;

    public class SN{
        public L language;
        public String name;
    }

    public class L{
        public String description;
        public Integer dnbCode;
    }
}