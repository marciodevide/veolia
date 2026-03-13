public class ProductUtil {
    public static boolean EnableOppModify;
    //Método que comprueba si se quiere modificar el Responsable de Proyeto
    public static void checkOppModify(Map<id,Oportunidad_Producto__c> oldmap,List<Oportunidad_Producto__c> newprod){
        //Recorremos los productos
        for (Oportunidad_Producto__c prod : newprod) {
            if(oldmap!=null){
                //Obtenemos el id del oldmap
                Oportunidad_Producto__c oldprod = oldmap.get(prod.ID);
                System.debug('oldprod.OpProd_LKP_Responsable_de_Proyecto_NEW__c '+ oldprod.OpProd_LKP_Responsable_de_Proyecto_NEW__c);
                //Comprobamos si se ha modificado el Responsable de Proyecto
                if(prod.OpProd_LKP_Responsable_de_Proyecto_NEW__c != oldprod.OpProd_LKP_Responsable_de_Proyecto_NEW__c) {
                    EnableOppModify = true;
                    System.debug('He activado el oppmodify');
                }
            }
        }
    }
}