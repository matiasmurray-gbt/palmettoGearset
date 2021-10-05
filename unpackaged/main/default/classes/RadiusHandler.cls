public class RadiusHandler
{
    static Boolean createPermittingJob = true;
    //This method is called on before update event of trigger.
    public void onBeforeUpdate(List<Project_Milestone__c> lstRadius, Map<Id, Project_Milestone__c> mapIdToOldRadius){
        calculateDesignMilestone(lstRadius);
    }
    //This method is called on after update event of trigger.
    public void onAfterUpdate(List<Project_Milestone__c> lstRadius, Map<Id, Project_Milestone__c> mapIdToOldRadius){
        createSiteApproval(lstRadius, mapIdToOldRadius);
        if(createPermittingJob == true){
            createPermittingJob(lstRadius, mapIdToOldRadius);
        }
        createInstallationJob(lstRadius, mapIdToOldRadius);
        createInspectionJob(lstRadius, mapIdToOldRadius);
        createSupplyChainJob(lstRadius, mapIdToOldRadius);
        createPTOJob(lstRadius, mapIdToOldRadius);
        createFinancingJob(lstRadius, mapIdToOldRadius);
        createDesignCase(lstRadius, mapIdToOldRadius);
        createInterconnectionJob(lstRadius, mapIdToOldRadius);
        createStateCertificationJob(lstRadius, mapIdToOldRadius);
        
        TriggerConfiguration__c objTriggerConfigCS = TriggerConfiguration__c.getInstance('Order API Trigger');
        
        if(objTriggerConfigCS != null && objTriggerConfigCS.Active__c){
            postMilestoneData(lstRadius, mapIdToOldRadius);
        }
    }
    
    //This method is used to create the PTO Job record when Inspection Completed - Milestone is populated.
    private void createPTOJob(List<Project_Milestone__c> lstRadius, Map<Id, Project_Milestone__c> mapIdToOldRadius){
        // && objRadius.Lease_Loan_M1_Approval_Milestone__c != null
        Set<Id> setOppId = new Set<Id>();
        for(Project_Milestone__c objRadius : lstRadius){
            Project_Milestone__c objOldRadius = mapIdToOldRadius.get(objRadius.Id);
            if(objRadius.Inspection_Complete_Milestone__c != null
                && objRadius.Inspection_Complete_Milestone__c != objOldRadius.Inspection_Complete_Milestone__c)
            {
                setOppId.add(objRadius.Opportunity__c);
            }
        }
        
        if(!setOppId.isEmpty()){
            List<Job__c> lstJobToInsert = new List<Job__c>();
            Id ptoID = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('PTO').getRecordTypeId();   
            for(Opportunity objOpp : [SELECT Id, Name, OwnerId, Contact__r.Name, Contact__c,
                    (SELECT Id 
                        FROM Jobs__r 
                        WHERE RecordType.DeveloperName = 'PTO' 
                        LIMIT 1)
                    FROM Opportunity
                    WHERE Id IN :setOppId])
            {
                if(objOpp.Jobs__r == null || objOpp.Jobs__r.isEmpty()){
                    String jobName = objOpp.Name + ' - PTO Job';
                    Job__c objJob = new Job__c();
                    objJob.Name = jobName;
                    objJob.RecordTypeId = ptoID;
                    objJob.Automation__c = true;
                    objJob.Job_Status__c = 'New';
                    objJob.Opportunity__c = objOpp.Id;
                    objJob.OwnerId = objOpp.OwnerId;
                    objJob.Type__c = 'PTO';
                    objJob.Flow_Status__c = 'Pending Submission';
                    lstJobToInsert.add(objJob);
                }
            }
            if(!lstJobToInsert.isEmpty())
                insert lstJobToInsert;
        }
    }
    
    //This method is used to create the Supply Chain job record when Contract Signed - Milestone is populated.
    private void createSupplyChainJob(List<Project_Milestone__c> lstRadius, Map<Id, Project_Milestone__c> mapIdToOldRadius){
        Set<Id> setOppId = new Set<Id>();
        for(Project_Milestone__c objRadius : lstRadius){
            Project_Milestone__c objOldRadius = mapIdToOldRadius.get(objRadius.Id);
            if(objRadius.Contract_Signed_Milestone__c != null && objOldRadius.Contract_Signed_Milestone__c == null){
                setOppId.add(objRadius.Opportunity__c);
            }
        }
        
        if(!setOppId.isEmpty()){
            List<Job__c> lstJobToInsert = new List<Job__c>();
            Id supplyChainId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Supply_Chain').getRecordTypeId(); 
            for(Opportunity objOpp : [SELECT Id, Name, OwnerId, Fulfillment_Method__c, NetSuite_Inventory_Location__c, 
                    Materials_Direct_To_Site_Confirmation__c, Contact__r.Name, Contact__c, Materials_Direct_To_Site_Instructions__c,
                    (SELECT Id 
                        FROM Jobs__r 
                        WHERE RecordType.DeveloperName = 'Supply_Chain' 
                        LIMIT 1)
                    FROM Opportunity
                    WHERE Id IN :setOppId])
            {
                if(objOpp.Jobs__r == null || objOpp.Jobs__r.isEmpty()){
                    String jobName = (String.isNotBlank(objOpp.Contact__c)?(objOpp.Contact__r.Name + ' - '):'') + 'Supply Chain';
                    Job__c objJob = new Job__c();
                    objJob.Name = jobName;
                    objJob.RecordTypeId = supplyChainId;
                    objJob.Job_Status__c = 'New';
                    objJob.Opportunity__c = objOpp.Id;
                    objJob.OwnerId = objOpp.OwnerId;
                    objJob.Type__c = 'PV Materials Verification';
                    objJob.Flow_Status__c = 'Awaiting Design';
                    objJob.Fulfillment_Method__c = objOpp.Fulfillment_Method__c;
                    objJob.Materials_Direct_To_Site_Instructions__c = objOpp.Materials_Direct_To_Site_Instructions__c;
                    objJob.Materials_Direct_To_Site_Confirmation__c = objOpp.Materials_Direct_To_Site_Confirmation__c;
                    objJob.NetSuite_Inventory_Location__c = objOpp.NetSuite_Inventory_Location__c;
                    lstJobToInsert.add(objJob);
                }
            }
            
            if(!lstJobToInsert.isEmpty())
                insert lstJobToInsert;
        }
    }
    
    //This method is used to create the Inspection job record when Installation Completed - Milestone is populated.
    private void createInspectionJob(List<Project_Milestone__c> lstRadius, Map<Id, Project_Milestone__c> mapIdToOldRadius){
        Set<Id> setOppId = new Set<Id>();
        for(Project_Milestone__c objRadius : lstRadius){
            Project_Milestone__c objOldRadius = mapIdToOldRadius.get(objRadius.Id);
            if(objRadius.Installation_Completed_Milestone__c != null && objOldRadius.Installation_Completed_Milestone__c == null){
                setOppId.add(objRadius.Opportunity__c);
            }
        }
        
        if(!setOppId.isEmpty()){
            List<Job__c> lstJobToInsert = new List<Job__c>();
            List<Job__c> lstJobToUpdate = new List<Job__c>();
            Id inspectionId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Inspection').getRecordTypeId();   
            for(Opportunity objOpp : [SELECT Id, Name, OwnerId, Site_Audit_Completed_By__c, Contact__r.Name, Contact__c,
                    (SELECT Id, RecordType.DeveloperName, Flow_Status__c
                        FROM Jobs__r 
                        WHERE (RecordType.DeveloperName = 'Inspection' OR RecordType.DeveloperName = 'Supply_Chain' )
                        LIMIT 1)
                    FROM Opportunity
                    WHERE Id IN :setOppId])
            {
                Boolean createInspectionJob = true;
                if(objOpp.Jobs__r != null && !objOpp.Jobs__r.isEmpty()){
                    for(Job__c objJob : objOpp.Jobs__r){
                        if(objJob.RecordType.DeveloperName == 'Inspection'){
                            createInspectionJob = false;
                        }
                        
                        if(objJob.RecordType.DeveloperName == 'Supply_Chain' && objJob.Flow_Status__c != 'Fulfilled'){
                            objJob.Flow_Status__c = 'Fulfilled';
                            lstJobToUpdate.add(objJob);
                        }
                    }
                }
            
                if(createInspectionJob){
                    String jobName = (String.isNotBlank(objOpp.Contact__c)?(objOpp.Contact__r.Name + ' - '):'') + 'Inspection';
                    Job__c objJob = new Job__c();
                    objJob.Name = jobName;
                    objJob.RecordTypeId = inspectionId;
                    objJob.Job_Status__c = 'New';
                    objJob.Opportunity__c = objOpp.Id;
                    objJob.OwnerId = System.Label.Permitting;
                    objJob.Type__c = 'Inspection';
                    objJob.Flow_Status__c = 'Installation Complete- Pending Scheduling';
                    objJob.Automation__c = true;
                    lstJobToInsert.add(objJob);
                }
            }
            
            if(!lstJobToInsert.isEmpty())
                insert lstJobToInsert;
            if(!lstJobToUpdate.isEmpty())
                update lstJobToUpdate;
        }
    }
    
    //This method is used to create the Installation job record when Permit Submitted milestone is populated.
    private void createInstallationJob(List<Project_Milestone__c> lstRadius, Map<Id, Project_Milestone__c> mapIdToOldRadius){

        List<String> oppStages = new List<String>();
        oppStages.add('20. Inspection Scheduled');
        oppStages.add('21. Inspection Complete');
        oppStages.add('22. PTO');
        oppStages.add('Closed Won');
        oppStages.add('Cancelled');
        oppStages.add('Closed Lost');

        Set<Id> setOppId = new Set<Id>();
        for(Project_Milestone__c objRadius : lstRadius){
            Project_Milestone__c objOldRadius = mapIdToOldRadius.get(objRadius.Id);
            if(objRadius.Permit_Submitted_Milestone__c != null && objOldRadius.Permit_Submitted_Milestone__c == null){
                setOppId.add(objRadius.Opportunity__c);
            }
        }
        
        if(!setOppId.isEmpty()){
            List<Job__c> lstJobToInsert = new List<Job__c>();
            
            Id installationSchedulingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Installation_Scheduling').getRecordTypeId();   
            for(Opportunity objOpp : [
                SELECT Id, Name, OwnerId, Site_Audit_Completed_By__c, Contact__r.Name, Contact__c, StageName, Installation_Complete_Date__c,
                    (SELECT Id 
                        FROM Jobs__r 
                        WHERE RecordType.DeveloperName = 'Installation_Scheduling' 
                        LIMIT 1)
                    FROM Opportunity
                    WHERE Id IN :setOppId
                ])
            {
                if(objOpp.Jobs__r == null || objOpp.Jobs__r.isEmpty() && !oppStages.contains(objOpp.StageName) && objOpp.Installation_Complete_Date__c == null){
                    String jobName = (String.isNotBlank(objOpp.Contact__c)?(objOpp.Contact__r.Name + ' - '):'') + 'Installation Scheduling';
                    Job__c objJob = new Job__c();
                    objJob.Name = jobName;
                    objJob.RecordTypeId = installationSchedulingId;
                    objJob.Job_Status__c = 'New';
                    objJob.Opportunity__c = objOpp.Id;
                    objJob.OwnerId = System.Label.Scheduling_Team;
                    objJob.Subject__c = 'Installation Scheduling';
                    objJob.Type__c = 'Installation Scheduling';
                    objJob.Flow_Status__c = 'Preparing for Scheduling';
                    objJob.Automation__c = true;
                    lstJobToInsert.add(objJob);
                }
            }
            
            if(!lstJobToInsert.isEmpty())
                insert lstJobToInsert;
        }
    }
    
    //This method is used to create the Permitting job record when design queued milestone is populated.
    private void createPermittingJob(List<Project_Milestone__c> lstRadius, Map<Id, Project_Milestone__c> mapIdToOldRadius){
        Set<Id> setOppId = new Set<Id>();
        for(Project_Milestone__c objRadius : lstRadius){
            Project_Milestone__c objOldRadius = mapIdToOldRadius.get(objRadius.Id);
            if(objRadius.Design_Completed_Milestone__c != null && objOldRadius.Design_Completed_Milestone__c == null){
                setOppId.add(objRadius.Opportunity__c);
            }
        }
        
        if(!setOppId.isEmpty()){
            List<Job__c> lstJobToInsert = new List<Job__c>();
            List<Job__c> lstJobToUpdate = new List<Job__c>();
            Id PermittingId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Permitting').getRecordTypeId();   
            for(Opportunity objOpp : [SELECT Id, Name, OwnerId, Site_Audit_Completed_By__c,
                    (SELECT Id, Flow_Status__c, RecordType.DeveloperName 
                        FROM Jobs__r 
                        WHERE (RecordType.DeveloperName = 'Permitting' OR RecordType.DeveloperName = 'Supply_Chain')
                        LIMIT 1)
                    FROM Opportunity
                    WHERE Id IN :setOppId])
            {       
                Boolean createPermittingJob = true;     
                if(objOpp.Jobs__r != null && !objOpp.Jobs__r.isEmpty()){
                    for(Job__c objJob : objOpp.Jobs__r){
                        if(objJob.RecordType.DeveloperName == 'Permitting'){
                            createPermittingJob = false;
                        }
                        
                        if(objJob.RecordType.DeveloperName == 'Supply_Chain' && objJob.Flow_Status__c != 'Awaiting BOM Verification'){
                            objJob.Flow_Status__c = 'Design / BOM Complete';
                            lstJobToUpdate.add(objJob);
                        }
                    }
                }
                
                if(createPermittingJob){
                    Job__c objJob = new Job__c();
                    objJob.Name = objOpp.Name + ' - Permitting Job';
                    objJob.RecordTypeId = PermittingId;
                    objJob.Job_Status__c = 'New';
                    objJob.Opportunity__c = objOpp.Id;
                    objJob.OwnerId = objOpp.OwnerId;
                    objJob.Type__c = 'Permit Issuance';
                    objJob.Flow_Status__c = 'Pending Submittal to AHJ';
                    objJob.Automation__c = true;
                    lstJobToInsert.add(objJob);
                }
            }
            
            if(!lstJobToInsert.isEmpty()){
                insert lstJobToInsert;
                createPermittingJob = false;
            }
            
            if(!lstJobToUpdate.isEmpty()){
                update lstJobToUpdate;
            }
        }
    }
    
    //This method is used to create the site approval job record when design queued milestone is populated.
    private void createSiteApproval(List<Project_Milestone__c> lstRadius, Map<Id, Project_Milestone__c> mapIdToOldRadius){
        Set<Id> setOppId = new Set<Id>();
        for(Project_Milestone__c objRadius : lstRadius){
            Project_Milestone__c objOldRadius = mapIdToOldRadius.get(objRadius.Id);
            if(objRadius.Design_Queued_Milestone__c != null && objOldRadius.Design_Queued_Milestone__c == null){
                setOppId.add(objRadius.Opportunity__c);
            }
        }
        
        if(!setOppId.isEmpty()){
            List<Job__c> lstJobToInsert = new List<Job__c>();
            Map<Id, Opportunity> mapOppById = new Map<Id,Opportunity>();
            
            Id siteApprovalId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Design').getRecordTypeId();   
            for(Opportunity objOpp : [SELECT Id, Contact__c, Contact__r.FirstName, Contact__r.LastName, Site_Audit_Completed_By__c, Site_Audit_Completed_By_BP__c,
                    (SELECT Id 
                        FROM Jobs__r 
                        WHERE RecordType.DeveloperName = 'Design' 
                        LIMIT 1)
                    FROM Opportunity
                    WHERE Id IN :setOppId])
            {
                if(objOpp.Jobs__r == null || objOpp.Jobs__r.isEmpty()){
                    Job__c objJob = new Job__c();
                    objJob.Name = (objOpp.Contact__c == null?'':(objOpp.Contact__r.FirstName + ' ' + objOpp.Contact__r.LastName + ' - ')) + 'Site Approval';
                    objJob.RecordTypeId = siteApprovalId;
                    objJob.Job_Status__c = 'New';
                    objJob.Opportunity__c = objOpp.Id;
                    objJob.OwnerId = System.Label.Project_Engineers;
                    objJob.Site_Audit_Completed_By__c = objOpp.Site_Audit_Completed_By__c;
                    objJob.Type__c = 'Site Approval';
                    objJob.Flow_Status__c = 'Not Started';
                    objJob.Automation__c = true;
                    lstJobToInsert.add(objJob);
                    mapOppById.put(objOpp.Id,objOpp);
                }
            }
            
            if(!lstJobToInsert.isEmpty())
                insert lstJobToInsert;
                createJobAssignTo(lstJobToInsert,mapOppById);
        }
    }
    
    //This method is used to calculate max date time value and set in design queued milestone field.
    private void calculateDesignMilestone(List<Project_Milestone__c> lstRadius){
        
        for(Project_Milestone__c objRadius : lstRadius){
            if(objRadius.Survey_Complete_Confirmed__c != null && objRadius.Energy_Bill_checked__c != null && objRadius.Contract_Received_Milestone__c != null){
                Datetime surveyCompleteDate = (objRadius.Survey_Complete_Confirmed__c == null?Datetime.now().addYears(-3):objRadius.Survey_Complete_Confirmed__c);
                Datetime energyBillDate = (objRadius.Energy_Bill_checked__c == null?Datetime.now().addYears(-3):objRadius.Energy_Bill_checked__c);
                Datetime contractReceivedDate = (objRadius.Contract_Received_Milestone__c == null?Datetime.now().addYears(-3):objRadius.Contract_Received_Milestone__c);
            
                if(surveyCompleteDate > energyBillDate && surveyCompleteDate > contractReceivedDate)
                    objRadius.Design_Queued_Milestone__c = surveyCompleteDate;
                if(energyBillDate > surveyCompleteDate && energyBillDate > contractReceivedDate)
                    objRadius.Design_Queued_Milestone__c = energyBillDate;
                if(contractReceivedDate > energyBillDate && contractReceivedDate > surveyCompleteDate)
                    objRadius.Design_Queued_Milestone__c = contractReceivedDate;
            }
        }
    }
    
    //This method is used to check which milestone is populated
    private void postMilestoneData(List<Project_Milestone__c> lstProjectMilestone, Map<Id, Project_Milestone__c> mapIdToOldMilestone){
        Map<String, String> mapMilestoneFieldToStatus = new Map<String, String>();
        mapMilestoneFieldToStatus.put('Contract_Signed_Milestone__c', 'contractSigned');
        mapMilestoneFieldToStatus.put('Contract_Received_Milestone__c', 'contractReceived');
        mapMilestoneFieldToStatus.put('Site_Survey_Completed_Milestone__c', 'surveyCompleted');
        mapMilestoneFieldToStatus.put('Design_Completed_Milestone__c', 'engineeringDesignComplete');
        mapMilestoneFieldToStatus.put('Permit_Received_Milestone__c', 'permitReceived');
        mapMilestoneFieldToStatus.put('Installation_Started_Milestone__c', 'installStarted');
        mapMilestoneFieldToStatus.put('Installation_Completed_Milestone__c', 'installComplete');
        mapMilestoneFieldToStatus.put('Inspection_Complete_Milestone__c', 'townInspectionComplete');
        mapMilestoneFieldToStatus.put('PTO_Complete_Milestone__c', 'permissionToOperateApproved');
        mapMilestoneFieldToStatus.put('Interconnection_Application_Submitted__c', 'interconnectionSubmitted');
        mapMilestoneFieldToStatus.put('Interconnection_Application_Approved__c', 'interconnectionApproved');
        mapMilestoneFieldToStatus.put('Installation_Scheduled_Milestone__c', 'installScheduled');
        mapMilestoneFieldToStatus.put('Installation_Ready_Milestone__c', 'installReady');
        
        Map<Id, String> mapOppIdToStatus = new Map<Id, String>();
        
        for(Project_Milestone__c objProjectMilestone : lstProjectMilestone){
            Project_Milestone__c objOldProjectMilestone = mapIdToOldMilestone.get(objProjectMilestone.Id);
            
            for(String fieldAPI : mapMilestoneFieldToStatus.keyset()){
                if(objProjectMilestone.get(fieldAPI) != null 
                    && objProjectMilestone.get(fieldAPI) != objOldProjectMilestone.get(fieldAPI))
                {
                    String orderStatus = mapMilestoneFieldToStatus.get(fieldAPI);
                    mapOppIdToStatus.put(objProjectMilestone.Opportunity__c, orderStatus);
                    break;
                }
            }
        }
        
        if(!mapOppIdToStatus.isEmpty() && !System.isBatch()){
            PalmettoAPIService.sendOrderStatus(mapOppIdToStatus);
        }
    }
    
    public void createFinancingJob(List<Project_Milestone__c> projectMilestones, Map<Id, Project_Milestone__c> oldMilestones) {
        Id financingId = Schema.SObjectType.Job__c
            .getRecordTypeInfosByDeveloperName()
            .get('Financing')
            .getRecordTypeId();

        Id thirdPartyDesignSalesId = Schema.SObjectType.Opportunity
            .getRecordTypeInfosByDeveloperName()
            .get('X3rd_Party_Design_Sales')
            .getRecordTypeId();
        
        Id storageId = Schema.SObjectType.Opportunity
            .getRecordTypeInfosByDeveloperName()
            .get('Storage')
            .getRecordTypeId();

        Id finOpsQueueId = [SELECT Id FROM Group WHERE Name = 'FinOps' AND Type = 'Queue'][0].Id;
        
        Set<Id> oppsIds = new Set<Id>();
        Map<Id, Opportunity> oppsMap = new Map<Id, Opportunity>();
        List<Job__c> jobsToCreate = new List<Job__c>();

        for (Project_Milestone__c aProjectMilestone : projectMilestones) {
            oppsIds.add(aProjectMilestone.Opportunity__c);
        }

        for(Opportunity anOpportunity : [
            SELECT Id, Name, Financing_Tool__c, Contact__r.FirstName, Contact__r.LastName, Contact__c, Channel_Partner__c, Channel_Partner__r.Name,
            (
                SELECT Id
                FROM Jobs__r
                WHERE RecordTypeId = :financingId
            )
            FROM Opportunity
            WHERE Id IN :oppsIds
            AND (RecordTypeId = :thirdPartyDesignSalesId OR RecordTypeId = :storageId)
        ]) {
            if(anOpportunity.Jobs__r.size() == 0) {
                
                oppsMap.put(anOpportunity.Id, anOpportunity);
            }
        }

        for (Project_Milestone__c aProjectMilestone : projectMilestones) {
            Project_Milestone__c oldMilestone = oldMilestones.get(aProjectMilestone.Id);

            if(aProjectMilestone.Design_Queued_Milestone__c != null &&
            oldMilestone.Design_Queued_Milestone__c == null &&
            aProjectMilestone.Design_Queued_Milestone__c != oldMilestone.Design_Queued_Milestone__c && 
            oppsMap.get(aProjectMilestone.Opportunity__c) != null) {

                Opportunity anOpportunity = oppsMap.get(aProjectMilestone.Opportunity__c);
                Job__c newJob = new Job__c();
                newJob.Name = anOpportunity.Contact__c != null ? anOpportunity.Contact__r.FirstName + ' ' + anOpportunity.Contact__r.LastName + ' - FinOps Job' : anOpportunity.Name + ' - FinOps Job';
                newJob.Opportunity__c = anOpportunity.Id;
                newJob.Flow_Status__c = 'M0 - Pending NTP';
                newJob.Job_Status__c = 'New';
                newJob.RecordTypeId = financingId;
                newJob.OwnerId = finOpsQueueId;
                newJob.Automation__c = true;
                
                if(anOpportunity.Channel_Partner__c != null && anOpportunity.Channel_Partner__r.Name == 'Quicken Loans') {
                    newJob.Type__c = 'Loan except Sunnova';
                    newJob.Sub_Type__c = 'Rocket';
                } else {
                    switch on anOpportunity.Financing_Tool__c {
                        when 'Sunlight'{
                            newJob.Type__c = 'Loan except Sunnova';
                            newJob.Sub_Type__c = 'Sunlight';
                        }
                        when 'Loan Pal - SubPrime'{
                            newJob.Type__c = 'Loan except Sunnova';
                            newJob.Sub_Type__c = 'LoanPal Subprime';
                        }
                        when 'Loanpal' {
                            newJob.Type__c = 'Loan except Sunnova';
                            newJob.Sub_Type__c = 'Loanpal';
                        }
                        when 'Sunnova Lease' {
                            newJob.Type__c = 'Sunnova';
                            newJob.Sub_Type__c = 'Lease';
                        }
                         when 'Sunnova Loan/Ownership' {
                            newJob.Type__c = 'Sunnova';
                            newJob.Sub_Type__c = 'Lease';
                        }
                        when 'SunRun' {
                            newJob.Type__c = 'SunRun';
                            newJob.Sub_Type__c = 'Rocket';
                        }
                    }
                }

                jobsToCreate.add(newJob);
            }
        }

        if(jobsToCreate.size() > 0) INSERT jobsToCreate;
    }

    public void createDesignCase(List<Project_Milestone__c> projectMilestones, Map<Id, Project_Milestone__c> oldMilestones){
        Set<Id> oppsId = new Set<Id>();
        List<Case> casesToInsert = new List<Case>();

        for (Project_Milestone__c aProjectMilestone : projectMilestones) {
            Project_Milestone__c oldMilestone = oldMilestones.get(aProjectMilestone.Id);

            if(aProjectMilestone.Permit_Received_Milestone__c != oldMilestone.Permit_Received_Milestone__c &&
            aProjectMilestone.Opportunity__c != null &&
            aProjectMilestone.Permit_Received_Milestone__c != null) {
                oppsId.add(aProjectMilestone.Opportunity__c);
            }
        }

        String solarPanelsSubject = 'Number of Solar Panels do not match with BOMs';
        String panelWattageSubject = 'Panel Wattage do not match with BOMs';
        String inverterSubject = 'Inverter 1 do not match with BOMs';

        for(Opportunity anOpportunity : [
            SELECT Id, Contact__c, Number_of_Solar_Panels__c, Inverter_1__c, Panel_Wattage__c,
                (SELECT Id, Part_Number2__r.Name, Inverter2__c, Quantity__c, Panel_Wattage2__c FROM BOMs__r)
            FROM Opportunity
            WHERE Id IN :oppsId
        ]){
            Decimal numberOfSolarPanel = 0, panelWattage = 0;
            Boolean inverterMatch = false, productStartsWithIn = false;

            if(anOpportunity.BOMs__r.size() > 0) {
                for(BOM__c aBom : anOpportunity.BOMs__r){
                    if(String.isNotBlank(aBom.Part_Number2__r.Name) && aBom.Part_Number2__r.Name.startsWithIgnoreCase('pv')){
                        numberOfSolarPanel += (aBom.Quantity__c == null? 0 : aBom.Quantity__c);
                        panelWattage += (String.isBlank(aBom.Panel_Wattage2__c)?0:Decimal.valueOf(aBom.Panel_Wattage2__c));
                    }
             
                    if(String.isNotBlank(aBom.Part_Number2__r.Name) && aBom.Part_Number2__r.Name.startsWithIgnoreCase('in')){
                        productStartsWithIn = true;
                        if(anOpportunity.Inverter_1__c == aBom.Inverter2__c){
                            inverterMatch = true;
                        }
                    }
                }
         
                if(anOpportunity.Number_of_Solar_Panels__c != numberOfSolarPanel && !verifyCases(anOpportunity.Id, solarPanelsSubject)){
                    casesToInsert.add(createCase(solarPanelsSubject, anOpportunity.Contact__c, anOpportunity.Id));
                }
         
                if(anOpportunity.Panel_Wattage__c != panelWattage && !verifyCases(anOpportunity.Id, panelWattageSubject)){
                    casesToInsert.add(createCase(panelWattageSubject, anOpportunity.Contact__c, anOpportunity.Id));
                }
                if(inverterMatch == false && productStartsWithIn && !verifyCases(anOpportunity.Id, inverterSubject)){
                    casesToInsert.add(createCase(inverterSubject, anOpportunity.Contact__c, anOpportunity.Id));
                }
            }
                 
        }  

        if(!casesToInsert.isEmpty()) INSERT casesToInsert;
        
    }

    public void createJobAssignTo(List<Job__c> lstJobs, Map<Id,Opportunity> mapOppById){
        List<Job_Assigned_To__c> lstJobAssignedTo = new List<Job_Assigned_To__c>();
        for(Job__c objJob : lstJobs){
            if(mapOppById.containsKey(objJob.Opportunity__c) && mapOppById.get(objJob.Opportunity__c).Site_Audit_Completed_By_BP__c != null){
                Job_Assigned_To__c objJobAssignment = new Job_Assigned_To__c(
                    Vendor__c = mapOppById.get(objJob.Id).Site_Audit_Completed_By_BP__c,
                    Job__c = objJob.Id,
                    Capability__c = 'Site Survey'
                );
                lstJobAssignedTo.add(objJobAssignment);
            }
        }
        if(!lstJobAssignedTo.isEmpty()){
            insert lstJobAssignedTo;
        }
    }

    private Case createCase(String subject, Id contactId, Id oppId){
        Id designChangeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Design_Change').getRecordTypeId();
        Id projectEngineerQueueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Project Engineers' LIMIT 1].Id;
        Case aCase = new Case();
        aCase.Subject = subject;
        aCase.RecordTypeId = designChangeId;
        aCase.ContactId = contactId;
        aCase.Opportunity__c = oppId;
        aCase.CaseType__c = 'Pre-Install';
        aCase.Reason_1__c = 'Not Started';
        aCase.OwnerId = projectEngineerQueueId;
        
        return aCase;
    }

    private Boolean verifyCases(Id oppId, String subject) {
        Boolean containBOMCase = false;
        List<Case> opportunityCases = new List<Case>();
        opportunityCases = [
            SELECT Id, Subject
            FROM Case
            WHERE Opportunity__c = :oppId   
        ];

        if( !opportunityCases.isEmpty() ) {
            for(Case aCase : opportunityCases) { 
                if(aCase.Subject != null && aCase.Subject.contains(subject) ){
                    containBOMCase = true;
                }
            }
        }
        

        return containBOMCase;
    }

    
    private void createInterconnectionJob(List<Project_Milestone__c> projectMilestones, Map<Id, Project_Milestone__c> oldMilestones) {

        Id interconnectionId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Interconnection').getRecordTypeId();
        Set<Id> oppsIds = new Set<Id>();
        List<Job__c> jobsToInsert = new List<Job__c>();

        for(Project_Milestone__c aProjectMilestone : projectMilestones) {
            Project_Milestone__c oldMilestone = oldMilestones.get(aProjectMilestone.Id);
            
            if( ( aProjectMilestone.Design_Completed_Milestone__c != oldMilestone.Design_Completed_Milestone__c || 
            aProjectMilestone.All_Documentation_Reviewed_and_Confirmed__c != oldMilestone.All_Documentation_Reviewed_and_Confirmed__c ) &&
            aProjectMilestone.Opportunity__c != null &&
            aProjectMilestone.Design_Completed_Milestone__c != null && 
            aProjectMilestone.All_Documentation_Reviewed_and_Confirmed__c != null){
                oppsIds.add(aProjectMilestone.Opportunity__c);
            }
        }

        for(Opportunity anOpportunity : [
            SELECT Id, OwnerId, Account.Name,
            (
                SELECT Id
                FROM Jobs__r
                WHERE RecordTypeId = :interconnectionId
            )
            FROM Opportunity
            WHERE Id IN :oppsIds
        ]) {

            if(anOpportunity.Jobs__r == null || anOpportunity.Jobs__r.isEmpty()) {
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
        if( jobsToInsert.size() > 0 ) INSERT jobsToInsert;
    }

    private void createStateCertificationJob(List<Project_Milestone__c> projectMilestones, Map<Id, Project_Milestone__c> oldMilestones){
        Id stateCertificationId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('State_Certification').getRecordTypeId();
        Set<Id> oppsIds = new Set<Id>();
        List<Job__c> jobsToInsert = new List<Job__c>();
        Group incentivesQueue = [SELECT Id FROM Group WHERE Name = 'Incentives' AND Type = 'Queue' LIMIT 1];

        for(Project_Milestone__c aProjectMilestone : projectMilestones) {
            Project_Milestone__c oldMilestone = oldMilestones.get(aProjectMilestone.Id);
            
            if(oldMilestone.Design_Completed_Milestone__c == null && aProjectMilestone.Design_Completed_Milestone__c != oldMilestone.Design_Completed_Milestone__c && aProjectMilestone.Opportunity__c != null){
                oppsIds.add(aProjectMilestone.Opportunity__c);
            }
        }
        Set<String> enabledProviders = new Set<String>();
        enabledProviders.add('Austin Energy');
        enabledProviders.add('CPS Energy');

        List<String> enabledLocation =  new List<String>();
        enabledLocation = System.Label.State_Certification_Job_Creation_States.split(',');
        
        for(Opportunity anOpportunity : [
            SELECT Id, OwnerId, Account.Name, Location__c, Utility__c, Name_on_Util_Bill_Exact_Name_Required__c, Address__c, Email__c, Financing_Tool__c
            FROM Opportunity
            WHERE Id IN :oppsIds
            AND (Location__c IN :enabledLocation OR Utility__c IN :enabledProviders)
        ]) {
            Job__c newJob = new Job__c();
            newJob.Type__c = 'State Certification';
            newJob.Job_Status__c = 'New';
            newJob.Flow_Status__c = 'Required - Pending Internal Review';
            newJob.Name = 'State Certification Job';
            newJob.RecordTypeId = stateCertificationId;
            newJob.OwnerId = incentivesQueue.Id;
            newJob.Opportunity__c = anOpportunity.Id;
            newJob.Contact_Address__c = anOpportunity.Address__c;
            newJob.Contact_Email__c = anOpportunity.Email__c;
            newJob.Financing_Tool__c = anOpportunity.Financing_Tool__c;
            newJob.Name_on_the_Utility_Bill__c = anOpportunity.Name_on_Util_Bill_Exact_Name_Required__c;
            jobsToInsert.add(newJob);
        }

        if(!jobsToInsert.isEmpty()){
            insert jobsToInsert;
        } 
    }
}