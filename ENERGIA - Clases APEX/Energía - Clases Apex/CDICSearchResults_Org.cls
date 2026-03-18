public with sharing class CDICSearchResults_Org {
    public String duns;
    public DCS dunsControlStatus;
    public String primaryName;
    public PA primaryAddress;
    public A registeredAddress;
    public List<PIC> primaryIndustryCodes;
    public CL corporateLinkage;
    public List<Fi> financials;
    public List<CDICData_RN> registrationNumbers;
    public List<NOE> numberOfEmployees;
    public List<CDICData_IC> industryCodes;
    public List<CDICData_FP> telephone;
    public CDICData_Description businessEntityType;
    public String domain;
    public Boolean isPublictradedCompany;
    public Boolean isStandalone;
    public Boolean isFortune1000Listed;

    public class DCS {
        public Boolean isOutOfBusiness;
        public Boolean isMarketable;
        public Boolean isTelephoneDisconnected;
        public Boolean isMailUndeliverable;
        public Boolean isDelisted;
    }

    public class A {
        public CDICData_Address_ACtr addressCountry;
        public CDICData_Address_AL addressLocality;
        public CDICData_Address_ACnt addressCounty;
        public String postalCode;
        public String streetName;
        public String streetNumber;
    }

    public class PA {
        public CDICData_Address_ACtr addressCountry;
        public CDICData_Address_AL addressLocality;
        public CDICData_Address_ACnt addressCounty;
        public String postalCode;
        public String streetName;
        public String streetNumber;
        public CDICData_Address_SA streetAddress;
        public String latitude;
        public String longitude;
    }

    public class PIC {
        public String usSicV4;
        public String usSicV4Description;
    }

    public class CL {
        public CDICData_CL_C globalUltimate;
        public CDICData_CL_C parent;
        public List<CDICData_Description> familytreeRolesPlayed;
        public Integer globalUltimateFamilyTreeMembersCount;
        public Integer hierarchyLevel;
        public Boolean isBranch;
    }
    public class Fi {
        public List<Fi_YR> yearlyRevenue;
    }

    public class Fi_YR {
        public Double value;
        public String curr;
    }

    public class NOE {
        public String informationScopeDescription;
        public String reliabilityDescription;
        public Integer value;
        public List<CDICData_Trend> trend;        
        public Integer informationScopeDnBCode;
        public Integer reliabilityDnBCode;
    }

}