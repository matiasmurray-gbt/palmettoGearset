global class BatchToUpdateProjectMilestoneV3 implements Database.Batchable<SObject>
{   
    String oppId;
    global BatchToUpdateProjectMilestoneV3(String oppId){
        this.oppId = oppId;
    }

    /*****************Batchable Interface Methods*****************/
    global Database.QueryLocator start(Database.BatchableContext context) {
        String query = System.Label.Project_Milestone_V3;
        if(String.isNotBlank(oppId)){
            query += ' AND Opportunity__c =: oppId';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext context, List<Project_Milestone__c> lstProjectMilestone) {
        Project_Milestone__c objProjectMilestone = lstProjectMilestone[0];
        if(objProjectMilestone.Opportunity__c != null){
            List<Job__c> lstInstallationJob = [SELECT Id, Installation_Start_Date__c 
                    FROM Job__c 
                    WHERE Opportunity__c = :objProjectMilestone.Opportunity__c
                    AND RecordType.DeveloperName = 'Installation_Scheduling'];
            
            String flowStatus = '';
            if(objProjectMilestone.Design_Completed_Milestone__c == null){
                flowStatus = 'Awaiting Design';
            }
            
            if(objProjectMilestone.Design_Completed_Milestone__c != null){
                if(lstInstallationJob == null || lstInstallationJob.isEmpty()){
                    flowStatus = 'Design / BOM Complete';
                } else{
                    if(lstInstallationJob[0].Installation_Start_Date__c == null){
                        flowStatus = 'Design / BOM Complete';
                    } else{
                        flowStatus = 'Start Date for Materials Delivery Committed';
                    }
                }
            }
            
        
            Id supplyChainId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Supply_Chain').getRecordTypeId();   
            
            String jobName = (String.isNotBlank(objProjectMilestone.Opportunity__r.Contact__c)?(objProjectMilestone.Opportunity__r.Contact__r.Name + ' - '):'') + 'Supply Chain';
            Job__c objJob = new Job__c();
            objJob.Name = jobName;
            objJob.RecordTypeId = supplyChainId;
            objJob.Job_Status__c = 'New';
            objJob.Opportunity__c = objProjectMilestone.Opportunity__c;
            objJob.OwnerId = (objProjectMilestone.Opportunity__r.Owner.IsActive == true?objProjectMilestone.Opportunity__r.OwnerId:Userinfo.getUserId());
            objJob.Type__c = 'PV Materials Verification';
            objJob.Flow_Status__c = flowStatus;
            objJob.Fulfillment_Method__c = objProjectMilestone.Opportunity__r.Fulfillment_Method__c;
            objJob.Materials_Direct_To_Site_Instructions__c = objProjectMilestone.Opportunity__r.Materials_Direct_To_Site_Instructions__c;
            objJob.Materials_Direct_To_Site_Confirmation__c = objProjectMilestone.Opportunity__r.Materials_Direct_To_Site_Confirmation__c;
            objJob.NetSuite_Inventory_Location__c = objProjectMilestone.Opportunity__r.NetSuite_Inventory_Location__c;
            
            insert objJob;
        }
    }
    
    global void finish(Database.BatchableContext context) {
        
    }
}