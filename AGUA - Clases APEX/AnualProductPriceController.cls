public class AnualProductPriceController {

    @AuraEnabled
    public static Oportunidad_Producto__c getProduct(Id productId) {
        return [SELECT OP_FOR_ImporteBruto__c,OP_FOR_ImporteNeto__c,OP_MD_Oportunidad__r.OPO_DAT_Fecha_Inicio_Proyecto__c,OP_MD_Oportunidad__r.OPO_DAT_Fecha_Fin_Proyecto__c FROM Oportunidad_Producto__c WHERE Id = :productId];
    }

    @InvocableMethod
    public static void createAtomaticAnualProductPrices(List<List<Oportunidad_Producto__c>> productListId) {
        List<Id> oportunidades = new List<Id>();
        AnualProductPriceController productPrice = new AnualProductPriceController();
        for(Oportunidad_Producto__c product: productListId.get(0)){
            createAnualProductPrices(product.Id);
        }
        /*
        List<AnualProductPrice__c> apps = [SELECT Id, Name from AnualProductPrice__c where Opportunity__c=:oportunidades.get(0)];
        Opportunity opp = [Select Id,OPO_LKP_Cartera__c from Opportunity where Id =: oportunidades.get(0)];
        opp.OPO_LKP_Cartera__c= apps[0].Id;
        update opp;*/
    }

    @AuraEnabled 
    public static void createAnualProductPrices(Id productId) {
        List<AnualProductPrice__c> existingApps = getAnualProductPricesByProduct(productId);
        if (existingApps.size() != 0) delete existingApps;

		Oportunidad_Producto__c product = [SELECT Id,OP_FOR_ImporteBruto__c,OP_FOR_ImporteNeto__c,OP_MD_Oportunidad__c,OP_MD_Oportunidad__r.OPO_DAT_Fecha_Inicio_Proyecto__c,OP_MD_Oportunidad__r.OPO_DAT_Fecha_Fin_Proyecto__c,CurrencyIsoCode,CreatedById FROM Oportunidad_Producto__c WHERE Id = :productId LIMIT 1];
        try {
            Boolean b;
            Decimal totalPrice = product.OP_FOR_ImporteNeto__c;
            Map<Integer, Integer> years = new Map<Integer, Integer>();
            Integer days;
            Date startDate = product.OP_MD_Oportunidad__r.OPO_DAT_Fecha_Inicio_Proyecto__c;
            Date dueDate = product.OP_MD_Oportunidad__r.OPO_DAT_Fecha_Fin_Proyecto__c;
            if (startDate != null && dueDate != null && totalPrice != null) {
                    
                Integer numberDaysDue = startDate.daysBetween(dueDate);
                System.debug('Dias entre fechas '+numberDaysDue);
                Integer yearDays;
                Integer anioIni = Integer.valueOf(startDate.year());
                Integer anioFin = Integer.valueOf(dueDate.year());
                
                System.debug('Dias transcurridos entre '+startDate+' y '+dueDate+' es: '+numberDaysDue);
                if (startDate.year() == dueDate.year()) {
                    days = startDate.daysBetween(dueDate);
                    if (days == 0) days =1;
                    years.put(startDate.year(), days);
                } else {
                    System.debug('Dias del año del startdate '+ startDate.dayOfYear());
                    System.debug('Dias del año del enddate '+ dueDate.dayOfYear());
                    if (Date.isLeapYear(anioIni)){
                        days =366 - (startDate.dayOfYear());
                        System.debug('Dias del startDate '+days);
                    } else{
                        days =365 - (startDate.dayOfYear());
                        System.debug('Dias del startDate '+days);
                    }
                    years.put(startDate.year(), days);
                    if(dueDate.month()==12 && dueDate.day()==31 && Date.isLeapYear(anioFin)){
                        days += dueDate.dayOfYear()-1;
                        System.debug('este es el caso de fecha fin 31/12 y año bisiesto  '+days);
                    } else{
                        days += dueDate.dayOfYear();
                        System.debug('este es el caso de fecha fin 31/12 pero año no bisiesto '+ days);
                    }
                    System.debug('Dias del EndDate '+days);
                    if(dueDate.month()==12 && dueDate.day()==31 && Date.isLeapYear(anioFin)) years.put(dueDate.year(), dueDate.dayOfYear()-1);
                    else years.put(dueDate.year(), dueDate.dayOfYear());
                    
                    for (Integer y = startDate.year()+1; y < dueDate.year(); y++) {
                        yearDays = 365;
                        days += yearDays;
                        years.put(y, yearDays);
                        System.debug('El mapa por años queda '+years);
                    }
                }
            
                System.debug('MArta _el mapa queda '+years);
                Decimal monthCalculatedPrice = totalPrice.divide(days, 6);
                System.Debug('MArta_dias: '+days);
                System.Debug('MArta_precio_dia: '+monthCalculatedPrice);
                System.Debug('MArta_total_dia: '+monthCalculatedPrice*days);
                Decimal remainder = totalPrice - (monthCalculatedPrice * days);
                System.Debug('MArta_remanente: '+remainder);
    
                List<AnualProductPrice__c> apps = new List<AnualProductPrice__c>();
                for (Integer year : years.keySet()) {
                    AnualProductPrice__c app = new AnualProductPrice__c();
                    app.Opportunity__c = product.OP_MD_Oportunidad__c;
                    app.Product__c = product.Id;
                    app.OwnerId = product.CreatedById;
                    app.CurrencyIsoCode = product.CurrencyIsoCode;
                    app.Year__c = String.valueOf(year);
                    app.APP_BOL_Opportunity_Modified__c = false;
                    app.CalculatedPrice__c = monthCalculatedPrice * years.get(year);
                    
                    System.debug('MArta_CalculatedPrice__c: '+app.CalculatedPrice__c+' _año: ' +year+' _meses:'+years.get(year) );
                    if (year == product.OP_MD_Oportunidad__r.OPO_DAT_Fecha_Fin_Proyecto__c.year()) app.CalculatedPrice__c += remainder;
                    
                    app.Price__c = app.CalculatedPrice__c;
                    System.debug('MArta_Price__c: '+app.Price__c);
                    apps.add(app);
                }
                System.Savepoint svpt = Database.setSavepoint();
                try {
                    insert apps;
                } catch (Exception e) {
                    Database.rollback(svpt);throw new DmlException();
                }

            }
        } catch (System.NullPointerException e) {
            e.setMessage('Null');
            throw new NullPointerException();
        }
    }
    
    @AuraEnabled
    public static String productPriceUpdated(Id productId){
        String response ='Ok';
        List<AnualProductPrice__c> existingApps = getAnualProductPricesByProduct(productId);
        for (AnualProductPrice__c annualPrice : existingApps) annualPrice.APP_BOL_Opportunity_Modified__c = true;

        try {
            update existingApps;
        } catch (Exception e) {
            response = e.getMessage();
        }

        return response;
    }

	@AuraEnabled
    public static List<AnualProductPrice__c> getAnualProductPricesByProduct(Id productId) {
        return new List<AnualProductPrice__c>([SELECT Id,Year__c,Price__c,CurrencyISOCode,CalculatedPrice__c, APP_BOL_Opportunity_Modified__c FROM AnualProductPrice__c WHERE Product__c = :productId ORDER BY Year__c ASC LIMIT 5000]);
    }

    @AuraEnabled
    public static void updateAnualProductPrices(List<AnualProductPrice__c> apps) {
        update apps;
    }
}