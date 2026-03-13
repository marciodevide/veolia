public class DeleteOpportunitySap implements Triggers.Handler{
    //Provisional class to patch the requirement to receive only sap opportunities that begin with sap 240 code 
    
    //Variable Declarations
    static List<opportunity> listToDelete = new List<opportunity>();
    static List<opportunity> listTriggerNew = new List<opportunity>((List<Opportunity>)Trigger.new);
    static List<opportunity> listTriggerOld = new List<opportunity>((List<Opportunity>)Trigger.old);

       
    // --Main method --
    public static void handle(){
        if (UserInfo.getUserId() == label.ADMIN_USER_SAP_ID){
                oppToDelete();
            }
        }

    //Method for get the list of opportunitys to delete
    
    public static void oppToDelete(){
        List<opportunity> listToDelete = new List<opportunity>();
        for (Opportunity opp:listTriggerNew){
            if ( (opp.OPO_TXT_Identificador_Oportunidad_SAP__c.substring(0,5) == '00240' || opp.OPO_TXT_Identificador_Oportunidad_SAP__c.substring(0,3) == '240' )){//Criteria for delete
                continue;
            }
            else{
                opp.addError('No se ha realizado la actualizacion. Solo las oportunidades que comienzan por 240 pueden ser modificadas por SAP.');
            }
        }
    }
}