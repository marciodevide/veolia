public with sharing class PDFOpportunityClassExtension {
    private final Opportunity Opp;

    public  PDFOpportunityClassExtension(ApexPages.StandardController controller){
        this.Opp = (Opportunity)controller.getRecord();
    }
    
    public Map<Integer, Oportunidad_Producto__c> getProductoCircuito(){
        Map <Integer, Oportunidad_Producto__c> producto = new Map<Integer, Oportunidad_Producto__c>();
        List <Oportunidad_Producto__c> listaProductos = new List <Oportunidad_Producto__c>();    
    
        listaProductos = [SELECT Id, Name, OP_SEL_LineaServicio__c, OpProd_PKL_Ambito__c, OP_SEL_Producto__c, OpProd_PKL_Tecnologia__c, Departamento__r.Name
                        FROM Oportunidad_Producto__c WHERE Id IN (SELECT COM_LKP_Producto_Lider__c FROM Opportunity) AND OP_MD_Oportunidad__c =: opp.Id];
    
        for(integer x = 0; x <listaProductos.size(); x++) producto.put(x+1, listaProductos.get(x));
    
        return producto;
    }
    public List<ProcessInstance> getAprobadorCircuito(){
        List<ProcessInstance> apro = new List<ProcessInstance>([SELECT Id, (SELECT Id, StepStatus,Actor.Name,OriginalActor.Name FROM StepsAndWorkitems) FROM ProcessInstance WHERE TargetObjectId =: opp.Id]);
           
        //aprobador.put('pr.StepsAndWorkitems', app);
        List<Map<String,String>> app = new List<Map<String,String>>();
        for (ProcessInstance pr : apro) {
            for(ProcessInstanceHistory  str : pr.StepsAndWorkitems) {
                //app.put(str.Id,str.OriginalActor.Name+'  --||--  '+ str.Actor.Name+'  --||--  '+ str.StepStatus);
                app.add(new Map<String,String>{'Id' => str.Id,'ActualName'=> str.Actor.Name,'Asigned'=>str.OriginalActor.Name, 'Status' => str.StepStatus});
            }
        }

        return apro;
    }
}