public class productBreakdownTriggerHelper {
    //
    // Procesos heredados de workflow rules y procesos
    //
	public void pBreakdownCreateWorkFlowRules(List<Oportunidad_Producto__c> newMap){      
        Set<Id> setIds = new Set<Id>();
        Map<Id,Oportunidad_Producto__c> newMapProduct = new Map<Id,Oportunidad_Producto__c>();
        for(Oportunidad_Producto__c oprod : newMap){
            setIds.add(oprod.id);
            newMapProduct.put(oprod.id,oprod);
        }
        //Productos desde SAP Labaqua Air Quality 
        //Cambiar esto para que se usa un campo checkbox en vez de nombres fijos.       
        List<Oportunidad_Producto__c> newProductList = [SELECT Id,Name,CreatedById,OP_MD_Oportunidad__r.OPO_LKP_Sociedad_Ofertante__r.EMP_BOL_Forzar_Nodo_Iberia__c,OpProd_LKP_SubAmbito__r.LKP_Producto_Aqualogy__r.Name,OpProd_SEL_Nodo_Dominio__c from Oportunidad_Producto__c where id in:setIds];
        for (Oportunidad_Producto__c pb :newProductList){
            if((String.valueOf(pb.CreatedById).contains('005w0000004dFzk') || String.valueOf(pb.CreatedById).contains('005w0000003hsY5')) 
               && (pb.OP_MD_Oportunidad__r.OPO_LKP_Sociedad_Ofertante__r.EMP_BOL_Forzar_Nodo_Iberia__c)){
                pb.OpProd_SEL_Nodo_Dominio__c='Iberia';
            }
        }
    }
    //
    //	Cuando se inserte un nuevo producto, comprobará si su opp tiene rellenado el producto lider, si no lo tiene, se le asignará el producto con mas valor como producto lider
    //	
    public void opportunityCheckProductLeader(List<Oportunidad_Producto__c> mapNewAccById){
        List<Id> listOppWithoutProduct = new List<Id>();
        set<Id> setOprodIds = new Set<Id>();
        for(Oportunidad_Producto__c oprod:mapNewAccById){
            setOprodIds.add(oprod.id);
        }
        List<Oportunidad_Producto__c> listOprod = [SELECT Id,OP_MD_Oportunidad__r.COM_LKP_Producto_Lider__c,OP_MD_Oportunidad__c FROM Oportunidad_Producto__c WHERE ID in:setOprodIds];
        for(Oportunidad_Producto__c oprod:listOprod){
            if(oprod.OP_MD_Oportunidad__r.COM_LKP_Producto_Lider__c==null){
                listOppWithoutProduct.add(oprod.id);
            }
        }
        if(!listOppWithoutProduct.isEmpty()){
            List<Id> idProductos = new List<Id>();
            List<AggregateResult> listProductos = [SELECT OP_MD_Oportunidad__c,MAX(OP_DIV_PrecioSinIVA__c),id from Oportunidad_Producto__c where id in:listOppWithoutProduct group by OP_MD_Oportunidad__c,id];
            for(AggregateResult ar : listProductos){
                idProductos.add(ar.id);
            }
            List<Oportunidad_Producto__c> ListProducts = [SELECT id,OP_MD_Oportunidad__c from Oportunidad_Producto__c where id in:idProductos];
            Map<Id,Id> mapOpportunidadProducto = new Map<Id,Id>();
            for(Oportunidad_Producto__c oprod :ListProducts){
                mapOpportunidadProducto.put(oprod.OP_MD_Oportunidad__c,oprod.id);
            }
            List<Opportunity> listOpp = [SELECT Id,COM_LKP_Producto_Lider__c from Opportunity where id in:mapOpportunidadProducto.keySet()];
            for(Opportunity opp:listOpp){
                opp.COM_LKP_Producto_Lider__c = mapOpportunidadProducto.get(opp.id);
            }
            if(!listOpp.isEmpty()){
                update listOpp;
            }
        }
    }
    
    //
    //	Cuando se elimine un producto, comprobará si su opp tiene rellenado el producto lider, si no lo tiene, se le asignará el producto con mas valor como producto lider
    //	
    public void prodbCheckProductLeaderAfterDelete(List<Oportunidad_Producto__c> mapNewAccById){
        List<Id> listOppWithoutProduct = new List<Id>();
        set<Id> setOpsIds = new Set<Id>();
        for(Oportunidad_Producto__c oprod:mapNewAccById){
            setOpsIds.add(oprod.OP_MD_Oportunidad__c);
        }
        List<Oportunidad_Producto__c> listOprod = [SELECT Id,OP_MD_Oportunidad__r.COM_LKP_Producto_Lider__c,OP_MD_Oportunidad__c FROM Oportunidad_Producto__c WHERE OP_MD_Oportunidad__c in:setOpsIds];
        for(Oportunidad_Producto__c oprod:listOprod){
            if(oprod.OP_MD_Oportunidad__r.COM_LKP_Producto_Lider__c==null){
                listOppWithoutProduct.add(oprod.id);
            }
        }
        if(!listOppWithoutProduct.isEmpty()){
            List<Id> idProductos = new List<Id>();
            List<AggregateResult> listProductos = [SELECT OP_MD_Oportunidad__c,MAX(OP_DIV_PrecioSinIVA__c),id from Oportunidad_Producto__c where id in:listOppWithoutProduct group by OP_MD_Oportunidad__c,id];
            for(AggregateResult ar : listProductos){
                idProductos.add(ar.id);
            }
            List<Oportunidad_Producto__c> ListProducts = [SELECT id,OP_MD_Oportunidad__c from Oportunidad_Producto__c where id in:idProductos];
            Map<Id,Id> mapOpportunidadProducto = new Map<Id,Id>();
            for(Oportunidad_Producto__c oprod :ListProducts){
                mapOpportunidadProducto.put(oprod.OP_MD_Oportunidad__c,oprod.id);
            }
            List<Opportunity> listOpp = [SELECT Id,COM_LKP_Producto_Lider__c from Opportunity where id in:mapOpportunidadProducto.keySet()];
            for(Opportunity opp:listOpp){
                opp.COM_LKP_Producto_Lider__c = mapOpportunidadProducto.get(opp.id);
            }
            if(!listOpp.isEmpty()){
                update listOpp;
            }
        }
    }
    
    //
    // BeforeUpdate
    //
    public void prodbComprobarResponsableElaboracionOferta(List<Oportunidad_Producto__c> newMap,List<Oportunidad_Producto__c> oldMap){
        for(Oportunidad_Producto__c prodb: newMap){
            if(prodb.OpProd_LKP_ResponsableElaboracionOferta__c!=oldMap.get(newMap.indexOf(prodb)).OpProd_LKP_ResponsableElaboracionOferta__c){
               	Listado_Elaborador_de_oferta__c elab = [SELECT Id,LEO_TXTEmail__c FROM Listado_Elaborador_de_oferta__c WHERE Id=:prodb.OpProd_LKP_ResponsableElaboracionOferta__c];
                prodb.Responsable_elaboracion_de_oferta__c = elab.LEO_TXTEmail__c;
            }
        }        
    }
}