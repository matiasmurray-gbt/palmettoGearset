global class BatchToUpdateProjectMilestone implements Database.Batchable<SObject>
{   
    String oppId;
    global BatchToUpdateProjectMilestone(String oppId){
        this.oppId = oppId;
    }

    /*****************Batchable Interface Methods*****************/
    global Database.QueryLocator start(Database.BatchableContext context) {
        String query = System.Label.Project_Milestone_Query_2;
        if(String.isNotBlank(oppId)){
            query += ' WHERE Opportunity__c =: oppId';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext context, List<Project_Milestone__c> lstProjectMilestone) {
        Project_Milestone__c objProjectMilestone = lstProjectMilestone[0];
        if(objProjectMilestone.Opportunity__c != null){
            Set<Id> setJobId = new Set<Id>();
            Map<String, Job__c> mapRecordTypeNameToJob = new Map<String, Job__c>();
            for(Job__c objJob : [
                    SELECT Id, Flow_Status__c, Installation_Start_Date__c, RecordType.DeveloperName, 
                    CreatedDate, Usage_Verification_Complete__c
                    FROM Job__c 
                    WHERE Opportunity__c = :objProjectMilestone.Opportunity__c])
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
                /*
                Map<Id, Job__History> mapJobIdToInstallationHistory = new Map<Id, Job__History>();
                for(Job__History objJobHistory : [
                        SELECT Id, ParentId, CreatedDate, Field, OldValue, NewValue 
                        FROM Job__History 
                        WHERE Field = 'Installation_Start_Date__c'
                        AND ParentId IN :setJobId 
                        ORDER BY CreatedDate desc])
                {
                    if(objProjectMilestone.Opportunity__r.Installation_Complete_Date__c == null){
                        mapJobIdToInstallationHistory.put(objJobHistory.ParentId, objJobHistory);    
                        break;
                    } else if(objProjectMilestone.Opportunity__r.Installation_Complete_Date__c >= objJobHistory.CreatedDate){
                        mapJobIdToInstallationHistory.put(objJobHistory.ParentId, objJobHistory);    
                        break;
                    }
                }*/
                
                //Code to populate the milestone fields.
                Boolean updateMilestone = false;
                if(objProjectMilestone.Contract_Signed_Milestone__c == null){
                    if(mapRecordTypeNameToJob.get('Business_Processing') != null){
                        Job__c objContractProcessingJob = mapRecordTypeNameToJob.get('Business_Processing');
                        objProjectMilestone.Contract_Signed_Milestone__c = objContractProcessingJob.CreatedDate;
                        updateMilestone = true;
                    }
                }
                
                if(objProjectMilestone.Contract_Received_Milestone__c == null){
                    if(mapRecordTypeNameToJob.get('Business_Processing') != null){
                        Job__c objContractProcessingJob = mapRecordTypeNameToJob.get('Business_Processing');
                        if(mapJobIdToLstFlowStatusHistory.get(objContractProcessingJob.Id) != null){
                            Datetime receivedMilestoneVal;
                            for(Job__History objJobHistory : mapJobIdToLstFlowStatusHistory.get(objContractProcessingJob.Id)){
                                if(objJobHistory.NewValue == 'Contract Processing Completed'){
                                    receivedMilestoneVal = objJobHistory.CreatedDate;
                                    break;
                                }
                            }   
                            
                            if(receivedMilestoneVal != null){
                                objProjectMilestone.Contract_Received_Milestone__c = receivedMilestoneVal;
                                updateMilestone = true;
                            }                     
                        }
                    }
                }
                
                if(objProjectMilestone.Survey_Complete_Confirmed__c == null){
                    if(mapRecordTypeNameToJob.get('SiteSurvey') != null){
                        Job__c objSiteSurveyJob = mapRecordTypeNameToJob.get('SiteSurvey');
                        if(mapJobIdToLstFlowStatusHistory.get(objSiteSurveyJob.Id) != null){
                            Datetime milestoneVal;
                            for(Job__History objJobHistory : mapJobIdToLstFlowStatusHistory.get(objSiteSurveyJob.Id)){
                                if(objJobHistory.NewValue == 'Survey Complete - Confirmed'){
                                    milestoneVal = objJobHistory.CreatedDate;
                                    break;
                                }
                            }   
                            
                            if(milestoneVal != null){
                                objProjectMilestone.Survey_Complete_Confirmed__c = milestoneVal;
                                updateMilestone = true;
                            }                     
                        }
                    }
                }
                
                if(objProjectMilestone.Energy_Bill_checked__c == null){
                    if(mapRecordTypeNameToJob.get('Document_Verification') != null){
                        Job__c objDocVerificationJob = mapRecordTypeNameToJob.get('Document_Verification');
                        objProjectMilestone.Energy_Bill_checked__c = objDocVerificationJob.Usage_Verification_Complete__c;
                        updateMilestone = true;
                    }
                }
                
                
                if(objProjectMilestone.Design_Completed_Milestone__c == null){
                    if(mapRecordTypeNameToJob.get('Design') != null){
                        Job__c objSiteApprovalJob = mapRecordTypeNameToJob.get('Design');
                        if(mapJobIdToLstFlowStatusHistory.get(objSiteApprovalJob.Id) != null){
                            Datetime milestoneVal;
                            for(Job__History objJobHistory : mapJobIdToLstFlowStatusHistory.get(objSiteApprovalJob.Id)){
                                if(objJobHistory.NewValue == 'Site Approved'){
                                    milestoneVal = objJobHistory.CreatedDate;
                                    break;
                                }
                            }   
                            
                            if(milestoneVal != null){
                                objProjectMilestone.Design_Completed_Milestone__c = milestoneVal;
                                updateMilestone = true;
                            }                     
                        }
                    }
                }
                
                if(objProjectMilestone.Permit_Submitted_Milestone__c == null){
                    if(mapRecordTypeNameToJob.get('Permitting') != null){
                        Job__c objPermittingJob = mapRecordTypeNameToJob.get('Permitting');
                        if(mapJobIdToLstFlowStatusHistory.get(objPermittingJob.Id) != null){
                            Datetime milestoneVal;
                            for(Job__History objJobHistory : mapJobIdToLstFlowStatusHistory.get(objPermittingJob.Id)){
                                if(objJobHistory.NewValue == 'Permit Submitted'){
                                    milestoneVal = objJobHistory.CreatedDate;
                                    break;
                                }
                            }   
                            
                            if(milestoneVal != null){
                                objProjectMilestone.Permit_Submitted_Milestone__c = milestoneVal;
                                updateMilestone = true;
                            }                     
                        }
                    }
                }
                
                if(objProjectMilestone.Permit_Received_Milestone__c == null){
                    if(mapRecordTypeNameToJob.get('Permitting') != null){
                        Job__c objPermittingJob = mapRecordTypeNameToJob.get('Permitting');
                        if(mapJobIdToLstFlowStatusHistory.get(objPermittingJob.Id) != null){
                            Datetime milestoneVal;
                            for(Job__History objJobHistory : mapJobIdToLstFlowStatusHistory.get(objPermittingJob.Id)){
                                if(objJobHistory.NewValue == 'Permit Received' || objJobHistory.NewValue == 'Permit Received, Pending Issuance'){
                                    milestoneVal = objJobHistory.CreatedDate;
                                    break;
                                }
                            }   
                            
                            if(milestoneVal != null){
                                objProjectMilestone.Permit_Received_Milestone__c = milestoneVal;
                                updateMilestone = true;
                            }                     
                        }
                    }
                }
                
                
                if(objProjectMilestone.Installation_Ready_Milestone__c == null){
                    if(mapRecordTypeNameToJob.get('Installation_Scheduling') != null){
                        Job__c objInstallationSchedulingJob = mapRecordTypeNameToJob.get('Installation_Scheduling');
                        if(mapJobIdToLstFlowStatusHistory.get(objInstallationSchedulingJob.Id) != null){
                            Datetime milestoneVal;
                            for(Job__History objJobHistory : mapJobIdToLstFlowStatusHistory.get(objInstallationSchedulingJob.Id)){
                                if(objJobHistory.NewValue == 'New- Pending Scheduling'){
                                    milestoneVal = objJobHistory.CreatedDate;
                                    break;
                                }
                            }   
                            
                            if(milestoneVal != null){
                                objProjectMilestone.Installation_Ready_Milestone__c = milestoneVal;
                                updateMilestone = true;
                            }                     
                        }
                    }
                }
                
                if(objProjectMilestone.Installation_Scheduled_Milestone__c == null){
                    if(mapRecordTypeNameToJob.get('Installation_Scheduling') != null){
                        Job__c objInstallationSchedulingJob = mapRecordTypeNameToJob.get('Installation_Scheduling');
                        if(mapJobIdToLstFlowStatusHistory.get(objInstallationSchedulingJob.Id) != null){
                            Datetime milestoneVal;
                            for(Job__History objJobHistory : mapJobIdToLstFlowStatusHistory.get(objInstallationSchedulingJob.Id)){
                                if(objJobHistory.NewValue == 'Installation Scheduled'){
                                    milestoneVal = objJobHistory.CreatedDate;
                                    break;
                                }
                            }   
                            
                            if(milestoneVal != null){
                                objProjectMilestone.Installation_Scheduled_Milestone__c = milestoneVal;
                                updateMilestone = true;
                            }                     
                        }
                    }
                }
                
                if(objProjectMilestone.Installation_Completed_Milestone__c == null){
                    if(mapRecordTypeNameToJob.get('Installation_Scheduling') != null){
                        Job__c objInstallationSchedulingJob = mapRecordTypeNameToJob.get('Installation_Scheduling');
                        if(mapJobIdToLstFlowStatusHistory.get(objInstallationSchedulingJob.Id) != null){
                            Datetime milestoneVal;
                            for(Job__History objJobHistory : mapJobIdToLstFlowStatusHistory.get(objInstallationSchedulingJob.Id)){
                                if(objJobHistory.NewValue == 'Installation Complete'){
                                    milestoneVal = objJobHistory.CreatedDate;
                                    break;
                                }
                            }   
                            
                            if(milestoneVal != null){
                                objProjectMilestone.Installation_Completed_Milestone__c = milestoneVal;
                                updateMilestone = true;
                            }                     
                        }
                    }
                }
                
                if(objProjectMilestone.Inspection_Scheduled_Milestone__c == null){
                    if(mapRecordTypeNameToJob.get('Inspection') != null){
                        Job__c objInspectionJob = mapRecordTypeNameToJob.get('Inspection');
                        if(mapJobIdToLstFlowStatusHistory.get(objInspectionJob.Id) != null){
                            Datetime milestoneVal;
                            for(Job__History objJobHistory : mapJobIdToLstFlowStatusHistory.get(objInspectionJob.Id)){
                                if(objJobHistory.NewValue == 'Inspection Scheduled'){
                                    milestoneVal = objJobHistory.CreatedDate;
                                    break;
                                }
                            }   
                            
                            if(milestoneVal != null){
                                objProjectMilestone.Inspection_Scheduled_Milestone__c = milestoneVal;
                                updateMilestone = true;
                            }                     
                        }
                    }
                }
                
                if(objProjectMilestone.Inspection_Complete_Milestone__c == null){
                    if(mapRecordTypeNameToJob.get('Inspection') != null){
                        Job__c objInspectionJob = mapRecordTypeNameToJob.get('Inspection');
                        if(mapJobIdToLstFlowStatusHistory.get(objInspectionJob.Id) != null){
                            Datetime milestoneVal;
                            for(Job__History objJobHistory : mapJobIdToLstFlowStatusHistory.get(objInspectionJob.Id)){
                                if(objJobHistory.NewValue == 'Inspection Complete'){
                                    milestoneVal = objJobHistory.CreatedDate;
                                    break;
                                }
                            }   
                            
                            if(milestoneVal != null){
                                objProjectMilestone.Inspection_Complete_Milestone__c = milestoneVal;
                                updateMilestone = true;
                            }                     
                        }
                    }
                }
                
                if(objProjectMilestone.PTO_Submitted_Milestone__c == null){
                    if(mapRecordTypeNameToJob.get('PTO') != null){
                        Job__c objPTOJob = mapRecordTypeNameToJob.get('PTO');
                        if(mapJobIdToLstFlowStatusHistory.get(objPTOJob.Id) != null){
                            Datetime milestoneVal;
                            for(Job__History objJobHistory : mapJobIdToLstFlowStatusHistory.get(objPTOJob.Id)){
                                if(objJobHistory.NewValue == 'Submitted'){
                                    milestoneVal = objJobHistory.CreatedDate;
                                    break;
                                }
                            }   
                            
                            if(milestoneVal != null){
                                objProjectMilestone.PTO_Submitted_Milestone__c = milestoneVal;
                                updateMilestone = true;
                            }                     
                        }
                    }
                }
                
                if(objProjectMilestone.PTO_Complete_Milestone__c == null){
                    if(mapRecordTypeNameToJob.get('PTO') != null){
                        Job__c objPTOJob = mapRecordTypeNameToJob.get('PTO');
                        if(mapJobIdToLstFlowStatusHistory.get(objPTOJob.Id) != null){
                            Datetime milestoneVal;
                            for(Job__History objJobHistory : mapJobIdToLstFlowStatusHistory.get(objPTOJob.Id)){
                                if(objJobHistory.NewValue == 'PTO Granted'){
                                    milestoneVal = objJobHistory.CreatedDate;
                                    break;
                                }
                            }   
                            
                            if(milestoneVal != null){
                                objProjectMilestone.PTO_Complete_Milestone__c = milestoneVal;
                                updateMilestone = true;
                            }                     
                        }
                    }
                }
                
                if(objProjectMilestone.Installation_Started_Milestone__c == null){
                    if(mapRecordTypeNameToJob.get('Installation_Scheduling') != null){
                        Job__c objInstallationSchedulingJob = mapRecordTypeNameToJob.get('Installation_Scheduling');
                        if(objInstallationSchedulingJob != null && objInstallationSchedulingJob.Installation_Start_Date__c != null){
                            //objProjectMilestone.Installation_Started_Milestone__c = mapJobIdToInstallationHistory.get(objInstallationSchedulingJob.Id).CreatedDate;
                            objProjectMilestone.Installation_Started_Milestone__c = objInstallationSchedulingJob.Installation_Start_Date__c;
                            updateMilestone = true;     
                        }
                    }
                }
                
                List<Job__c> lstJobToUpdate = new List<Job__c>();
                if(mapRecordTypeNameToJob.get('Installation_Scheduling') != null){
                    Job__c objInstallationSchedulingJob = mapRecordTypeNameToJob.get('Installation_Scheduling');
                    objInstallationSchedulingJob.Installation_Start_Date_Observed__c = objInstallationSchedulingJob.Installation_Start_Date__c;
                    update objInstallationSchedulingJob;
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