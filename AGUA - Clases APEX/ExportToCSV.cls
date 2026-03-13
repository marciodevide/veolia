public class ExportToCSV {
    public String csvContent { get; set; }

    public ExportToCSV() {
        // Obtener el contenido CSV
        csvContent = generateCSV();
    }

    // Método para generar el CSV
    public static String generateCSV() {
        DateTime fechaCorte = DateTime.newInstance(2025, 2, 08, 0, 0, 0);
Integer contador = 0;
List<Id> listAccountWithHistory = new List<Id>();
List<AccountHistory> listHistoryAccountWithHistory = 
    [SELECT AccountId, CreatedDate
    FROM AccountHistory
    WHERE 
        Field = 'COM_TXT_Numero_Compania_SAP__c' AND 
        CreatedDate > :fechaCorte];
for(AccountHistory acch:listHistoryAccountWithHistory){
    listAccountWithHistory.add(acch.accountId);
}
List<Account> listAccountWithoutWin = 
    [SELECT 
    Id, Name, LastModifiedDate,
    (SELECT Id, Name, StageName, CloseDate, Amount, IsClosed, IsWon 
     FROM Opportunities 
     WHERE IsClosed = FALSE) 
     FROM Account WHERE COM_TXT_Numero_Compania_SAP__c != null];
List<Account> listAccountWithWinFiltered = 
    [SELECT 
    Id, 
    Name, 
    LastModifiedDate,
    (SELECT 
        Id, Name, StageName, CloseDate, Amount, IsClosed, IsWon 
     FROM Opportunities 
     WHERE IsWon = TRUE AND LastStageChangeDate > 2025-02-08T00:00:00Z
    )
FROM Account
WHERE LastModifiedDate > 2025-02-08T00:00:00Z AND COM_TXT_Numero_Compania_SAP__c!=null];
List<Account> listFinalAccount = 
    [SELECT Id, Name,LastModifiedDate,COM_TXT_Numero_Compania_SAP__c, (SELECT 
        Id,Name, 
        StageName, 
        CloseDate, 
        Amount, 
        IsClosed, 
        IsWon
     FROM Opportunities 
     WHERE 
        IsClosed = FALSE OR 
        (IsWon = TRUE AND AccountId IN:listAccountWithHistory)
    )
FROM Account
WHERE 
    Id IN:listAccountWithoutWin AND ID IN:listAccountWithWinFiltered
    ];
    //for(Account acc : listFinalAccount){
    //    contador ++;
    //    system.debug('MARC-ACC'+contador+': '+acc);
    //}
	//system.debug('MARC-ListaCompleta: '+listFinalAccount);
 // Paso 2: Crear el archivo CSV
        String csvContent = 'Id,Name,StageName,IsClosed,IsWon,CloseDate,AccountId\n';
        
        for (Account acc : listFinalAccount) {
            csvContent += '"' + acc.Id + '","'
                          + acc.COM_TXT_Numero_Compania_SAP__c + '","'
                          + acc.LastModifiedDate + '"\n';
        }
        
        Blob csvBlob = Blob.valueOf(csvContent);
        
        // Paso 3: Hacer una respuesta HTTP para descarga
        PageReference pageRef = new PageReference('/apex/DownloadCSVPage');
        pageRef.getParameters().put('fileName', 'Oportunidades.csv');
        
        // Headers para descarga de archivo CSV
        pageRef.getHeaders().put('Content-Type', 'text/csv');
        pageRef.getHeaders().put('Content-Disposition', 'attachment; filename="Oportunidades.csv"');
        pageRef.getHeaders().put('Content-Length', String.valueOf(csvBlob.size()));
        return csvContent;
    }
}