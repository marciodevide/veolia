public with sharing class CDICData_MA {
    public CDICData_Address_ACtr addressCountry;
    public CDICData_Address_ACnt addressCounty;
    public CDICData_Address_AL addressLocality;
    public CDICData_Address_AR addressRegion;
    public CDICData_Description language;
    public String minorTownName;
    public CDICData_MA_POB postOfficeBox;
    public String postalCode;
    public CDICData_Description postalCodePosition;
    public String postalRoute;
    public CDICData_Address_SA streetAddress;
    public String streetName;
    public String streetNumber;
    public CR continentalRegion;

    public class CDICData_MA_POB{
        public String postOfficeBoxNumber;
        public String typeDescription;
    }

    public class CR {
        public String name;
    }
}