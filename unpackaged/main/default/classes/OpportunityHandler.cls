public class OpportunityHandler
{
    public static Boolean runBuildOnlyTrigger = true;
    public static Boolean createDesignCaseTrigger = true;
    //This method is called on before insert event of trigger.
    public void onBeforeInsert(List<Opportunity> lstOpp){
        maniplulateFinancingTool(lstOpp);
        validateOppStage(lstOpp, null);
        TriggerConfiguration__c objTriggerConfigurationCS = TriggerConfiguration__c.getInstance('Alchemy API trigger');
        if(objTriggerConfigurationCS != null && objTriggerConfigurationCS.Active__c == true){
            populateChannelPartner(lstOpp, null);
        }
        populateCommissionProduct(lstOpp, null);
        populateMSAId(lstOpp, null);
    }
    //This method is called on before update event of trigger.
    public void onBeforeUpdate(List<Opportunity> lstOpp, Map<Id, Opportunity> mapIdToOpp){
        maniplulateFinancingTool(lstOpp);
        TriggerConfiguration__c objStageValidationCS = TriggerConfiguration__c.getInstance('Stage backward validation');
        if(objStageValidationCS != null && objStageValidationCS.Active__c == true){
            preventBackwardMovement(lstOpp, mapIdToOpp);
        }
        validateOppStage(lstOpp, mapIdToOpp);
        populateLastRefreshDate(lstOpp, mapIdToOpp);
        TriggerConfiguration__c objTriggerConfigurationCS = TriggerConfiguration__c.getInstance('Alchemy API trigger');
        if(objTriggerConfigurationCS != null && objTriggerConfigurationCS.Active__c == true){
            populateChannelPartner(lstOpp, mapIdToOpp);
        }
        populateCommissionProduct(lstOpp, mapIdToOpp);
        populateMSAId(lstOpp, mapIdToOpp);
        updateFinOpsJob(lstOpp, mapIdToOpp);
    }
    
    
    private void maniplulateFinancingTool(List<Opportunity> lstOpp){
        for(Opportunity objOpp : lstOpp){
            if(objOpp.Financing_Tool__c == 'Loan Pal'){
                objOpp.Financing_Tool__c = 'Loanpal';
            }
        }
    }
    
    //This method is called on after insert event of trigger.
    public void onAfterInsert(List<Opportunity> lstOpp){
        createOppTeamMember(lstOpp);
        createRadius(lstOpp);
    }
    
    //This method is used to create the radius record.
    private void createRadius(List<Opportunity> lstOpp){
        List<Project_Milestone__c> lstRadius = new List<Project_Milestone__c>();
        for(Opportunity objOpp : lstOpp){
            Project_Milestone__c objRadius = new Project_Milestone__c();
            objRadius.Name = objOpp.Name;
            objRadius.Opportunity__c = objOpp.Id;
            lstRadius.add(objRadius);
        }
        
        if(!lstRadius.isEmpty())
            insert lstRadius;
    }
    
    //This method is used to populate MSA ID on Opp object.
    private void populateMSAId(List<Opportunity> lstOpp, Map<Id, Opportunity> mapIdToOldOpp){
        Map<String, Opportunity> mapUniqueComboToOpp = new Map<String, Opportunity>();
        for(Opportunity objOpp : lstOpp){
            System.debug('>>>>>>'+objOpp.Location__c);
            if(String.isNotBlank(objOpp.Location__c) && String.isNotBlank(objOpp.Vendor__c)){
                String uniqueCombo = String.valueOf(objOpp.Vendor__c).left(15) + ':' + objOpp.Location__c;
                if(mapIdToOldOpp == null){
                    mapUniqueComboToOpp.put(uniqueCombo, objOpp);
                } else{
                    Opportunity objOldOpp = mapIdToOldOpp.get(objOpp.Id);
                    if(objOpp.Location__c != objOldOpp.Location__c || objOpp.Vendor__c != objOldOpp.Vendor__c){
                        mapUniqueComboToOpp.put(uniqueCombo, objOpp);
                    }
                }
            }
        }
        System.debug('>>>>>'+mapUniqueComboToOpp);
        if(!mapUniqueComboToOpp.isEmpty()){
            Map<String, Service_Agreement__c> mapUniqueCombeToAgreement = new Map<String, Service_Agreement__c>();
            for(Service_Agreement__c objServiceAgreement : [
                    SELECT Id, Unique_Combo__c, 
                    (SELECT Id, Service_Territory__c FROM Pricing_Details__r) 
                    FROM Service_Agreement__c
                    WHERE Unique_Combo__c IN :mapUniqueComboToOpp.keyset()])
            {
                mapUniqueCombeToAgreement.put(objServiceAgreement.Unique_Combo__c, objServiceAgreement);
            }
            System.debug('>>>>>'+mapUniqueCombeToAgreement);
            System.debug('>>>>>'+mapUniqueComboToOpp);
            for(String uniqueCombo : mapUniqueComboToOpp.keyset()){
                Opportunity objOpp = mapUniqueComboToOpp.get(uniqueCombo);
                List<Pricing_Detail__c> lstPricingDetail = new List<Pricing_Detail__c>();
                if(mapUniqueCombeToAgreement.get(uniqueCombo) != null){
                    Service_Agreement__c objAgreement = mapUniqueCombeToAgreement.get(uniqueCombo);
                    objOpp.MSA_Id__c = objAgreement.Id;
                    if(objAgreement.Pricing_Details__r != null && !objAgreement.Pricing_Details__r.isEmpty()){
                        lstPricingDetail = objAgreement.Pricing_Details__r;
                    }
                    
                    for(Pricing_Detail__c objPricingDetail : lstPricingDetail){
                        if(String.isBlank(objOpp.Service_Territory__c)){
                            objOpp.Pricing_Detail_Id__c = objPricingDetail.Id;
                            break;
                        } else{
                            if(objOpp.Service_Territory__c == objPricingDetail.Service_Territory__c){
                                objOpp.Pricing_Detail_Id__c = objPricingDetail.Id;
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    
    //This method is used to prevent backward movement of stages.
    private void preventBackwardMovement(List<Opportunity> lstOpp, Map<Id, Opportunity> mapIdToOldOpp){
        Id designSalesOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('X3rd_Party_Design_Sales').getRecordTypeId();
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
        List<Opportunity> lstOppToProcess = new List<Opportunity>();
    
        for(Opportunity objOpp : lstOpp){
            Opportunity objOldOpp = mapIdToOldOpp.get(objOpp.Id);
            if(objOpp.StageName != objOldOpp.StageName && objOpp.RecordTypeId == designSalesOppId){
                Integer previousOrder = (mapStageToIndex.containsKey(objOldOpp.StageName)?mapStageToIndex.get(objOldOpp.StageName):0);
                Integer currentOrder = (mapStageToIndex.containsKey(objOpp.StageName)?mapStageToIndex.get(objOpp.StageName):0);
                if(currentOrder < previousOrder){
                    lstOppToProcess.add(objOpp);
                }
            }
        }
        
        if(!lstOppToProcess.isEmpty()){
            Set<String> setUserName = new Set<String>();
            for(Backward_Validation_Exclude_List__c objUserName : Backward_Validation_Exclude_List__c.getAll().values()){
                setUserName.add(objUserName.Name);
            }
        
            Set<Id> setUserId = new Set<Id>();
            for(User objUser : [SELECt Id FROM User
                    WHERE Name in :setUserName])
            {
                setUserId.add(objUser.Id);
            }
            
            if(!setUserId.contains(Userinfo.getuserId())){
                for(Opportunity objOpp : lstOppToProcess){
                    objOpp.addError('Stage Can not be moved in backward direction.');
                }
            }
        }
    }
    
    //This method is used to populate the alchemy product on opp.
    private void populateCommissionProduct(List<Opportunity> lstOpp, Map<Id, Opportunity> mapIdToOpp){
        Set<String> setUniqueCombo = new Set<String>();
        Set<String> setCashUniqueCombo = new Set<String>();
        List<Opportunity> lstOppToProcess = new List<Opportunity>();
        List<Opportunity> lstCashOppToProcess = new List<Opportunity>();
        for(Opportunity objOpp : lstOpp){
            if(String.isNotBlank(objOpp.Financing_Tool__c) && String.isNotBlank(objOpp.Location__c))
            {
                String uniqueCombo = objOpp.Financing_Tool__c + ':' + objOpp.APR__c + ':' +  objOpp.Loan_Term__c;
                Boolean criteriaSatisfied = false;
                if(mapIdToOpp == null){
                    criteriaSatisfied = true;
                } else{
                    Opportunity objOldOpp = mapIdToOpp.get(objOpp.Id);
                    if(objOpp.Financing_Tool__c != objOldOpp.Financing_Tool__c || objOpp.APR__c != objOldOpp.APR__c
                        || objOpp.Loan_Term__c != objOldOpp.Loan_Term__c || objOpp.Location__c != objOldOpp.Location__c
                        || objOpp.Channel_Partner__c != objOldOpp.Channel_Partner__c || objOpp.Contract_Received_Date__c != objOldOpp.Contract_Received_Date__c)
                    {
                        criteriaSatisfied = true;
                    }
                }
                
                if(criteriaSatisfied){
                    if(objOpp.Financing_Tool__c == 'Cash' || objOpp.Financing_Tool__c == 'SunRun' 
                                || objOpp.Financing_Tool__c == 'Sunnova Lease')
                    {
                        lstCashOppToProcess.add(objOpp);
                        setCashUniqueCombo.add(objOpp.Financing_Tool__c);
                    } else if(String.isNotBlank(objOpp.APR__c) && String.isNotBlank(objOpp.Loan_Term__c)){
                        lstOppToProcess.add(objOpp);
                        setUniqueCombo.add(uniqueCombo);
                    }
                }
            }
        }
        
        if(!lstOppToProcess.isEmpty()){
            Map<String, List<Dealer_Fee_Product__c>> mapUniqueComboToLstProduct = new Map<String, List<Dealer_Fee_Product__c>>();
            for(Dealer_Fee_Product__c objProduct : [SELECT Id, Unique_Combo__c, State__c, Classification__c, Start_Date__c, End_Date__c, Channel_Partner__c
                    FROM Dealer_Fee_Product__c
                    WHERE Unique_Combo__c IN :setUniqueCombo
                    ORDER BY Start_Date__c])
            {
                String uniqueCombo = objProduct.Unique_Combo__c;
                if(objProduct.Channel_Partner__c != null){
                    uniqueCombo += ':' + objProduct.Channel_Partner__c;
                }
                
                if(mapUniqueComboToLstProduct.containsKey(uniqueCombo)){
                    mapUniqueComboToLstProduct.get(uniqueCombo).add(objProduct);
                } else{
                    mapUniqueComboToLstProduct.put(uniqueCombo, new List<Dealer_Fee_Product__c>{objProduct});
                }
            }
            
            System.debug('>>>>>>>'+mapUniqueComboToLstProduct);
            for(Opportunity objOpp : lstOppToProcess){
                String uniqueCombo1 = objOpp.Financing_Tool__c + ':' + objOpp.APR__c + ':' +  objOpp.Loan_Term__c;
                String uniqueCombo2 = uniqueCombo1 + ':' + objOpp.Channel_Partner__c;
                Id dealerId, internalDealerId;
                //Code to populate dealer commission.
                if(mapUniqueComboToLstProduct.containsKey(uniqueCombo2))
                    dealerId = populateDealerId(objOpp, mapUniqueComboToLstProduct.get(uniqueCombo2), 'Commissions');
                if(dealerId == null && mapUniqueComboToLstProduct.containsKey(uniqueCombo1))
                    dealerId = populateDealerId(objOpp, mapUniqueComboToLstProduct.get(uniqueCombo1), 'Commissions');
                
                objOpp.Commission_Dealer_Fee_Product2__c = dealerId;
                
                //Code to populate internal dealer.
                if(mapUniqueComboToLstProduct.containsKey(uniqueCombo2))
                    internalDealerId = populateDealerId(objOpp, mapUniqueComboToLstProduct.get(uniqueCombo2), 'Internal');
                if(internalDealerId == null && mapUniqueComboToLstProduct.containsKey(uniqueCombo1))
                    internalDealerId = populateDealerId(objOpp, mapUniqueComboToLstProduct.get(uniqueCombo1), 'Internal');
                
                objOpp.Internal_Dealer_Fee_Product2__c = internalDealerId;
            }
        }
        
        //Code for Cash/Sunrun and Sunnova Lease Opps.
        if(!lstCashOppToProcess.isEmpty()){
            Map<String, List<Dealer_Fee_Product__c>> mapUniqueComboToLstProduct = new Map<String, List<Dealer_Fee_Product__c>>();
            for(Dealer_Fee_Product__c objProduct : [
                    SELECT Id, State__c, Classification__c, Start_Date__c, End_Date__c, Channel_Partner__c, Financing_Tool__c
                    FROM Dealer_Fee_Product__c
                    WHERE Financing_Tool__c IN :setCashUniqueCombo
                    ORDER BY Start_Date__c])
            {
                String uniqueCombo = objProduct.Financing_Tool__c;
                if(objProduct.Channel_Partner__c != null){
                    uniqueCombo += ':' + objProduct.Channel_Partner__c;
                }
                
                if(mapUniqueComboToLstProduct.containsKey(uniqueCombo)){
                    mapUniqueComboToLstProduct.get(uniqueCombo).add(objProduct);
                } else{
                    mapUniqueComboToLstProduct.put(uniqueCombo, new List<Dealer_Fee_Product__c>{objProduct});
                }
            }
            
            System.debug('>>>>>>>'+mapUniqueComboToLstProduct);
            for(Opportunity objOpp : lstCashOppToProcess){
                String uniqueCombo1 = objOpp.Financing_Tool__c;
                String uniqueCombo2 = uniqueCombo1 + ':' + objOpp.Channel_Partner__c;
                Id dealerId, internalDealerId;
                //Code to populate dealer commission.
                if(mapUniqueComboToLstProduct.containsKey(uniqueCombo2))
                    dealerId = populateDealerId(objOpp, mapUniqueComboToLstProduct.get(uniqueCombo2), 'Commissions');
                if(dealerId == null && mapUniqueComboToLstProduct.containsKey(uniqueCombo1))
                    dealerId = populateDealerId(objOpp, mapUniqueComboToLstProduct.get(uniqueCombo1), 'Commissions');
                
                objOpp.Commission_Dealer_Fee_Product2__c = dealerId;
                
                //Code to populate internal dealer.
                if(mapUniqueComboToLstProduct.containsKey(uniqueCombo2))
                    internalDealerId = populateDealerId(objOpp, mapUniqueComboToLstProduct.get(uniqueCombo2), 'Internal');
                if(internalDealerId == null && mapUniqueComboToLstProduct.containsKey(uniqueCombo1))
                    internalDealerId = populateDealerId(objOpp, mapUniqueComboToLstProduct.get(uniqueCombo1), 'Internal');
                
                objOpp.Internal_Dealer_Fee_Product2__c = internalDealerId;
            }
        }
    }
    
    //This method is used to find out the dealer fee commission record.
    private Id populateDealerId(Opportunity objOpp, List<Dealer_Fee_Product__c> lstProduct, String classification){
        Id dealerId;
        for(Dealer_Fee_Product__c objProduct : lstProduct){
            if(String.isNotBlank(objProduct.State__c) && objProduct.State__c.containsIgnoreCase(objOpp.Location__c)){
                if(((objProduct.Start_Date__c == null || objProduct.Start_Date__c <= objOpp.Contract_Received_Date__c) && (objProduct.End_Date__c == null || objProduct.End_Date__c >= objOpp.Contract_Received_Date__c)) || (objProduct.Start_Date__c != null && objProduct.End_Date__c != null && objOpp.Contract_Received_Date__c >= objProduct.Start_Date__c && objOpp.Contract_Received_Date__c <= objProduct.End_Date__c)){
                    if(objProduct.Classification__c == classification){
                        dealerId = objProduct.Id;  
                    } 
                }
            }
        }  
        
        return dealerId;      
    }
    
    //This method is used to populate the Opportunity channel partner field.
    private void populateChannelPartner(List<Opportunity> lstOpp, Map<Id, Opportunity> mapIdToOpp){
        Map<Id, List<Opportunity>> mapContactIdToLstOpp = new Map<Id, List<Opportunity>>();
        for(Opportunity objOpp : lstOpp){
            if(objOpp.Opp_Primary_Contact__c != null && (objOpp.Channel_Partner__c == null || (mapIdToOpp != null && mapIdToOpp.get(objOpp.Id).Opp_Primary_Contact__c != objOpp.Opp_Primary_Contact__c))){
                if(mapContactIdToLstOpp.containsKey(objOpp.Opp_Primary_Contact__c)){
                    mapContactIdToLstOpp.get(objOpp.Opp_Primary_Contact__c).add(objOpp);
                } else{
                    mapContactIdToLstOpp.put(objOpp.Opp_Primary_Contact__c, new List<Opportunity>{objOpp});
                }
            }
        }

        if(!mapContactIdToLstOpp.isEmpty()){
            for(Contact objContact : [
                    SELECT Id, AccountId 
                    FROM Contact 
                    WHERE Id in :mapContactIdToLstOpp.keyset() 
                    AND AccountId != null])
            {
                for(Opportunity objOpp : mapContactIdToLstOpp.get(objContact.Id)){
                    objOpp.Channel_Partner__c = objContact.AccountId;
                }
            }
        }
    }


    //This method is called on after update event of trigger.
    public void onAfterUpdate(List<Opportunity> lstOpp, Map<Id, Opportunity> mapIdToOpp){
        createIncentivesSRECTradeRegistrationJob(lstOpp, mapIdToOpp);
        createPTOJob(lstOpp, mapIdToOpp);
        TriggerConfiguration__c objTriggerConfigurationCS = TriggerConfiguration__c.getInstance('LGCY API trigger');
        if(objTriggerConfigurationCS != null && objTriggerConfigurationCS.Active__c == true){
            postOppData(lstOpp, mapIdToOpp);
        }
        
        TriggerConfiguration__c objTriggerConfigurationRCCS = TriggerConfiguration__c.getInstance('Refresh Commissions');
        if(objTriggerConfigurationRCCS != null && objTriggerConfigurationRCCS.Active__c == true){
            refreshCommission(lstOpp, mapIdToOpp);
        }
        
        updateFlowStatus(lstOpp, mapIdToOpp);
        if(OpportunityHandler.runBuildOnlyTrigger == true){
            createJob(lstOpp, mapIdToOpp);
        }
        if(OpportunityHandler.createDesignCaseTrigger == true){
            createDesignCase(lstOpp, mapIdToOpp);
        }
        updateJobFlowStatus(lstOpp, mapIdToOpp);
        updateInstallationFlowStatus(lstOpp, mapIdToOpp);
        
        TriggerConfiguration__c objTriggerConfigCS = TriggerConfiguration__c.getInstance('Order API Trigger');
        
        if(objTriggerConfigCS != null && objTriggerConfigCS.Active__c){
            postData(lstOpp, mapIdToOpp);
        }
        updateOppTeamMember(lstOpp, mapIdToOpp);
        createPreConstructionWorkCase(lstOpp, mapIdToOpp);
    }

    //This method is used to post data to Alchemy order status end-point.
    private void postData(List<Opportunity> lstOpp, Map<Id, Opportunity> mapIdToOpp){
        Set<Id> setOppId = new Set<Id>();
        for(Opportunity objOpp : lstOpp){
            Opportunity objOldOpp = mapIdToOpp.get(objOpp.Id);
            if(objOpp.Schedule_System_Activation_Walk_Through__c == true && objOldOpp.Schedule_System_Activation_Walk_Through__c == false){
                setOppId.add(objOpp.Id);
            }
        }
        
        if(!setOppId.isEmpty()){
            PalmettoAPIService.sendOrderStatusFromOpp(setOppId);
        }
    }
    
    //This method is used to create the design case under Opportunity.
    private void createDesignCase(List<Opportunity> lstOpp, Map<Id, Opportunity> mapIdToOpp){
        List<Case> lstCaseToCreate = new List<Case>();
        Id designChangeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Design_Change').getRecordTypeId();
        Set<Id> setOppId = new Set<Id>();
        Set<Id> setOppId2 = new Set<Id>();
        Id designSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('X3rd_Party_Design_Sales').getRecordTypeId();
        for(Opportunity objOpp : lstOpp){
            Opportunity objOldOpp = mapIdToOpp.get(objOpp.Id);
            if(objOpp.RecordTypeId == designSalesId){
                if(objOpp.StageName == '13. Engineering Design Complete'){
                    if(objOpp.Panel_Wattage__c != objOldOpp.Panel_Wattage__c){
                        lstCaseToCreate.add(getCaseData('Panel Wattage has changed', designChangeId, objOpp.Contact__c, objOpp.Id));
                        setOppId.add(objOpp.Id);
                    }
                    
                    if(objOpp.Number_of_Solar_Panels__c != objOldOpp.Number_of_Solar_Panels__c){
                        lstCaseToCreate.add(getCaseData('Number of Solar Panels has changed', designChangeId, objOpp.Contact__c, objOpp.Id));
                        setOppId.add(objOpp.Id);
                    }
                }
                
                if(objOpp.StageName == '17. Install Ready' && objOldOpp.StageName != '17. Install Ready'){
                    setOppId2.add(objOpp.Id);
                }
            }
        }
        
        if(!setOppId2.isEmpty()){
            List<Case> lstCaseToInsert = new List<Case>();
            for(Opportunity objOpp : [
                    SELECT Id, Panel_Wattage__c, Contact__c, Number_of_Solar_Panels__c, Battery_Qty__c, Inverter_1__c,
                        (SELECT Id, Part_Number2__r.Name, Quantity__c, Panel_Wattage2__c, Inverter2__c
                        FROM BOMs__r) 
                    FROM Opportunity 
                    WHERE Id IN :setOppId2])
            {  
                Decimal numberOfSolarPanel = 0, panelWattage = 0;
                Boolean inverterMatch = false;
                for(BOM__c objBOM : objOpp.BOMs__r){
                    if(String.isNotBlank(objBOM.Part_Number2__r.Name) && objBOM.Part_Number2__r.Name.startsWithIgnoreCase('pv')){
                        numberOfSolarPanel += (objBOM.Quantity__c == null?0:objBOM.Quantity__c);
                        panelWattage += (String.isBlank(objBOM.Panel_Wattage2__c)?0:Decimal.valueOf(objBOM.Panel_Wattage2__c));
                    }
                    
                    if(String.isNotBlank(objBOM.Part_Number2__r.Name) && objBOM.Part_Number2__r.Name.startsWithIgnoreCase('in')){
                        if(objOpp.Inverter_1__c == objBOM.Inverter2__c){
                            inverterMatch = true;
                        }
                    }
                }
                
                if(objOpp.Number_of_Solar_Panels__c != numberOfSolarPanel){
                    lstCaseToInsert.add(getCaseData('Number of Solar Panels do not match with BOMs', designChangeId, objOpp.Contact__c, objOpp.Id));
                }
                
                if(objOpp.Panel_Wattage__c != panelWattage){
                    lstCaseToInsert.add(getCaseData('Panel Wattage do not match with BOMs', designChangeId, objOpp.Contact__c, objOpp.Id));
                }
                
                if(inverterMatch == false){
                    lstCaseToInsert.add(getCaseData('Inverter 1 do not match with BOMs', designChangeId, objOpp.Contact__c, objOpp.Id));
                }
            }
            
            
            if(!lstCaseToInsert.isEmpty())
                insert lstCaseToInsert;
                
            OpportunityHandler.createDesignCaseTrigger = false;
        }
        
        if(!setOppId.isEmpty()){
            Map<Id, List<Case>> mapOppIdToLstCase = new Map<Id, List<Case>>();
            for(Case objCase : lstCaseToCreate){
                if(mapOppIdToLstCase.containsKey(objCase.Opportunity__c)){
                    mapOppIdToLstCase.get(objCase.Opportunity__c).add(objCase);
                } else{
                    mapOppIdToLstCase.put(objCase.Opportunity__c, new List<Case>{objCase});
                }
            }
            
            List<Case> lstCaseToInsert = new List<Case>();
            for(Opportunity objOpp : [SELECT Id, (SELECT Id FROM Cases__r WHERE RecordType.DeveloperName = 'Change_Order') 
                    FROM Opportunity WHERE Id IN :setOppId])
            {
                if(objOpp.Cases__r.isEmpty()){
                    for(Case objCase : mapOppIdToLstCase.get(objOpp.Id)){
                        lstCaseToInsert.add(objCase);
                    }
                }
            }
            
            if(!lstCaseToInsert.isEmpty())
                insert lstCaseToInsert;
                
            OpportunityHandler.createDesignCaseTrigger = false;
        }
    }
    
    private Case getCaseData(String subject, Id designChangeId, Id contactId, Id oppId){
        Case objCase = new Case();
        objCase.Subject = subject;
        objCase.RecordTypeId = designChangeId;
        objCase.ContactId = contactId;
        objCase.Opportunity__c = oppId;
        objCase.CaseType__c = 'Pre-Install';
        objCase.Reason_1__c = 'Not Started';
        objCase.OwnerId = System.Label.ProjectEngineersId;
        
        return objCase;
    }
    
    //This method is used to create jobs for build only opportunities.
    private void createJob(List<Opportunity> lstOpp, Map<Id, Opportunity> mapIdToOpp){
        Id buildOnlyOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Build Only').getRecordTypeId();
        Id interconnectionId = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Interconnection').getRecordTypeId();
        Id permittingId = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Permitting').getRecordTypeId();
        Id schedulingId = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Installation Scheduling').getRecordTypeId();
        Id jcoId = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Job Close Out').getRecordTypeId();
        Id InspectionId = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Inspection').getRecordTypeId();
        
        Set<String> setStages = new Set<String>();
        setStages.add('13. Engineering Design Complete');
        setStages.add('17. Install Ready');
        setStages.add('18. Installation');
        setStages.add('19. Install Completed');
        
        //List<Opportunity> lstOppToProcess = new List<Opportunity>();
        Set<Id> setOppId = new Set<Id>();
        for(Opportunity objOpp : lstOpp){
            Opportunity objOldOpp = mapIdToOpp.get(objOpp.Id);
            if(objOpp.StageName != objOldOpp.StageName && objOpp.RecordTypeId == buildOnlyOppId && setStages.contains(objOpp.StageName)){
                //lstOppToProcess.add(objOpp);
                setOppId.add(objOpp.Id);
            }
        }
        
        
        if(!setOppId.isEmpty()){
            
            OpportunityHandler.runBuildOnlyTrigger = false;
            Id schedulingQueueId, marketTeamId;
            for(Group objGroup : [
                    SELECT Id, DeveloperName
                    FROM Group
                    WHERE DeveloperName IN ('Scheduling_Team', 'Market_Team_Install_Supervisor')])
            {
                if(objGroup.DeveloperName == 'Scheduling_Team')
                    schedulingQueueId = objGroup.Id;
                if(objGroup.DeveloperName == 'Market_Team_Install_Supervisor')
                    marketTeamId = objGroup.Id;
            }
        
            List<Job__c> lstJobToInsert = new List<Job__c>();
            for(Opportunity objOpp : [
                    SELECT Id, StageName, OwnerId, Contact__r.Name, Build_Only_Partner__c
                    FROM Opportunity
                    WHERE Id in :setOppId])
            {
                String contactName = objOpp.Contact__r.Name;
                if(objOpp.StageName == '13. Engineering Design Complete'){
                    /*
                    if(objOpp.Build_Only_Partner__c != System.Label.Encor_Id){
                        lstJobToInsert.add(getJobRecord('Interconnection', 'Pending Submission', 'New', (contactName + '- Interconnection'), interconnectionId, objOpp.OwnerId, objOpp.Id, ''));
                    }
                    */
                    lstJobToInsert.add(getJobRecord('Permit Issuance', 'Pending Submittal to AHJ', 'New', (contactName + '- Permitting Job'), permittingId, objOpp.OwnerId, objOpp.Id, ''));
                }
                
                if(objOpp.StageName == '17. Install Ready'){
                    lstJobToInsert.add(getJobRecord('Installation Scheduling', 'New- Pending Scheduling', 'New', (contactName + '- Installation Scheduling'), schedulingId, schedulingQueueId, objOpp.Id, 'Installation Scheduling'));
                }
                
                if(objOpp.StageName == '18. Installation'){
                    lstJobToInsert.add(getJobRecord('Installation Scheduling', 'New- Pending Scheduling', 'New', (contactName + '- Installation'), schedulingId, schedulingQueueId, objOpp.Id, 'Installation Scheduling'));
                }
                
                if(objOpp.StageName == '19. Install Completed'){
                    lstJobToInsert.add(getJobRecord('Job Close Out', 'Pending JCO', 'New', (contactName + '- JCO Job'), jcoId, marketTeamId, objOpp.Id, ''));
                    lstJobToInsert.add(getJobRecord('Inspection', 'Installation Complete- Pending Scheduling', 'New', (contactName + '- Inspection'), InspectionId, System.Label.Build_Inspection_Owner, objOpp.Id, ''));
                }
            }
            
            if(!lstJobToInsert.isEmpty())
                insert lstJobToInsert;
        }
    }
    
    //This method is used to return Job__c instance.
    private Job__c getJobRecord(String type, String flowStatus, String jobStatus, String jobName, Id recordTypeId, Id ownerId, Id oppId, String subject){
        Job__c objJob = new Job__c();
        objJob.Type__c = type;
        objJob.Flow_Status__c = flowStatus;
        objJob.Job_Status__c = jobStatus;
        objJob.Name = jobName;
        objJob.RecordTypeId = recordTypeId;
        objJob.OwnerId = ownerId;
        objJob.Opportunity__c = oppId;
        objJob.Subject__c = subject;
        
        return objJob;
    }
    
    //This method is used to update the flow status on job records .
    private void updateFlowStatus(List<Opportunity> lstOpp, Map<Id, Opportunity> mapIdToOpp){
        Set<Id> setOppId = new Set<Id>();
        Set<Id> setOppId2 = new Set<Id>();
        Set<Id> setOppId3 = new Set<Id>();

        for(Opportunity objOpp : lstOpp){
            Opportunity objOldOpp = mapIdToOpp.get(objOpp.Id);
            if(objOpp.StageName != objOldOpp.StageName && objOpp.StageName == '19. Install Completed'){ //|| objOpp.StageName == '22. PTO'
                setOppId.add(objOpp.Id);
            }
            if(objOpp.StageName != objOldOpp.StageName && objOpp.StageName == '22. PTO'){ 
                setOppId3.add(objOpp.Id);
            }            
            if(objOpp.System_Size_kW__c != objOldOpp.System_Size_kW__c && objOpp.System_Size_kW__c != null){
                setOppId2.add(objOpp.Id);
            }
        }

        if(!setOppId3.isEmpty()){
            List<Job__c> lstJobToUpdate = new List<Job__c>();
            for(Opportunity objOpportunity : [
                    SELECT Id, Name, OwnerId, StageName,
                        (SELECT Id, Flow_Status__c, Type__c from Jobs__r
                        WHERE RecordType.DeveloperName = 'Financing'
                        AND Type__c != 'SunRun')
                    FROM Opportunity 
                    WHERE Id in :setOppId3])
            {
                if(objOpportunity.Jobs__r != null && !objOpportunity.Jobs__r.isEmpty()){
                    for(Job__c objJob : objOpportunity.Jobs__r){
                        if(objJob.Flow_Status__c == 'M1 -  Approved'){
                            objJob.Flow_Status__c = 'M2 - Pending Submittal';
                            lstJobToUpdate.add(objJob);
                        } 
                    }
                }
            }
            
            if(!lstJobToUpdate.isEmpty()){
                update lstJobToUpdate;
            }
        }
        
        if(!setOppId2.isEmpty()){
            List<Job__c> lstJobToUpdate = new List<Job__c>();
            for(Opportunity objOpportunity : [
                    SELECT Id, Name, OwnerId, StageName,
                        (SELECT Id, Flow_Status__c, Type__c from Jobs__r
                        WHERE RecordType.Name = 'Financing'
                        AND Type__c IN ('Sunnova', 'SunRun'))
                    FROM Opportunity 
                    WHERE Id in :setOppId2])
            {
                if(objOpportunity.Jobs__r != null && !objOpportunity.Jobs__r.isEmpty()){
                    for(Job__c objJob : objOpportunity.Jobs__r){
                        if(objJob.Flow_Status__c != 'M0 - Pending NTP'){
                            objJob.Flow_Status__c = 'M0 - Pending NTP';
                            lstJobToUpdate.add(objJob);
                        } 
                    }
                }
            }
            
            if(!lstJobToUpdate.isEmpty()){
                update lstJobToUpdate;
            }
        }
        
        if(!setOppId.isEmpty()){
            List<Job__c> lstJobToUpdate = new List<Job__c>();
            for(Opportunity objOpportunity : [
                    SELECT Id, Name, OwnerId, StageName,
                        (SELECT Id, Flow_Status__c, Type__c from Jobs__r
                        WHERE RecordType.Name = 'Financing'
                        AND Type__c IN ('Loan except Sunnova', 'SunRun'))
                    FROM Opportunity 
                    WHERE Id in :setOppId])
            {
                if(objOpportunity.Jobs__r != null && !objOpportunity.Jobs__r.isEmpty()){
                    for(Job__c objJob : objOpportunity.Jobs__r){
                        if(objOpportunity.StageName == '19. Install Completed' && objJob.Type__c == 'Loan except Sunnova' 
                            && objJob.Flow_Status__c != 'M1 - Pending Submittal')
                        {
                            objJob.Flow_Status__c = 'M1 - Pending Submittal';
                            lstJobToUpdate.add(objJob);
                        } /*else if(objOpportunity.StageName == '22. PTO' && objJob.Type__c == 'SunRun' 
                            && objJob.Flow_Status__c != 'M3 - Pending Submittal')
                        {
                            objJob.Flow_Status__c = 'M3 - Pending Submittal';
                            lstJobToUpdate.add(objJob);
                        }*/
                    }
                }
            }
            
            if(!lstJobToUpdate.isEmpty()){
                update lstJobToUpdate;
            }
        }
    }
    
    //This method is used to create the job records for Sunrun opps.
    private void createPTOJob(List<Opportunity> lstOpp, Map<Id, Opportunity> mapIdToOpp){
        Set<Id> setOppId = new Set<Id>();
        for(Opportunity objOpp : lstOpp){
            Opportunity objOldOpp = mapIdToOpp.get(objOpp.Id);
            if(objOpp.StageName == '21. Inspection Complete' && objOldOpp.StageName != '21. Inspection Complete'
                && objOpp.Financing_Tool__c == 'SunRun')
            {
                setOppId.add(objOpp.Id);
            }
        }
        
        if(!setOppId.isEmpty()){
            Set<String> setFlowStatus = new Set<String>{
                'M2 - Pending Submittal', 'M2 - Kickback', 'M3 - Pending Submittal', 'M3 - Submitted', 'M3 - Kickback', 'Project Closed'
            };
            Id PTOId = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('PTO').getRecordTypeId();
            
            List<Job__c> lstJobToInsert = new List<Job__c>();
            List<Job__c> lstJobToUpdate = new List<Job__c>();
            for(Opportunity objOpportunity : [
                    SELECT Id, Name, OwnerId,
                        (SELECT Id, Flow_Status__c from Jobs__r
                        WHERE RecordType.Name = 'Financing')
                    FROM Opportunity 
                    WHERE Id in :setOppId])
            {
                if(objOpportunity.Jobs__r != null && !objOpportunity.Jobs__r.isEmpty()){
                    Boolean createPTOJob = false;
                    for(Job__c objFinancingJob : objOpportunity.Jobs__r){
                        if(setFlowStatus.contains(objFinancingJob.Flow_Status__c)){
                            createPTOJob = true;
                            break;
                        }
                    }
                
                    if(createPTOJob){
                        Job__c objJob = new Job__c();
                        objJob.Name = objOpportunity.Name + ' - PTO Job';
                        objJob.RecordTypeId = PTOId;
                        objJob.OwnerId = objOpportunity.OwnerId;
                        objJob.Opportunity__c = objOpportunity.Id;
                        objJob.Job_Status__c = 'New';
                        objJob.Automation__c = true;
                        objJob.Type__c = 'PTO';
                        objJob.Flow_Status__c = 'Pending Submission';
                        lstJobToInsert.add(objJob);
                    } else{
                        for(Job__c objFinancingJob : objOpportunity.Jobs__r){
                            objFinancingJob.Flow_Status__c = (objFinancingJob.Flow_Status__c == 'M1 - Approved'?'M2 - Pending Submittal':'M1 - Approved');
                            lstJobToUpdate.add(objFinancingJob);
                        }
                    }
                }
            }
            if(!lstJobToInsert.isEmpty())
                insert lstJobToInsert;
            /*
            if(!lstJobToUpdate.isEmpty())
                update lstJobToUpdate;
            */
        }
    }
    
    //This method is used to populate last refresh date.
    private void populateLastRefreshDate(List<Opportunity> lstOpp, Map<Id, Opportunity> mapIdToOpp){
        Set<String> setFieldAPIs = new Set<String>();
        for(Opportunity_Field_List__c objOppCS : Opportunity_Field_List__c.getAll().values()){
            setFieldAPIs.add(objOppCS.Name.trim());
        }
        
        Set<Id> setOppId = new Set<Id>();
        for(Opportunity objOpp : lstOpp){
            Opportunity objOldOpp = mapIdToOpp.get(objOpp.Id);
            for(String fieldAPI : setFieldAPIs){
                if(objOpp.get(fieldAPI) != objOldOpp.get(fieldAPI)){
                    objOpp.Last_Refreshed_Commissions__c = Datetime.now();
                    break;
                }
            }
        }
    }
    
    //This method is used to refresh commission list.
    private void refreshCommission(List<Opportunity> lstOpp, Map<Id, Opportunity> mapIdToOpp){
        Set<String> setFieldAPIs = new Set<String>();
        for(Opportunity_Field_List__c objOppCS : Opportunity_Field_List__c.getAll().values()){
            setFieldAPIs.add(objOppCS.Name.trim());
        }
        
        Set<Id> setOppId = new Set<Id>();
        for(Opportunity objOpp : lstOpp){
            Opportunity objOldOpp = mapIdToOpp.get(objOpp.Id);
            for(String fieldAPI : setFieldAPIs){
                if(objOpp.get(fieldAPI) != objOldOpp.get(fieldAPI)){
                    setOppId.add(objOpp.Id);
                    break;
                }
            }
        }
        
        if(!setOppId.isEmpty()){
            OpportunityService.refreshCommission(setOppId);
        }
    }
        
    
    //This method is called to post opp data to End-point API.
    private void postOppData(List<Opportunity> lstOpp, Map<Id, Opportunity> mapIdToOpp){
        Set<Id> setOppId = new Set<Id>();
        Id designSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('3rd Party - Design Sales').getRecordTypeId();
        for(Opportunity objOpp : lstOpp){
            Opportunity objOldOpp = mapIdToOpp.get(objOpp.Id);
            if(objOpp.StageName != objOldOpp.StageName && objOpp.RecordTypeId == designSalesId && objOpp.X3rd_Party_Partner__c == 'LGCY Power'
                && objOpp.Test_Account__c == false)
            {
                setOppId.add(objOpp.Id);
            }
        }
        
        if(!setOppId.isEmpty()){
            Set<Id> setOppId2 = new Set<Id>();//and Opp_Primary_Contact__r.AccountId = '0012L000012GUMjQAO'
            for(Opportunity objOpp : [select Id from Opportunity where Id in :setOppId ]){
                setOppId2.add(objOpp.Id);
            }
            
            if(!setOppId2.isEmpty()){
                PalmettoAPIService.sendOppData(setOppId2);
            }
        }
    }
    
    //This method is used to update job flow status.
    private void updateInstallationFlowStatus(List<Opportunity> lstOpp, Map<Id, Opportunity> mapIdToOpp){
        Id designSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('X3rd_Party_Design_Sales').getRecordTypeId();
        Set<Id> setOppId = new Set<Id>();
        for(Opportunity objOpp : lstOpp){
            Opportunity objOldOpp = mapIdToOpp.get(objOpp.Id);
            if(objOpp.StageName == '17. Install Ready' && objOldOpp.StageName != '17. Install Ready' && objOpp.RecordTypeId == designSalesId){
                setOppId.add(objOpp.Id);
            }
        }
        
        if(!setOppId.isEmpty()){
            List<Job__c> lstJobToUpdate = new List<Job__c>();
            for(Job__c objJob : [
                    SELECT Id, Flow_Status__c 
                    FROM Job__c 
                    WHERE Opportunity__c in :setOppId 
                    AND RecordType.DeveloperName = 'Installation_Scheduling'
                    AND Flow_Status__c != 'New- Pending Scheduling'])
            {
                objJob.Flow_Status__c = 'New- Pending Scheduling';
                lstJobToUpdate.add(objJob);
            }
            
            if(!lstJobToUpdate.isEmpty())
                update lstJobToUpdate;
        }
    }
    
    //This method is used to update job flow status.
    private void updateJobFlowStatus(List<Opportunity> lstOpp, Map<Id, Opportunity> mapIdToOpp){
        Set<Id> setOppId = new Set<Id>();
        for(Opportunity objOpp : lstOpp){
            Opportunity objOldOpp = mapIdToOpp.get(objOpp.Id);
            if(objOpp.StageName == '22. PTO' && objOldOpp.StageName != '22. PTO'){
                setOppId.add(objOpp.Id);
            }
        }
        
        if(!setOppId.isEmpty()){
            List<Job__c> lstJobToUpdate = new List<Job__c>();
            for(Job__c objJob : [select Id, Opportunity__r.Financing_Tool__c, Flow_Status__c from Job__c where Opportunity__c in :setOppId and RecordType.Name = 'Financing']){
                if(objJob.Opportunity__r.Financing_Tool__c == 'SunRun'){
                    objJob.Flow_Status__c = (objJob.Flow_Status__c == 'M2 - Approved'?'M3 - Pending Submittal':'M2 - Approved');
                    lstJobToUpdate.add(objJob);
                } else{
                    objJob.Flow_Status__c = 'M2 - Pending Submittal';
                    lstJobToUpdate.add(objJob);
                }
            }
            
            if(!lstJobToUpdate.isEmpty())
                update lstJobToUpdate;
        }
    }
    //This method is used to validate the opp stage.
    private void validateOppStage(List<Opportunity> lstOpp, Map<Id, Opportunity> mapIdToOldOpp){
        Map<Id, Opportunity> mapIdToOpp = new Map<Id, Opportunity>();
        for(Opportunity objOpp : lstOpp){
            if(mapIdToOldOpp == null){
                if(objOpp.StageName == '17. Install Ready'){
                    mapIdToOpp.put(objOpp.Id, objOpp);
                }
            } else{
                Opportunity objOldOpp = mapIdToOldOpp.get(objOpp.Id);
                if(objOpp.StageName == '17. Install Ready' && objOldOpp.StageName != '17. Install Ready'){
                    mapIdToOpp.put(objOpp.Id, objOpp);
                }
            }
        }
        
        if(!mapIdToOpp.isEmpty()){
            Map<Id, List<Job__c>> mapOppIdToLstJob = new Map<Id, List<Job__c>>();
            for(Job__c objJob : [select Id, Flow_Status__c, Type__c, Opportunity__c, (select Id from Cases__r where RecordType.Name = 'Change Order' and IsClosed = false) 
                    from Job__c where RecordType.Name = 'Financing' and Opportunity__c in :mapIdToOpp.keyset()])
            {
                if(mapOppIdToLstJob.containsKey(objJob.Opportunity__c)){
                    mapOppIdToLstJob.get(objJob.Opportunity__c).add(objJob);
                } else{
                    mapOppIdToLstJob.put(objJob.Opportunity__c, new List<Job__c>{objJob});
                }
            }
        
            for(Id oppId : mapOppIdToLstJob.keyset()){
                for(Job__c objJob : mapOppIdToLstJob.get(oppId)){
                    //objJob.Flow_Status__c != 'M1 - Approved' &&
                    if(objJob.Flow_Status__c != null && objJob.Flow_Status__c != 'Notice to Proceed'){
                        mapIdToOpp.get(oppId).addError('Opportunity stage Install Ready is blocked until the FinOps job status is Notice to Proceed');
                        break;
                    }
                    
                    if(!objJob.Cases__r.isEmpty() && objJob.Type__c == 'Sunnova'){
                        mapIdToOpp.get(oppId).addError('Opportunity stage Installation is blocked until CR Case is closed under sunnova job');
                        break;
                    }
                }
            }
        }
    }

    private void createOppTeamMember(List<Opportunity> lstOpp){

        Set<Id> oppsIds = new Set<Id>();
        for(Opportunity objOpp : lstOpp){
            if(objOpp.Vendor__c != null){
                oppsIds.add(objOpp.Id);
            }
        }
        if(!oppsIds.isEmpty()){
            List<Opportunity> oppsToCreateOTM = [SELECT Id, Vendor__r.Account__c, Location__c FROM Opportunity WHERE Id IN :oppsIds];

            Set<Id> accountIds = new Set<Id>();
            List<Opportunity> oppsToProcess = new List<Opportunity>();
            for(Opportunity objOpp : oppsToCreateOTM){
                if(objOpp.Vendor__r != null && objOpp.Vendor__r.Account__c != null){
                    accountIds.add(objOpp.Vendor__r.Account__c);
                    oppsToProcess.add(objOpp);
                }
            }
            if(!accountIds.isEmpty()){
                Map<Id, Account> accoutnsById = new Map<Id, Account>([
                    SELECT Id, (
                        SELECT Id, UserId, State__c
                        FROM AccountTeamMembers
                        WHERE TeamMemberRole = 'Market Manager'
                    )
                    FROM Account
                    WHERE Id IN :accountIds
                ]);
                List<OpportunityTeamMember> oppTmToCreate = new List<OpportunityTeamMember>();
                for(Opportunity objOpp : oppsToProcess){
                    if(accoutnsById.containsKey(objOpp.Vendor__r.Account__c) && !accoutnsById.get(objOpp.Vendor__r.Account__c).AccountTeamMembers.isEmpty()){
                        for(AccountTeamMember accTM : accoutnsById.get(objOpp.Vendor__r.Account__c).AccountTeamMembers){
                            if(accTM.State__c.contains(objOpp.Location__c)){
                                oppTmToCreate.add(new OpportunityTeamMember(
                                    TeamMemberRole = 'Market Manager',
                                    UserId = accTM.UserId,
                                    OpportunityId = objOpp.Id
                                ));
                            }
                        }
                    }
                }
                if(!oppTmToCreate.isEmpty()){
                    insert oppTmToCreate;
                }
            }
        }
    }

    private void updateOppTeamMember(List<Opportunity> lstOpp, Map<Id,Opportunity> mapIdToOldOpp){
        Set<Id> oppsIds = new Set<Id>();
        for(Opportunity objOpp : lstOpp){
            if(objOpp.Vendor__c != mapIdToOldOpp.get(objOpp.Id).Vendor__c){
                oppsIds.add(objOpp.Id);
            }
        }
        if(!oppsIds.isEmpty()){
            List<Opportunity> oppsToCreateOTM = [SELECT Id, Vendor__r.Account__c, Location__c FROM Opportunity WHERE Id IN :oppsIds];

            Set<Id> accountIds = new Set<Id>();
            List<Opportunity> oppsToProcess = new List<Opportunity>();
            for(Opportunity objOpp : oppsToCreateOTM){
                if(objOpp.Vendor__r != null && objOpp.Vendor__r.Account__c != null){
                    accountIds.add(objOpp.Vendor__r.Account__c);
                    oppsToProcess.add(objOpp);
                }
            }
            if(!accountIds.isEmpty()){

                Map<Id, OpportunityTeamMember> existingOTMByOppId = new Map<Id, OpportunityTeamMember>();
                for(OpportunityTeamMember objOTM : [SELECT Id, UserId, OpportunityId FROM OpportunityTeamMember WHERE OpportunityId IN :oppsIds AND TeamMemberRole = 'Market Manager']){
                    existingOTMByOppId.put(objOTM.OpportunityId,objOTM);
                }

                Map<Id, Account> accoutnsById = new Map<Id, Account>([
                    SELECT Id, (
                        SELECT Id, UserId, State__c
                        FROM AccountTeamMembers
                        WHERE TeamMemberRole = 'Market Manager'
                    )
                    FROM Account
                    WHERE Id IN :accountIds
                ]);
                List<OpportunityTeamMember> oppTmToInsert = new List<OpportunityTeamMember>();
                List<OpportunityTeamMember> oppTmToDelete = new List<OpportunityTeamMember>();
                for(Opportunity objOpp : oppsToProcess){
                    if(accoutnsById.containsKey(objOpp.Vendor__r.Account__c) && !accoutnsById.get(objOpp.Vendor__r.Account__c).AccountTeamMembers.isEmpty()){
                        for(AccountTeamMember accTM : accoutnsById.get(objOpp.Vendor__r.Account__c).AccountTeamMembers){
                            if(accTM.State__c.contains(objOpp.Location__c)){

                                if(existingOTMByOppId.containsKey(objOpp.Id)){
                                    oppTmToDelete.add(existingOTMByOppId.get(objOpp.Id));
                                }
                                
                                oppTmToInsert.add(new OpportunityTeamMember(
                                    TeamMemberRole = 'Market Manager',
                                    UserId = accTM.UserId,
                                    OpportunityId = objOpp.Id
                                ));
                            }
                        }
                    }
                }
                if(!oppTmToDelete.isEmpty()){
                    delete oppTmToDelete;
                }
                if(!oppTmToInsert.isEmpty()){
                    upsert oppTmToInsert;
                }
            }
        }
    }
    
private void createIncentivesSRECTradeRegistrationJob(List<Opportunity> lstOpp, Map<Id, Opportunity> mapIdToOpp){
        Set<Id> setOppId = new Set<Id>();
        List<String> enabledLocations = new List<String>();

        enabledLocations = System.Label.SRECTrade_Registration_Job_Creation_States.split(',');

        for(Opportunity objOpp : lstOpp){
            Opportunity objOldOpp = mapIdToOpp.get(objOpp.Id);
            if(objOpp.StageName == '22. PTO' && objOldOpp.StageName != '22. PTO'
                && objOpp.Financing_Tool__c != 'SunRun'
                && objOpp.Financing_Tool__c != 'Sunnova Lease')
            {
                setOppId.add(objOpp.Id);
            }
        }
        
        if(!setOppId.isEmpty()){
            Group incentivesQueue = [SELECT Id FROM Group WHERE Name = 'Incentives' AND Type = 'Queue' LIMIT 1];
            Id SRECTradeId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Incentives_SRECTrade_Registration').getRecordTypeId();
            
            List<Job__c> lstJobToInsert = new List<Job__c>();
            for(Opportunity objOpportunity : [
                    SELECT Id, Name, OwnerId, Account.Name, Location__c, Utility__c, Name_on_Util_Bill_Exact_Name_Required__c, Address__c, Email__c, Financing_Tool__c,
                        (SELECT Id, Certification_Complete__c, RecordType.DeveloperName FROM Jobs__r
                        WHERE RecordType.DeveloperName = 'State_Certification'
                        OR RecordType.DeveloperName = 'Incentives_SRECTrade_Registration')
                    FROM Opportunity 
                    WHERE Id in :setOppId AND location__c IN :enabledLocations])
            {
                Job__c certJob = new Job__c();
                Job__c SRECJob = new Job__c();
                if(!objOpportunity.Jobs__r.isEmpty()){
                    for(Job__c objJob : objOpportunity.Jobs__r){    
                        if(objJob.RecordType.DeveloperName == 'State_Certification'){
                            certJob = objJob;
                        }
                        else if(objJob.RecordType.DeveloperName == 'Incentives_SRECTrade_Registration'){
                            SRECJob = objJob;
                        }
                    }
                }
                if(SRECJob.Id == null){
                    Job__c objJob = new Job__c();
                    objJob.Name = 'Incentives SRECTrade Registration Job';
                    objJob.RecordTypeId = SRECTradeId;
                    objJob.OwnerId = incentivesQueue.Id;
                    objJob.Opportunity__c = objOpportunity.Id;
                    objJob.Job_Status__c = 'New';
                    objJob.Flow_status__c = 'Required';
                    objJob.Date_of_State_Approval__c = certJob.Certification_Complete__c;
                    objJob.Type__c = 'Incentives SRECTrade';
                    objJob.Contact_Address__c = objOpportunity.Address__c;
                    objJob.Contact_Email__c = objOpportunity.Email__c;
                    objJob.Financing_Tool__c = objOpportunity.Financing_Tool__c;
                    objJob.Name_on_the_Utility_Bill__c = objOpportunity.Name_on_Util_Bill_Exact_Name_Required__c;
                    lstJobToInsert.add(objJob);
                }
            }
            

            if(!lstJobToInsert.isEmpty()){
                System.debug(lstJobToInsert);
                insert lstJobToInsert;
            }
        }
    }
    
private void createPreConstructionWorkCase(List<Opportunity> lstOpp,  Map<Id, Opportunity> mapIdToOpp){
    
		Set<String> oppIds = new Set<String>();
    	for (Opportunity opp : lstOpp) {
    		oppIds.add(opp.Id);
    	}

    	List<String> listOpps = new List<String>();
    	listOpps.addAll(oppIds);
    	
    	List<Product__c> lstStorageProducts = [SELECT Id,Opportunity__c, Name FROM Product__c];
    	List<Product__c> oppProducts = new List<Product__c>();
    	String preConstructionWorkRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Pre-Construction Work').getRecordTypeId();
    	List<Case> oppStorageCases = [SELECT RecordTypeId, CaseType__c, Opportunity__c FROM Case WHERE Opportunity__c IN :oppIds];	
		List<Case> lstStorageCases = new List<Case>();    
    	for(Product__c product : lstStorageProducts){
        	if(oppIds.contains(product.Opportunity__c)){
            	oppProducts.add(product);
        	}
    	}
    for(Case storageCase : oppStorageCases){
        if(storageCase.RecordTypeId == preConstructionWorkRecordTypeId &&
           storageCase.CaseType__c == 'Storage'){
               lstStorageCases.add(storageCase);
           }
    }
    	if(lstStorageProducts.size() > 0 && lstStorageCases.size() == 0){
            List <Case> preConCasesToInsert = new List<Case>();
            for(String opp : oppIds){
                Case preConCase = new Case(
                	RecordTypeId =  preConstructionWorkRecordTypeId,   
                	Opportunity__c = opp,
                	CaseType__c = 'Storage',
					Subject = 'Storage Management',
					Description = 'Field should include storage detail from customers order, pertinent communication between customer and PM, PM and Design, Adder approval notes, etc. ');
				
                preConCasesToInsert.add(preConCase);
               }
            insert preConCasesToInsert;
    	}
	}

    private void updateFinOpsJob(List<Opportunity> lstOpp, Map<Id, Opportunity> mapIdToOldOpp){
        Set<Id> oppIds = new Set<Id>();
        for(Opportunity objOpp : lstOpp){
            if(objOpp.Amount != null && objOpp.Amount != mapIdToOldOpp.get(objOpp.Id).Amount){
                oppIds.add(objOpp.Id);
            }
        }
        Id financingJobId = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Financing').getRecordTypeId();
        if(!oppIds.isEmpty()){
            List<Job__c> jobsToUpdate = new List<Job__c>();
            for(Opportunity objOpp : [SELECT Id, (SELECT Id, Flow_Status__c FROM Jobs__r WHERE RecordTypeId = :financingJobId) FROM Opportunity WHERE Id IN :oppIds]){
                if(objOpp.Jobs__r != null && !objOpp.Jobs__r.isEmpty()){
                    for(Job__c objJob : objOpp.Jobs__r){
                        if(objJob.Flow_Status__c == 'Notice to Proceed'){
                            objJob.Flow_Status__c = 'M0 - Pending NTP';
                            jobsToUpdate.add(objJob);
                        }
                    }
                }
            }
            if(!jobsToUpdate.isEmpty()){
                update jobsToUpdate;
            }
        }
    }
}