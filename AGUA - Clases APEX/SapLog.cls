public class SapLog implements Triggers.Handler{
    Public void handle(){
        integer contador = 0;
        if (UserInfo.getUserId() == label.ADMIN_USER_SAP_ID || Test.isRunningTest()){
                for(sObject obj :Trigger.new){
                    
                    System.debug('El objeto '+contador+' Contiene: '+obj);
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.toAddresses = new String[] { 'salesforce.aqualogy@everis.com','jtrancos@gmail.com' };
                        message.subject = 'Sap Log';
                    message.plainTextBody = String.valueOf(obj);
                    Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    return;
                }
            }
            
            
            
        }
    }