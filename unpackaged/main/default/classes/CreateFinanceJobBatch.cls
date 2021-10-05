global class CreateFinanceJobBatch implements Database.Batchable<SObject> {
    /*****************Batchable Interface Methods*****************/
    global Database.QueryLocator start(Database.BatchableContext context) {
        Date startDate = Date.newInstance(2020, 7, 1);
        String query = 'select Id, Amount, Account.celigo_sfnsio__Account_Balance__c from Opportunity '; 
        query += 'where Contract_Received_Date__c >= :startDate ';
        query += 'AND Financing_Tool__c IN (\'Loanpal\') ';
        query += 'AND SA_Approved__c = false ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext context, List<Opportunity> lstOpportunity) {
        List<Job__c> lstJobToInsert = new List<Job__c>();
        
        Id financingId = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Financing').getRecordTypeId();
        Group objGroup = [select Id from Group where Name = 'FinOps' and type = 'Queue'];
        for(Opportunity objOpportunity : lstOpportunity){
            Job__c objJob = new Job__c();
            objJob.Name = 'Financial Operations (FinOps) Job';
            objJob.RecordTypeId = financingId;
            objJob.Opportunity__c = objOpportunity.Id;
            objJob.OwnerId = objGroup.Id;
            objJob.Type__c = 'Loan except Sunnova';
            //objJob.Amount__c = objOpportunity.Amount;
            objJob.Account_Balance__c = objOpportunity.Account.celigo_sfnsio__Account_Balance__c;

            lstJobToInsert.add(objJob);
        }

        if(!lstJobToInsert.isEmpty())
            insert lstJobToInsert;
    }
    
    global void finish(Database.BatchableContext context) {}
}