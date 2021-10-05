global class BatchToUpdateProjectMilestoneV2 implements Database.Batchable<SObject>
{   
    String oppId;
    global BatchToUpdateProjectMilestoneV2(String oppId){
        this.oppId = oppId;
    }

    /*****************Batchable Interface Methods*****************/
    global Database.QueryLocator start(Database.BatchableContext context) {
        String query = System.Label.Project_Milestone_Query_3;
        if(String.isNotBlank(oppId)){
            query += ' AND Opportunity__c =: oppId';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext context, List<Project_Milestone__c> lstProjectMilestone) {
        Project_Milestone__c objProjectMilestone = lstProjectMilestone[0];
        if(objProjectMilestone.Opportunity__c != null){
            Boolean updateMilestone = false;
            if(objProjectMilestone.Site_Survey_Completed_Milestone__c == null 
                && objProjectMilestone.Survey_Complete_Confirmed__c != null)
            {
                objProjectMilestone.Site_Survey_Completed_Milestone__c = objProjectMilestone.Survey_Complete_Confirmed__c;
                updateMilestone = true;
            }
            
            if(objProjectMilestone.Energy_Usage_Verification_Milestone__c == null 
                && objProjectMilestone.Energy_Bill_checked__c != null)
            {
                objProjectMilestone.Energy_Usage_Verification_Milestone__c = objProjectMilestone.Energy_Bill_checked__c;
                updateMilestone = true;
            }
            
            if(objProjectMilestone.Contract_Received_Confirmed_Milestone__c == null 
                && objProjectMilestone.Contract_Received_Milestone__c != null)
            {
                objProjectMilestone.Contract_Received_Confirmed_Milestone__c = objProjectMilestone.Contract_Received_Milestone__c;
                updateMilestone = true;
            }
            
            Set<Id> setJobId = new Set<Id>();
            Map<String, Job__c> mapRecordTypeNameToJob = new Map<String, Job__c>();
            for(Job__c objJob : [
                    SELECT Id, RecordType.DeveloperName
                    FROM Job__c 
                    WHERE Opportunity__c = :objProjectMilestone.Opportunity__c
                    AND RecordType.DeveloperName = 'Financing'])
            {
                setJobId.add(objJob.Id);
                mapRecordTypeNameToJob.put(objJob.RecordType.DeveloperName, objJob);
            }
            
            if(!setJobId.isEmpty()){
                Map<Id, List<Job__History>> mapJobIdToLstFlowStatusHistory = new Map<Id, List<Job__History>>();
                Set<String> setUniqueCombo = new Set<String>();
                for(Job__History objJobHistory : [
                        SELECT Id, ParentId, CreatedDate, Field, OldValue, NewValue 
                        FROM Job__History 
                        WHERE Field = 'Flow_Status__c'
                        AND ParentId IN :setJobId
                        ORDER By Createddate])
                {
                    String uniqueCombo = objJobHistory.ParentId + '::' + objJobHistory.NewValue;
                    
                    if(!setUniqueCombo.contains(uniqueCombo)){
                        if(mapJobIdToLstFlowStatusHistory.containsKey(objJobHistory.ParentId)){
                            mapJobIdToLstFlowStatusHistory.get(objJobHistory.ParentId).add(objJobHistory);
                        } else{
                            mapJobIdToLstFlowStatusHistory.put(objJobHistory.ParentId, new List<Job__History>{objJobHistory});        
                        }
                        
                        setUniqueCombo.add(uniqueCombo);
                    }
                }
                
                if(objProjectMilestone.Lease_Loan_M1_Approval_Milestone__c == null){
                    if(mapRecordTypeNameToJob.get('Financing') != null){
                        Job__c objFinancingJob = mapRecordTypeNameToJob.get('Financing');
                        if(mapJobIdToLstFlowStatusHistory.get(objFinancingJob.Id) != null){
                            Datetime milestoneVal;
                            for(Job__History objJobHistory : mapJobIdToLstFlowStatusHistory.get(objFinancingJob.Id)){
                                if(objJobHistory.NewValue == 'M1 - Approved'){
                                    milestoneVal = objJobHistory.CreatedDate;
                                    break;
                                }
                            }   
                            
                            if(objFinancingJob != null){
                                objProjectMilestone.Lease_Loan_M1_Approval_Milestone__c = milestoneVal;
                                updateMilestone = true;
                            }                     
                        }
                    }
                }
            }
            
            if(updateMilestone){
                update objProjectMilestone;
            }
        }
    }
    
    global void finish(Database.BatchableContext context) {
        
    }
}