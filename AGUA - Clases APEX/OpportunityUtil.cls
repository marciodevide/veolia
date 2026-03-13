public class OpportunityUtil {
    
    public static Boolean recursivityCount = false;

    //Copia diferentes campos de Oportunidad en el Producto.
    public static void copyStageToProduct(Map<id,opportunity> oppMapNew,Map<id,opportunity> oppMapOld){
        try{
            for(Id oppId : oppMapNew.keySet()) {
                if(oppMapOld.get(oppId).stagename == oppMapNew.get(oppId).stagename &&
                oppMapOld.get(oppId).OPO_SEL_Canal_Entrada__c == oppMapNew.get(oppId).OPO_SEL_Canal_Entrada__c &&
                oppMapOld.get(oppId).OPO_PKL_Estado_de_ejecucion__c == oppMapNew.get(oppId).OPO_PKL_Estado_de_ejecucion__c &&
                oppMapOld.get(oppId).OPO_LKP_Contacto_Administrativo__c == oppMapNew.get(oppId).OPO_LKP_Contacto_Administrativo__c) {
                    return;
                }
            }
            
            //Recogemos los valores de la lista Productos de la Oportunidad para hacer la actualización, modificando campos que vienen de la Oportunidad.
            List<oportunidad_producto__C> productList = new List<oportunidad_producto__C>([SELECT id,OP_MD_Oportunidad__c,OpProd_PKL_Estado_de_ejecucion__c FROM oportunidad_producto__c WHERE OP_MD_Oportunidad__c IN :oppMapNew.keySet()]);
            for (oportunidad_producto__c product :productList){
                //product.OpProd_TXT_Contacto_Administrativo__c = oppMapNew.get(product.OP_MD_Oportunidad__c).OPO_LKP_Contacto_Administrativo__c;
                //product.OpProd_PKL_Stage__c = oppMapNew.get(product.OP_MD_Oportunidad__c).stagename;
                //product.OpProd_PKL_Canal_de_Entrada__c = oppMapNew.get(product.OP_MD_Oportunidad__c).OPO_SEL_Canal_Entrada__c;
                product.OpProd_PKL_Estado_de_ejecucion__c = oppMapNew.get(product.OP_MD_Oportunidad__c).OPO_PKL_Estado_de_ejecucion__c;
                product.OpProd_LKP_Contacto_Administrativo__c = oppMapNew.get(product.OP_MD_Oportunidad__c).OPO_LKP_Contacto_Administrativo__c;
            }
            System.debug('Voy a hacer update');
            update productList;             
        } catch(Exception e){
            System.debug('exception');
            return;
        }
    }
}