global class PopulateChannelPartner implements Database.Batchable<SObject> {
    /*****************Batchable Interface Methods*****************/
    global Database.QueryLocator start(Database.BatchableContext context) {
        //String query = 'SELECT Id, Opp_Primary_Contact__r.AccountId from Opportunity '; 
        //query += 'where Channel_Partner__c = null AND Opp_Primary_Contact__r.AccountId != null';
        String query = Label.OppQuery;
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext context, List<Opportunity> lstOpportunity) {
        for(Opportunity objOpp : lstOpportunity){
            objOpp.Channel_Partner__c = objOpp.Opp_Primary_Contact__r.AccountId;
        }
        
        if(!lstOpportunity.isEmpty())
            Database.update(lstOpportunity, false);
    }
    
    global void finish(Database.BatchableContext context) {}
}