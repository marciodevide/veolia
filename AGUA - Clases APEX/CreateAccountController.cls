public class CreateAccountController {
    
	public static Map<Id, String> recordtypemap {get;set;}
    
    @AuraEnabled        
    public static List<String> fetchRecordTypeValues(){
        List<Schema.RecordTypeInfo> recordtypes = Account.SObjectType.getDescribe().getRecordTypeInfos();    
        recordtypemap = new Map<Id, String>();
        for(RecordTypeInfo rt : recordtypes){
            if(rt.getName() != 'Master' && rt.getName() != 'Principal') recordtypemap.put(rt.getRecordTypeId(), rt.getName());
        }
        
        return recordtypemap.values();
    }
    
    @AuraEnabled
    public static Account getRecTypeId(String recordTypeLabel, String record){

        //Obtenemos los campos a mapear
        Map<String, String> mapAccountRQFieldAccountField = new Map<String, String>();

        for(CreateAccountFromRequest__mdt mdtObj : [SELECT Account_Field__c,Account_Request_Field__c FROM CreateAccountFromRequest__mdt]){
            mapAccountRQFieldAccountField.put(mdtObj.Account_Field__c, mdtObj.Account_Request_Field__c);
        }
        
        //Construimos los campos a buscar
        String selectField = '';
        for(String accountRQField : mapAccountRQFieldAccountField.values()){
            selectField = selectField + accountRQField +', ';
        }
        //Obtenemos los field del contacto
        AQUA_PeticionAltaCompania__c accountRecord = Database.query('SELECT '+selectField+'Id FROM AQUA_PeticionAltaCompania__c WHERE id =  :record');
        
		Map<String,String> mapAccountRQFieldAccountRQValue =  new Map<String,String>();
        
        for(String accountRQField: mapAccountRQFieldAccountField.values()){
            mapAccountRQFieldAccountRQValue.put(accountRQField,String.valueOf(accountRecord.get(accountRQField)));
        }
        
        //Obtenemos el recordID
        Id recid = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();
        
        //Mapeamos los valores del contacto en Account
		Account accToCreate= new Account();
        accToCreate.RecordTypeId = recid;
        
        String fieldType;
        String valueToSet='';
        for(String accountField : mapAccountRQFieldAccountField.keySet()){
            valueToSet = mapAccountRQFieldAccountRQValue.get(mapAccountRQFieldAccountField.get(accountField));
            fieldType = getFieldType(accountField);
            
            switch on fieldType {
                when 'INTEGER','DOUBLE','PERCENT','CURRENCY' {
                    if (!String.isBlank(valueToSet)){
                        Double accountFieldValue = Double.valueOf(valueToSet);	
                        // account field nombre api del campo -
                        accToCreate.put(accountField,accountFieldValue);
                    }
                }	
                when 'STRING','PICKLIST','TEXTAREA' {
                    accToCreate.put(accountField,valueToSet);
                }  
                when else {// Sino por defecto como String
                    accToCreate.put(accountField,valueToSet);
                }
            }            
        }
        // si el recordtype es hija que machaque el kam del padre
        if(accToCreate.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Compañia Matriz').getRecordTypeId()){
            accToCreate.COM_LKP_Director_de_Cuenta_KAM__c=accountRecord.PET_LKP_ACCOUNT_KAM__c;
        }
        if(accToCreate.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Compañia Hija').getRecordTypeId()){
            accToCreate.COM_LKP_Gerente_de_Cuenta__c=accountRecord.PET_LKP_Gerente_Cuenta__c;
        }

        return accToCreate;
    }
    
   	private static String getFieldType(String fieldAPIName){
        String type = '';

        Schema.SObjectField field = Schema.SObjectType.Account.fields.getMap().get(fieldAPIName);
        Schema.DisplayType fldType = field.getDescribe().getType();
        type=String.valueOf(fldType);

        return type;
  	}
}