public class UserGroupController {
    
    public List<Wrapp> wrapp {get;set;}
    public List<WrappOpp> wrappopp{get;set;}
    public List<WrappContact> wrappcontact{get;set;}
    public List<WrappAllOpp> wrappAllopp{get;set;}
    public List<WrappLogin> wrapplogin {get;set;}
    public List<WrappTask> wrapptask{get;set;}
    public List<WrappAllTask> wrappalltask{get;set;}
    public List<WrappEvent> wrappevent{get;set;}
    public List<WrappAllEvent> wrappallevent{get;set;}
    public List<WrappAllContact> wrappallcontact{get;set;}
    public List<WrappAllGanadas> wrappallganadas{get;set;}
    public List<WrappAllPerdidas> wrappallperdidas{get;set;}
    public String selectedOption{get;set;}
    public String nameopp{get;set;}
    public date startDate {get;set;}
    public date endDate {get;set;}
    DateTime endDateTime;
    public boolean showOpp{get;set;}
    public boolean showCont{get;set;}
    public boolean showEvent{get;set;}
    public boolean showTask{get;set;}
    //Realizamos map para obtener los valores que queremos
    public Map<Id,User> userList;
    public Map<Id,User> alluserList;
    public Map<Id,User> userName;
    public Map<Id,LoginHistory> objectmapLogin;
    public Map<Id,Opportunity> objectMapOpportunity;
    public Map<Id,Opportunity> objectMapAllOpportunity;
    public Map<Id, Contact> objectMapContact;
    public Map<Id,Task> objectMapTask;
    public Map<Id,Event> objectMapEvent;
    public Map<Id,AggregateResult> objectMapCreadas;
    public Map<Id,AggregateResult> objectMapGanadas;
    public Map<Id,AggregateResult> objectMapPerdIdas;
    public Map<Id,Opportunity> objectMapAllGanadas;
    public Map<Id,Opportunity> objectMapAllPerdidas;
    public Map<Id,AggregateResult> objectMapContactosCreados;
    public Map<Id,AggregateResult> objectMapVisitasEvent;
    public Map<Id,AggregateResult> objectMapVisitasTask;
    
    //Constructor, iniciamos los valores de las fechas
    public UserGroupController(){
        string dateFrom;
        Integer day = 1; 
        Integer year = date.today().year(); 
        Integer month =date.today().month(); 
        startDate = date.newInstance(year, month, day);
        endDate = Date.today();
        endDateTime = DateTime.newInstance(enddate.year(), enddate.month(), enddate.day(), 23, 59, 59);
        showOpp=true;
        showCont=false;
        showEvent=false;
        showTask=false;
    }
    
    //Opciones de selección el la PickList
    public List<SelectOption> getuserOptions() {
        List<SelectOption> usersOptions = new List<SelectOption>();
        usersOptions.add(new SelectOption('OPPORTUNITIES','Opportunities'));
        usersOptions.add(new SelectOption('CONTACTS','Contacts'));
        usersOptions.add(new SelectOption('EVENT','Event'));
        usersOptions.add(new SelectOption('TASK','Task'));
        return usersOptions;
    }

    //Método funciones PickList
    public void pruebaPickList(){
        System.debug('Prueba PickList:'+selectedOption);
        //Si eliges Opportunities
        if (selectedOption=='OPPORTUNITIES'){
            showOpp=true;
            showCont=false;
            showEvent=false;
            showTask=false;
            showOpportunity();
        }
        //Si eliges Contact
        if (selectedOption=='CONTACTS'){
            showOpp=false;
            showCont=true;
            showEvent=false;
            showTask=false;
            showContact();
        }
        //Si eliges Event
        if (selectedOption=='EVENT'){
            showOpp=false;
            showCont=false;
            showEvent=true;
            showTask=false;
            showEvent();
        }
        //Si eliges Task
        if (selectedOption=='TASK'){
            showOpp=false;
            showCont=false;
            showEvent=false;
            showTask=true;
            showTask();
        }
    }
    
    //Creamos un método para controlar los valores null
    public Integer returnValue(Map<Id,AggregateResult> maptoReturn, id userId){
        Integer valuetoReturn;
        try{
            valuetoReturn=Integer.valueof(maptoReturn.get(userId).get('idReturn'));
        }catch(Exception e){
            valuetoReturn=0;
        }
        return valuetoReturn;
    }
    
