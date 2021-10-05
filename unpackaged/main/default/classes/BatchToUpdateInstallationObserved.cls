global class BatchToUpdateInstallationObserved implements Database.Batchable<SObject>, Schedulable
{
    global void execute(SchedulableContext sc){
        BatchToUpdateInstallationObserved objBatchToUpdateInstallationObserved = new BatchToUpdateInstallationObserved();
        Database.executeBatch(objBatchToUpdateInstallationObserved, 1);
    }
    
    /*****************Batchable Interface Methods*****************/
    global Database.QueryLocator start(Database.BatchableContext context) {
        Datetime compareDate = Datetime.now().addDays(-5);
        
        String query = 'SELECT Id, Opportunity__c, Installation_Start_Date__c, Installation_Start_Date_Observed__c FROM Job__c ';
        query += 'WHERE Opportunity__c != null AND Installation_Start_Date__c != null ';
        query += 'AND RecordType.DeveloperName = \'Installation_Scheduling\' ';
        //query += 'AND Installation_Start_Date__c > :compareDate';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext context, List<Job__c> lstJob) {
        Job__c objJob = lstJob[0];
        Boolean firstCriteria = false, secondcriteria = false;
        if(objJob.Installation_Start_Date_Observed__c == null){
            firstCriteria = true;
        }
        
        
        Boolean updateJob = false;
        if(objJob.Installation_Start_Date_Observed__c != null){
            if(objJob.Installation_Start_Date__c != Date.today().addDays(-1) && objJob.Installation_Start_Date__c > Date.today()){
                objJob.Installation_Start_Date_Observed__c = null;
                updateJob = true;
            }
        }
        
        if(objJob.Installation_Start_Date__c == Date.today() && objJob.Installation_Start_Date_Observed__c == null){
            objJob.Installation_Start_Date_Observed__c = Date.today();
            updateJob = true;
            
            if(firstCriteria){
                secondcriteria = true;
            }
        }
        
        List<Project_Milestone__c> lstProjectMilestone = [
                        SELECT Id, Installation_Started_Milestone__c 
                        FROM Project_Milestone__c
                        WHERE Opportunity__c = :objJob.Opportunity__c
                        LIMIT 1];
                        
        if(lstProjectMilestone != null && !lstProjectMilestone.isEmpty()){
            Project_Milestone__c objProjectMilestone = lstProjectMilestone[0];
            //if(objJob.Installation_Start_Date_Observed__c != null){
                objProjectMilestone.Installation_Started_Milestone__c = objJob.Installation_Start_Date_Observed__c;
                update objProjectMilestone;
            //}
        }
        
        if(secondcriteria){
            List<Job__c> lstSupplyChainJob = [
                        SELECT Id, Flow_Status__c 
                        FROM Job__c
                        WHERE RecordType.DeveloperName = 'Supply_Chain'
                        AND Opportunity__c = :objJob.Opportunity__c
                        AND Flow_Status__c != 'Materials Delivery Confirmed'
                        AND Flow_Status__c != 'Materials Delivery Exception'
                        AND Flow_Status__c != 'Fulfilled'];
                        
            if(lstSupplyChainJob != null && !lstSupplyChainJob.isEmpty()){
                lstSupplyChainJob[0].Flow_Status__c = 'Materials Delivery Confirmed';
                update lstSupplyChainJob[0];
            }
        }
        
        if(updateJob){
            update objJob;
        }
    }
    
    global void finish(Database.BatchableContext context) {
        
    }
}