public with sharing class CDICData_Fi {
    public String accountantName;
    public String financialStatementDuration;
    public String financialStatementToDate;
    public String informationScopeDescription;
    public String reliabilityDescription;
    public String unitCode;
    public List<CDICData_Fi_YR> yearlyRevenue;

    public class CDICData_Fi_YR {
        public Double value;
        public String curr;
        public List<CDICData_Trend> trend;
    }
}