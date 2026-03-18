public with sharing class CDICData_P {
    public String familyName;
    public String middleName;
    public String fullName;
    public String givenName;
    public CDICData_P_G gender;
    public String namePrefix;
    public String nameSuffix;
    public List<CDICData_P_JT> jobTitles;
    public List<CDICData_P_MR> managementResponsabilities;
    public List<OLN> otherLanguageNames;
    public List<IdN> idNumbers;
    public String associationStartDate;

    public class CDICData_P_JT{
        public String title;
    }

    public class CDICData_P_MR{
        public String description;
        public String mrcCode;
    }

    public class CDICData_P_G{
        public String description;
        public Integer dnbCode;
    }

    public class OLN {
        public CDICData_P_G language;
        public CDICData_P_G writingScript;
        public String familyName;
        public String fullName;
        public String givenName;
    }

    public class IdN {
        public CDICData_P_G idType;
        public String idNumber;
    }
}