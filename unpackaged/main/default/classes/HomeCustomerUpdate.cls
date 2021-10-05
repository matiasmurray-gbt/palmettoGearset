global class HomeCustomerUpdate{
    
    public static Boolean runOnce = false;
    //This method is called on after update event of trigger.
    public void onAfterUpdate(List<Opportunity> lstOpp, Map<Id, Opportunity> mapIdToOldOpp){
        Set<Id> setOpportunityId = new Set<Id>();
        Id designSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        for(Opportunity objOpp : lstOpp){
            Opportunity objOldOpp = mapIdToOldOpp.get(objOpp.Id);
            if(objOpp.StageName != objOldOpp.StageName && objOpp.RecordTypeId == designSalesId){
                setOpportunityId.add(objOpp.Id);
            }
        }
        System.debug('>>>>>>'+setOpportunityId);
        if(!setOpportunityId.isEmpty()){
            if(runOnce == false){
                runOnce = true;
                for(Id oppId : setOpportunityId){
                    CustomerUpdate(oppId);
                }
            }
        }
    }


    @future (callout=true)
    public static void CustomerUpdate(id oppId) {
        try
        {   
            // kalidass
            /*
            Opportunity oppHome=[select SolarEdge_Site_ID__c,Palmetto_Home_App_Downloaded__c,Site_Audit_FieldCompleted_Date__c,Customer_Care_Representative__c,
                    HOA_Appeal__c, Site_Audit_Completed_Date__c,Site_Audit_Completed__c,Site_Approved_Date__c,Home_Owners_Association__c,Reason_for_loss__c,
                    HOA_Application_Sent_Date__c,HOA_Approval_Date__c,Engineering_Sent_Date__c,Engineering_Complete_Date__c,
                    NM_App_Rec_d_Date__c,Permit_Filed_Date__c,Signed_NMA_Rec_d_Date__c,Permit_Rec_d_Date__c,Equipment_Ordered_Date__c,
                    Install_Ready_Date__c,Installation_Start_Date__c,Installation_Complete_Date__c,Inspection_Completed_Date__c,
                    Net_Meter_Install_Date__c,SA_Approved_Date__c,StageName,Contact__c,Name,id,RecordType.Name 
                    from Opportunity where id=:oppId];
                    
            String JsonStringHome = JSON.serialize(oppHome);
            system.debug('>>>>>>>>'+JsonStringHome);
            if(oppHome.RecordType.Name != 'Energy Monitor'){
                HTTPResponse resHome = getInfoFromExternalService(JsonStringHome,'https://alchemy.palmetto.com/api/updateUserOpportunity');
                //HTTPResponse resHome = getInfoFromExternalService(JsonStringHome,'https://legacy-home-next.palmetto.com/api/updateUserOpportunity');
                //HTTPResponse resHome = getInfoFromExternalService(JsonStringHome,'https://legacy-home.palmetto.com/api/updateUserOpportunity'); 
                //system.debug('>>>>>>>>>'+resHome.getBody());
            }*/
            //end 
            //SOQL to construct JSON string in set body
            Opportunity opp = [select id,X18_Character_Opportunity_ID__c,StageName,RecordTypeId,Email__c,Contact__c,
                    Contract_Received_Date__c,Change_Order_Reason__c,Site_Audit_Order_Date__c,Site_Audit_FieldCompleted_Date__c,
                    Interconnection_Sent_Date__c,Permitting_Jurisdiction__c,Proposed_Installation_Date__c,Installation_Complete_Date__c,
                    Utility__c,Reason_for_loss__c,Other_Reason_for_Loss__c,Installation_Start_Date__c 
                    from Opportunity where id=:oppId]; 
                    
            String JsonString = JSON.serialize(opp);
            String status = '';
            String code = '';
            //Below code added by Prakash for Alchemy SF triggers
            system.debug('>>>>>>>'+JsonString);  
            String endPoint = System.Label.Alchemy_End_Point;           
            //HTTPResponse res1 = getInfoFromExternalService(JsonString,'https://alchemy-next.palmetto.com/updateOpportunityStatus');
            HTTPResponse res1 = getInfoFromExternalService(JsonString, endPoint);
            system.debug('>>>>>>>'+res1.getBody());             
            /*Id designSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
            Id oppProcessId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Opportunity - Process').getRecordTypeId();
            Id energyMotorId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Energy Monitor').getRecordTypeId();
            if(((opp.RecordTypeId == designSalesId || opp.RecordTypeId == oppProcessId)&&(opp.StageName == '7a. Contract Received Confirmed' || opp.StageName == '22. PTO')) || (opp.RecordTypeId ==  energyMotorId && opp.StageName == 'EM4 Payment/Contract Received'))
            {
                system.debug('serialized JSON'+JSON.serialize(opp));
                system.debug('>>>>>>>'+JsonString);             
                HTTPResponse res = getInfoFromExternalService(JsonString,'https://alchemy.palmetto.com/api/upgradeuser');
                //HTTPResponse res = getInfoFromExternalService(JsonString,'https://legacy-home-next.palmetto.com/api/upgradeuser');
                //HTTPResponse res = getInfoFromExternalService(JsonString,'https://legacy-home.palmetto.com/api/upgradeuser');
                
                System.debug('>>>>>'+res.getBody());
                status =  CheckResponse('status',res);
                code = CheckResponse('code',res);             
                
                if (status != 'true' || code != '1' || res.getStatusCode() != 200)
                {
                    //SendEmail(JsonString);
                }
            }*/
            // Below code added by Kalidass for store Opportunity values in Home 
        }
        catch (Exception e){
            SendEmail( 'Exception' + e + '\n Opportunity Id = ' +  oppId);
        } 
    }
    public static String CheckResponse(String FieldName,HTTPResponse res )
    {
        JSONParser parser = JSON.createParser(res.getBody());
        string result = '';
        while (parser.nextToken() != null) 
        { 
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) 
            {
                String field= parser.getText();
                parser.nextToken();
                if (field == FieldName) 
                {
                    result =  parser.getText();
                    break;
                }                      
            }
        }
        return result;
    }
    
    
    public static HttpResponse getInfoFromExternalService(String jsonstr,String url)
    {
        //Construct HTTP request and response
        //Http request method,Endpoint and setBody
        HttpRequest req = new HttpRequest();
        req.setTimeout(20000);
        req.setHeader('Content-Type','application/json');
        String endpoint = url;
        req.setMethod('POST');
        req.setEndpoint(endpoint); 
        req.setBody(jsonstr);
        //Http response method 
        Http http = new Http();
        return http.send(req);
    }
    public static void SendEmail(String MailBody) 
    {
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        //sendTo.add('mkpkarthiktest1@gmail.com');
        sendTo.add('technologyteam@palmetto.com');
        sendTo.add('bhargav.rentala@palmetto.com');
        mail.setReplyTo('alchemy@palmettoventures.com');
        mail.setSubject('URGENT SF Trigger Issue');
        //String body = 'Exception Details ' + e ;
        mail.setToAddresses(sendTo);
        mail.setHtmlBody(MailBody);
        mails.add(mail);
        Messaging.sendEmail(mails);
    }    
}