public with sharing class CDICSearchResults { 

    public Integer candidatesReturnedQuantity;
    public Integer candidatesMatchedQuantity;
    public List<CDICSearchResults_SearchCandidates> searchCandidates;

    public class CDICSearchResults_SearchCandidates{
        public Integer displaySequence;
        public CDICSearchResults_Org organization;
        public String accID;
        public String leadID;
        public Boolean disableAcc;
        public Boolean disableLea;
    }


    public static CDICSearchResults parser(String json){
        return (CDICSearchResults) System.JSON.deserialize(json, CDICSearchResults.class);
    }    
    }