public with sharing class CDICData {
    public String duns;
    public String primaryName;
    public String startData;
    public CDICData_Description businessEntityType;
    public String ControlOwnershipDate;
    public CDICData_CL corporateLinkage;
    public CDICData_DCS dunsControlStatus;
    public List<CDICData_FP> fax;
    public List<CDICData_Fi> financials;
    public List<CDICData_IC> industryCodes;
    public CDICData_MA mailingAddress;
    public List<CDICData_P> mostSeniorsPrincipals;
    public List<CDICData_P> currentPrincipals;
    public List<CDICData_NOE> numberOfEmployees;
    public CDICData_PA primaryAddress;
    public List<CDICData_RN> registrationNumbers;
    public List<CDICData_FP> telephone;
    public List<CDICData_W> websiteAddress;
    public List<CDICData_SE> stockExchanges;
    public List<CDICData_SSE> standardStockExchanges;
    public String countryISOAlpha2Code;
    public String defaultCurrency;
    public String datec;
    public String blocks;
    public String monitoring;
    public Boolean isAgent;
    public Boolean isExporter;
    public Boolean isImporter;
    public Boolean isSmallBusiness;
    public Boolean isStandalone;
    public String certifiedEmail;
    public String incorporatedDate;
    public String employerDesignation;
    public String securitiesReportID;
    public CDICData_COT controlOwnershipType;
    public List<CDICData_E> email;
    public CDICData_LF legalForm;
    public CDICData_RD registeredDetails;
    public List<CDICData_B> banks;
    public CDICData_GU globalUltimate;
    public CDICData_GU domesticUltimate;
    public CDICData_BTI businessTrustIndex;
    
    public static CDICData parser(String json){
        return (CDICData) System.JSON.deserialize(json, CDICData.class);
    }
}