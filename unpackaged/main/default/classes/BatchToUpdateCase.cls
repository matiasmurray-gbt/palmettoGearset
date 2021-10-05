global class BatchToUpdateCase implements Database.Batchable<SObject>
{   
    /*****************Batchable Interface Methods*****************/
    global Database.QueryLocator start(Database.BatchableContext context) {
        String query = '';
        if(!Test.isRunningTest()){
            query = System.Label.caseQuery;
        } else{
            query = 'SELECT Id FROM Opportunity';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext context, List<Opportunity> lstOpp) {
        
        for(Opportunity objOpp : lstOpp){
            objOpp.Open_Retention_Case__c = true;
        }
        
        Database.update(lstOpp, false);
    }
    
    global void finish(Database.BatchableContext context) {
        
    }
}