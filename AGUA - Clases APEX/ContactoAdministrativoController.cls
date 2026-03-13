public class ContactoAdministrativoController {
	public String oppId {get; set;}
	public String prodId {get; set;}
    
    //Está clase la llamamos desde Flow
    public ContactoAdministrativoController(){
        oppId = ApexPages.currentPage().getParameters().get('OpportunityId');
        prodId = ApexPages.currentPage().getParameters().get('newid');
    }
}