    //Método para obtener los valores de la tabla
    public void showData(){
        //Query para obtener los datos
        userList = new Map<Id,User>([SELECT Id, name FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE group.Name ='USUARIOS UK DETS Y LATIS')]);
        objectMapCreadas = new Map<Id,AggregateResult>([SELECT CreatedById Id, count(CreatedBy.Id) idReturn FROM Opportunity WHERE CreatedBy.Id IN :userList.keyset() AND CreatedDate>= :startDate AND CreatedDate<= :endDateTime  GROUP BY CreatedById]);
        objectMapGanadas = new Map<Id,AggregateResult>([SELECT CreatedById Id, count(CreatedBy.Id) idReturn FROM Opportunity WHERE CreatedBy.Id IN :userList.keyset() AND LastModifiedDate >= :startDate AND LastModifiedDate <= :endDateTime AND StageName = 'Ganada' GROUP BY CreatedById]); 
        objectMapPerdIdas = new Map<Id,AggregateResult>([SELECT CreatedById Id, count(CreatedBy.Id) idReturn FROM Opportunity WHERE CreatedBy.Id IN :userList.keyset() AND LastModifiedDate >= :startDate AND LastModifiedDate <= :endDateTime AND StageName = 'PerdIda' GROUP BY CreatedById]); 
        objectMapContactosCreados = new Map<Id,AggregateResult>([SELECT CreatedById Id, count(CreatedBy.Id) idReturn FROM Contact WHERE CreatedBy.Id IN :userList.keyset() AND CreatedDate>= :startDate AND CreatedDate<= :endDateTime GROUP BY CreatedById]); 
        objectMapVisitasEvent = new Map<Id,AggregateResult>([SELECT Owner.Id Id, count(Owner.Name) idReturn  FROM Event WHERE Owner.Id IN :userList.keyset() AND CreatedDate>= :startDate AND LastModifiedDate<= :endDateTime GROUP BY Owner.Id]); 
        objectMapVisitasTask = new Map<Id,AggregateResult>([SELECT Owner.Id Id, count(Owner.Name) idReturn FROM Task WHERE Owner.Id IN :userList.keyset() AND CreatedDate>= :startDate AND LastModifiedDate<= :endDateTime GROUP BY Owner.Id]); 
        
