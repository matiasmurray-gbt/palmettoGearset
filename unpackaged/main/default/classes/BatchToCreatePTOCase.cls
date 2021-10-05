global class BatchToCreatePTOCase implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable
{
    global void execute(SchedulableContext sc){
        BatchToCreatePTOCase objBatchToCreatePTOCase = new BatchToCreatePTOCase();
        Database.executeBatch(objBatchToCreatePTOCase, 1);
    }
    
    /*****************Batchable Interface Methods*****************/
    global Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'select Id, Installation_Complete_Date__c, AccountId, Contact__c, Contact__r.Email, Phone_Textey__c from Opportunity '; 
        query += 'where StageName != \'22. PTO\' AND StageName != \'Closed Won\' AND RecordType.DeveloperName = \'X3rd_Party_Design_Sales\' ';
        query += 'AND Installation_Complete_Date__c != null AND Financing_Tool__c IN (\'Sunlight\', \'Loan Pal\', \'Loanpal\') ';
        query += 'AND PTO_Processed__c = false AND Additional_Alchemy_Products__c EXCLUDES (\'Promo UB6\') ';
        System.debug('>>>>>>>'+query);
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext context, List<Opportunity> lstOpportunity) {
        Opportunity objOpp = lstOpportunity[0];
        Case objCase;
        Group objGroup = [select Id from Group where DeveloperName = 'Customer_Care' and type = 'queue'];
        OrgWideEmailAddress objOrgWideAddress = [select Id, Address FROM OrgWideEmailAddress WHERE Address = 'customer.care@palmetto.com' LIMIT 1];
        EmailTemplate objTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'PTO_Reimbursment'];
        
        Id reimbursementId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Reimbursement').getRecordTypeId();
        List<simplesms.Invocable_SendMessage.SendMessageRequest> lstMessageRequest = new List<simplesms.Invocable_SendMessage.SendMessageRequest>();
        List<Messaging.SingleEmailMessage> lstSingleEmail = new List<Messaging.SingleEmailMessage>();
        
        if(objOpp.Installation_Complete_Date__c.addDays(60) == Date.today()){
            objCase = getCaseData(objOpp, objGroup.Id, reimbursementId, 'Delayed PTO - First payment');
            if(String.isNotBlank(objOpp.Phone_Textey__c)){
                lstMessageRequest.add(getMessageRequest(objOpp, 'Contact-1429'));
            }
        }
        if(objOpp.Installation_Complete_Date__c.addDays(90) == Date.today()){
            objCase = getCaseData(objOpp, objGroup.Id, reimbursementId, 'Delayed PTO - Second payment');
            if(String.isNotBlank(objOpp.Phone_Textey__c)){
                lstMessageRequest.add(getMessageRequest(objOpp, 'Contact-8096'));
            }
        }
        if(objOpp.Installation_Complete_Date__c.addDays(120) == Date.today()){
            objCase = getCaseData(objOpp, objGroup.Id, reimbursementId, 'Delayed PTO - Third payment');
            if(String.isNotBlank(objOpp.Phone_Textey__c)){
                lstMessageRequest.add(getMessageRequest(objOpp, 'Contact-6846'));
            }
        }
        
        if(objOpp.Installation_Complete_Date__c.addDays(150) == Date.today())
            objCase = getCaseData(objOpp, objGroup.Id, reimbursementId, 'Delayed PTO - Fourth payment');
        if(objOpp.Installation_Complete_Date__c.addDays(180) == Date.today())
            objCase = getCaseData(objOpp, objGroup.Id, reimbursementId, 'Delayed PTO - Fifth payment');
        if(objOpp.Installation_Complete_Date__c.addDays(210) == Date.today())
            objCase = getCaseData(objOpp, objGroup.Id, reimbursementId, 'Delayed PTO - Sixth payment');
        
        if(objOpp.Installation_Complete_Date__c.addDays(45) == Date.today() 
            || objOpp.Installation_Complete_Date__c.addDays(75) == Date.today()
            || objOpp.Installation_Complete_Date__c.addDays(105) == Date.today())
        {
            if(String.isNotBlank(objOpp.COntact__r.Email)){
                lstSingleEmail.add(getSingleEmail(objTemplate.Id, objOrgWideAddress.Id, objOpp));
            }
        }
        try{
            if(!lstMessageRequest.isEmpty())
                simplesms.Invocable_SendMessage.sendMessage(lstMessageRequest);
        } catch(Exception e){}
        
        if(!lstSingleEmail.isEmpty())
            Messaging.sendEmail(lstSingleEmail);
        if(objCase != null)
            insert objCase;
    }
    
    private Messaging.SingleEmailMessage getSingleEmail(Id templateId, Id orgWideId, Opportunity objOpp){
        Messaging.SingleEmailMessage objSingleEmail = new Messaging.SingleEmailMessage();
        objSingleEmail.setTemplateId(templateId);
        objSingleEmail.setTargetObjectId(objOpp.Contact__c);
        objSingleEmail.setWhatId(objOpp.Id);
        objSingleEmail.setOrgWideEmailAddressId(orgWideId);
        
        return objSingleEmail;
    }
    
    private simplesms.Invocable_SendMessage.SendMessageRequest getMessageRequest(Opportunity objOpp, String templateCode){
        simplesms.Invocable_SendMessage.SendMessageRequest objMessageRequest = new simplesms.Invocable_SendMessage.SendMessageRequest();
        objMessageRequest.fromNumber = '8437018055';
        objMessageRequest.parentId = objOpp.Id;
        objMessageRequest.ownerId = '0052L000003HoWsQAK';
        objMessageRequest.toNumber = objOpp.Phone_Textey__c;
        objMessageRequest.templateCode = templateCode;
        
        return objMessageRequest;
    }
    
    private Case getCaseData(Opportunity objOpp, Id ownerId, Id reimbursementId, String subject){
        Case objCase = new Case();
        objCase.AccountId = objOpp.AccountId;
        objCase.Check_Request_Date__c = Date.today();
        objCase.CaseType__c = 'Sales Op';
        objCase.Company_Cost__c = 'Yes';
        objCase.ContactId = objOpp.Contact__c;
        objCase.Opportunity__c = objOpp.Id;
        objCase.OwnerID = ownerId;
        objCase.Reason_1__c = 'PTO Delay';
        objCase.RecordTypeId = reimbursementId;
        objCase.Status = 'New';
        objCase.Subject = subject;
        objCase.Type__c = 'Delays/Extended Timelines';

        return objCase;
    }
    
    global void finish(Database.BatchableContext context) {
        
    }
}