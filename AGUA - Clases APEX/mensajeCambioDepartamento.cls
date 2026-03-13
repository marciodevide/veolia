public class mensajeCambioDepartamento{ 

    public final Oportunidad_Producto__c oppProduct;

    public mensajeCambioDepartamento(ApexPages.StandardController controller) {
        this.oppProduct = [SELECT id, Departamento__c,OP_MD_Oportunidad__c,OP_BOL_product_leader_modified__c FROM Oportunidad_Producto__c WHERE id =: ApexPages.currentPage().getParameters().get('id')];
        Opportunity opp = [SELECT id, COM_LKP_Producto_Lider__c FROM Opportunity WHERE id =: this.oppProduct.OP_MD_Oportunidad__c];
        if (opp.COM_LKP_Producto_Lider__c != null && opp.COM_LKP_Producto_Lider__c == oppProduct.id){ 
            if(oppProduct.OP_BOL_product_leader_modified__c == true){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'El cambio de departamento realizado lleva asociado un cambio en los aprobadores de la oportunidad.');
                ApexPages.addMessage(myMsg);
            }else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'');
                ApexPages.addMessage(myMsg);    
            }           
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'');
            ApexPages.addMessage(myMsg);
        }
    }

    public static void mensajeError(List<Oportunidad_Producto__c> newObjList, List<Oportunidad_Producto__c> oldObjList){
        Oportunidad_Producto__c newOppProduct = newObjList.get(0);
        Oportunidad_Producto__c oldOppProduct = oldObjList.get(0);
        Opportunity opp = [SELECT id, RecordType.Name, StageName, OPO_SEL_Canal_Entrada__c, OPO_LKP_Contacto_Administrativo__c, COM_LKP_Producto_Lider__c FROM Opportunity WHERE id =: newOppProduct.OP_MD_Oportunidad__c];
        Departamento__c depart = [SELECT id, DP_CHK_Sase__c,DP_TXT_Dom_Sel__c,DP_MPKL_Dominios__c FROM Departamento__c WHERE id =: newOppProduct.Departamento__c];
        //regla validacion de contacto adminstrativo necesario
        if(depart.DP_CHK_Sase__c == true && opp.RecordType.Name == 'España' && opp.OPO_LKP_Contacto_Administrativo__c == null && (opp.OPO_SEL_Canal_Entrada__c == 'Licitación pública'|| opp.OPO_SEL_Canal_Entrada__c == 'Licitación privada'  || opp.OPO_SEL_Canal_Entrada__c == 'Concesión')){
            newOppProduct.addError('Si el departamneto es SASE y el tipo de oportunidad es licitación/concesion, el contacto administrativo debe de estar informado. Accede a la oportunidad para informarlo antes de realizar el cambio.');
        }
        //regla de validación para verificar que el dominio seleccionado y el dominio del departamento coinciden
        String productDomTXT = newOppProduct.OpProd_SEL_Nodo_Dominio__c;
        String departDomTXT = depart.DP_MPKL_Dominios__c;
        if(productDomTXT != null && departDomTXT != null){
            if(!departDomTXT.contains(productDomTXT)){    
                newOppProduct.addError('El dominio seleccionado debe de coincidir con el dominio asignado al departamento seleccionado.');        
            }    
        }
        //Si no se ha produccido ningún error, actualizamos el campo booleano para saber si el producto es lider o no;
        if(opp.COM_LKP_Producto_Lider__c != null && opp.COM_LKP_Producto_Lider__c == newOppProduct.id){
            if(newOppProduct.Departamento__c != oldOppProduct.Departamento__c){
                newOppProduct.OP_BOL_product_leader_modified__c = true;
            }
        }
    }    
}