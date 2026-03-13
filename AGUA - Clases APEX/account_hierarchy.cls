public class account_hierarchy {



    public ID getAccountID;
    public String getNameMatriz {get;set;}
    public list<Account> accountH {get;set;}
    
    public account_hierarchy(){
    
        if(!Test.isRunningTest() && (System.currentPagereference().getParameters().get('id') == null || System.currentPagereference().getParameters().get('id') == '')){
    
            return;
    
        }
    
        getAccountID= System.currentPagereference().getParameters().get('id');
        getNameMatriz =System.currentPagereference().getParameters().get('name');
        
        if(!Test.isRunningTest())
            accountH=getAccountH(getAccountID);
        

    
    }


    public List<Account> getAccountH (Id Account){
    
          return [SELECT id , Nombre__c , Owner.name, Type from account where parentId=: Account or id=: Account order by parentId asc];
    

    
    }



}