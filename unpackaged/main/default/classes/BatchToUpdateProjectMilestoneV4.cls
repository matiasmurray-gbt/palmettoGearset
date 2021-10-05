global class BatchToUpdateProjectMilestoneV4 implements Database.Batchable<SObject>
{   
    String oppId;
    global BatchToUpdateProjectMilestoneV4(String oppId){
        this.oppId = oppId;
    }

    /*****************Batchable Interface Methods*****************/
    global Database.QueryLocator start(Database.BatchableContext context) {
        String query = System.Label.Project_Milestone_V5;
        if(String.isNotBlank(oppId)){
            query += ' AND Opportunity__c =: oppId';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext context, List<Project_Milestone__c> lstProjectMilestone) {
        Project_Milestone__c objProjectMilestone = lstProjectMilestone[0];
        if(objProjectMilestone.Opportunity__c != null){
            Boolean updateMilestone = false;
            List<Job__c> lstJob = new List<Job__c>();
            Map<String, Job__c> mapRecordTypeNameToJob = new Map<String, Job__c>();
            for(Job__c objJob : [
                    SELECT Id, Flow_Status__c, CreatedDate
                    FROM Job__c 
                    WHERE Opportunity__c = :objProjectMilestone.Opportunity__c
                    AND RecordType.DeveloperName = 'Interconnection'])
            {
                lstJob.add(objJob);
                objProjectMilestone.Interconnection_Process_Initiated__c = objJob.CreatedDate;
                updateMilestone = true;
            }
            
            if(!lstJob.isEmpty()){
                Id jobId = lstJob[0].Id;
                Map<Id, List<Job__History>> mapJobIdToLstFlowStatusHistory = new Map<Id, List<Job__History>>();
                Set<String> setUniqueCombo = new Set<String>();
                for(Job__History objJobHistory : [
                        SELECT Id, ParentId, CreatedDate, Field, OldValue, NewValue 
                        FROM Job__History 
                        WHERE Field = 'Flow_Status__c'
                        AND ParentId = :jobId
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
                                
                if(objProjectMilestone.Interconnection_Application_Submitted__c == null){
                    if(mapJobIdToLstFlowStatusHistory.get(jobId) != null){
                        Datetime milestoneVal;
                        for(Job__History objJobHistory : mapJobIdToLstFlowStatusHistory.get(jobId)){
                            if(objJobHistory.NewValue == 'Submitted'){
                                milestoneVal = objJobHistory.CreatedDate;
                                break;
                            }
                        }   
                        
                        if(milestoneVal != null){
                            objProjectMilestone.Interconnection_Application_Submitted__c = milestoneVal;
                            updateMilestone = true;
                        }                     
                    }
                }
                
                if(objProjectMilestone.Interconnection_Application_Approved__c == null){
                    if(mapJobIdToLstFlowStatusHistory.get(jobId) != null){
                        Datetime milestoneVal;
                        for(Job__History objJobHistory : mapJobIdToLstFlowStatusHistory.get(jobId)){
                            if(objJobHistory.NewValue == 'Interconnection Approved'){
                                milestoneVal = objJobHistory.CreatedDate;
                                break;
                            }
                        }   
                        
                        if(milestoneVal != null){
                            objProjectMilestone.Interconnection_Application_Approved__c = milestoneVal;
                            updateMilestone = true;
                        }                     
                    }
                }
                
                if(objProjectMilestone.Net_Metering_Application_Approved__c == null){
                    if(mapJobIdToLstFlowStatusHistory.get(jobId) != null){
                        Datetime milestoneVal;
                        for(Job__History objJobHistory : mapJobIdToLstFlowStatusHistory.get(jobId)){
                            if(objJobHistory.NewValue == 'Net Metering Approved'){
                                milestoneVal = objJobHistory.CreatedDate;
                                break;
                            }
                        }   
                        
                        if(milestoneVal != null){
                            objProjectMilestone.Net_Metering_Application_Approved__c = milestoneVal;
                            updateMilestone = true;
                        }                     
                    }
                }
                
                if(objProjectMilestone.Utility_Approval_for_Installation__c == null){
                    if(mapJobIdToLstFlowStatusHistory.get(jobId) != null){
                        Datetime milestoneVal;
                        for(Job__History objJobHistory : mapJobIdToLstFlowStatusHistory.get(jobId)){
                            if(objJobHistory.NewValue == 'Utility Approval for Install'){
                                milestoneVal = objJobHistory.CreatedDate;
                                break;
                            }
                        }   
                        
                        if(milestoneVal != null){
                            objProjectMilestone.Utility_Approval_for_Installation__c = milestoneVal;
                            updateMilestone = true;
                        }                     
                    }
                }
                
               
                if(updateMilestone){
                    update objProjectMilestone;
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext context) {
        
    }
}