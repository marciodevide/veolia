public class LSU_editaLineasUsuario{

    private static boolean alreadyCreatedTasks = false;

    public LSU_editaLineasUsuario(){}

    //El método recibe una lista de lineas de servicio de usuario (objeto junction pero lookups de lineas de servicio y usuario)
    public static void editaUsuario(List<AQUA_Linea_de_Servicio_de_Usuario__c> lineasUsuarios){    

        //Obtenermos un set con los Ids de los usuarios relacionados con las lineas de servicio de usuario que entran en el método por parámetro
        Set<Id> IdUsers = new Set<Id>();
        for(AQUA_Linea_de_Servicio_de_Usuario__c lin: lineasUsuarios) IdUsers.add(lin.LSU_LKP_Usuario__c);

        //Creamos un mapa de pares {Id usuario, List de líneas de servicio de usuario}
        Map<Id,List<AQUA_Linea_de_Servicio_de_Usuario__c>> mapLineasActuales = new Map<Id,List<AQUA_Linea_de_Servicio_de_Usuario__c>>();
        for(AQUA_Linea_de_Servicio_de_Usuario__c lsu: [SELECT LSU_LKP_Linea_de_Servicio__c,LSU_LKP_Usuario__c,LSU_LKP_Linea_de_Servicio__r.name FROM AQUA_Linea_de_Servicio_de_Usuario__c WHERE LSU_LKP_Usuario__c IN: IdUsers]){
            if(mapLineasActuales.containsKey(lsu.LSU_LKP_Usuario__c)) mapLineasActuales.get(lsu.LSU_LKP_Usuario__c).add(lsu);
            else mapLineasActuales.put(lsu.LSU_LKP_Usuario__c,new List<AQUA_Linea_de_Servicio_de_Usuario__c> {lsu});
        }
        
        //Creamos un mapa de pares {Id usuario, usuario}
        Map<Id,User> mapUser = new Map<Id,User>();
        for(user u: [SELECT Id,USER_TXT_Lineas_de_Servicio__c FROM User WHERE Id IN: IdUsers]) mapUser.put(u.Id,u);
        
        Set<User> setUsuarios = new Set<User>();
        //Creamos un string "lineas" para guardar concatenadas y separadas por ', ' el nombre de las linea de servicio del usuario
        String lineas;
        //Recorremos la lista de líneas de usuario que entran por parámetro
        for(AQUA_Linea_de_Servicio_de_Usuario__c a: lineasUsuarios){
            System.debug('Recorro LSU pendientes: '+ lineasUsuarios);
            lineas = '';
            if(mapLineasActuales.containsKey(a.LSU_LKP_Usuario__c)){
                for(AQUA_Linea_de_Servicio_de_Usuario__c b: mapLineasActuales.get(a.LSU_LKP_Usuario__c)){
                   lineas = lineas + b.LSU_LKP_Linea_de_Servicio__r.name + ',';
                   System.debug('Incluyo linea en string: '+ lineas);
                }
            }
            //Actualizamos el campo User.USER_TXT_Lineas_de_Servicio__c con el string que hemos rellenado
            mapUser.get(a.LSU_LKP_Usuario__c).USER_TXT_Lineas_de_Servicio__c = lineas;
            //Guardamos el Usuario actualiado en un set para más adelante ser actualizado
            setUsuarios.add(mapUser.get(a.LSU_LKP_Usuario__c));
        }
        List<User> usuarios = new List<User>();
        usuarios.addAll(setUsuarios);

        update usuarios;
    }
}