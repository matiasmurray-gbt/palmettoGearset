public class SendExpirationEmailToBP {   
    public SendExpirationEmailToBP(){}
    /*
    public void execute(SchedulableContext sc){
        sendEmail();
     
    //This method is used to send expiration Email to BP.
    private void sendEmail() 
        List<Messaging.SingleEmailMessage> lstSingleEmail = new List<Messaging.SingleEmailMessage>();
        List<Vendor__c> lstVendorToUpdate = new List<Vendor__c>();
        for(Vendor__c objVendor : [SELECT Id, Email__c, (select Id, Expiration_Date__c from Trade_Licensing__r) from Vendor__c 
                WHERE Email__c != null AND Stage__c != 'Do not Schedule'])
                 
            Boolean sendExpirationNotification = (objVendor.Trade_Licensing__r.size() == 0?false:true);
            for(Trade_Licensing__c objTradeLicensing : objVendor.Trade_Licensing__r){
                if(objTradeLicensing.Expiration_Date__c > Date.today()){
                    sendExpirationNotSendExpirationEmailToBPification = false;
                    break;
                }
                 
            if(sendExpirationNotification){
                String htmlBody = '<p>To our Valued Build Partner:</p>';
                htmlBody += '<p>Maintaining your license(s) and insurance coverage is an important part of our ongoing partnership. Please provide your updated document(s) to: buildpartners@palmetto.com to avoid any disruption of work opportunities.</p>';
                htmlBody += '<p>Thank you,</p>';
                htmlBody += '<p>Palmetto Build Partner Team</p>';
                String subject = 'Trade License Expiring notification'             
                Messaging.SingleEmailMessage objSingleEmail = new Messaging.SingleEmailMessage();
                objSingleEmail.setHTMLBody(htmlBody);
                objSingleEmail.setSubject(subject);
                objSingleEmail.setToAddresses(new List<String>{objVendor.Email__c});
                lstSingleEmail.add(objSingleEmail)             
                objVendor.Stage__c = 'Do not Schedule';
                lstVendorToUpdate.add(objVendor);
            }
             
        if(!lstSingleEmail.isEmpty())
            Messaging.sendEmail(lstSingleEmail);
        if(!lstVendorToUpdate.isEmpty())
            update lstVendorToUpdate;
    }
    */
}