        //Recorremos los datos y los guardamos en la lista
        wrapp = new List<Wrapp>();
        for (User userId :userList.values()){
            Wrapp userWrapp = new Wrapp();
            userWrapp.name = userId.name;
            userWrapp.numOpp=returnValue(objectMapCreadas,userId.Id);
            userWrapp.numWon = returnValue(objectMapGanadas,userId.Id);
            userWrapp.numLost = returnValue(objectMapPerdIdas,userId.Id);
            userWrapp.numContacts = returnValue(objectMapContactosCreados,userId.Id);
            userWrapp.numEvent = returnValue(objectMapVisitasEvent,userId.Id);
            userWrapp.numTask = returnValue(objectMapVisitasTask,userId.Id);
            System.debug('Prueba2:'+userWrapp);
            wrapp.add(userWrapp);
        }  
    }
    
    //Método para obtener los valores de la tabla Opportunity
    public void showOpportunity(){
        //Query para obtener los datos
        objectMapOpportunity = new Map<Id,Opportunity>([SELECT Name,OPO_TXT_Codigo_Oportunidad__c,id,StageName,Account.Name, CreatedBy.CreatedDate, OPO_RUS_Volumen_Total__c, OPO_FOR_Divisa__c FROM Opportunity WHERE CreatedBy.Name = :nameopp AND CreatedDate>= :startDate AND CreatedDate<= :endDateTime]);
        System.debug('ME-showOpportunity');
        System.debug('ME-nameopp: ' + nameopp);
        System.debug('ME-startDate: ' + startDate);
        System.debug('ME-endDateTime: ' + endDateTime);
        System.debug('ME-objectMapOpportunity: ' + objectMapOpportunity);
        
        //Recorremos los datos y los guardamos en la lista
        wrappopp = new List<WrappOpp>();
        for (Opportunity opp :objectMapOpportunity.values()){
            WrappOpp oppWrapp = new WrappOpp(); 
            oppWrapp.nameOpp=opp.Name;
            oppWrapp.stageNameOpp=opp.StageName;
            oppWrapp.accountNameOpp=opp.Account.Name;
            oppWrapp.createDate=opp.CreatedBy.CreatedDate;
            oppWrapp.totalAmount=opp.OPO_RUS_Volumen_Total__c.setscale(2);
            oppWrapp.CurrencyType=opp.OPO_FOR_Divisa__c;
            oppWrapp.url = URL.getSalesforceBaseUrl().toExternalForm() + '/'+opp.id;
            oppWrapp.codeOpp=opp.OPO_TXT_Codigo_Oportunidad__c;
            System.debug('Entro');
            wrappopp.add(oppWrapp);
        }
    }
    
    //Método para obtener los valores de la tabla Contacts
    public void showContact(){
        //Query para obtener los datos
        objectMapContact= new Map<Id,Contact>([SELECT Name, CreatedBy.Name, CreatedDate,Account.Name, id FROM Contact WHERE CreatedBy.Name = :nameopp AND CreatedDate>= :startDate AND CreatedDate<= :endDateTime]);
        System.debug('ME-showContact');
        System.debug('ME-nameopp: ' + nameopp);
        System.debug('ME-startDate: ' + startDate);
        System.debug('ME-endDateTime: ' + endDateTime);
        System.debug('ME-objectMapOpportunity: ' + objectMapOpportunity);
        //Recorremos los datos y los guardamos en la lista
        wrappcontact = new List<WrappContact>();
        for (Contact cont: objectMapContact.values()){
            WrappContact contWrapp= new WrappContact();
            contWrapp.nameCont=cont.Name;
            contWrapp.nameCreatedCont=cont.CreatedBy.Name;
            contWrapp.nameAccount=cont.Account.Name;
            contWrapp.createDate=cont.CreatedDate;
            contWrapp.urlCont= URL.getSalesforceBaseUrl().toExternalForm() + '/'+cont.id;
            wrappcontact.add(contWrapp);
        }
    }

    //Método para obtener los valores de la tabla Event
    public void showEvent(){
        //Query para obtener los datos
        userName= new Map<Id,User>([SELECT id,Name FROM User WHERE Name = :nameopp]);
        objectMapEvent= new Map<Id,Event>([SELECT id, CreatedDate, Subject, Account.Name FROM Event WHERE Owner.Id IN :userName.keyset() AND CreatedDate>= :startDate AND LastModifiedDate<= :endDateTime]);
        System.debug('UserName: '+userName);
        System.debug('objectMapEvent: '+objectMapEvent);
        wrappevent = new List<WrappEvent>();
        //Recorremos los datos y los guardamos en la lista
        for (Event event :objectMapEvent.values()){
            WrappEvent eventWrapp = new WrappEvent();
            eventWrapp.nameEvent=event.Subject;
            eventWrapp.CreateTimeEvent=event.CreatedDate;
            eventWrapp.accountNameEvent=event.Account.Name;
            eventWrapp.urlEvent = URL.getSalesforceBaseUrl().toExternalForm() + '/'+event.id;
            System.debug('taskEventWrapp Event'+eventWrapp);
            wrappevent.add(eventWrapp);
        } 
    }

    //Método para obtener los valores de la tabla Task
    public void showTask(){
        //Query para obtener los datos
        userName= new Map<Id,User>([SELECT id,name FROM user WHERE Name = :nameopp]);
        objectMapTask= new Map<Id,Task>([SELECT id, CreatedDate, Subject, Account.Name FROM Task WHERE Owner.Id IN :userName.keyset() AND CreatedDate>= :startDate AND LastModifiedDate<= :endDateTime]);
        //Recorremos los datos y los guardamos en la lista
        wrapptask = new List<WrappTask>();
        for (Task task :objectMapTask.values()){
            WrappTask taskWrapp = new WrappTask();
            taskWrapp.nameTask=task.Subject;
            taskWrapp.CreateTimeTask=task.CreatedDate;
            taskWrapp.accountNameTask=task.Account.Name;
            taskWrapp.urlTask = URL.getSalesforceBaseUrl().toExternalForm() + '/'+task.id;
            System.debug('taskEventWrapp Task'+taskWrapp);
            wrapptask.add(taskWrapp);
        } 
    }
    
    //Método para obtener los valores de la tabla Opportunity
    public void showAllOpportunity(){
        //Query para obtener los datos
        alluserList = new Map<Id,User>([SELECT Id, Name FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE group.Name ='USUARIOS UK DETS Y LATIS')]);
        objectMapAllOpportunity = new Map<Id,Opportunity>([SELECT Name,id,StageName,Account.Name, CreatedBy.Name, CreatedBy.CreatedDate, OPO_RUS_Volumen_Total__c, OPO_FOR_Divisa__c, OPO_TXT_Codigo_Oportunidad__c FROM Opportunity WHERE CreatedBy.Id IN :alluserList.keyset() AND CreatedDate>= :startDate AND CreatedDate<= :endDateTime]); 
        //Recorremos los datos y los guardamos en la lista
        wrappAllopp = new List<WrappAllOpp>();
        System.debug('estoy aqui! '+objectMapAllOpportunity);
        for (Opportunity opp :objectMapAllOpportunity.values()){
            WrappAllOpp oppAllWrapp = new WrappAllOpp(); 
            oppAllWrapp.codeOpp= opp.OPO_TXT_Codigo_Oportunidad__c;
            oppAllWrapp.nameOpp=opp.Name;
            oppAllWrapp.stageNameOpp=opp.StageName;
            oppAllWrapp.accountNameOpp=opp.Account.Name;
            oppAllWrapp.createDate=opp.CreatedBy.CreatedDate;
            oppAllWrapp.totalAmount=opp.OPO_RUS_Volumen_Total__c.setscale(2);
            oppAllWrapp.CurrencyType=opp.OPO_FOR_Divisa__c;
            oppAllWrapp.nameUser=opp.CreatedBy.Name;
            System.debug('Prueba3:'+oppAllWrapp);
            wrappAllopp.add(oppAllWrapp);
        } 
    }
    
    //Método para obtener los valores de la tabla Event
    public void showAllEvent(){
        //Query para obtener los datos
        alluserList = new Map<Id,User>([SELECT Id, Name FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE group.Name ='USUARIOS UK DETS Y LATIS')]);
        objectMapEvent= new Map<Id,Event>([SELECT Id, CreatedDate, Subject,Account.Name, Owner.Name FROM Event WHERE Owner.Id IN :alluserList.keyset() AND CreatedDate>= :startDate AND LastModifiedDate<= :endDateTime]);
        wrappallevent = new List<WrappAllEvent>();
        //Recorremos los datos y los guardamos en la lista
        for (Event event :objectMapEvent.values()){
            /*
            WrappAllEvent eventAllWrapp = new WrappAllEvent();
            eventAllWrapp.nameEvent=event.Subject;
            eventAllWrapp.CreateTimeEvent=event.CreatedDate;
            eventAllWrapp.accountNameEvent=event.Account.Name;
            eventAllWrapp.ownerNameEvent=event.Owner.Name;
            wrappallevent.add(eventAllWrapp);
            */
        } 
    }
    
    //Método para obtener los valores de la tabla Task
    public void showAllTask(){
        //Query para obtener los datos
        alluserList = new Map<Id,User>([SELECT Id, Name FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE group.Name ='USUARIOS UK DETS Y LATIS')]);
        objectMapTask= new Map<Id,Task>([SELECT id, CreatedDate, Subject, Account.Name, Owner.Name FROM Task WHERE Owner.Id IN :alluserList.keyset() AND CreatedDate>= :startDate AND LastModifiedDate<= :endDateTime]);
        //Recorremos los datos y los guardamos en la lista
        wrappalltask = new List<WrappAllTask>();
        for (Task task :objectMapTask.values()){
            /*
            WrappAllTask taskAllWrapp = new WrappAllTask();
            taskAllWrapp.nameTask=task.Subject;
            taskAllWrapp.CreateTimeTask=task.CreatedDate;
            taskAllWrapp.accountNameTask=task.Account.Name;
            taskAllWrapp.ownerNameTask= task.Owner.Name;
            wrappalltask.add(taskAllWrapp);
            */
        } 
    }

    //Método para obtener los valores de la tabla Contacts
    public void showAllContact(){
        //Query para obtener los datos
        alluserList = new Map<Id,User>([SELECT Id, Name FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE group.Name ='USUARIOS UK DETS Y LATIS')]);
        objectMapContact= new Map<Id,Contact>([SELECT Name, CreatedBy.Name, CreatedDate,Account.Name, id FROM Contact WHERE CreatedBy.Id IN :alluserList.keyset() AND CreatedDate>= :startDate AND CreatedDate<= :endDateTime]);
        //Recorremos los datos y los guardamos en la lista
        wrappallcontact = new List<WrappAllContact>();
        for (Contact cont: objectMapContact.values()){
            /*
            WrappAllContact contallWrapp= new WrappAllContact();
            contallWrapp.nameCont=cont.Name;
            contallWrapp.nameCreatedCont=cont.CreatedBy.Name;
            contallWrapp.nameAccount=cont.Account.Name;
            contallWrapp.createDate=cont.CreatedDate;
            //contWrapp.urlCont= URL.getSalesforceBaseUrl().toExternalForm() + '/'+cont.id;
            wrappallcontact.add(contallWrapp);
            */
        }
    }

    //Método para obtener los valores de la tabla LoginHistory
    public void showLogin(){
        userList = new Map<Id,User>([SELECT Id, Name FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE group.Name ='USUARIOS UK DETS Y LATIS')]);
        objectmapLogin = new Map<Id,LoginHistory>([SELECT UserId, LoginTime FROM LoginHistory WHERE UserId IN (SELECT id FROM User WHERE id IN :userList.keySet()) AND LoginTime>= :startDate AND LoginTime<= :endDateTime]);
        //Recorremos los usuarios para agruparlos con sus LoginTime, y los añadimos a una lista
        wrapplogin = new List<WrappLogin>();
        for (LoginHistory lh :objectmapLogin.values()){
            /*
            WrappLogin userWrappLogin = new wrappLogin();
            userWrappLogin.nameUser = String.valueOf(userList.get(lh.userId).get('name'));
            userWrappLogin.loginTimeUser=(lh.LoginTime);
            wrapplogin.add(userWrappLogin);
            */
        }
    }

    public void showAllOpportunityWon(){
        //Query para obtener los datos
        alluserList = new Map<Id,User>([SELECT Id, Name FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE group.Name ='USUARIOS UK DETS Y LATIS')]);
        objectMapAllGanadas = new Map<Id,Opportunity>([SELECT Name,id,StageName,Account.Name, CreatedBy.Name, OPO_TXT_Codigo_Oportunidad__c FROM Opportunity WHERE CreatedBy.Id IN :alluserList.keyset() AND LastModifiedDate>= :startDate AND LastModifiedDate<= :endDateTime AND StageName = 'Ganada']); 
        //Recorremos los datos y los guardamos en la lista
        wrappallganadas = new List<WrappAllGanadas>();
        for (Opportunity opp :objectMapAllGanadas.values()){
            /*
            WrappAllGanadas wonAllWrapp = new WrappAllGanadas(); 
            wonAllWrapp.codeOppGanadas= opp.OPO_TXT_Codigo_Oportunidad__c;
            wonAllWrapp.nameOppGanadas=opp.Name;
            wonAllWrapp.stageNameOppGanadas=opp.StageName;
            wonAllWrapp.accountNameOppGanadas=opp.Account.Name;
            wonAllWrapp.nameUserGanadas=opp.CreatedBy.Name;
            wrappallganadas.add(wonAllWrapp);
            */
        } 
    }

    public void showAllOpportunityLost(){
        //Query para obtener los datos
        alluserList = new Map<Id,User>([SELECT Id, Name FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE group.Name ='USUARIOS UK DETS Y LATIS')]);
        objectMapAllPerdidas = new Map<Id,Opportunity>([SELECT Name,id,StageName,Account.Name, CreatedBy.Name, OPO_TXT_Codigo_Oportunidad__c FROM Opportunity WHERE CreatedBy.Id IN :alluserList.keyset() AND LastModifiedDate>= :startDate AND LastModifiedDate<= :endDateTime AND StageName = 'Perdida']); 
        //Recorremos los datos y los guardamos en la lista
        wrappallperdidas = new List<WrappAllPerdidas>();
        for (Opportunity opp :objectMapAllPerdidas.values()){
            /*
            WrappAllPerdidas lostAllWrapp = new WrappAllPerdidas(); 
            lostAllWrapp.codeOppPerdidas= opp.OPO_TXT_Codigo_Oportunidad__c;
            lostAllWrapp.nameOppPerdidas=opp.Name;
            lostAllWrapp.stageNameOppPerdidas=opp.StageName;
            lostAllWrapp.accountNameOppPerdidas=opp.Account.Name;
            lostAllWrapp.nameUserPerdidas=opp.CreatedBy.Name;
            wrappallperdidas.add(lostAllWrapp);
            */
        } 
    }
    
    //Clase Wrapp que unen campos de Oportunidad, Contactos, Eventos y Task.
    public class Wrapp{
        public String name{get;set;}
        public Integer numOpp{get;set;}
        public Integer numWon{get;set;}
        public Integer numLost{get;set;}
        public Integer numContacts{get;set;}
        public Integer numEvent{get;set;}
        public Integer numTask{get;set;}
    } 
    
    //Clase WrappOpp para unir campos de Oportunidad.
    public class WrappOpp{
        public String nameOpp{get;set;}
        public string codeOpp{get;set;}
        public String stageNameOpp{get;set;}
        public String accountNameOpp{get;set;}
        public Datetime CreateDate{get;set;}
        public Double totalAmount{get;set;}
        public String CurrencyType{get;set;}
        public String url{get;set;}
    } 
    
    //Clase WrappContact para unir campos de Contact.
    public class WrappContact{
        public String nameCont{get;set;}
        public String nameCreatedCont{get;set;}
        public Datetime createDate{get;set;}
        public String urlCont{get;set;}
        public String nameAccount{get;set;}
    }

    //Clase WrappAllOpp para unir campos de Oportunidad.
    public class WrappAllOpp{
        public String nameOpp{get;set;}
        public String stageNameOpp{get;set;}
        public String accountNameOpp{get;set;}
        public Datetime CreateDate{get;set;}
        public Double totalAmount{get;set;}
        public String CurrencyType{get;set;}
        public string nameUser{get;set;}
        public string codeOpp{get;set;}
    }

    //Clase WrappLogin para unir campos de Usuario con LoginHistory
    public class WrappLogin{
        public String nameUser{get;set;}
        public Datetime loginTimeUser{get;set;}
    }

    //Clase WrappTask para unir campos de Task.
    public class WrappTask{
        public String urlTask{get;set;}
        public String nameTask{get;set;}
        public String accountNameTask{get;set;}
        public Datetime CreateTimeTask{get;set;}
    }

    //Clase WrappEvent para unir campos de Event.
    public class WrappEvent{
        public String urlEvent{get;set;}
        public String nameEvent{get;set;}
        public String accountNameEvent{get;set;}
        public Datetime CreateTimeEvent{get;set;}
    }

    //Clase WrappAllEvent para unir campos de Event.
    public class WrappAllEvent{
        public String ownerNameEvent{get;set;}
        public String nameEvent{get;set;}
        public String accountNameEvent{get;set;}
        public Datetime CreateTimeEvent{get;set;}
    }

    //Clase WrappAllTask para unir campos de Task.
    public class WrappAllTask{
        public String ownerNameTask{get;set;}
        public String nameTask{get;set;}
        public String accountNameTask{get;set;}
        public Datetime CreateTimeTask{get;set;}
    }

    public class WrappAllContact{
        public String nameCont{get;set;}
        public String nameCreatedCont{get;set;}
        public Datetime createDate{get;set;}
        public String nameAccount{get;set;}
    }

    public class WrappAllGanadas{
        public String nameOppGanadas{get;set;}
        public String stageNameOppGanadas{get;set;}
        public String accountNameOppGanadas{get;set;}
        public string nameUserGanadas{get;set;}
        public string codeOppGanadas{get;set;}
    } 
    
    public class WrappAllPerdidas{
        public String nameOppPerdidas{get;set;}
        public String stageNameOppPerdidas{get;set;}
        public String accountNameOppPerdidas{get;set;}
        public string nameUserPerdidas{get;set;}
        public string codeOppPerdidas{get;set;}
    }

    /*
    //Redirige a la página UserReportToExcelPage
    public PageReference UserReportToExcelPage() {
        return Page.UserReportToExcelPage;
    }

    //Redirige a la página OpportunityReportToExcelPage
    public PageReference OpportunityReportToExcelPage() {
        return Page.OpportunityReportToExcelPage;
    }

    //Redirige a la página LoginReportToExcelPage
    public PageReference LoginReportToExcelPage() {
        return Page.LoginReportToExcelPage;
    }
    
    //Redirige a la página TaskReportToExcelPage
    public PageReference TaskReportToExcelPage() {
        return Page.TaskReportToExcelPage;
    }

    //Redirige a la página EventToExcelPage
    public PageReference EventToExcelPage() {
        return Page.EventToExcelPage;
    }
    
    public PageReference ContactReportToExcelPage() {
        return Page.ContactReportToExcelPage;
    }

    public PageReference WonReportToExcelPage() {
        return Page.WonReportToExcelPage;
    }

    public PageReference LostReportToExcelPage() {
        return Page.LostReportToExcelPage;
    }
    */

    //Método que renderiza los dos métodos.
    public void Rerender(){
        endDateTime = DateTime.newInstance(enddate.year(), enddate.month(), enddate.day(), 23, 59, 59);
        showData();
        showOpportunity();
        pruebaPickList();
    }
}