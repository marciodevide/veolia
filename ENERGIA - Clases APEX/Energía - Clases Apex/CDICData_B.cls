public with sharing class CDICData_B {
    public String name;
    public List<CDICData_FP> telephone;
    public A address;
    public Boolean isSmallBusiness;
    public Boolean isStandalone;

    public class A {
        public CDICData_Address_AL addressLocality;
        public CDICData_Address_AR addressRegion;
        public CDICData_Address_SA streetAddress;
        public String postalCode;
    }
}