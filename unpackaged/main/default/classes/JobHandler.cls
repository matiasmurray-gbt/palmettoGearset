public class JobHandler
{
    static Boolean manualChange = true;
    //This method is called on before insert event of trigger.
    public void onBeforeInsert(List<Job__c> lstJob){
        populateJobFields(lstJob);
        populateJobStatus(lstJob);
        populateContractReceived(lstJob);
        populateDocumentVerification(lstJob);
        populateSeconadryInspection(lstJob);
        preventSiteApprovalJob(lstJob);
        preventPermittingJob(lstJob);
        captureInstallationStartDate(lstJob);
        populateInterconnectionDatesFromFlowStatus(lstJob, null);
    }
    //This method is called on after update event of trigger.
    public void onAfterUpdate(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        //updateAppNumber(lstJob, mapIdToOldJob);
        //createJobRecord(lstJob, mapIdToOldJob);
        updateDocumentationNotes(lstJob, mapIdToOldJob);
        closeJCOJob(lstJob, mapIdToOldJob);
        rejectJCOJob(lstJob, mapIdToOldJob);
        changeFlowStatusOnFinOps(lstJob, mapIdToOldJob);
        changeFlowStatusOnFinOpsFromDV(lstJob, mapIdToOldJob);
        updateOppData(lstJob, mapIdToOldJob);
        updateOppStage(lstJob, mapIdToOldJob);
        updateSurveyCompleteMilestone(lstJob, mapIdToOldJob);
        updateEnergyBillMilestone(lstJob, mapIdToOldJob);
        updateDesignCompletedMilestone(lstJob, mapIdToOldJob);
        updatePermittingMilestone(lstJob, mapIdToOldJob);
        //createPTOJob(lstJob, mapIdToOldJob);
        updateInspectionMilestone(lstJob, mapIdToOldJob);
        updatePTOMilestone(lstJob, mapIdToOldJob);
        updateInstallationMilestone(lstJob, mapIdToOldJob);
        updateFieldsonOpp(lstJob, mapIdToOldJob);
        updateFlowStatusOnSupplyChain(lstJob, mapIdToOldJob);
        updateFlowStatusOnSupplyChain2(lstJob, mapIdToOldJob);
        updateFlowStatusOnSupplyChain3(lstJob, mapIdToOldJob);
        updateFinancingMilestone(lstJob, mapIdToOldJob);
        updateNoticeToProceedMilestone(lstJob, mapIdToOldJob);
        runNetsuiteTrigger();
        updateInterconnectionMilestones(lstJob, mapIdToOldJob);
        updateBuildPartner(lstJob, mapIdToOldJob);
        updateDocumentVerificationMilestone(lstJob, mapIdToOldJob);
        populateMilestoneQCFields(lstJob, mapIdToOldJob);
        createInterconnectionJob(lstJob, mapIdToOldJob);
        populateContractReceivedConfirmedMilestone(lstJob, mapIdToOldJob);
    }
    //This method is called on after insert event of trigger.
    public void onAfterInsert(List<Job__c> lstJob){
        //createJobRecord(lstJob, null);
        updateOppStage(lstJob, null);
        updateContractSignedMilestone(lstJob);
        updateSurveyCompleteMilestone(lstJob, null);
        updateEnergyBillMilestone(lstJob, null);
        updateDesignCompletedMilestone(lstJob, null);
        updatePermittingMilestone(lstJob, null);
        updateInspectionMilestone(lstJob, null);
        updatePTOMilestone(lstJob, null);
        updateInstallationMilestone(lstJob, null);
        linkBOMs(lstJob);
        updateFlowStatusOnSupplyChain(lstJob, null);
        updateFlowStatusOnSupplyChain2(lstJob, null);
        updateFinancingMilestone(lstJob, null);
        updateNoticeToProceedMilestone(lstJob, null);
        runNetsuiteTrigger();
        updateInterconnectionMilestones(lstJob, null);
        sendJobAssignmentData(lstJob, null);
        populateContractReceivedConfirmedMilestone(lstJob, null);
    }
    //This method is called on before update event of trigger.
    public void onBeforeUpdate(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        populateJobStatus(lstJob);
        populateJobAndFlowStatus(lstJob, mapIdToOldJob);
        //preventPendingFlowStatus(lstJob, mapIdToOldJob);
        preventPermitReceivedFlowStatus(lstJob, mapIdToOldJob);
        captureInstallationStartDate(lstJob);
        sendJobAssignmentData(lstJob, mapIdToOldJob);
        if(manualChange){
            preventExcpetionselection(lstJob, mapIdToOldJob);
        }
        populateInterconnectionDatesFromFlowStatus(lstJob, mapIdToOldJob);
    }
    
    private void runNetsuiteTrigger(){  
        TriggerConfiguration__c objTriggerConfigCS = TriggerConfiguration__c.getInstance('Netsuite Trigger');   
        if(objTriggerConfigCS != null && objTriggerConfigCS.Active__c == true){ 
            integrator_da__.RealTimeExportResult res = integrator_da__.RealTimeExporter.processExport();    
        }   
    }
    
    //This method is called to update build partner on opp from Installation Scheduling job
    private void updateBuildPartner(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        Id installationSchedulingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Installation_Scheduling').getRecordTypeId();    
        Map<Id, Job__c> mapOppIdToJob = new Map<Id, Job__c>();
        for(Job__c objJob : lstJob){
            if(objJob.RecordTypeId == installationSchedulingId && objJob.Opportunity__c != null) {
                Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
                if(objJob.Build_Partner__c != objOldJob.Build_Partner__c && objJob.Build_Partner__c != null){
                    mapOppIdToJob.put(objJob.Opportunity__c, objJob);
                }
            }
        }
        
        if(!mapOppIdToJob.isEmpty()){
            List<Opportunity> lstOppToUpdate = new List<Opportunity>();
            for(Opportunity objOpp : [SELECT Id, Vendor__c
                        FROM Opportunity
                        WHERE Id IN :mapOppIdToJob.keyset()])
            {
                Job__c objInstallationSchedulingJob = mapOppIdToJob.get(objOpp.Id);
                if(objInstallationSchedulingJob.Build_Partner__c != objOpp.Vendor__c){
                    objOpp.Vendor__c = objInstallationSchedulingJob.Build_Partner__c;
                    lstOppToUpdate.add(objOpp);
                }
            }
            
            if(!lstOppToUpdate.isEmpty())
                update lstOppToUpdate;
        }
    }
    
    //This method is used to update the Notice to Proceed - Milestone.
    private void updateNoticeToProceedMilestone(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        Id financingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Financing').getRecordTypeId();    
        Set<String> setFlowStatus = new Set<String>{'Notice to Proceed'};
        Set<Id> setOppId = new Set<Id>();
        
        for(Job__c objJob : lstJob){
            if(objJob.RecordTypeId == financingId && objJob.Opportunity__c != null && setFlowStatus.contains(objJob.Flow_Status__c)){
                if(mapIdToOldJob == null){
                    setOppId.add(objJob.Opportunity__c);
                } else{
                    Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
                    if(objJob.Flow_Status__c != objOldJob.Flow_Status__c){
                        setOppId.add(objJob.Opportunity__c);
                    }
                }
            }
        }
        
        if(!setOppId.isEmpty()){
            List<Project_Milestone__c> lstRadiusToUpdate = new List<Project_Milestone__c>();
            for(Opportunity objOpp : [
                    SELECT Id,
                        (SELECT Id, Lease_Loan_Notice_to_Proceed_Milestone__c
                        FROM Project_Milestones__r
                        WHERE Lease_Loan_Notice_to_Proceed_Milestone__c = null)
                    FROM Opportunity
                    WHERE Id IN :setOppId])
            {
                if(objOpp.Project_Milestones__r != null && !objOpp.Project_Milestones__r.isEmpty()){
                    for(Project_Milestone__c objRadius : objOpp.Project_Milestones__r){
                        objRadius.Lease_Loan_Notice_to_Proceed_Milestone__c = Datetime.now();
                        lstRadiusToUpdate.add(objRadius);
                    }
                }
            }
            if(!lstRadiusToUpdate.isEmpty()){
                update lstRadiusToUpdate;
            }
        }
    }
    
    //This method is used to change the flow status on Supply chain job.
    private void preventExcpetionselection(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        Id supplyChainId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Supply_Chain').getRecordTypeId();    
        for(Job__c objJob : lstJob){
            Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
            if(objJob.RecordTypeId == supplyChainId && objJob.Flow_status__c == 'Materials Delivery Exception' 
                && objOldJob.Flow_status__c != 'Materials Delivery Exception' && String.isBlank(objJob.Exception_Reason__c)) 
            {
                objJob.Exception_Reason__c.addError('Please provide Materials Delivery Exception Reason.');
            }
        }
    }
    
    //This method is used to change the flow status on Supply chain job.
    private void updateFlowStatusOnSupplyChain(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        Id installationSchedulingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Installation_Scheduling').getRecordTypeId();    
        Set<Id> setOppId = new Set<Id>();
        for(Job__c objJob : lstJob){
            if(objJob.RecordTypeId == installationSchedulingId && objJob.Opportunity__c != null && objJob.Tentative_Installation_Start_Date__c != null) {
                if(mapIdToOldJob == null || mapIdToOldJob.get(objJob.Id).Tentative_Installation_Start_Date__c == null){
                    setOppId.add(objJob.Opportunity__c);
                }
            }
        }
        
        if(!setOppId.isEmpty()){
            List<Job__c> lstJobToUpdate = new List<Job__c>();
            for(Job__c objJob : [SELECT Id, Flow_Status__c 
                    FROM Job__c 
                    WHERE RecordType.DeveloperName = 'Supply_Chain' 
                    AND Opportunity__c IN :setOppId
                    AND Flow_Status__c != 'Start Date for Bulk Materials Order Queued'])
            {
                objJob.Flow_Status__c = 'Start Date for Bulk Materials Order Queued';
                lstJobToUpdate.add(objJob);
            }
            
            if(!lstJobToUpdate.isEmpty())
                update lstJobToUpdate;
        }
    }
    
    //This method is used to change the flow status on Supply chain job.
    private void updateFlowStatusOnSupplyChain2(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        Id installationSchedulingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Installation_Scheduling').getRecordTypeId();    
        Set<Id> setOppId = new Set<Id>();
        for(Job__c objJob : lstJob){
            if(objJob.RecordTypeId == installationSchedulingId && objJob.Opportunity__c != null && objJob.Installation_Start_Date__c != null) {
                if(mapIdToOldJob == null || mapIdToOldJob.get(objJob.Id).Installation_Start_Date__c == null){
                    setOppId.add(objJob.Opportunity__c);
                }
            }
        }
        
        if(!setOppId.isEmpty()){
            List<Job__c> lstJobToUpdate = new List<Job__c>();
            for(Job__c objJob : [SELECT Id, Flow_Status__c 
                    FROM Job__c 
                    WHERE RecordType.DeveloperName = 'Supply_Chain' 
                    AND Opportunity__c IN :setOppId
                    AND Flow_Status__c != 'Materials Delivery Exception'
                    AND Flow_Status__c != 'Start Date for Materials Delivery Committed'])
            {
                objJob.Flow_Status__c = 'Start Date for Materials Delivery Committed';
                lstJobToUpdate.add(objJob);
            }
            
            if(!lstJobToUpdate.isEmpty())
                update lstJobToUpdate;
        }
    }
    
    //This method is used to change the flow status on Supply chain job.
    private void updateFlowStatusOnSupplyChain3(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        Id installationSchedulingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Installation_Scheduling').getRecordTypeId();    
        Set<Id> setOppId = new Set<Id>();
        for(Job__c objJob : lstJob){
            if(objJob.RecordTypeId == installationSchedulingId && objJob.Opportunity__c != null) {
                if(mapIdToOldJob.get(objJob.Id).Installation_Start_Date__c != objJob.Installation_Start_Date__c && mapIdToOldJob.get(objJob.Id).Installation_Start_Date__c != null){
                    setOppId.add(objJob.Opportunity__c);
                }
            }
        }
        
        if(!setOppId.isEmpty()){
            List<Job__c> lstJobToUpdate = new List<Job__c>();
            for(Job__c objJob : [SELECT Id, Flow_Status__c 
                    FROM Job__c 
                    WHERE RecordType.DeveloperName = 'Supply_Chain' 
                    AND Opportunity__c IN :setOppId
                    AND Flow_Status__c != 'Materials Delivery Exception'])
            {
                objJob.Flow_Status__c = 'Materials Delivery Exception';
                lstJobToUpdate.add(objJob);
            }
            
            try{
                manualChange = false;
                if(!lstJobToUpdate.isEmpty())
                    update lstJobToUpdate;
            } catch(DMLException e){
                lstJobToUpdate[0].addError(e.getDMLMessage(0));
            }
        }
    }
    
    //This method is called to link BOM Records with Supply chain job.
    private void linkBOMs(List<Job__c> lstJob){
        Id supplyChainId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Supply_Chain').getRecordTypeId();    
        Set<Id> setOppId = new Set<Id>();
        for(Job__c objJob : lstJob){
            if(objJob.RecordTypeId == supplyChainId && objJob.Opportunity__c != null ) {
                setOppId.add(objJob.Opportunity__c);
            }
        }
        
        if(!setOppId.isEmpty()){
            List<BOM__c> lstBOMToUpdate = new List<BOM__c>();
            for(Opportunity objOpp : [SELECT Id,
                    (SELECT Id, Supply_Chain_Job__c
                    FROM BOMs__r),
                    (SELECT Id 
                    FROM Jobs__r
                    WHERE RecordType.DeveloperName = 'Supply_Chain')
                    FROM Opportunity
                    WHERE Id IN :setOppId])
            {
                if(objOpp.BOMs__r != null && !objOpp.BOMs__r.isEmpty() && objOpp.Jobs__r != null && !objOpp.Jobs__r.isEmpty()){
                    for(BOM__c objBOM : objOpp.BOMs__r){
                        objBOM.Supply_Chain_Job__c = objOpp.Jobs__r[0].Id;
                        lstBOMToUpdate.add(objBOM);
                    }
                }
            }
            
            if(!lstBOMToUpdate.isEmpty())
                update lstBOMToUpdate;
        }
    }
    
    //This method is called to link BOM Records with Supply chain job.
    private void updateFieldsonOpp(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        Id supplyChainId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Supply_Chain').getRecordTypeId();    
        Set<String> setFieldAPI = new Set<String>();
        setFieldAPI.add('Fulfillment_Method__c');
        setFieldAPI.add('NetSuite_Inventory_Location__c');
        setFieldAPI.add('Materials_Direct_To_Site_Confirmation__c');
        setFieldAPI.add('Materials_Direct_To_Site_Instructions__c');
        
        Map<Id, Job__c> mapOppIdToJob = new Map<Id, Job__c>();
        for(Job__c objJob : lstJob){
            if(objJob.RecordTypeId == supplyChainId && objJob.Opportunity__c != null) {
                Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
                for(String fieldAPI : setFieldAPI){
                    if(objJob.get(fieldAPI) != objOldJob.get(fieldAPI)){
                        mapOppIdToJob.put(objJob.Opportunity__c, objJob);
                        break;
                    }
                }
            }
        }
        
        if(!mapOppIdToJob.isEmpty()){
            List<Opportunity> lstOppToUpdate = new List<Opportunity>();
            for(Opportunity objOpp : [SELECT Id, Materials_Direct_To_Site_Confirmation__c, Materials_Direct_To_Site_Instructions__c, 
                        NetSuite_Inventory_Location__c, Fulfillment_Method__c
                        FROM Opportunity
                        WHERE Id IN :mapOppIdToJob.keyset()])
            {
                Job__c objSupplyChainJob = mapOppIdToJob.get(objOpp.Id);
                objOpp.Materials_Direct_To_Site_Confirmation__c = objSupplyChainJob.Materials_Direct_To_Site_Confirmation__c;
                objOpp.Materials_Direct_To_Site_Instructions__c = objSupplyChainJob.Materials_Direct_To_Site_Instructions__c;
                objOpp.NetSuite_Inventory_Location__c = objSupplyChainJob.NetSuite_Inventory_Location__c;
                objOpp.Fulfillment_Method__c = objSupplyChainJob.Fulfillment_Method__c;
                lstOppToUpdate.add(objOpp);
            }
            
            if(!lstOppToUpdate.isEmpty())
                update lstOppToUpdate;
        }
    }
    
    //This method is used to capture installation start date - initial field value.
    private void captureInstallationStartDate(List<Job__c> lstJob){
        Id installationSchedulingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Installation_Scheduling').getRecordTypeId();
        for(Job__c objJob : lstJob){
            if(objJob.RecordTypeId == installationSchedulingId){
                if(objJob.Installation_Start_Date_Initial__c == null && objJob.Installation_Start_Date__c != null){
                    objJob.Installation_Start_Date_Initial__c = objJob.Installation_Start_Date__c;
                }
            }
        }
    }
    
    //This method is used to update the Interconnection milestones.
    private void updateInterconnectionMilestones(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        Id interconnectionId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Interconnection').getRecordTypeId();    
        Set<String> setFlowStatus = new Set<String>();
        setFlowStatus.add('Submitted');
        setFlowStatus.add('Interconnection Approved');
        setFlowStatus.add('Net Metering Approved');
        setFlowStatus.add('Utility Approval for Install');
        
        
        Map<Id, String> mapOppIdToAction = new Map<Id, String>();
        
        for(Job__c objJob : lstJob){
            if(objJob.RecordTypeId == interconnectionId && objJob.Opportunity__c != null)
            {
                if(mapIdToOldJob == null){
                    mapOppIdToAction.put(objJob.Opportunity__c, 'insert');
                } else{
                    if(setFlowStatus.contains(objJob.Flow_Status__c)){
                        Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
                        if(objJob.Flow_Status__c != objOldJob.Flow_Status__c){
                            mapOppIdToAction.put(objJob.Opportunity__c, 'update');
                        }
                    }
                }
            }
        }
        
        if(!mapOppIdToAction.isEmpty()){
            List<Project_Milestone__c> lstRadiusToUpdate = new List<Project_Milestone__c>();
            List<Opportunity> lstOppToUpdate = new List<Opportunity>();
            for(Opportunity objOpp : [
                    SELECT Id,
                        (SELECT Id, Utility_Approval_for_Installation__c, Net_Metering_Application_Approved__c,
                        Interconnection_Process_Initiated__c, Interconnection_Application_Submitted__c, 
                        Interconnection_Application_Approved__c
                        FROM Project_Milestones__r),
                        (SELECT Id, Flow_Status__c
                        FROM Jobs__r 
                        WHERE RecordType.DeveloperName = 'Interconnection'
                        LIMIT 1)
                    FROM Opportunity
                    WHERE Id IN :mapOppIdToAction.keyset()])
            {
                Job__c objJob = objOpp.Jobs__r[0];
                for(Project_Milestone__c objRadius : objOpp.Project_Milestones__r){
                    Boolean updateMilestone = false;
                    if(mapOppIdToAction.get(objOpp.Id) == 'insert' && objRadius.Interconnection_Process_Initiated__c == null){
                        objRadius.Interconnection_Process_Initiated__c = Datetime.now();
                        updateMilestone = true;
                    }
                    
                    if(objJob.Flow_Status__c == 'Submitted' && objRadius.Interconnection_Application_Submitted__c == null){
                        objRadius.Interconnection_Application_Submitted__c = Datetime.now();
                        updateMilestone = true;
                    } else if(objJob.Flow_Status__c == 'Interconnection Approved' && objRadius.Interconnection_Application_Approved__c == null){
                        objRadius.Interconnection_Application_Approved__c = Datetime.now();
                        updateMilestone = true;
                    } else if(objJob.Flow_Status__c == 'Net Metering Approved' && objRadius.Net_Metering_Application_Approved__c == null){
                        objRadius.Net_Metering_Application_Approved__c = Datetime.now();
                        updateMilestone = true;
                    } else if(objJob.Flow_Status__c == 'Utility Approval for Install' && objRadius.Utility_Approval_for_Installation__c == null){
                        objRadius.Utility_Approval_for_Installation__c = Datetime.now();
                        updateMilestone = true;
                    }
                    
                    if(updateMilestone){
                        lstRadiusToUpdate.add(objRadius);
                    }
                }
            }
            if(!lstRadiusToUpdate.isEmpty())
                update lstRadiusToUpdate;
        }
    }
    
    //This method is used to update the Installation milestone.
    private void updateInstallationMilestone(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        Id installationSchedulingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Installation_Scheduling').getRecordTypeId();    
        Set<String> setFlowStatus = new Set<String>{'New- Pending Scheduling', 'Installation Scheduled', 'Installation Complete'};
        Set<Id> setOppId = new Set<Id>();
        
        for(Job__c objJob : lstJob){
            if(objJob.RecordTypeId == installationSchedulingId && objJob.Opportunity__c != null 
                && setFlowStatus.contains(objJob.Flow_Status__c))
            {
                if(mapIdToOldJob == null){
                    setOppId.add(objJob.Opportunity__c);
                } else{
                    Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
                    if(objJob.Flow_Status__c != objOldJob.Flow_Status__c){
                        setOppId.add(objJob.Opportunity__c);
                    }
                }
            }
        }
        
        if(!setOppId.isEmpty()){
            System.debug('>>>>>>>'+setOppId);
            List<Project_Milestone__c> lstRadiusToUpdate = new List<Project_Milestone__c>();
            List<Opportunity> lstOppToUpdate = new List<Opportunity>();
            for(Opportunity objOpp : [
                    SELECT Id,Installation_Complete_Date__c, 
                        (SELECT Id, Installation_Ready_Milestone__c, Installation_Scheduled_Milestone__c, Installation_Completed_Milestone__c 
                        FROM Project_Milestones__r),
                        (SELECT Id, Flow_Status__c
                        FROM Jobs__r 
                        WHERE RecordType.DeveloperName = 'Installation_Scheduling'
                        AND Flow_Status__c IN :setFlowStatus
                        LIMIT 1)
                    FROM Opportunity
                    WHERE Id IN :setOppId])
            {
                Job__c objJob = objOpp.Jobs__r[0];
                for(Project_Milestone__c objRadius : objOpp.Project_Milestones__r){
                    if(objJob.Flow_Status__c == 'New- Pending Scheduling' && objRadius.Installation_Ready_Milestone__c == null){
                        objRadius.Installation_Ready_Milestone__c = Datetime.now();
                        lstRadiusToUpdate.add(objRadius);
                    } else if(objJob.Flow_Status__c == 'Installation Scheduled' && objRadius.Installation_Scheduled_Milestone__c == null){
                        objRadius.Installation_Scheduled_Milestone__c = Datetime.now();
                        lstRadiusToUpdate.add(objRadius);
                    } else if(objJob.Flow_Status__c == 'Installation Complete' && objRadius.Installation_Completed_Milestone__c == null && objOpp.Installation_Complete_Date__c == null){
                        objRadius.Installation_Completed_Milestone__c = Datetime.now();
                        lstRadiusToUpdate.add(objRadius);
                        
                        objOpp.Installation_Complete_Date__c = Date.today();
                        objOpp.Installation_Complete__c = true;
                        lstOppToUpdate.add(objOpp);
                    }
                }
            }
            if(!lstRadiusToUpdate.isEmpty())
                update lstRadiusToUpdate;
            if(!lstOppToUpdate.isEmpty())
                update lstOppToUpdate;
        }
    }
    
    //This method is used to update the PTO milestone.
    private void updatePTOMilestone(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        Id ptoId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('PTO').getRecordTypeId();    
        Set<String> setFlowStatus = new Set<String>{'Submitted', 'PTO Granted'};
        Set<Id> setOppId = new Set<Id>();
        
        for(Job__c objJob : lstJob){
            if(objJob.RecordTypeId == ptoId && objJob.Opportunity__c != null && setFlowStatus.contains(objJob.Flow_Status__c)){
                if(mapIdToOldJob == null){
                    setOppId.add(objJob.Opportunity__c);
                } else{
                    Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
                    if(objJob.Flow_Status__c != objOldJob.Flow_Status__c){
                        setOppId.add(objJob.Opportunity__c);
                    }
                }
            }
        }
        
        if(!setOppId.isEmpty()){
            List<Project_Milestone__c> lstRadiusToUpdate = new List<Project_Milestone__c>();
            for(Opportunity objOpp : [
                    SELECT Id,
                        (SELECT Id, PTO_Submitted_Milestone__c, PTO_Complete_Milestone__c 
                        FROM Project_Milestones__r),
                        (SELECT Id, Flow_Status__c
                        FROM Jobs__r 
                        WHERE RecordType.DeveloperName = 'PTO'
                        AND Flow_Status__c IN :setFlowStatus
                        LIMIT 1)
                    FROM Opportunity
                    WHERE Id IN :setOppId])
            {
                Job__c objJob = objOpp.Jobs__r[0];
                if(objJob.Flow_Status__c == 'Submitted'){
                    for(Project_Milestone__c objRadius : objOpp.Project_Milestones__r){
                        if(objRadius.PTO_Submitted_Milestone__c == null){
                            objRadius.PTO_Submitted_Milestone__c = Datetime.now();
                            lstRadiusToUpdate.add(objRadius);
                        }
                    }
                } else if(objJob.Flow_Status__c == 'PTO Granted'){
                    for(Project_Milestone__c objRadius : objOpp.Project_Milestones__r){
                        if(objRadius.PTO_Complete_Milestone__c == null){
                            objRadius.PTO_Complete_Milestone__c = Datetime.now();
                            lstRadiusToUpdate.add(objRadius);
                        }
                    }
                }
            }
            if(!lstRadiusToUpdate.isEmpty()){
                update lstRadiusToUpdate;
            }
        }
    }
    
    //This method is used to update the Lease/Loan M1 Approval - Milestone.
    private void updateFinancingMilestone(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        Id financingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Financing').getRecordTypeId();    
        Set<String> setFlowStatus = new Set<String>{'M1 - Approved'};
        Set<Id> setOppId = new Set<Id>();
        
        for(Job__c objJob : lstJob){
            if(objJob.RecordTypeId == financingId && objJob.Opportunity__c != null && setFlowStatus.contains(objJob.Flow_Status__c)){
                if(mapIdToOldJob == null){
                    setOppId.add(objJob.Opportunity__c);
                } else{
                    Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
                    if(objJob.Flow_Status__c != objOldJob.Flow_Status__c){
                        setOppId.add(objJob.Opportunity__c);
                    }
                }
            }
        }
        
        if(!setOppId.isEmpty()){
            List<Project_Milestone__c> lstRadiusToUpdate = new List<Project_Milestone__c>();
            for(Opportunity objOpp : [
                    SELECT Id,
                        (SELECT Id, Lease_Loan_M1_Approval_Milestone__c
                        FROM Project_Milestones__r)
                    FROM Opportunity
                    WHERE Id IN :setOppId])
            {
                for(Project_Milestone__c objRadius : objOpp.Project_Milestones__r){
                    if(objRadius.Lease_Loan_M1_Approval_Milestone__c == null){
                        objRadius.Lease_Loan_M1_Approval_Milestone__c = Datetime.now();
                        lstRadiusToUpdate.add(objRadius);
                    }
                }
            }
            if(!lstRadiusToUpdate.isEmpty()){
                update lstRadiusToUpdate;
            }
        }
    }
    
    //This method is used to update the inspection milestone.
    private void updateInspectionMilestone(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        Id inspectionId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Inspection').getRecordTypeId();    
        Set<String> setFlowStatus = new Set<String>{'Inspection Scheduled', 'Inspection Complete'};
        Set<Id> setOppId = new Set<Id>();
        
        for(Job__c objJob : lstJob){
            if(objJob.RecordTypeId == inspectionId && objJob.Opportunity__c != null && setFlowStatus.contains(objJob.Flow_Status__c)){
                if(mapIdToOldJob == null){
                    setOppId.add(objJob.Opportunity__c);
                } else{
                    Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
                    if(objJob.Flow_Status__c != objOldJob.Flow_Status__c){
                        setOppId.add(objJob.Opportunity__c);
                    }
                }
            }
        }
        
        if(!setOppId.isEmpty()){
            List<Project_Milestone__c> lstRadiusToUpdate = new List<Project_Milestone__c>();
            for(Opportunity objOpp : [
                    SELECT Id,
                        (SELECT Id, Inspection_Scheduled_Milestone__c, Inspection_Complete_Milestone__c 
                        FROM Project_Milestones__r),
                        (SELECT Id, Flow_Status__c
                        FROM Jobs__r 
                        WHERE RecordType.DeveloperName = 'Inspection'
                        AND Flow_Status__c IN :setFlowStatus
                        LIMIT 1)
                    FROM Opportunity
                    WHERE Id IN :setOppId])
            {
                Job__c objJob = objOpp.Jobs__r[0];
                if(objJob.Flow_Status__c == 'Inspection Scheduled'){
                    for(Project_Milestone__c objRadius : objOpp.Project_Milestones__r){
                        if(objRadius.Inspection_Scheduled_Milestone__c == null){
                            objRadius.Inspection_Scheduled_Milestone__c = Datetime.now();
                            lstRadiusToUpdate.add(objRadius);
                        }
                    }
                } else if(objJob.Flow_Status__c == 'Inspection Complete'){
                    for(Project_Milestone__c objRadius : objOpp.Project_Milestones__r){
                        if(objRadius.Inspection_Complete_Milestone__c == null){
                            objRadius.Inspection_Complete_Milestone__c = Datetime.now();
                            lstRadiusToUpdate.add(objRadius);
                        }
                    }
                }
            }
            if(!lstRadiusToUpdate.isEmpty()){
                update lstRadiusToUpdate;
            }
        }
    }
    
    //This method is used to create the PTO Job under the Opportunity.
    /*
    private void createPTOJob(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        Id financingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Financing').getRecordTypeId();
        Set<Id> setOppId = new Set<Id>();
        for(Job__c objJob : lstJob){
            Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
            if(objJob.RecordTypeId == financingId && objJob.Opportunity__c != null 
                && objJob.Flow_Status__c == 'M2 - Approved' && objOldJob.Flow_Status__c != 'M2 - Approved')
            {
                setOppId.add(objJob.Opportunity__c);
            }
        }
        
        if(!setOppId.isEmpty()){
            List<Job__c> lstJobToInsert = new List<Job__c>();
            Id PTOId = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('PTO').getRecordTypeId();
            for(Opportunity objOpportunity : [
                    SELECT Id, Name, OwnerId
                    FROM Opportunity 
                    WHERE Id in :setOppId
                    AND Financing_Tool__c = 'SunRun'])
            {
                    
                Job__c objJob = new Job__c();
                objJob.Name = objOpportunity.Name + ' - PTO Job';
                objJob.RecordTypeId = PTOId;
                objJob.OwnerId = objOpportunity.OwnerId;
                objJob.Opportunity__c = objOpportunity.Id;
                objJob.Job_Status__c = 'New';
                objJob.Automation__c = true;
                lstJobToInsert.add(objJob);
            }
            /*
            if(!lstJobToInsert.isEmpty())
                insert lstJobToInsert;
            
        }
    }
    */
    
    //This method is used to prevent pending flow status change if permitting submitted milestone is not blank.
    private void preventPermitReceivedFlowStatus(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        Id PermittingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Permitting').getRecordTypeId();
        Set<String> setFlowStatus = new Set<String>{'Permit Received', 'Permit Approved, Pending Issuance'};    
        Map<Id, Job__c> mapOppIdToJob = new Map<Id, Job__c>();
        for(Job__c objJob : lstJob){
            Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
            if(objJob.RecordTypeId == PermittingId && objJob.Opportunity__c != null && objJob.Flow_Status__c != objOldJob.Flow_Status__c){
                if(String.isNotBlank(objJob.Flow_Status__c) && setFlowStatus.contains(objJob.Flow_Status__c)){
                    mapOppIdToJob.put(objJob.Opportunity__c, objJob);
                }
            }
        }
        
        if(!mapOppIdToJob.isEmpty()){
            for(Project_Milestone__c objProjectMilestone : [
                    SELECT Id, Opportunity__c 
                    FROM Project_Milestone__c 
                    WHERE Permit_Submitted_Milestone__c = null
                    AND Opportunity__c IN :mapOppIdToJob.keyset()
                    AND Opportunity__r.RecordType.DeveloperName = 'X3rd_Party_Design_Sales'])
            {
                String errorMsg = 'Flow Status can\'t be changed to Permit Received or Permit Approved, Pending Issuance before Permit Submitted Milestone.';
                mapOppIdToJob.get(objProjectMilestone.Opportunity__c).addError(errorMsg);
            }
        }
    }
    
    //This method is used to prevent pending flow status change if permitting submitted milestone is not blank.
    //NO ESTA HACIENDO NADA
    /*
    private void preventPendingFlowStatus(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        
        Id PermittingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Permitting').getRecordTypeId();
        Set<String> setFlowStatus = new Set<String>{'Permit Received', 'Permit Received, Pending Issuance'};    
        Map<Id, Job__c> mapOppIdToJob = new Map<Id, Job__c>();
        for(Job__c objJob : lstJob){
            Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
            if(objJob.RecordTypeId == PermittingId && objJob.Opportunity__c != null && objJob.Flow_Status__c != objOldJob.Flow_Status__c){
                if(String.isNotBlank(objJob.Flow_Status__c) && objJob.Flow_Status__c.startsWithIgnoreCase('pending')){
                    mapOppIdToJob.put(objJob.Opportunity__c, objJob);
                }
            }
        }
        
        if(!mapOppIdToJob.isEmpty()){
            for(Project_Milestone__c objProjectMilestone : [
                    SELECT Id, Opportunity__c 
                    FROM Project_Milestone__c 
                    WHERE Permit_Submitted_Milestone__c != null
                    AND Opportunity__c IN :mapOppIdToJob.keyset()])
            {
                String errorMsg = 'Flow Status can\'t be changed to Pending.. after Permit Submitted Milestone.';
                //mapOppIdToJob.get(objProjectMilestone.Opportunity__c).addError(errorMsg);
            }
        }
    }*/
    
    //This method is used to prevent Permitting job creation if Design Queued milestone is blank.
    private void preventPermittingJob(List<Job__c> lstJob){
        Id PermittingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Permitting').getRecordTypeId();    
        Map<Id, Job__c> mapOppIdToJob = new Map<Id, Job__c>();
        for(Job__c objJob : lstJob){
            if(objJob.RecordTypeId == PermittingId && objJob.Opportunity__c != null && objJob.Automation__c == false){
                mapOppIdToJob.put(objJob.Opportunity__c, objJob);
            }
        }
        
        if(!mapOppIdToJob.isEmpty()){
            for(Project_Milestone__c objProjectMilestone : [
                    SELECT Id, Opportunity__c 
                    FROM Project_Milestone__c 
                    WHERE Design_Completed_Milestone__c = null
                    AND Opportunity__c IN :mapOppIdToJob.keyset()
                    AND Opportunity__r.RecordType.DeveloperName = 'X3rd_Party_Design_Sales'])
            {
                String errorMsg = 'Permitting Job Creation is not allowed prior to Design Completed Milestone';
                mapOppIdToJob.get(objProjectMilestone.Opportunity__c).addError(errorMsg);
            }
        }
    }
    
    //This method is used to prevent site approval job creation if Design Queued milestone is blank.
    private void preventSiteApprovalJob(List<Job__c> lstJob){
        Id siteApprovalId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Design').getRecordTypeId();    
        Map<Id, Job__c> mapOppIdToJob = new Map<Id, Job__c>();
        for(Job__c objJob : lstJob){
            if(objJob.RecordTypeId == siteApprovalId && objJob.Opportunity__c != null && objJob.Automation__c == false){
                mapOppIdToJob.put(objJob.Opportunity__c, objJob);
            }
        }
        
        if(!mapOppIdToJob.isEmpty()){
            for(Project_Milestone__c objProjectMilestone : [
                    SELECT Id, Opportunity__c 
                    FROM Project_Milestone__c 
                    WHERE Design_Queued_Milestone__c = null
                    AND Opportunity__c IN :mapOppIdToJob.keyset()
                    AND Opportunity__r.RecordType.DeveloperName = 'X3rd_Party_Design_Sales'])
            {
                String errorMsg = 'Site Approval Job Creation is not allowed prior to Design Queued Milestone';
                mapOppIdToJob.get(objProjectMilestone.Opportunity__c).addError(errorMsg);
            }
        }
    }
    
    //This method is used to update the Permitting Milestone on Project Milestone record.
    private void updatePermittingMilestone(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        Id permittingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Permitting').getRecordTypeId();    
        Set<String> setFlowStatus = new Set<String>{'Permit Submitted', 'Permit Received', 'Permit Approved, Pending Issuance'};
        Set<Id> setOppId = new Set<Id>();
        
        for(Job__c objJob : lstJob){
            if(objJob.RecordTypeId == permittingId && objJob.Opportunity__c != null && setFlowStatus.contains(objJob.Flow_Status__c)){
                if(mapIdToOldJob == null){
                    setOppId.add(objJob.Opportunity__c);
                } else{
                    Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
                    if(objJob.Flow_Status__c != objOldJob.Flow_Status__c){
                        setOppId.add(objJob.Opportunity__c);
                    }
                }
            }
        }
        
        if(!setOppId.isEmpty()){
            List<Project_Milestone__c> lstRadiusToUpdate = new List<Project_Milestone__c>();
            for(Opportunity objOpp : [
                    SELECT Id,
                        (SELECT Id, Permit_Submitted_Milestone__c, Permit_Received_Milestone__c 
                        FROM Project_Milestones__r),
                        (SELECT Id, Flow_Status__c
                        FROM Jobs__r 
                        WHERE RecordType.DeveloperName = 'Permitting'
                        AND Flow_Status__c IN :setFlowStatus
                        LIMIT 1)
                    FROM Opportunity
                    WHERE Id IN :setOppId])
            {
                Job__c objJob = objOpp.Jobs__r[0];
                if(objJob.Flow_Status__c == 'Permit Submitted'){
                    for(Project_Milestone__c objRadius : objOpp.Project_Milestones__r){
                        if(objRadius.Permit_Submitted_Milestone__c == null){
                            objRadius.Permit_Submitted_Milestone__c = Datetime.now();
                            lstRadiusToUpdate.add(objRadius);
                        }
                    }
                } else if(objJob.Flow_Status__c == 'Permit Received' || objJob.Flow_Status__c == 'Permit Approved, Pending Issuance'){
                    for(Project_Milestone__c objRadius : objOpp.Project_Milestones__r){
                        if(objRadius.Permit_Received_Milestone__c == null){
                            objRadius.Permit_Received_Milestone__c = Datetime.now();
                            lstRadiusToUpdate.add(objRadius);
                        }
                    }
                }
            }
            if(!lstRadiusToUpdate.isEmpty()){
                update lstRadiusToUpdate;
            }
        }
    }
    
    //This method is used to update the Design completed Milestone on Project Milestone record.
    private void updateDesignCompletedMilestone(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        Id siteApprovalId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Design').getRecordTypeId();    
        Set<Id> setOppId = new Set<Id>();
        
        for(Job__c objJob : lstJob){
            if(objJob.RecordTypeId == siteApprovalId && objJob.Opportunity__c != null && objJob.Flow_Status__c == 'Site Approved'){
                if(mapIdToOldJob == null){
                    setOppId.add(objJob.Opportunity__c);
                } else{
                    Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
                    if(objJob.Flow_Status__c != objOldJob.Flow_Status__c){
                        setOppId.add(objJob.Opportunity__c);
                    }
                }
            }
        }
        
        if(!setOppId.isEmpty()){
            List<Project_Milestone__c> lstRadiusToUpdate = new List<Project_Milestone__c>();
            List<Opportunity> lstOppsToUpdate = new List<Opportunity>();
            for(Opportunity objOpp : [
                    SELECT Id,
                        (SELECT Id, Design_Completed_Milestone__c 
                        FROM Project_Milestones__r 
                        WHERE Design_Completed_Milestone__c = null)
                    FROM Opportunity
                    WHERE Id IN :setOppId])
            {
                for(Project_Milestone__c objRadius : objOpp.Project_Milestones__r){
                    objRadius.Design_Completed_Milestone__c = Datetime.now();
                    lstRadiusToUpdate.add(objRadius);
                }
                objOpp.StageName = '13. Engineering Design Complete';
                lstOppsToUpdate.add(objOpp);
            }   
            if(!lstRadiusToUpdate.isEmpty()){
                update lstRadiusToUpdate;
            }
            if(!lstOppsToUpdate.isEmpty()){
                update lstOppsToUpdate;
            }
        }
    }
    
    //This method is used to update the Energy Bill Checked datetime on radius record.
    private void updateEnergyBillMilestone(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        Id documentVerificationId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Document_Verification').getRecordTypeId();    
        Set<Id> setOppId = new Set<Id>();
        
        for(Job__c objJob : lstJob){
            if(objJob.RecordTypeId == documentVerificationId && objJob.Opportunity__c != null && objJob.Usage_Verification_Complete__c != null){
                if(mapIdToOldJob == null){
                    setOppId.add(objJob.Opportunity__c);
                } else{
                    Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
                    if(objJob.Usage_Verification_Complete__c != objOldJob.Usage_Verification_Complete__c){
                        setOppId.add(objJob.Opportunity__c);
                    }
                }
            }
        }
        
        if(!setOppId.isEmpty()){
            List<Project_Milestone__c> lstRadiusToUpdate = new List<Project_Milestone__c>();
            for(Opportunity objOpp : [
                    SELECT Id,
                        (SELECT Id, Energy_Bill_checked__c 
                        FROM Project_Milestones__r 
                        WHERE Energy_Bill_checked__c = null)
                    FROM Opportunity
                    WHERE Id IN :setOppId])
            {
                for(Project_Milestone__c objRadius : objOpp.Project_Milestones__r){
                    objRadius.Energy_Bill_checked__c = Datetime.now();
                    objRadius.Energy_Usage_Verification_Milestone__c = Datetime.now();
                    lstRadiusToUpdate.add(objRadius);
                }
            }
            if(!lstRadiusToUpdate.isEmpty()){
                update lstRadiusToUpdate;
            }
        }
    }
    //This method is used to update the Survey Complete Confirmed datetime on radius record.
    private void updateSurveyCompleteMilestone(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        Id siteSurveyId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('SiteSurvey').getRecordTypeId();    
        Set<Id> setOppId = new Set<Id>();
        
        for(Job__c objJob : lstJob){
            if(objJob.RecordTypeId == siteSurveyId && objJob.Opportunity__c != null && objJob.Flow_Status__c == 'Survey Complete'){
                if(mapIdToOldJob == null){
                    setOppId.add(objJob.Opportunity__c);
                } else{
                    Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
                    if(objJob.Flow_Status__c != objOldJob.Flow_Status__c){
                        setOppId.add(objJob.Opportunity__c);
                    }
                }
            }
        }
        
        if(!setOppId.isEmpty()){
            List<Project_Milestone__c> lstRadiusToUpdate = new List<Project_Milestone__c>();
            for(Opportunity objOpp : [
                    SELECT Id,
                        (SELECT Id, Survey_Complete_Confirmed__c 
                        FROM Project_Milestones__r 
                        WHERE Survey_Complete_Confirmed__c = null)
                    FROM Opportunity
                    WHERE Id IN :setOppId])
            {
                for(Project_Milestone__c objRadius : objOpp.Project_Milestones__r){
                    objRadius.Survey_Complete_Confirmed__c = Datetime.now();
                    objRadius.Site_Survey_Completed_Milestone__c = Datetime.now();
                    lstRadiusToUpdate.add(objRadius);
                }
            }
            if(!lstRadiusToUpdate.isEmpty()){
                update lstRadiusToUpdate;
            }
        }
    }
    //This method is used to update the Contract Signed Milestone on radius record.
    private void updateContractSignedMilestone(List<Job__c> lstJob){
        Id contractProcessingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Business_Processing').getRecordTypeId();    
        Set<Id> setOppId = new Set<Id>();
        
        for(Job__c objJob : lstJob){
            if(objJob.RecordTypeId == contractProcessingId && objJob.Opportunity__c != null){
                setOppId.add(objJob.Opportunity__c);
            }
        }
        
        if(!setOppId.isEmpty()){
            List<Project_Milestone__c> lstRadiusToUpdate = new List<Project_Milestone__c>();
            for(Opportunity objOpp : [
                    SELECT Id,
                        (SELECT Id, Contract_Signed_Milestone__c 
                        FROM Project_Milestones__r 
                        WHERE Contract_Signed_Milestone__c = null)
                    FROM Opportunity
                    WHERE Id IN :setOppId])
            {
                for(Project_Milestone__c objRadius : objOpp.Project_Milestones__r){
                    objRadius.Contract_Signed_Milestone__c = Datetime.now();
                    lstRadiusToUpdate.add(objRadius);
                }
            }
            if(!lstRadiusToUpdate.isEmpty()){
                update lstRadiusToUpdate;
            }
        }
    }
    //This method is used to update the stage of Opportunity.
    private void updateOppStage(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        Id businessProcessingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Business_Processing').getRecordTypeId();
        Id PTOId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('PTO').getRecordTypeId();
        Id InstallationSchedulingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Installation_Scheduling').getRecordTypeId();
       
        Map<Id, String> mapOppIdToStage = new Map<Id, String>();
        Map<Id, Job__c> mapOppAndJob = new Map<Id, Job__c>();
        
        for(Job__c objJob : lstJob){
            if(objJob.Opportunity__c != null && objJob.Flow_Status__c == 'Contract Processing Completed' && objJob.RecordTypeId == businessProcessingId){
                if(mapIdToOldJob == null){
                    mapOppIdToStage.put(objJob.Opportunity__c, '7. Contract Received');
                } else{
                    Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
                    if(objJob.Flow_Status__c != objOldJob.Flow_Status__c){
                        mapOppIdToStage.put(objJob.Opportunity__c, '7. Contract Received');
                    }
                }
            }
            
            if(objJob.Opportunity__c != null && objJob.Flow_Status__c == 'Permit Submitted' && objJob.Type__c == 'Permit Issuance'){
                if(mapIdToOldJob == null){
                    mapOppIdToStage.put(objJob.Opportunity__c, '14. Permit Sent');
                } else{
                    Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
                    if(objJob.Flow_Status__c != objOldJob.Flow_Status__c || objJob.Type__c != objOldJob.Type__c){
                        mapOppIdToStage.put(objJob.Opportunity__c, '14. Permit Sent');
                    }
                }
            }
            
            if(objJob.Opportunity__c != null && objJob.Flow_Status__c == 'Permit Received' && objJob.Type__c == 'Permit Issuance'){
                if(mapIdToOldJob == null){
                    mapOppIdToStage.put(objJob.Opportunity__c, '16. Permit Received');
                } else{
                    Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
                    if(objJob.Flow_Status__c != objOldJob.Flow_Status__c || objJob.Type__c != objOldJob.Type__c){
                        mapOppIdToStage.put(objJob.Opportunity__c, '16. Permit Received');
                    }
                }
            }
            
            if(objJob.Opportunity__c != null && objJob.Flow_Status__c == 'Inspection Scheduled' && objJob.Type__c == 'Inspection'){
                mapOppAndJob.put(objJob.Opportunity__c, objJob);
                if(mapIdToOldJob == null){
                    mapOppIdToStage.put(objJob.Opportunity__c, '20. Inspection Scheduled');
                } else{
                    Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
                    if(objJob.Flow_Status__c != objOldJob.Flow_Status__c || objJob.Type__c != objOldJob.Type__c){
                        mapOppIdToStage.put(objJob.Opportunity__c, '20. Inspection Scheduled');
                    }
                }
            }
            
            if(objJob.Opportunity__c != null && objJob.Flow_Status__c == 'Inspection Complete' && objJob.Type__c == 'Inspection'){
                mapOppAndJob.put(objJob.Opportunity__c, objJob);
                if(mapIdToOldJob == null){
                    mapOppIdToStage.put(objJob.Opportunity__c, '21. Inspection Complete');
                } else{
                    Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
                    if(objJob.Flow_Status__c != objOldJob.Flow_Status__c || objJob.Type__c != objOldJob.Type__c){
                        mapOppIdToStage.put(objJob.Opportunity__c, '21. Inspection Complete');
                    }
                }
            }
            
            if(objJob.Opportunity__c != null && objJob.Flow_Status__c == 'PTO Granted' && objJob.Type__c == 'PTO' && objJob.RecordTypeId == PTOId){
                mapOppAndJob.put(objJob.Opportunity__c, objJob);
                if(mapIdToOldJob == null){
                    mapOppIdToStage.put(objJob.Opportunity__c, '22. PTO');
                } else{
                    Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
                    if(objJob.Flow_Status__c != objOldJob.Flow_Status__c || objJob.Type__c != objOldJob.Type__c){
                        mapOppIdToStage.put(objJob.Opportunity__c, '22. PTO');
                    }
                }
            }
            
            if(objJob.Opportunity__c != null && objJob.Flow_Status__c == 'Installation Scheduled' 
                && objJob.Installation_Start_Date__c != null && objJob.RecordTypeId == InstallationSchedulingId)
            {
                mapOppAndJob.put(objJob.Opportunity__c, objJob);
                if(mapIdToOldJob == null){
                    mapOppIdToStage.put(objJob.Opportunity__c, '18. Installation');
                } else{
                    Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
                    if(objJob.Flow_Status__c != objOldJob.Flow_Status__c || objJob.Installation_Start_Date__c != objOldJob.Installation_Start_Date__c){
                        mapOppIdToStage.put(objJob.Opportunity__c, '18. Installation');
                    }
                }
            }
            
            if(objJob.Opportunity__c != null && objJob.Flow_Status__c == 'Installation Complete' 
                && objJob.Job_Status__c == 'Closed' && objJob.RecordTypeId == InstallationSchedulingId)
            {
                mapOppAndJob.put(objJob.Opportunity__c, objJob);
                if(mapIdToOldJob == null){
                    mapOppIdToStage.put(objJob.Opportunity__c, '19. Install Completed');
                } else{
                    Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
                    if(objJob.Flow_Status__c != objOldJob.Flow_Status__c || objJob.Job_Status__c != objOldJob.Job_Status__c){
                        mapOppIdToStage.put(objJob.Opportunity__c, '19. Install Completed');
                    }
                }
            }
        }

        List<String> oppStageValidation = new List<String>();
        oppStageValidation.add('18. Installation');
        oppStageValidation.add('19. Install Completed');
        oppStageValidation.add('20. Inspection Scheduled');
        oppStageValidation.add('21. Inspection Complete');
        oppStageValidation.add('22. PTO');
        
        if(!mapOppIdToStage.isEmpty()){
            List<Opportunity> lstOppToUpdate = new List<Opportunity>();
            List<Project_Milestone__c> lstRadiusToUpdate = new List<Project_Milestone__c>();
            for(Opportunity objOpp : [
                    SELECT Id, StageName, Install_ready__c, Install_ready_Date__c, 
                    (SELECT Id, Contract_Received_Milestone__c
                    FROM Project_Milestones__r
                    WHERE Contract_Received_Milestone__c = null)                    
                    FROM Opportunity 
                    WHERE Id IN :mapOppIdToStage.keyset() ])
            {
                String newStageName = mapOppIdToStage.get(objOpp.Id);
                String oldStageName = objOpp.StageName;

                if(newStageName != oldStageName && isValidStage(oldStageName, newStageName)  && oldStageName != 'Cancelled' ){
                    if(oppStageValidation.contains(newStageName) && objOpp.Install_Ready__c == false && objOpp.Install_Ready_Date__c == null ){
                        mapOppAndJob.get(objOpp.Id).addError(' You can not set this Flow Status because the Opportunity did not go to Stage 17');
                    } else {
                        objOpp.StageName = newStageName;
                        lstOppToUpdate.add(objOpp);
                    }
                }
                
                if(newStageName == '7. Contract Received'){
                    for(Project_Milestone__c objRadius : objOpp.Project_Milestones__r){
                        objRadius.Contract_Received_Milestone__c = Datetime.now();
                        //objRadius.Contract_Received_Confirmed_Milestone__c = Datetime.now();
                        lstRadiusToUpdate.add(objRadius);
                    }
                }
            }
            
            if(!lstOppToUpdate.isEmpty())
                update lstOppToUpdate;
            if(!lstRadiusToUpdate.isEmpty())
                update lstRadiusToUpdate;
        }
    }
    
    private Boolean isValidStage(String oldStageName, String newStageName){
        Boolean validStage = false;
        Map<String, Integer> mapStageToIndex = new Map<String, Integer>();
        mapStageToIndex.put('1. Appointment Set', 1);
        mapStageToIndex.put('2. Appointment Complete', 2);
        mapStageToIndex.put('3. Proposal Presented', 3);
        mapStageToIndex.put('3a. Proposal Redesign', 4);
        mapStageToIndex.put('4. Verbal Committment', 5);
        mapStageToIndex.put('5. Credit Approved', 6);
        mapStageToIndex.put('6. Contract Signed', 7);
        mapStageToIndex.put('7. Contract Received', 8);
        mapStageToIndex.put('7a. Contract Received Confirmed', 9);
        mapStageToIndex.put('8. Site Audit Scheduled', 10);
        mapStageToIndex.put('8a. Site Audit Completed', 11);
        mapStageToIndex.put('9. Change Order Pending', 12);
        mapStageToIndex.put('10. Site Approved', 13);
        mapStageToIndex.put('11. Interconnection Sent', 14);
        mapStageToIndex.put('12. Engineering Package Sent', 15);
        mapStageToIndex.put('13. Engineering Design Complete', 16);
        mapStageToIndex.put('14. Permit Sent', 17);
        mapStageToIndex.put('15. Permit Ready', 18);
        mapStageToIndex.put('16. Permit Received', 19);
        mapStageToIndex.put('17. Install Ready', 20);
        mapStageToIndex.put('18. Installation', 21);
        mapStageToIndex.put('19. Install Completed', 22);
        mapStageToIndex.put('20. Inspection Scheduled', 23);
        mapStageToIndex.put('21. Inspection Complete', 24);
        mapStageToIndex.put('22. PTO', 25);
        mapStageToIndex.put('Closed Won', 26);
        mapStageToIndex.put('Cancelled', 27);
        mapStageToIndex.put('Closed Lost', 28);
        
        Integer previousOrder = (mapStageToIndex.containsKey(oldStageName)?mapStageToIndex.get(oldStageName):0);
        Integer currentOrder = (mapStageToIndex.containsKey(newStageName)?mapStageToIndex.get(newStageName):0);
        if(currentOrder > previousOrder || oldStageName == 'Cancelled'){
            validStage = true;
        }
        
        return validStage;
    }
    
    //This method is used to populate the Secondary/Building Inspection Required field value.
    private void populateSeconadryInspection(List<Job__c> lstJob){
        Id InspectionId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Inspection').getRecordTypeId();
        Set<String> setLocation = new Set<String>();
        setLocation.add('Massachusetts');
        setLocation.add('Rhode Island');
        setLocation.add('New Jersey');
        
        for(Job__c objJob : lstJob){
            if(objJob.RecordTypeId == InspectionId && objJob.Opportunity__c != null && setLocation.contains(objJob.Location__c)){
                objJob.Secondary_Building_Inspection_Required__c = 'Yes';
            }
        }
    }
    
    //This method is used to update Opportunity fields to keep data in sync.
    private void updateOppData(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        Id HOAId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('HOA').getRecordTypeId();
        Map<Id, Opportunity> mapIdToOpp = new Map<Id, Opportunity>();
        for(Job__c objJob : lstJob){
            Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
            Boolean updateOpp = false;
            if(objJob.Opportunity__c != null && objJob.RecordTypeId == HOAId){
                Opportunity objOpportunity = new Opportunity();
                objOpportunity.Id = objJob.Opportunity__c;
                if(objJob.HOA_Approval_Not_Required__c != objOldJob.HOA_Approval_Not_Required__c && String.isNotBlank(objJob.HOA_Approval_Not_Required__c)){
                    objOpportunity.HOA_Approval_Not_Required__c = objJob.HOA_Approval_Not_Required__c;
                    updateOpp = true;
                }
                if(objJob.Approval_Required_for_Permit__c == true && objOldJob.Approval_Required_for_Permit__c == false){
                    objOpportunity.HOA_Approved__c = true;
                    updateOpp = true;
                }
                if(objJob.Application_Method__c != objOldJob.Application_Method__c && String.isNotBlank(objJob.Application_Method__c)){
                    objOpportunity.HOA_Application_Fee_Paid__c = objJob.Application_Method__c;
                    updateOpp = true;
                }
                if(objJob.Application_Submitted_Date__c != objOldJob.Application_Submitted_Date__c && objJob.Application_Submitted_Date__c != null){
                    objOpportunity.HOA_Application_Sent_Date__c = objJob.Application_Submitted_Date__c;
                    updateOpp = true;
                }
                if(objJob.Application_Submission_Confirmed__c != objOldJob.Application_Submission_Confirmed__c && objJob.Application_Submission_Confirmed__c != null){
                    objOpportunity.Customer_Sent_HOA_Application_Date__c = objJob.Application_Submission_Confirmed__c;
                    updateOpp = true;
                }
                if(objJob.Approval_Date__c != objOldJob.Approval_Date__c && objJob.Approval_Date__c != null){
                    objOpportunity.HOA_Approval_Date__c = objJob.Approval_Date__c;
                    updateOpp = true;
                }
                if(objJob.HOA_Denial__c != objOldJob.HOA_Denial__c && objJob.HOA_Denial__c != null){
                    objOpportunity.HOA_Appeal__c = true;
                    updateOpp = true;
                }
                
                
                if(updateOpp){
                    mapIdToOpp.put(objOpportunity.Id, objOpportunity);
                }
            }
        }
        
        if(!mapIdToOpp.isEmpty())
            update mapIdToOpp.values();
    }
    
    //This method is used to populate flow status/job status.
    private void populateJobAndFlowStatus(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        Id HOAId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('HOA').getRecordTypeId();
        Id installationSchedulingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Installation_Scheduling').getRecordTypeId();
        Id supplyChainId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Supply_Chain').getRecordTypeId();
        
        for(Job__c objJob : lstJob){
            Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
            if(objJob.RecordTypeId == HOAId){
                if(objJob.HOA_Approval_Not_Required__c != objOldJob.HOA_Approval_Not_Required__c && String.isNotBlank(objJob.HOA_Approval_Not_Required__c))
                    objJob.Flow_Status__c = 'Project Closed';
                if(objJob.Sent_for_Signature__c != objOldJob.Sent_for_Signature__c && objJob.Sent_for_Signature__c != null)
                    objJob.Flow_Status__c = 'Docs Sent for Signature';
                if(objJob.Homeowner_Instructions_Sent__c != objOldJob.Homeowner_Instructions_Sent__c && objJob.Homeowner_Instructions_Sent__c != null)
                    objJob.Flow_Status__c = 'Submitted';
                if(objJob.Application_Submitted_Date__c != objOldJob.Application_Submitted_Date__c && objJob.Application_Submitted_Date__c != null)
                    objJob.Flow_Status__c = 'Submitted';
                if(objJob.Application_Submission_Confirmed__c != objOldJob.Application_Submission_Confirmed__c && objJob.Application_Submission_Confirmed__c != null)
                    objJob.Flow_Status__c = 'Confirmed';
                if(objJob.Approval_Date__c != objOldJob.Approval_Date__c && objJob.Approval_Date__c != null){
                    objJob.Flow_Status__c = 'Approved';
                    objJob.Job_Status__c = 'Closed';
                }
                if(objJob.HOA_Denial__c != objOldJob.HOA_Denial__c && objJob.HOA_Denial__c != null)
                    objJob.Flow_Status__c = 'Denied/Appealing';
                if(objJob.Customer_Unresponsive__c == true && objOldJob.Customer_Unresponsive__c == false)
                    objJob.Job_Status__c = 'Closed';
                if(objJob.Customer_Failing_to_Action__c == true && objOldJob.Customer_Failing_to_Action__c == false)
                    objJob.Job_Status__c = 'Closed';
                if(objJob.HOA_Unresponsive__c == true && objOldJob.HOA_Unresponsive__c == false)
                    objJob.Job_Status__c = 'On-Hold';
                if(objJob.HO_Does_Not_Want_to_Proceed__c != objOldJob.HO_Does_Not_Want_to_Proceed__c && String.isNotBlank(objJob.HO_Does_Not_Want_to_Proceed__c)){
                    objJob.Job_Status__c = 'Closed';
                    objJob.Flow_Status__c = 'Cancelled';
                }
                if(objJob.Project_On_Hold__c != objOldJob.Project_On_Hold__c && String.isNotBlank(objJob.Project_On_Hold__c)){
                    objJob.Job_Status__c = 'On-Hold';
                }
            }
            
            if(objJob.RecordTypeId == installationSchedulingId){
                if(objJob.Flow_Status__c == 'Installation Complete' && objOldJob.Flow_Status__c != 'Installation Complete'){
                    objJob.Job_Status__c = 'Closed';
                    objJob.Installation_End_Date__c = Date.today();
                }
                
                if(objJob.Installation_Reschedule_Reason__c != objOldJob.Installation_Reschedule_Reason__c){
                    String rescheduleHistory = String.isBlank(objJob.Reschedule_Reason_History__c)?'':objJob.Reschedule_Reason_History__c;
                    String oldReason = (String.isBlank(objOldJob.Installation_Reschedule_Reason__c)?'blank':objOldJob.Installation_Reschedule_Reason__c);
                    String newReason = (String.isBlank(objJob.Installation_Reschedule_Reason__c)?'blank':objJob.Installation_Reschedule_Reason__c);
                    String rescheduleReason = 'Installation Reschedule Reason is changed from ' + oldReason + ' to ' + newReason;
                    rescheduleReason += ' by ' + Userinfo.getFirstName() + ' ' + Userinfo.getLastName() + ' on ' + Datetime.now().format('MM/dd/yyyy HH:mm a', Userinfo.getTimezone().getId());
                    
                    rescheduleHistory = rescheduleReason + '\n' + rescheduleHistory;
                    objJob.Reschedule_Reason_History__c = rescheduleHistory;
                }
            }
            /*
            if(objJob.RecordTypeId == supplyChainId && objOldJob.BOM_Confirmed__c == false && objJob.BOM_Confirmed__c == true){
                objJob.Flow_Status__c = 'BOM Verification Complete';
            }*/
            
            if(objJob.RecordTypeId == supplyChainId && objOldJob.Flow_status__c != 'Fulfilled' && objJob.Flow_status__c == 'Fulfilled'){
                objJob.Job_Status__c = 'Closed';
            }
        }
    }
    
    //This method is used to populate the document verification fields of Interconnection job.
    private void populateDocumentVerification(List<Job__c> lstJob){
        Id interconnectionId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Interconnection').getRecordTypeId();
        Map<Id, List<Job__c>> mapIdToLstJob = new Map<Id, List<Job__c>>();
        for(Job__c objJob : lstJob){
            if(objJob.RecordTypeId == interconnectionId && objJob.Opportunity__c != null){
                if(mapIdToLstJob.containsKey(objJob.Opportunity__c)){
                    mapIdToLstJob.get(objJob.Opportunity__c).add(objJob);
                } else{
                    mapIdToLstJob.put(objJob.Opportunity__c, new List<Job__c>{objJob});
                }
            }
        }
        
        if(!mapIdToLstJob.isEmpty()){
            for(Opportunity objOpp : [
                    SELECT Id, 
                        (SELECT Id, HOI_Only_if_system_is_above_20KW_AC__c, Utility_Bill_Upload_within_2_months__c, RecordType.DeveloperName, ICA_Docs__c,
                        HOI_only_if_system_is_above_11_76KW_DC__c, Homeowners_Insurance_Upload_NC__c, ICA_Document_To_Upload_Notarize_Afidavit__c,
                        Homeowners_Insurance_Upload_SC__c, HOI_Ameren_only_Illinois__c, Consumption_Report_For_less_than_12_mo__c, New_First_Year_kWh__c 
                        FROM Jobs__r where RecordType.DeveloperName IN ('Document_Verification', 'Design')) 
                    FROM Opportunity 
                    WHERE Id in :mapIdToLstJob.keyset()])
            {
                if(objOpp.Jobs__r != null && !objOpp.Jobs__r.isEmpty()){
                    for(Job__c objDVJob : objOpp.Jobs__r){
                        for(Job__c objJob : mapIdToLstJob.get(objOpp.Id)){
                            if(objDVJob.RecordType.DeveloperName == 'Document_Verification'){
                                objJob.HOI_Only_if_system_is_above_20KW_AC__c = objDVJob.HOI_Only_if_system_is_above_20KW_AC__c;
                                objJob.Utility_Bill_Upload_within_2_months__c = objDVJob.Utility_Bill_Upload_within_2_months__c;
                                objJob.HOI_only_if_system_is_above_11_76KW_DC__c = objDVJob.HOI_only_if_system_is_above_11_76KW_DC__c;
                                objJob.Homeowners_Insurance_Upload_NC__c = objDVJob.Homeowners_Insurance_Upload_NC__c;
                                objJob.ICA_Document_To_Upload_Notarize_Afidavit__c = objDVJob.ICA_Document_To_Upload_Notarize_Afidavit__c;
                                objJob.Homeowners_Insurance_Upload_SC__c = objDVJob.Homeowners_Insurance_Upload_SC__c;
                                objJob.HOI_Ameren_only_Illinois__c = objDVJob.HOI_Ameren_only_Illinois__c;
                                objJob.Consumption_Report_For_less_than_12_mo__c = objDVJob.Consumption_Report_For_less_than_12_mo__c;
                                objJob.ICA_Docs__c = objDVJob.ICA_Docs__c;
                            } else{
                                objJob.New_First_Year_kWh__c = objDVJob.New_First_Year_kWh__c;
                            }
                        }
                    }
                }
            }
        }
    }
    
    //This method is used to change flow status of Financing job when Flow status of JCO job is changed.
    private void changeFlowStatusOnFinOpsFromDV(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        Id DVId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Document_Verification').getRecordTypeId();
        Set<Id> setOppId = new Set<Id>();
        for(Job__c objJob : lstJob){
            Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
            if(objJob.RecordTypeId == DVId && objJob.Financier_M0_Submitted__c == true
                && objOldJob.Financier_M0_Submitted__c == false && objJob.Opportunity__c != null)
            {
                setOppId.add(objJob.Opportunity__c);
            }
        }
        
        if(!setOppId.isEmpty()){
            List<Job__c> lstJobToUpdate = new List<Job__c>();
            for(Job__c objJob : [
                    SELECT Id, Flow_Status__c from Job__c 
                    WHERE RecordType.DeveloperName = 'Financing' 
                    AND Opportunity__c IN :setOppId])
            {
                objJob.Flow_Status__c = 'M0 - Submitted';
                lstJobToUpdate.add(objJob);    
            }
            
            if(!lstJobToUpdate.isEmpty())
                update lstJobToUpdate;
        }
    }
    
    //This method is used to change flow status of Financing job when Flow status of JCO job is changed.
    private void changeFlowStatusOnFinOps(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        Id jobCloseOutId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Job_Close_Out').getRecordTypeId();
        Set<Id> setOppId = new Set<Id>();//'QC Approved With Exceptions', 
        Set<String> setFlowStatus = new Set<String>{'QC Approved - Field Remedies Needed', 'QC Approved Complete', 'Field Remedies Needed - QCA'};
        for(Job__c objJob : lstJob){
            Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
            if(objJob.RecordTypeId == jobCloseOutId && setFlowStatus.contains(objJob.Flow_Status__c) 
                && !setFlowStatus.contains(objOldJob.Flow_Status__c) && objJob.Opportunity__c != null)
            {
                setOppId.add(objJob.Opportunity__c);
            }
        }
        
        if(!setOppId.isEmpty()){
            List<Job__c> lstJobToUpdate = new List<Job__c>();
            Map<String, Integer> mapFlowStatusToNumber = new Map<String, Integer>{
                'New' => 1, 'Not Started' => 2, 'Preparing' => 3, 'Change Order Pending' => 4, 'Change Order Complete' => 5, 'Design Outsourced' => 6, 'Professional Engineering Stamp' => 7, 'Final Review' => 8, 'Site Approved' => 9, 'Installation Complete- Pending Scheduling' => 10, 'Inspection Pending Customer' => 11, 'Scheduling Pending As-Builts/Redesign' => 12, 'Inspection Pending Inspector' => 13, 'Inspection Pending Affidavit' => 14, 'Inspection Scheduling Blocked' => 15, 'Inspection Scheduled' => 16, 'Inspection Failed' => 17, 'Pending Remediation/Corrections' => 18, 'Inspection Complete' => 19, 'Inspection Complete-Pending WO Close Out' => 20, 'Virtual Survey Sent to Customer' => 21, 'Virtual Survey Received- Pending Review' => 22, 'Additional Photos Needed' => 23, 'Physical Survey Required - Palmetto Requested' => 24, 'Physical Survey Required - 3rd Party Requested' => 25, 'New- Physical Survey Pending Scheduling' => 26, 'Physical Survey Scheduling Pending Customer' => 27, 'Physical Survey Scheduled' => 28, 'Physical Re-Survey Required' => 29, 'Physical Re-Survey Scheduled' => 30, 'Physical Survey Reschedule Required' => 31, 'Physical Survey Rescheduled' => 32, 'Survey Complete - Confirmed' => 33, 'Action Required' => 34, 'Required' => 35, 'Required - Pending Production' => 36, 'Step 1 of 2 - Submitted' => 37, 'Step 2 of 2 - Docs Sent for Signature' => 38, 'Step 2 of 2 - Docs Received Signed' => 39, 'Step 1 of 2 - Approved' => 40, 'Step 1 of 2 - Docs Sent for Signature' => 41, 'Step 1 of 2 - Docs Received Signed' => 42, 'Step 2 of 2 - Required - Pending Production' => 43, 'Step 2 of 2 - Account Transfer Initiated' => 44, 'Step 2 of 2 - Account Transfer Accepted' => 45, 'Step 1 of 1 - Submitted' => 46, 'Step 2 of 2 - Approved' => 47, 'Step 2a - Change Order Requested' => 48, 'Step 2a - Change Order Approved' => 49, 'Step 2b - Inspection Requested' => 50, 'Step 2a/b - Corrections Required' => 51, 'Step 2a/b - Corrections Submitted' => 52, 'Step 2c - Pending Green Bank Action' => 53, 'Step 2 of 2 - Pipeline Report Sent' => 54, 'Step 2 of 2 - Facility Certified - Pending Customer Action' => 55, 'Step 1 of 3 - Docs Sent for Signature' => 56, 'Step 1 of 3 - Docs Received Signed' => 57, 'Step 1 of 3 - Submitted' => 58, 'Step 1 of 3 - Corrections Required' => 59, 'Step 1 of 3 - Approved' => 60, 'Step 2 of 3 Required' => 61, 'Step 2 of 3 - Approved' => 62, 'Step 3 of 3 - Facility Certified - Pending Customer Action' => 63, 'Step 1 of 2 - RCEG App Submitted' => 64, 'Step 1 of 2 - Corrections Required' => 65, 'Step 2 of 2 - Required' => 66, 'Step 2 of 2 - Submitted' => 67, 'Step 2 of 2 - Corrections Required' => 68, 'Step 2 of 2 - Pending Customer Action' => 69, 'Step 1 of 3 - LOI Received' => 70, 'Step 2 of 3 - Docs Sent for Signature' => 71, 'Step 2 of 3 - Docs Received Signed' => 72, 'Step 3 of 3 - Required' => 73, 'Step 3 of 3 - Submitted' => 74, 'Step 3 of 3 - Corrections Required' => 75, 'App Submitted' => 76, 'Docs Sent for Signature' => 77, 'Docs Received Signed' => 78, 'Submitted' => 79, 'Corrections Required' => 80, 'Approved' => 81, 'Incentive Process Complete' => 82, 'Contract Processing Pending Review' => 83, 'Contracts reviewed- Documents Incomplete' => 84, 'Contracts reviewed- Documents Incomplete(Reason 1)' => 85, 'Contracts reviewed- Documents Incomplete(Reason 2)' => 86, 'Contracts reviewed- Documents Incomplete(Reason 3)' => 87, 'Contracts reviewed- Documents Incomplete(Reason 4)' => 88, 'Contract reviewed- Third Party delay/ Discrepancy' => 89, 'Contract Processing Completed' => 90, 'Date Field / Mirroring information to main opportunity' => 91, 'Pending JCO' => 92, 'Incomplete JCO' => 93, 'Punchlist / Photos Scheduled' => 94, 'Punchlist / Photos Completed' => 95, 'Field Complete in QC Review' => 96, 'QC Review - Pending Design Revision' => 97, 'QC Approved With Exceptions' => 98, 'QC Approved - Field Remedies Needed' => 99, 'QC Approved Complete' => 100, 'Rejected - Pending Correction' => 101, 'Escalated' => 102, 'Submission Not Required (Non Carolina Markets)' => 103, 'Confirmed' => 104, 'Denied/Appealing' => 105, 'HO Bypass' => 106, 'Cancelled' => 107, 'Pending Submittal to AHJ' => 108, 'Permit Received' => 109, 'Permit Submitted' => 110, 'Permit Approved, Pending Issuance' => 111, 'Permit Rejected' => 112, 'Pending ICA Approval' => 113, 'Pending Work Order' => 114, 'Pending Redesign' => 115, 'Pending Resurvey' => 116, 'Pending Wet Stamped Plans' => 117, 'Pending Customer Signed Docs' => 118, 'Pending Customer Action' => 119, 'Pending AHJ' => 120, 'Pending HOA' => 121, 'Pending Submission' => 122, 'Customer Signature Requested' => 123, 'Customer Signature Received' => 124, 'Customer Action Required' => 125, 'Internal Action Required' => 126, 'Revision Signature Requested' => 127, 'Revision Request Resubmitted' => 128, 'Kickback' => 129, 'Resubmitted' => 130, 'Interconnection Approved' => 131, 'Net Metering Approved' => 132, 'Utility Approval for Install' => 133, 'Meter Ordered' => 134, 'PTO Granted' => 135, 'Document Verification - Pending Review' => 136, 'Document Verification - Incomplete' => 137, 'Document Verification - Incomplete (Reason 1)' => 138, 'Document Verification - Incomplete (Reason 2)' => 139, 'Document Verification - Incomplete (Reason 3)' => 140, 'Document Verification - Documentation Delay' => 141, 'Document Verification - Documentation Delay (Reason 1)' => 142, 'Document Verification - Documentation Delay (Reason 2)' => 143, 'Document Verification - Documentation Delay (Reason 3)' => 144, 'Document Verification - Document Reviewed CRC completed' => 145, 'M0 - Pending NTP' => 146, 'M0 - Submitted' => 147, 'M0 - Kickback' => 148, 'M0 - Pending Invoice' => 149, 'Notice to Proceed' => 150, 'M1 - Pending Submittal' => 151, 'M1 - Submitted' => 152, 'M1 - Kickback' => 153, 'M1 - Approved' => 154, 'M2 - Pending Submittal' => 155, 'M2 - Submtted' => 156, 'M2 - Kickback' => 157, 'M2 - Approved' => 158, 'M3 - Pending Submittal' => 159, 'M3 - Kickback' => 160, 'M3 - Submitted' => 161, 'Project Closed' => 162, 'New- Pending Scheduling' => 163, 'Scheduling Pending Homeowner' => 164, 'Scheduling on Hold- Palmetto' => 165, 'Scheduling on Hold- Homeowner' => 166, 'Installation Scheduled' => 167, 'Installation Reschedule Required' => 168, 'Installation Rescheduled' => 169, 'Installation Completion Required' => 170, 'Installation Completion Scheduled' => 171, 'Installation Complete' => 172
            };
            for(Job__c objJob : [
                    SELECT Id, Flow_Status__c from Job__c 
                    WHERE RecordType.DeveloperName = 'Financing' 
                    AND Opportunity__c IN :setOppId
                    AND Type__c != 'SunRun'])
            {
                //!objJob.Flow_Status__c.containsIgnoreCase('M2') && !objJob.Flow_Status__c.containsIgnoreCase('M3'))
                if(objJob.Flow_Status__c == null || (mapFlowStatusToNumber.containsKey(objJob.Flow_Status__c) && mapFlowStatusToNumber.get(objJob.Flow_Status__c) < 151)){
                    objJob.Flow_Status__c = 'M1 - Pending Submittal';
                    lstJobToUpdate.add(objJob);    
                }
            }
            
            if(!lstJobToUpdate.isEmpty())
                update lstJobToUpdate;
        }
    }
    
    //This method is used to populate the contract received field.
    private void populateContractReceived(List<Job__c> lstJob){
        Id financingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Financing').getRecordTypeId();
        Map<Id, List<Job__c>> mapIdToLstJob = new Map<Id, List<Job__c>>();
        for(Job__c objJob : lstJob){
            if(objJob.RecordTypeId == financingId && objJob.Opportunity__c != null){
                if(mapIdToLstJob.containsKey(objJob.Opportunity__c)){
                    mapIdToLstJob.get(objJob.Opportunity__c).add(objJob);
                } else{
                    mapIdToLstJob.put(objJob.Opportunity__c, new List<Job__c>{objJob});
                }
            }
        }

        if(!mapIdToLstJob.isEmpty()){
            for(Opportunity objOpp : [select Id, (select Id, Days_Since_Contract_Received__c, Loan_Term__c, APR__c from Jobs__r where RecordType.DeveloperName = 'Business_Processing' limit 1) 
                    from Opportunity where Id in :mapIdToLstJob.keyset()])
            {
                if(objOpp.Jobs__r != null && !objOpp.Jobs__r.isEmpty()){
                    for(Job__c objJob : mapIdToLstJob.get(objOpp.Id)){
                        objJob.Days_Since_Contract_Received__c = objOpp.Jobs__r[0].Days_Since_Contract_Received__c;
                        objJob.Loan_Term__c = objOpp.Jobs__r[0].Loan_Term__c;
                        objJob.APR__c = objOpp.Jobs__r[0].APR__c;
                    }
                }
            }
        }
    }
    
    
    //This method is used to populate the Job status.
    private void populateJobStatus(List<Job__c> lstJob){
        for(Job__c objJob : lstJob){
            if(objJob.Flow_Status__c == 'Project Closed'){
                objJob.Job_Status__c = 'Closed';
            }
            objJob.DHB__c = ((objJob.Amount__c == objJob.Account_Balance_IO__c)?'Yes':'No');
            if(objJob.Contract_Received_Confirmed_Illinois__c != null){
                objJob.Credit_Expiration__c = objJob.Contract_Received_Confirmed_Illinois__c.addDays(120);
            }
        }
    }
    
    //This method is used to close the JCO Job when Fin Ops job is closed.
    private void rejectJCOJob(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        Id financingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Financing').getRecordTypeId();
        Set<Id> setOppId = new Set<Id>();
        for(Job__c objJob : lstJob){
            Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
            if(objJob.RecordTypeId == financingId && objJob.Flow_Status__c != objOldJob.Flow_Status__c &&
                (objJob.Flow_Status__c == 'M1 - Kickback' || objJob.Flow_Status__c == 'M2 - Kickback') && objJob.Opportunity__c != null)
            {
                setOppId.add(objJob.Opportunity__c);
            }
        }
        
        if(!setOppId.isEmpty()){
            List<Job__c> lstJobToUpdate = new List<Job__c>();
            for(Job__c objJob : [
                    SELECT Id from Job__c 
                    WHERE RecordType.DeveloperName = 'Job_Close_Out' 
                    AND Opportunity__c IN :setOppId
                    AND Flow_Status__c != 'Rejected - Pending Correction'])
            {
                objJob.Flow_Status__c = 'Rejected - Pending Correction';
                lstJobToUpdate.add(objJob);
            }
            
            if(!lstJobToUpdate.isEmpty())
                update lstJobToUpdate;
        }
    }
    
    //This method is used to close the JCO Job when Fin Ops job is closed.
    private void closeJCOJob(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        Id financingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Financing').getRecordTypeId();
        Set<Id> setOppId = new Set<Id>();
        for(Job__c objJob : lstJob){
            Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
            if(objJob.RecordTypeId == financingId && objJob.Job_Status__c == 'Closed' && objOldJob.Job_Status__c != 'Closed'
                && objJob.Opportunity__c != null)
            {
                setOppId.add(objJob.Opportunity__c);
            }
        }
        
        if(!setOppId.isEmpty()){
            List<Job__c> lstJobToUpdate = new List<Job__c>();
            for(Job__c objJob : [
                    SELECT Id from Job__c 
                    WHERE RecordType.DeveloperName = 'Job_Close_Out' 
                    AND Opportunity__c IN :setOppId
                    AND Job_Status__c != 'Closed'])
            {
                objJob.Job_Status__c = 'Closed';
                lstJobToUpdate.add(objJob);
            }
            
            if(!lstJobToUpdate.isEmpty())
                update lstJobToUpdate;
        }
    }
    
    //This method is used to update documentation notes on related opp.
    private void updateDocumentationNotes(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        Map<Id, String> mapOppIdToNotes = new Map<Id, String>();
        for(Job__c objJob : lstJob){
            Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
            if(objJob.Documentation_Notes__c != objOldJob.Documentation_Notes__c && objJob.Opportunity__c != null && String.isNotBlank(objJob.Documentation_Notes__c)){
                mapOppIdToNotes.put(objJob.Opportunity__c, objJob.Documentation_Notes__c);
            }
        }
        
        if(!mapOppIdToNotes.isEmpty()){
            List<Opportunity> lstOppToUpdate = new List<Opportunity>();
            
            for(Opportunity objOpp : [select Id, Customer_Satisfaction_Install_Notes__c from Opportunity 
                    where Id in :mapOppIdToNotes.keyset()])
            {
                //objOpp.Customer_Satisfaction_Install_Notes__c = mapOppIdToNotes.get(objOpp.Id) + '' + (String.isBlank(objOpp.Customer_Satisfaction_Install_Notes__c)?'':('\n' + objOpp.Customer_Satisfaction_Install_Notes__c));
				objOpp.Customer_Satisfaction_Install_Notes__c = mapOppIdToNotes.get(objOpp.Id);

                lstOppToUpdate.add(objOpp);
            }
            
            if(!lstOppToUpdate.isEmpty())
                update lstOppToUpdate;
        }
    }
    
    //This method is used to call the related job records.
    /*
    private void createJobRecord(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        
        Id siteApprovalId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Design').getRecordTypeId();
        Id documentVerificationId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Document_Verification').getRecordTypeId();
        Map<Id, List<Job__c>> mapOppIdToLstJob = new Map<Id, List<Job__c>>();
        Set<String> setFlowStatus2 = new Set<String>{'Professional Engineering Stamp', 'Final Review', 'Site Approved', 'Document Verification - Document Reviewed CRC completed'};
        for(Job__c objJob : lstJob){
            if(objJob.Opportunity__c != null && (objJob.RecordTypeId == siteApprovalId || objJob.RecordTypeId == documentVerificationId)){
                Boolean criteriaFullFilled = true;
                if(mapIdToOldJob != null){
                    Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
                    if((setFlowStatus2.contains(objJob.Flow_Status__c) && setFlowStatus2.contains(objOldJob.Flow_Status__c)))
                    {
                        criteriaFullFilled = false;
                    }
                }
                if(criteriaFullFilled){
                    if(mapOppIdToLstJob.containsKey(objJob.Opportunity__c)){
                        mapOppIdToLstJob.get(objJob.Opportunity__c).add(objJob);
                    } else{
                        mapOppIdToLstJob.put(objJob.Opportunity__c, new List<Job__c>{objJob});
                    }
                }
            }
        }
        
        if(!mapOppIdToLstJob.isEmpty()){
            Id interconnectionId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Interconnection').getRecordTypeId();
            Id ownerId;
            for(Group objGroup : [select Id from Group where DeveloperName = 'Utility_Team' limit 1]){
                ownerId = objGroup.Id;
            }
            Set<String> setFlowStatus = new Set<String>{'Professional Engineering Stamp', 'Final Review', 'Site Approved'};
            List<Job__c> lstJobToInsert = new List<Job__c>();
            for(Opportunity objOpp : [
                    SELECT Id, Account.Name, 
                        (SELECT Id, RecordType.DeveloperName, Utility_Bill_Upload_within_2_months__c, Usage_Verification_Complete__c, ICA_Docs__c,
                        Homeowners_Insurance_Upload_NC__c, Homeowners_Insurance_Upload_SC__c, ICA_Document_To_Upload_Notarize_Afidavit__c,
                        HOI_Ameren_only_Illinois__c, Consumption_Report_For_less_than_12_mo__c, Flow_Status__c, Location__c
                        FROM Jobs__r 
                        WHERE RecordType.DeveloperName in ('Design', 'Document_Verification', 'Interconnection')) 
                    FROM Opportunity where Id in :mapOppIdToLstJob.keyset()])
            {
                Set<String> setRecordType = new Set<String>();
                Job__c objDocVerificationjob = new Job__c();
                Job__c objSiteApprovaljob = new Job__c();
                Boolean createInterconnectionJob = true;
                for(Job__c objJob : objOpp.Jobs__r){
                    if(objJob.RecordType.DeveloperName == 'Document_Verification'){
                        objDocVerificationjob = objJob;
                        setRecordType.add(objJob.RecordType.DeveloperName);
                    } else if(objJob.RecordType.DeveloperName == 'Design'){
                        objSiteApprovaljob = objJob;
                        setRecordType.add(objJob.RecordType.DeveloperName);
                    }
                    
                    if(objJob.RecordType.DeveloperName == 'Interconnection'){
                        createInterconnectionJob = false;
                    }
                }
                
                if(setRecordType.size() == 2 && createInterconnectionJob){
                    String jobName = objOpp.Account.Name + ' - Interconnection Job';
                    if( objSiteApprovaljob.Location__c == 'New Jersey' && setFlowStatus.contains(objSiteApprovaljob.Flow_Status__c) 
                        && ( ( objDocVerificationjob.Utility_Bill_Upload_within_2_months__c != null 
                                && objDocVerificationjob.Usage_Verification_Complete__c != null 
                                && objDocVerificationjob.ICA_Docs__c != null ) 
                                || (objDocVerificationjob.Flow_Status__c == 'Document Verification - Document Reviewed CRC completed')
                           ) 
                      )
                    {
                        lstJobToInsert.add(getJob(jobName, interconnectionId, ownerId, objOpp.Id));
                    } else if(objSiteApprovaljob.Location__c == 'North Carolina' && setFlowStatus.contains(objSiteApprovaljob.Flow_Status__c) &&
                        ( (objDocVerificationjob.Utility_Bill_Upload_within_2_months__c != null 
                        && objDocVerificationjob.Homeowners_Insurance_Upload_NC__c != null) 
                        || (objDocVerificationjob.Flow_Status__c == 'Document Verification - Document Reviewed CRC completed')
                        ))
                    {
                        lstJobToInsert.add(getJob(jobName, interconnectionId, ownerId, objOpp.Id));
                    } else if(objSiteApprovaljob.Location__c == 'South Carolina' && setFlowStatus.contains(objSiteApprovaljob.Flow_Status__c) &&
                        ( (objDocVerificationjob.Utility_Bill_Upload_within_2_months__c != null 
                            && objDocVerificationjob.Homeowners_Insurance_Upload_SC__c != null)
                        || (objDocVerificationjob.Flow_Status__c == 'Document Verification - Document Reviewed CRC completed')
                        ))
                    {
                        lstJobToInsert.add(getJob(jobName, interconnectionId, ownerId, objOpp.Id));
                    } else if(objSiteApprovaljob.Location__c == 'Massachusetts' && setFlowStatus.contains(objSiteApprovaljob.Flow_Status__c) && 
                        ( (objDocVerificationjob.Utility_Bill_Upload_within_2_months__c != null 
                            && objDocVerificationjob.ICA_Docs__c != null)
                        || (objDocVerificationjob.Flow_Status__c == 'Document Verification - Document Reviewed CRC completed')
                        ))
                    {
                        lstJobToInsert.add(getJob(jobName, interconnectionId, ownerId, objOpp.Id));
                    } else if(objSiteApprovaljob.Location__c == 'Rhode Island' && setFlowStatus.contains(objSiteApprovaljob.Flow_Status__c) && 
                        ( (objDocVerificationjob.Utility_Bill_Upload_within_2_months__c != null 
                            && objDocVerificationjob.ICA_Docs__c != null 
                            && objDocVerificationjob.ICA_Document_To_Upload_Notarize_Afidavit__c != null) 
                         || (objDocVerificationjob.Flow_Status__c == 'Document Verification - Document Reviewed CRC completed')
                        ))
                    {
                        lstJobToInsert.add(getJob(jobName, interconnectionId, ownerId, objOpp.Id));
                    } else if(objSiteApprovaljob.Location__c == 'Pennsylvania' && setFlowStatus.contains(objSiteApprovaljob.Flow_Status__c) && 
                        ( (objDocVerificationjob.Utility_Bill_Upload_within_2_months__c != null 
                            && objDocVerificationjob.ICA_Docs__c != null) 
                        || (objDocVerificationjob.Flow_Status__c == 'Document Verification - Document Reviewed CRC completed')
                        ))
                    {
                        lstJobToInsert.add(getJob(jobName, interconnectionId, ownerId, objOpp.Id));
                    } else if(objSiteApprovaljob.Location__c == 'Connecticut' && setFlowStatus.contains(objSiteApprovaljob.Flow_Status__c) &&
                        ( (objDocVerificationjob.Utility_Bill_Upload_within_2_months__c != null 
                            && objDocVerificationjob.ICA_Docs__c != null) 
                        || (objDocVerificationjob.Flow_Status__c == 'Document Verification - Document Reviewed CRC completed')
                        ) )
                    {
                        lstJobToInsert.add(getJob(jobName, interconnectionId, ownerId, objOpp.Id));
                    } else if(objSiteApprovaljob.Location__c == 'Florida' && setFlowStatus.contains(objSiteApprovaljob.Flow_Status__c) && 
                        objDocVerificationjob.Flow_Status__c == 'Document Verification - Document Reviewed CRC completed')
                    {
                        lstJobToInsert.add(getJob(jobName, interconnectionId, ownerId, objOpp.Id));
                    } else if(objSiteApprovaljob.Location__c == 'Illinois'  && setFlowStatus.contains(objSiteApprovaljob.Flow_Status__c) &&
                        objDocVerificationjob.Flow_Status__c == 'Document Verification - Document Reviewed CRC completed')
                    {
                        lstJobToInsert.add(getJob(jobName, interconnectionId, ownerId, objOpp.Id));
                    } else if(objSiteApprovaljob.Location__c == 'Maryland' && setFlowStatus.contains(objSiteApprovaljob.Flow_Status__c) &&
                        objDocVerificationjob.Flow_Status__c == 'Document Verification - Document Reviewed CRC completed')
                    {
                        lstJobToInsert.add(getJob(jobName, interconnectionId, ownerId, objOpp.Id));
                    } else if(objSiteApprovaljob.Location__c == 'Nevada' && setFlowStatus.contains(objSiteApprovaljob.Flow_Status__c) && 
                        ( (objDocVerificationjob.Utility_Bill_Upload_within_2_months__c != null 
                            && objDocVerificationjob.Usage_Verification_Complete__c != null) 
                        || (objDocVerificationjob.Flow_Status__c == 'Document Verification - Document Reviewed CRC completed')
                        ))
                    {
                        lstJobToInsert.add(getJob(jobName, interconnectionId, ownerId, objOpp.Id));
                    } else if(objSiteApprovaljob.Location__c == 'Texas' && setFlowStatus.contains(objSiteApprovaljob.Flow_Status__c) &&
                        objDocVerificationjob.Flow_Status__c == 'Document Verification - Document Reviewed CRC completed')
                    {
                        lstJobToInsert.add(getJob(jobName, interconnectionId, ownerId, objOpp.Id));
                    } else if(objSiteApprovaljob.Location__c == 'Virginia' && setFlowStatus.contains(objSiteApprovaljob.Flow_Status__c) &&
                        objDocVerificationjob.Flow_Status__c == 'Document Verification - Document Reviewed CRC completed')
                    {
                        lstJobToInsert.add(getJob(jobName, interconnectionId, ownerId, objOpp.Id));
                    } else if(objSiteApprovaljob.Location__c == 'Ohio' && setFlowStatus.contains(objSiteApprovaljob.Flow_Status__c) &&
                        objDocVerificationjob.Flow_Status__c == 'Document Verification - Document Reviewed CRC completed')
                    {
                        lstJobToInsert.add(getJob(jobName, interconnectionId, ownerId, objOpp.Id));
                    } else if(objSiteApprovaljob.Location__c == 'Georgia' && setFlowStatus.contains(objSiteApprovaljob.Flow_Status__c) &&
                        objDocVerificationjob.Flow_Status__c == 'Document Verification - Document Reviewed CRC completed')
                    {
                        lstJobToInsert.add(getJob(jobName, interconnectionId, ownerId, objOpp.Id));
                    } else if(setFlowStatus.contains(objSiteApprovaljob.Flow_Status__c) &&
                        objDocVerificationjob.Flow_Status__c == 'Document Verification - Document Reviewed CRC completed')
                    {
                        lstJobToInsert.add(getJob(jobName, interconnectionId, ownerId, objOpp.Id));
                    }
                }
            }
            
            if(!lstJobToInsert.isEmpty())
                insert lstJobToInsert;
        }
    }
    

    private Job__c getJob(String jobName, Id recordTypeId, Id ownerId, Id oppId){
        Job__c objJob = new Job__c();
        objJob.Type__c = 'Interconnection';
        objJob.Flow_Status__c = 'Pending Submission';
        objJob.Job_Status__c = 'New';
        objJob.Name = jobName;
        objJob.RecordTypeId = recordTypeId;
        objJob.OwnerId = ownerId;
        objJob.Opportunity__c = oppId;
        
        return objJob;
    }*/

    /*
    //This method is used to update App number on interconnection job record.
    private void updateAppNumber(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        Id incentiveId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Incentives').getRecordTypeId();
        Map<Id, String> mapOppIdToApp = new Map<Id, String>();
        for(Job__c objJob : lstJob){
            Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
            if(objJob.RecordTypeId == incentiveId && objJob.App__c != objOldJob.App__c && String.isNotBlank(objJob.App__c) && objJob.Opportunity__c != null){
                mapOppIdToApp.put(objJob.Opportunity__c, objJob.App__c);
            } 
        }
        
        if(!mapOppIdToApp.isEmpty()){
            List<Job__c> lstJobToUpdate = new List<Job__c>();
            for(Opportunity objOpp : [select Id, (select Id, App__c from Jobs__r where RecordType.DeveloperName = 'Interconnection') from Opportunity where Id in :mapOppIdToApp.keyset()]){
                for(Job__c objJob : objOpp.Jobs__r){
                    if(objJob.App__c != mapOppIdToApp.get(objOpp.Id)){
                        objJob.App__c = mapOppIdToApp.get(objOpp.Id);
                        lstJobToUpdate.add(objJob);
                    }
                }
            }
            
            if(!lstJobToUpdate.isEmpty())
                update lstJobToUpdate;
        }
    }
    */

    //This method is called to update the opp stage to 22. PTO.
    /*
    private void updateOppStage(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        Map<Id, Opportunity> mapIdToOpp = new Map<Id, Opportunity>();
        for(Job__c objJob : lstJob){
            Job__c objOldJob = mapIdToOldJob.get(objJob.Id);
            if(objJob.Flow_Status__c == 'M2 - Pending Submittal' && objOldJob.Flow_Status__c != 'M2 - Pending Submittal' && objJob.Opportunity__c != null){
                Opportunity objOpp = new Opportunity();
                objOpp.Id = objJob.Opportunity__c;
                objOpp.StageName = '22. PTO';
                mapIdToOpp.put(objOpp.Id, objOpp);
            } 
        }
        
        if(!mapIdToOpp.isEmpty())
            update mapIdToOpp.values();
    }*/
    
    //This method is used to populate job fields if job record type = financing.
    private void populateJobFields(List<Job__c> lstJob){
        Map<Id, List<Job__c>> mapOppIdToLstJob = new Map<Id, List<Job__c>>();
        for(Job__c objJob : lstJob){
            if(objJob.Opportunity__c != null){
                if(mapOppIdToLstJob.containsKey(objJob.Opportunity__c)){
                    mapOppIdToLstJob.get(objJob.Opportunity__c).add(objJob);
                } else{
                    mapOppIdToLstJob.put(objJob.Opportunity__c, new List<Job__c>{objJob});
                }
            }
        }
        
        if(!mapOppIdToLstJob.isEmpty()){
            Id financingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Financing').getRecordTypeId();
            for(Opportunity objOpp : [select Id, Amount, Financing_Tool__c, Account.celigo_sfnsio__Account_Balance__c 
                    from Opportunity where Id in :mapOppIdToLstJob.keyset()])
            {
                for(Job__c objJob : mapOppIdToLstJob.get(objOpp.Id)){
                    if(objJob.RecordTypeId == financingId){
                        objJob.Account_Balance__c = objOpp.Account.celigo_sfnsio__Account_Balance__c;
                        if(objOpp.Financing_Tool__c == 'Sunlight' || objOpp.Financing_Tool__c == 'Loanpal' || objOpp.Financing_Tool__c == 'Loan Pal' || objOpp.Financing_Tool__c == 'Dividend Loan' || objOpp.Financing_Tool__c == 'Mosaic Loan'){
                            objJob.Type__c = 'Loan except Sunnova';
                        } else if(objOpp.Financing_Tool__c == 'Sunnova Lease' || objOpp.Financing_Tool__c == 'Sunnova Loan/Ownership'){
                            objJob.Type__c = 'Sunnova';
                        } else if(objOpp.Financing_Tool__c == 'Sunrun Lease'){
                            objJob.Type__c = 'SunRun';
                        }
                    }
                    //Code to populate all default fields.
                }
            }
        }
    }

    public void updateDocumentVerificationMilestone(List<Job__c> jobs, Map<Id, Job__c> oldJobsMap) {
        Id documentVerificationId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Document_Verification').getRecordTypeId();
        Set<Id> oppsIds = new Set<Id>();
        Boolean changedIcaDocs = false, documentationReviewed = false, changedUtilityBill = false, changedHOADisclosure = false;
        List<Project_Milestone__c> milestonesToUpdate = new List<Project_Milestone__c>();

        for(Job__c newJob : jobs) {
            Job__c oldJob = oldJobsMap.get(newJob.Id);
            oppsIds.add(newJob.Opportunity__c);

            if(newJob.RecordTypeId == documentVerificationId){
                if(newJob.ICA_Docs__c != oldJob.ICA_Docs__c && newJob.ICA_Docs__c != null && oldJob.ICA_Docs__c == null) {
                    changedIcaDocs = true;
                }

                if(newJob.Utility_Bill_Upload_within_2_months__c != oldJob.Utility_Bill_Upload_within_2_months__c && newJob.Utility_Bill_Upload_within_2_months__c != null && oldJob.Utility_Bill_Upload_within_2_months__c == null) {
                    changedUtilityBill = true;
                }

                if(newJob.HOA_Disclosure__c != oldJob.HOA_Disclosure__c && newJob.HOA_Disclosure__c != null && oldJob.HOA_Disclosure__c == null) {
                    changedHOADisclosure = true;
                }

                if(newJob.Flow_Status__c != oldJob.Flow_Status__c && newJob.Flow_Status__c != null && newJob.Flow_Status__c == 'Document Verification - Document Reviewed CRC completed') {
                    documentationReviewed = true;
                }
            }
        }

        for(Project_Milestone__c aProjectMilestone : [
            SELECT Id
            FROM Project_Milestone__c
            WHERE Opportunity__c IN :oppsIds
        ]){
            if(changedIcaDocs) aProjectMilestone.ICA_Documents_On_File_Date_Milestone__c = Datetime.now();
            if(changedUtilityBill) aProjectMilestone.Utility_Bill_on_File_Date_Milestone__c = Datetime.now();
            if(changedHOADisclosure) aProjectMilestone.HOA_Disclosure_On_File_Date_Milestone__c = Datetime.now();
            if(documentationReviewed) aProjectMilestone.All_Documentation_Reviewed_and_Confirmed__c = Datetime.now();

            milestonesToUpdate.add(aProjectMilestone);
        }

        if(milestonesToUpdate.size() > 0) UPDATE milestonesToUpdate;

    }
    
    private void populateMilestoneQCFields(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        Id jcoId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Job_Close_Out').getRecordTypeId();
        Set<String> setFlowStatus = new Set<String>();
        setFlowStatus.add('QC Approved Complete');
        setFlowStatus.add('QC Approved With Exceptions');
        setFlowStatus.add('QC Approved - Field Remedies Needed');

        Set<Id> setOppId = new Set<Id>();
        Map<Id,Job__c> jobsByOpsIds = new Map<Id,Job__c>();
        for(Job__c objJob : lstJob){
            if(objJob.RecordTypeId == jcoId && objJob.Opportunity__c != null)
            {
                if(setFlowStatus.contains(objJob.Flow_Status__c) && 
                mapIdToOldJob.get(objJob.Id).Flow_Status__c != 'QC Approved Complete'){
                    jobsByOpsIds.put(objJob.Opportunity__c,objJob);
                }
            }
        }

        if(!jobsByOpsIds.isEmpty()){
            List<Project_Milestone__c> lstRadiusToUpdate = new List<Project_Milestone__c>();
            for(Opportunity objOpp : [
                SELECT Id,
                    (SELECT Id, QC_Approval_Final_Date_Milestone__c, QC_Approval_Preliminary_Date_Milestone__c
                    FROM Project_Milestones__r)
                FROM Opportunity
                WHERE Id IN :jobsByOpsIds.keySet()
            ]){
                for(Project_Milestone__c objRadius : objOpp.Project_Milestones__r){
                    if(setFlowStatus.contains(jobsByOpsIds.get(objOpp.Id).Flow_Status__c) && objRadius.QC_Approval_Preliminary_Date_Milestone__c == null){
                        objRadius.QC_Approval_Preliminary_Date_Milestone__c = Datetime.now();
                    }
                    if(jobsByOpsIds.get(objOpp.Id).Flow_Status__c == 'QC Approved Complete' && objRadius.QC_Approval_Final_Date_Milestone__c == null){
                        objRadius.QC_Approval_Final_Date_Milestone__c = Datetime.now();
                    }
                    lstRadiusToUpdate.add(objRadius);
                }
            }
            if(!lstRadiusToUpdate.isEmpty()){
                update lstRadiusToUpdate;
            }
        }
    }

    private void createInterconnectionJob(List<Job__c> jobs, Map<Id, Job__c> oldsJobs) {
        Id siteApprovalId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Design').getRecordTypeId();
        Id interconnectionId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Interconnection').getRecordTypeId();
        Set<String> setFlowStatus = new Set<String>();
        setFlowStatus.add('Professional Engineering Stamp');
        setFlowStatus.add('Final Review');
        setFlowStatus.add('Site Approved');

        Set<Id> setOppId = new Set<Id>();
        List<Job__c> jobsToInsert = new List<Job__c>();
        
        for(Job__c aJob : jobs) {
            Job__c oldJob = oldsJobs.get(aJob.Id);
            
            if(aJob.RecordTypeId == siteApprovalId && 
            aJob.Opportunity__c != null &&
            setFlowStatus.contains(aJob.Flow_Status__c) && 
            aJob.Flow_Status__c != oldJob.Flow_Status__c) {
                setOppId.add(aJob.Opportunity__c);
            }
        }

        for(Opportunity anOpportunity : [
            SELECT Id, Account.Name, OwnerId,
                (
                    SELECT Id
                    FROM Jobs__r
                    WHERE RecordTypeId = :interconnectionId
                ),
                (
                    SELECT Id, All_Documentation_Reviewed_and_Confirmed__c
                    FROM Project_Milestones__r
                )
            FROM Opportunity
            WHERE Id IN :setOppId
        ]) {

            if( (anOpportunity.Jobs__r == null || anOpportunity.Jobs__r.isEmpty()) && 
            (anOpportunity.Project_Milestones__r != null || !anOpportunity.Project_Milestones__r.isEmpty()) ){
                if(anOpportunity.Project_Milestones__r[0].All_Documentation_Reviewed_and_Confirmed__c != null) {
                    Job__c newJob = new Job__c();
                    newJob.Type__c = 'Interconnection';
                    newJob.Flow_Status__c = 'Pending Submission';
                    newJob.Job_Status__c = 'New';
                    newJob.Name = anOpportunity.Account.Name + ' - Interconnection Job';
                    newJob.RecordTypeId = interconnectionId;
                    newJob.OwnerId = anOpportunity.OwnerId;
                    newJob.Opportunity__c = anOpportunity.Id;
                    jobsToInsert.add(newJob);
                }
            }
        }

        if(!jobsToInsert.isEmpty()) INSERT jobsToInsert;
    }
    
	private void populateInterconnectionDatesFromFlowStatus(List<Job__c> jobs, Map<Id, Job__c> oldsJobs) {
        Id interconnectionId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Interconnection').getRecordTypeId();
        Set<String> setFlowStatus = new Set<String>();
        setFlowStatus.add('Pending Submission');
        setFlowStatus.add('Docket Number Requested');
        setFlowStatus.add('Customer Signature Requested');
        setFlowStatus.add('Customer Signature Received');
        setFlowStatus.add('Customer Action Required');
        setFlowStatus.add('Internal Action Required');
        setFlowStatus.add('Revision Signature Requested');
        setFlowStatus.add('Revision Request Resubmitted');
        setFlowStatus.add('Submitted');
        setFlowStatus.add('Final Signature Pending');
        setFlowStatus.add('Resubmitted');
        setFlowStatus.add('Interconnection Approved');
        setFlowStatus.add('Net Metering Approved');
        setFlowStatus.add('Utility Approval for Install');

        Boolean isNew = oldsJobs == null ? true : false;

        for(Job__c newJob : jobs){
            if(newJob.RecordTypeId == interconnectionId &&
            setFlowStatus.contains(newJob.Flow_Status__c) ) {
                String fieldToChange = buildFieldName(newJob.Flow_Status__c);
                if(isNew) {
                    newJob.put(fieldToChange, Date.today());
                } else {
                    Job__c oldJob = oldsJobs.get(newJob.Id);
                    if( newJob.Flow_Status__c != oldJob.Flow_Status__c) {
                        newJob.put(fieldToChange, Date.today());
                    }
                }
            }
        }
    }

    private String buildFieldName(String flowStatus) {
        String fieldName;
        
        if(flowStatus == 'Pending Submission') {
            fieldName = 'Pending_Submission__c';
        } else {
            fieldName = flowStatus.replace(' ', '_') + '_Date__c';
        }
        return fieldName;
    }

    private void sendJobAssignmentData(List<Job__c> lstJob, Map<Id, Job__c> mapIdToOldJob){
        Set<Id> lstJobsToSend = new Set<Id>();
        for(Job__c objJob : lstJob){
            if(objJob.Build_Partner__c != null && (mapIdToOldJob == null || mapIdToOldJob.get(objJob.Id).Build_Partner__c != objJob.Build_Partner__c)){
                lstJobsToSend.add(objJob.Id);
            }
        }
        if(!lstJobsToSend.isEmpty()){
            PalmettoAPIService.sendJobData(lstJobsToSend);
        }
    }

    private void populateContractReceivedConfirmedMilestone(List<Job__c> newJobs, Map<Id,Job__c> oldJobs){
        Id documentVerificationId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Document_Verification').getRecordTypeId();
        Set<Id> setOppId = new Set<Id>();
        List<Project_Milestone__c> listPMToUpdate = new List<Project_Milestone__c>();

        for(Job__c newJob : newJobs) {
            if(newJob.Opportunity__c != null && 
            newJob.RecordTypeId == documentVerificationId &&
            newJob.Flow_Status__c == 'Document Verification - Document Reviewed CRC Completed') {
                if( oldJobs == null || newJob.Flow_Status__c != oldJobs.get(newJob.Id).Flow_Status__c){
                    setOppId.add(newJob.Opportunity__c);
                }
            }
        }

        for(Project_Milestone__c aProjectMilestone : [
            SELECT Id, Contract_Received_Confirmed_Milestone__c
            FROM Project_Milestone__c
            WHERE Opportunity__c = :setOppId
        ]) {
            if(aProjectMilestone.Contract_Received_Confirmed_Milestone__c == null) {
                aProjectMilestone.Contract_Received_Confirmed_Milestone__c = Datetime.now();
                listPMToUpdate.add(aProjectMilestone);
            }
        }

        if( !listPMToUpdate.isEmpty() ) UPDATE listPMToUpdate;

    }
}