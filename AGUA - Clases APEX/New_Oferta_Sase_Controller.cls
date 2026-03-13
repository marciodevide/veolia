public class New_Oferta_Sase_Controller {
    String name;
    id producto;
    id ofertaId;
    public New_Oferta_Sase_Controller(){
    }

    //Metodo que llama al metodo que crea un registro de Oferta SASE, redirecciona a dicho registro.
    public void callCreateOferta(){
        name = ApexPages.currentPage().getParameters().get('nombre');
        producto = ApexPages.currentPage().getParameters().get('productoId');
        ofertaId = createOferta(name,producto);
        System.debug(ofertaId);
        redirect();
    }
    
    //Metodo que crea Oferta SASE, rellena el nombre añadiendole el contador de ofertas sase 
    //para ese producto y devuelve el id de dicho registro.
    public  id createOferta(string name, id producto){
        Oferta_SASE__c oferta = new Oferta_SASE__c();
        oferta.OSASE_LKP_Producto__c = producto;
        System.debug('test ' +producto);
        oferta.Name = name;
        AggregateResult[] groupedResults = [SELECT COUNT(id)contador FROM Oferta_SASE__c WHERE OSASE_LKP_Producto__c =:producto GROUP BY OSASE_LKP_Producto__c];
        if (groupedResults.size() > 0)  oferta.Name = oferta.Name+'_'+groupedResults[0].get('contador');
        else oferta.Name = oferta.Name+'_0';
        
		insert oferta;
		return oferta.id;
    }

    //Metodo encargado de la redireccion
    public PageReference redirect(){
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Record Created Successfully.Thank you!'));
        PageReference pageRef = new PageReference('/'+ofertaId);
        pageRef.setRedirect(true);
        return pageRef;
    }
}