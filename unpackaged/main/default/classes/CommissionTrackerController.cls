public with sharing class  CommissionTrackerController 
{
    public Date toDate{get;set;}
    public Date fromDate{get;set;}
    public List<ComissionToBeProcessed> comissionToBeProcessedList{get;set;}
    public string trackerMode{get;set;} 
    public string selectedCommission {get;set;}
    public string selectedMilestone {get;set;}
    public List<string> selectedAll3rdPartyProvider{get;set;}
    public List<string> selectedAll3rdPartyProviderForEmail{get;set;}
    public List<SelectOption> mileStoneOptions{get;set;}
    public List<SelectOption> partyProvidersOptions{get;set;}
    public Boolean paidMileStone{get;set;}
    private Date fromDateExport{get;set;}
    private Date toDateExport{get;set;}
    private integer ReportType{get;set;}
    public boolean selectAllForProcessedCommission{get;set;}
    public boolean selectAllForCommissionToBeProcessed{get;set;}
    public Boolean displayUnprocessPopup{get; set;}
    public Map<string,string> providerNameMap{get;set;}
    public List<UnprocessCommissionWrapper> lstUnprocessCommissionWrapper{get; set;}
    public Boolean isUnprocessed{get; set;}
    public Boolean showSummaryView{get; set;}
    public String unprocessMsg{get; set;}
    public List<CommissionSummayWrapper> lstCommissionSummayWrapper{get; set;}
    User userobj_AccMgr =[SELECT profileid from User where Id=:UserInfo.getUserId()];
    
    public CommissionTrackerController()
    {
        //toDate = new Task();
        //fromDate = new Task();
        displayUnprocessPopup = false;
        isUnprocessed = false;
        find3rdPartyUser();
        comissionToBeProcessedList = new List<ComissionToBeProcessed>();
        trackerMode = 'Commission to be processed';
        isCommissionToBeProcessed = false;
        populateFilterPicklists();
        commissionToBeProcessed(false);
        isCommissionProcessed = false;
        paidMileStone = true;
        selectedCommission = '';
        findPartyProvider();
        selectAllForProcessedCommission = false;
        selectAllForCommissionToBeProcessed = false;
        showSummaryView = false;
    }
    public Boolean CPOwner
    {
        get
        {
            return (providerNameMap.containsKey('account_name') || userobj_AccMgr.ProfileId == '00e1a000000ZkbV');
            
        }
    }
    
    public string CPError
    {
        get
        {
             return providerNameMap.get('error');
        }
    }
    private void populateFilterPicklists()
    {
        selectedAllMilestone = new List<string>();
        selectedAllMilestone.add('M1');
        selectedAllMilestone.add('M2');
        selectedAllMilestone.add('M3');
        selectedAllMilestone.add('Clawbacks');
        milestonePickListOptions();
        partyProvidersPickListOptions();
    }
    public List<SelectOption> commissionPickListOptions
    {
        get
        {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('','Select'));
            if(fromDate == null)
            {
                options.add(new SelectOption('Commission to be Processed','Future Commissions'));
                options.add(new SelectOption('Processed Commissions','Processed Commission'));
                options.add(new SelectOption('Paid Commissions','Paid Commission'));
            }
            else if(checkDateIsFuture())
            {
                options.add(new SelectOption('Commission to be Processed','Future Commissions'));
            }
            else
            {
                options.add(new SelectOption('Processed Commissions','Processed Commission'));
                options.add(new SelectOption('Paid Commissions','Paid Commission'));
            }
            
            return options;
        }
    }
    
    private Boolean checkDateIsFuture()
    {
        if(fromDate > System.today() || (fromDate <=System.Today() && toDate > System.today()))
        {
            return true;
        }
        return false;
    }
    
    public List<string> selectedAllMilestone 
    {
        get;
        set;
        
    }
    public void milestonePickListOptions()
    {
        
        mileStoneOptions = new List<SelectOption>();
        mileStoneOptions.add(new SelectOption('M1','M1'));
        mileStoneOptions.add(new SelectOption('M2','M2'));
        mileStoneOptions.add(new SelectOption('M3','M3'));
        mileStoneOptions.add(new SelectOption('Clawbacks','Clawbacks'));
    }
    
    public string selected3rdPartyProvider{get;set;}
    public void partyProvidersPickListOptions()
    {
        partyProvidersOptions = new List<SelectOption>();
        if(providerNameMap.containsKey('account_name'))
        {
           selectedAll3rdPartyProvider = new List<String>();
           selectedAll3rdPartyProvider.add(providerNameMap.get('account_name'));
           partyProvidersOptions.add(new SelectOption(providerNameMap.get('account_name'),providerNameMap.get('account_name'))); 
        }
        else
        {
            partyProvidersOptions.addAll(get3rdPartyPartners());
        }
        
        
    }
    
    private string commissionToBeProcessedSOQL()
    {
        selectedMilestone = string.join(selectedAllMilestone,';');
        DateTime start_date = dateTime.now().addDays(-360);
        DateTime end_date = System.Datetime.now().addDays(-1);
        fromDateExport = start_Date.date();
        toDateExport = end_date.date();
        ReportType = 1;
        selected3rdPartyProvider = setToDelimitedString(',',selectedAll3rdPartyProvider,true);
        string soql = CommissionTrackerUtility.commissionToBeProcessedSOQL(selectedMilestone,selected3rdPartyProvider,start_date,end_date);
        return soql;
    }
    private string commissionToBeProcessedSOQLWhenSearch()
    {
        selectedMilestone = string.join(selectedAllMilestone,';');
        DateTime start_date = dateTime.newinstance(fromDate,Time.newInstance(0, 0, 0, 0));
        DateTime end_date = dateTime.newinstance(toDate,Time.newInstance(0, 0, 0, 0));
        fromDateExport = start_Date.date();
        toDateExport = end_date.date();
        ReportType = 1;
        selected3rdPartyProvider = setToDelimitedString(',',selectedAll3rdPartyProvider,true);
        string soql = CommissionTrackerUtility.commissionToBeProcessedSOQL(selectedMilestone,selected3rdPartyProvider,start_date,end_date);
        return soql;
    }
    private string commissionProcessedSOQL()
    {
       
        DateTime start_date = dateTime.newinstance(fromDate,Time.newInstance(0, 0, 0, 0));
        DateTime end_date = dateTime.newinstance(toDate,Time.newInstance(0, 0, 0, 0));
        fromDateExport = start_date.date();
        toDateExport = end_date.date();
        ReportType = 2;
        selected3rdPartyProvider = setToDelimitedString(',',selectedAll3rdPartyProvider,true);
        selectedMilestone = string.join(selectedAllMilestone,';');
       string soql = CommissionTrackerUtility.commissionProcessedSOQL(selectedMilestone,selected3rdPartyProvider,start_date,end_date,paidMileStone);
       return soql; 
   }
    
    private string commissionPaidSOQL()
    {
        
        DateTime start_date = dateTime.newinstance(fromDate,Time.newInstance(0, 0, 0, 0));
        DateTime end_date = dateTime.newinstance(toDate,Time.newInstance(0, 0, 0, 0));
        selectedMilestone = string.join(selectedAllMilestone,';');
        fromDateExport = start_date.date();
        toDateExport = end_date.date();
        ReportType = 3;
        selected3rdPartyProvider = setToDelimitedString(',',selectedAll3rdPartyProvider,true);
        selectedMilestone = string.join(selectedAllMilestone,';');
        string soql = CommissionTrackerUtility.commissionPaidSOQL(selectedMilestone,selected3rdPartyProvider,start_date,end_date);
     return soql;
   }
    
    private string createSOQL(string mode)
    {
        
        string commmission_to_be_processed;
        string soql;
        if(mode == 'Commission to be processed')
        {
            soql = commissionToBeProcessedSOQL();
        }
        else if(mode == 'Processed Commissions')
        {
            soql = commissionProcessedSOQL();    
        }
        else if(mode == 'Paid Commissions')
        {
            soql = commissionPaidSOQL();
        }
        else if(mode =='Commission to be processed When Searched')
        {
            soql = commissionToBeProcessedSOQLWhenSearch();
        }
        
        return soql;
    }
    
    
    public List<SelectOption> get3rdPartyPartners()
    {
        selectedAll3rdPartyProvider = new List<String>();
        selectedAll3rdPartyProviderForEmail = new List<String>();
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Opportunity.X3rd_Party_Partner__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
            selectedAll3rdPartyProvider.add(f.getValue());
            selectedAll3rdPartyProviderForEmail.add(f.getValue());
        }     
        return options;
    }
    
    public void changeFilter()
    {
        if(isCommissionToBeProcessed)
        {
            if(selectedCommission == 'Commission to be Processed')
            {
                paidMileStone = true;
                commissionToBeProcessed(true);
            }
            else
            {
               commissionToBeProcessed(false); 
            }
            
        }
        else if(isCommissionProcessed)
        {
            processTracker();
        }
    }
    public void commissionToBeProcessedOnSearch()
    {
        toDate = null;
        fromDate = null;
        paidMileStone = true;
        selectedCommission = '';
        //populateFilterPicklists();
        commissionToBeProcessed(false);
    }
    
    public Map<string,Map<string,List<CommissionProcessed>>> commissionToBeProcessed{get;set;}
    public Boolean isCommissionToBeProcessed{get;set;}
    public Map<string,Decimal> milestone1AmountActualPaidTotalMap {get;set;} 
    public Map<string,Decimal> milestone2AmountActualPaidTotalMap {get;set;}
    public Map<string,Decimal> milestone3AmountActualPaidTotalMap {get;set;}
    public Map<string,Decimal> milestoneClawBackAmountActualPaidTotalMap {get;set;}
    public Map<string,Decimal> partyProviderMilestone1AmountActualPaidTotalMap {get;set;} 
    public Map<string,Decimal> partyProviderMilestone2AmountActualPaidTotalMap {get;set;}
    public Map<string,Decimal> partyProviderMilestone3AmountActualPaidTotalMap {get;set;}
    public Map<string,Decimal> partyProviderMilestoneClawBackAmountActualPaidTotalMap {get;set;}
    public Map<string,Decimal> milestone1AmountTotalMap {get;set;} 
    public Map<string,Decimal> milestone2AmountTotalMap {get;set;}
    public Map<string,Decimal> milestone3AmountTotalMap {get;set;}
    public Map<string,Decimal> milestoneClawBackAmountTotalMap {get;set;}
    public Map<string,Decimal> partyProviderMilestone1AmountTotalMap {get;set;} 
    public Map<string,Decimal> partyProviderMilestone2AmountTotalMap {get;set;}
    public Map<string,Decimal> partyProviderMilestone3AmountTotalMap {get;set;}
    public Map<string,Decimal> partyProviderMilestoneClawBackAmountTotalMap {get;set;}
    
    
    public void unprocessCommission(){
        List<Commission__c> lstCommission = new List<Commission__c>();
        for(UnprocessCommissionWrapper objWrapper : lstUnprocessCommissionWrapper){
            if(objWrapper.isSelected == true){
                if(objWrapper.milestone == 'M1'){
                    objWrapper.objCommission.Milestone_1_Processed__c = false;
                    objWrapper.objCommission.Milestone_1_Processed_Date__c = null;
                    objWrapper.objCommission.Milestone_1_Amount_Actual_Paid__c = null;
                } else if(objWrapper.milestone == 'M2'){
                    objWrapper.objCommission.Milestone_2_Processed__c = false;
                    objWrapper.objCommission.Milestone_2_Processed_Date__c = null;
                    objWrapper.objCommission.Milestone_2_Amount_Actual_Paid__c = null;
                } else if(objWrapper.milestone == 'M3'){
                    objWrapper.objCommission.Milestone_3_Processed__c = false;
                    objWrapper.objCommission.Milestone_3_Processed_Date__c = null;
                    objWrapper.objCommission.Milestone_3_Actual_Paid__c = null;
                } else if(objWrapper.milestone == 'Cancellation Clawback'){
                    objWrapper.objCommission.M1_Clawback_Complete__c = false;
                    objWrapper.objCommission.M1_Clawback_Processed_Date__c = null;
                    objWrapper.objCommission.Clawback_Amount_Actual__c = null;
                }

                lstCommission.add(objWrapper.objCommission);
            }
        }
        
        if(!lstCommission.isEmpty())
            update lstCommission;
            
        unprocessMsg = 'Commission Unprocessed successfully.';
        isUnprocessed = true; 
    }
    
    //This method is used to show summary of commissions.
    public void showSummaryCommissions(){
        lstCommissionSummayWrapper = new List<CommissionSummayWrapper>();
        Map<String, CommissionSummayWrapper> mapProviderToSummaryWrapper = new Map<String, CommissionSummayWrapper>();
        if(commissionProcessedWithCustomClass != null){
            //Code for M1 Milestone.
            if(commissionProcessedWithCustomClass.get('M1') != null){
                for(String partyProvider : commissionProcessedWithCustomClass.get('M1').keyset()){
                    //partyProvider = partyProvider.capitalize();
                    String m1Key = partyProvider + '-M1';
                    if(partyProviderMilestone1AmountActualPaidTotalMap.get(m1Key) != null){
                        if(mapProviderToSummaryWrapper.containsKey(partyProvider)){
                            CommissionSummayWrapper objCommissionSummayWrapper = mapProviderToSummaryWrapper.get(partyProvider);
                            objCommissionSummayWrapper.milestone1Amount = (objCommissionSummayWrapper.milestone1Amount == null?0:objCommissionSummayWrapper.milestone1Amount) + partyProviderMilestone1AmountActualPaidTotalMap.get(m1Key);
                            mapProviderToSummaryWrapper.put(partyProvider, objCommissionSummayWrapper);
                        } else{
                            CommissionSummayWrapper objCommissionSummayWrapper = new CommissionSummayWrapper();
                            objCommissionSummayWrapper.milestone1Amount = partyProviderMilestone1AmountActualPaidTotalMap.get(m1Key);
                            mapProviderToSummaryWrapper.put(partyProvider, objCommissionSummayWrapper);
                        }
                    }
                }
            }
            
            //Code for M2 Milestone.
            if(commissionProcessedWithCustomClass.get('M2') != null){
                for(String partyProvider : commissionProcessedWithCustomClass.get('M2').keyset()){
                    //partyProvider = partyProvider.capitalize();
                    String m2Key = partyProvider + '-M2';
                    if(partyProviderMilestone2AmountActualPaidTotalMap.get(m2Key) != null){
                        if(mapProviderToSummaryWrapper.containsKey(partyProvider)){
                            CommissionSummayWrapper objCommissionSummayWrapper = mapProviderToSummaryWrapper.get(partyProvider);
                            objCommissionSummayWrapper.milestone2Amount = (objCommissionSummayWrapper.milestone2Amount == null?0:objCommissionSummayWrapper.milestone2Amount) + partyProviderMilestone2AmountActualPaidTotalMap.get(m2Key);
                            mapProviderToSummaryWrapper.put(partyProvider, objCommissionSummayWrapper);
                        } else{
                            CommissionSummayWrapper objCommissionSummayWrapper = new CommissionSummayWrapper();
                            objCommissionSummayWrapper.milestone2Amount = partyProviderMilestone2AmountActualPaidTotalMap.get(m2Key);
                            mapProviderToSummaryWrapper.put(partyProvider, objCommissionSummayWrapper);
                        }
                    }
                }
            }
            
            //Code for M3 Milestone.
            if(commissionProcessedWithCustomClass.get('M3') != null){
                for(String partyProvider : commissionProcessedWithCustomClass.get('M3').keyset()){
                    //partyProvider = partyProvider.capitalize();
                    String m3Key = partyProvider + '-M3';
                    if(partyProviderMilestone3AmountActualPaidTotalMap.get(m3Key) != null){
                        if(mapProviderToSummaryWrapper.containsKey(partyProvider)){
                            CommissionSummayWrapper objCommissionSummayWrapper = mapProviderToSummaryWrapper.get(partyProvider);
                            objCommissionSummayWrapper.milestone3Amount = (objCommissionSummayWrapper.milestone3Amount == null?0:objCommissionSummayWrapper.milestone3Amount) + partyProviderMilestone3AmountActualPaidTotalMap.get(m3Key);
                            mapProviderToSummaryWrapper.put(partyProvider, objCommissionSummayWrapper);
                        } else{
                            CommissionSummayWrapper objCommissionSummayWrapper = new CommissionSummayWrapper();
                            objCommissionSummayWrapper.milestone3Amount = partyProviderMilestone3AmountActualPaidTotalMap.get(m3Key);
                            mapProviderToSummaryWrapper.put(partyProvider, objCommissionSummayWrapper);
                        }
                    }
                }
            }
            
            //Code for Clawback Milestone.
            if(commissionProcessedWithCustomClass.get('Cancellation Clawback') != null){
                for(String partyProvider : commissionProcessedWithCustomClass.get('Cancellation Clawback').keyset()){
                    //partyProvider = partyProvider.capitalize();
                    String clawbackKey = partyProvider + '-Cancellation Clawback';
                    if(partyProviderMilestoneClawBackAmountActualPaidTotalMap.get(clawbackKey) != null){
                        if(mapProviderToSummaryWrapper.containsKey(partyProvider)){
                            CommissionSummayWrapper objCommissionSummayWrapper = mapProviderToSummaryWrapper.get(partyProvider);
                            objCommissionSummayWrapper.clawBackAmount = (objCommissionSummayWrapper.clawBackAmount == null?0:objCommissionSummayWrapper.clawBackAmount) + partyProviderMilestoneClawBackAmountActualPaidTotalMap.get(clawbackKey);
                            mapProviderToSummaryWrapper.put(partyProvider, objCommissionSummayWrapper);
                        } else{
                            CommissionSummayWrapper objCommissionSummayWrapper = new CommissionSummayWrapper();
                            objCommissionSummayWrapper.clawBackAmount = partyProviderMilestoneClawBackAmountActualPaidTotalMap.get(clawbackKey);
                            mapProviderToSummaryWrapper.put(partyProvider, objCommissionSummayWrapper);
                        }
                    }
                }
            }
        }
        
        if(commissionToBeProcessed != null && commissionProcessedWithCustomClass == null){
            //Code for M1 Milestone.
            if(commissionToBeProcessed.get('M1') != null){
                for(String partyProvider : commissionToBeProcessed.get('M1').keyset()){
                    //partyProvider = partyProvider.capitalize();
                    String m1Key = partyProvider + '-M1';
                    if(partyProviderMilestone1AmountTotalMap.get(m1Key) != null){
                        if(mapProviderToSummaryWrapper.containsKey(partyProvider)){
                            CommissionSummayWrapper objCommissionSummayWrapper = mapProviderToSummaryWrapper.get(partyProvider);
                            objCommissionSummayWrapper.milestone1Amount = (objCommissionSummayWrapper.milestone1Amount == null?0:objCommissionSummayWrapper.milestone1Amount) + partyProviderMilestone1AmountTotalMap.get(m1Key);
                            mapProviderToSummaryWrapper.put(partyProvider, objCommissionSummayWrapper);
                        } else{
                            CommissionSummayWrapper objCommissionSummayWrapper = new CommissionSummayWrapper();
                            objCommissionSummayWrapper.milestone1Amount = partyProviderMilestone1AmountTotalMap.get(m1Key);
                            mapProviderToSummaryWrapper.put(partyProvider, objCommissionSummayWrapper);
                        }
                    }
                }
            }
            
            //Code for M2 Milestone.
            if(commissionToBeProcessed.get('M2') != null){
                for(String partyProvider : commissionToBeProcessed.get('M2').keyset()){
                    //partyProvider = partyProvider.capitalize();
                    String m2Key = partyProvider + '-M2';
                    if(partyProviderMilestone2AmountTotalMap.get(m2Key) != null){
                        if(mapProviderToSummaryWrapper.containsKey(partyProvider)){
                            CommissionSummayWrapper objCommissionSummayWrapper = mapProviderToSummaryWrapper.get(partyProvider);
                            objCommissionSummayWrapper.milestone2Amount = (objCommissionSummayWrapper.milestone2Amount == null?0:objCommissionSummayWrapper.milestone2Amount) + partyProviderMilestone2AmountTotalMap.get(m2Key);
                            mapProviderToSummaryWrapper.put(partyProvider, objCommissionSummayWrapper);
                        } else{
                            CommissionSummayWrapper objCommissionSummayWrapper = new CommissionSummayWrapper();
                            objCommissionSummayWrapper.milestone2Amount = partyProviderMilestone2AmountTotalMap.get(m2Key);
                            mapProviderToSummaryWrapper.put(partyProvider, objCommissionSummayWrapper);
                        }
                    }
                }
            }
            
            //Code for M3 Milestone.
            if(commissionToBeProcessed.get('M3') != null){
                for(String partyProvider : commissionToBeProcessed.get('M3').keyset()){
                    //partyProvider = partyProvider.capitalize();
                    String m3Key = partyProvider + '-M3';
                    if(partyProviderMilestone3AmountTotalMap.get(m3Key) != null){
                        if(mapProviderToSummaryWrapper.containsKey(partyProvider)){
                            CommissionSummayWrapper objCommissionSummayWrapper = mapProviderToSummaryWrapper.get(partyProvider);
                            objCommissionSummayWrapper.milestone3Amount = (objCommissionSummayWrapper.milestone3Amount == null?0:objCommissionSummayWrapper.milestone3Amount) + partyProviderMilestone3AmountTotalMap.get(m3Key);
                            mapProviderToSummaryWrapper.put(partyProvider, objCommissionSummayWrapper);
                        } else{
                            CommissionSummayWrapper objCommissionSummayWrapper = new CommissionSummayWrapper();
                            objCommissionSummayWrapper.milestone3Amount = partyProviderMilestone3AmountTotalMap.get(m3Key);
                            mapProviderToSummaryWrapper.put(partyProvider, objCommissionSummayWrapper);
                        }
                    }
                }
            }
            
            //Code for Clawback Milestone.
            if(commissionToBeProcessed.get('Cancellation Clawback') != null){
                for(String partyProvider : commissionToBeProcessed.get('Cancellation Clawback').keyset()){
                    //partyProvider = partyProvider.capitalize();
                    String clawbackKey = partyProvider + '-Cancellation Clawback';
                    if(partyProviderMilestoneClawBackAmountTotalMap.get(clawbackKey) != null){
                        if(mapProviderToSummaryWrapper.containsKey(partyProvider)){
                            CommissionSummayWrapper objCommissionSummayWrapper = mapProviderToSummaryWrapper.get(partyProvider);
                            objCommissionSummayWrapper.clawBackAmount = (objCommissionSummayWrapper.clawBackAmount == null?0:objCommissionSummayWrapper.clawBackAmount) + partyProviderMilestoneClawBackAmountTotalMap.get(clawbackKey);
                            mapProviderToSummaryWrapper.put(partyProvider, objCommissionSummayWrapper);
                        } else{
                            CommissionSummayWrapper objCommissionSummayWrapper = new CommissionSummayWrapper();
                            objCommissionSummayWrapper.clawBackAmount = partyProviderMilestoneClawBackAmountTotalMap.get(clawbackKey);
                            mapProviderToSummaryWrapper.put(partyProvider, objCommissionSummayWrapper);
                        }
                    }
                }
            }
        }
        System.debug('>>>>>>>>>'+commissionToBeProcessed);
        System.debug('>>>>>>>>>'+commissionProcessedWithCustomClass);
        System.debug('>>>>>>>>>'+partyProviderMilestone1AmountTotalMap);
        System.debug('>>>>>>>>>'+partyProviderMilestone2AmountTotalMap);
        System.debug('>>>>>>>>>'+partyProviderMilestone3AmountTotalMap);
        System.debug('>>>>>>>>>'+partyProviderMilestoneClawBackAmountTotalMap);
            
        
        
        List<String> lstProvider = new List<String>();
        Map<String, CommissionSummayWrapper> mapTemp = new Map<String, CommissionSummayWrapper>();
        for(String partyProvider : mapProviderToSummaryWrapper.keyset()){
            CommissionSummayWrapper objWrapper = mapProviderToSummaryWrapper.get(partyProvider);
            partyProvider = partyProvider.capitalize();
            lstProvider.add(partyProvider);
            mapTemp.put(partyProvider, objWrapper);
        }
        lstProvider.sort();
        
        for(String partyProvider : lstProvider){
            CommissionSummayWrapper objWrapper = mapTemp.get(partyProvider);
            objWrapper.provideName = partyProvider;
            objWrapper.milestone1Amount = (objWrapper.milestone1Amount == null?0:objWrapper.milestone1Amount);
            objWrapper.milestone2Amount = (objWrapper.milestone2Amount == null?0:objWrapper.milestone2Amount);
            objWrapper.milestone3Amount = (objWrapper.milestone3Amount == null?0:objWrapper.milestone3Amount);
            objWrapper.clawBackAmount = (objWrapper.clawBackAmount == null?0:objWrapper.clawBackAmount);
            objWrapper.commissionAmount = objWrapper.milestone1Amount + objWrapper.milestone2Amount + objWrapper.milestone3Amount - objWrapper.clawBackAmount;
            lstCommissionSummayWrapper.add(objWrapper);
        }
        showSummaryView = true;
    }
    
    public void closeSummaryView(){
        showSummaryView = false;
    }
    
    public void openUpprocessPopup(){
        lstUnprocessCommissionWrapper = new List<UnprocessCommissionWrapper>();
        displayUnprocessPopup = true;
        isUnprocessed = false;
        
        if(commissionToBeProcessed != null){
            for(string item : commissionToBeProcessed.keySet())
            {
                Map<string,List<CommissionProcessed>> temp_commission_map = commissionToBeProcessed.get(item);
                for(string party_provider:temp_commission_map.keySet())
                {
                    List<CommissionProcessed> processed_list = temp_commission_map.get(party_provider);
                    for(CommissionProcessed processed_record : processed_list)
                    {
                        if(processed_record.isChecked)
                        {
                            lstUnprocessCommissionWrapper.add(new UnprocessCommissionWrapper(processed_record.commission, item));
                        }
                    }
                }
            }
        }
        
        if(commissionProcessedWithCustomClass != null){
            for(string item : commissionProcessedWithCustomClass.keySet())
            {
                Map<string,List<CommissionProcessed>> temp_commission_map = commissionProcessedWithCustomClass.get(item);
                for(string party_provider:temp_commission_map.keySet())
                {
                    List<CommissionProcessed> processed_list = temp_commission_map.get(party_provider);
                    for(CommissionProcessed processed_record : processed_list)
                    {
                        if(processed_record.isChecked)
                        {
                            lstUnprocessCommissionWrapper.add(new UnprocessCommissionWrapper(processed_record.commission, item));
                        }
                    }
                }
            }   
        }  
    }
    
    public void commissionToBeProcessed(boolean is_searched)
    {
        lstUnprocessCommissionWrapper = new List<UnprocessCommissionWrapper>();
        isCommissionToBeProcessed = true;
        isCommissionProcessed = false;
        string soql = '';
        if(is_searched)
        {
            soql = createSOQL('Commission to be processed When Searched');
        }
        else
        {
            soql = createSOQL('Commission to be processed');
        }
         
        system.debug('soql:'+soql);
        List<Commission__c> commission_list = (List<Commission__c>)Database.query(soql);
        /*
        if(commission_list != null && !commission_list.isEmpty()){
            for(Commission__c objCommission : commission_list){
                Decimal positiveCommission = 0, negativeCommission = 0;
                positiveCommission += (objCommission.Milestone_1_Amount__c == null?0:objCommission.Milestone_1_Amount__c);
                positiveCommission += (objCommission.Milestone_2_Amount__c == null?0:objCommission.Milestone_2_Amount__c);
                positiveCommission += (objCommission.Milestone_3_Amount__c == null?0:objCommission.Milestone_3_Amount__c);
                negativeCommission += (objCommission.Clawback_Amount_Actual__c == null?0:objCommission.Clawback_Amount_Actual__c);
                
                if(negativeCommission > positiveCommission){
                    lstUnprocessCommissionWrapper.add(new UnprocessCommissionWrapper(objCommission));
                }
            }
        }
        */
        
        commissionToBeProcessed = new Map<string,Map<string,List<CommissionProcessed>>>();
        
        generateTableForCommissionToBeProcessed(commission_list,commissionToBeProcessed);
        milestone1AmountActualPaidTotalMap = new Map<string,Decimal>();
        milestone2AmountActualPaidTotalMap = new Map<string,Decimal>();
        milestone3AmountActualPaidTotalMap = new Map<string,Decimal>();
        milestoneClawBackAmountActualPaidTotalMap = new Map<string,Decimal>();
        partyProviderMilestone1AmountActualPaidTotalMap = new Map<string,Decimal>();
        partyProviderMilestone2AmountActualPaidTotalMap = new Map<string,Decimal>();
        partyProviderMilestone3AmountActualPaidTotalMap = new Map<string,Decimal>();
        partyProviderMilestoneClawBackAmountActualPaidTotalMap = new Map<string,Decimal>();
        
        /********************/
        milestone1AmountTotalMap = new Map<string,Decimal>();
        milestone2AmountTotalMap = new Map<string,Decimal>();
        milestone3AmountTotalMap = new Map<string,Decimal>();
        milestoneClawBackAmountTotalMap = new Map<string,Decimal>();
        partyProviderMilestone1AmountTotalMap  = new Map<string,Decimal>();
        partyProviderMilestone2AmountTotalMap = new Map<string,Decimal>();
        partyProviderMilestone3AmountTotalMap = new Map<string,Decimal>();
        partyProviderMilestoneClawBackAmountTotalMap = new Map<string,Decimal>();
            
        for(string milestone:commissionToBeProcessed.keySet())
        {
            Map<string,List<CommissionProcessed>> commission_to_be_processed_map = commissionToBeProcessed.get(milestone);
            Decimal milestone1AmountActualPaidTotal = 0;
            Decimal milestone2AmountActualPaidTotal = 0;
            Decimal milestone3AmountActualPaidTotal = 0;
            Decimal milestoneClawBackAmountActualPaidTotal = 0;
            Decimal milestone1AmountTotal = 0;
            Decimal milestone2AmountTotal = 0;
            Decimal milestone3AmountTotal = 0;
            Decimal milestoneClawBackAmountTotal = 0;
            for(string party_provider:commission_to_be_processed_map.keySet())
            {
                List<CommissionProcessed> commission_list_temp = commission_to_be_processed_map.get(party_provider);
                Decimal partyProviderMilestone1AmountActualPaidTotal = 0;
                Decimal partyProviderMilestone2AmountActualPaidTotal = 0;
                Decimal partyProviderMilestone3AmountActualPaidTotal = 0;
                Decimal partyProviderMilestoneClawBackAmountActualPaidTotal = 0;
                Decimal partyProviderMilestone1AmountTotal = 0;
                Decimal partyProviderMilestone2AmountTotal = 0;
                Decimal partyProviderMilestone3AmountTotal = 0;
                Decimal partyProviderMilestoneClawBackAmountTotal = 0;
                for(CommissionProcessed item:commission_list_temp)
                {
                    if(item.commission.Milestone_1_Amount_Actual_Paid__c != null)
                    {
                        milestone1AmountActualPaidTotal += item.commission.Milestone_1_Amount_Actual_Paid__c;
                        partyProviderMilestone1AmountActualPaidTotal += item.commission.Milestone_1_Amount_Actual_Paid__c;
                    }
                    if(item.commission.Milestone_2_Amount_Actual_Paid__c != null)
                    {
                        milestone2AmountActualPaidTotal += item.commission.Milestone_2_Amount_Actual_Paid__c;
                        partyProviderMilestone2AmountActualPaidTotal += item.commission.Milestone_2_Amount_Actual_Paid__c;
                    }
                    if(item.commission.Milestone_3_Actual_Paid__c != null)
                    {
                        milestone3AmountActualPaidTotal += item.commission.Milestone_3_Actual_Paid__c;
                        partyProviderMilestone3AmountActualPaidTotal += item.commission.Milestone_3_Actual_Paid__c;
                    }
                    if(item.commission.Clawback_Amount_Actual__c != null)
                    {
                        milestoneClawBackAmountActualPaidTotal += item.commission.Clawback_Amount_Actual__c;
                        partyProviderMilestoneClawBackAmountActualPaidTotal += item.commission.Clawback_Amount_Actual__c;
                    }
                    if(item.commission.Milestone_1_Amount__c != null)
                    {
                        milestone1AmountTotal +=item.commission.Milestone_1_Amount__c;
                        partyProviderMilestone1AmountTotal +=item.commission.Milestone_1_Amount__c;
                    }
                    
                    if(item.commission.Milestone_2_Amount__c != null)
                    {
                        milestone2AmountTotal +=item.commission.Milestone_2_Amount__c;
                        partyProviderMilestone2AmountTotal +=item.commission.Milestone_2_Amount__c;
                    }
                    if(item.commission.Milestone_3_Amount__c != null)
                    {
                        milestone3AmountTotal +=item.commission.Milestone_3_Amount__c;
                        partyProviderMilestone3AmountTotal +=item.commission.Milestone_3_Amount__c;
                    }
                    if(item.commission.M1_Clawback_Amount__c != null)
                    {
                        milestoneClawBackAmountTotal +=item.commission.M1_Clawback_Amount__c;
                        partyProviderMilestoneClawBackAmountTotal +=item.commission.M1_Clawback_Amount__c;
                    }
                }
                partyProviderMilestone1AmountActualPaidTotalMap.put(party_provider+'-'+milestone,partyProviderMilestone1AmountActualPaidTotal);
                partyProviderMilestone2AmountActualPaidTotalMap.put(party_provider+'-'+milestone,partyProviderMilestone2AmountActualPaidTotal);
                partyProviderMilestone3AmountActualPaidTotalMap.put(party_provider+'-'+milestone,partyProviderMilestone3AmountActualPaidTotal);
                partyProviderMilestoneClawBackAmountActualPaidTotalMap.put(party_provider+'-'+milestone,partyProviderMilestoneClawBackAmountActualPaidTotal);
                
                partyProviderMilestone1AmountTotalMap.put(party_provider+'-'+milestone,partyProviderMilestone1AmountTotal);
                partyProviderMilestone2AmountTotalMap.put(party_provider+'-'+milestone,partyProviderMilestone2AmountTotal);
                partyProviderMilestone3AmountTotalMap.put(party_provider+'-'+milestone,partyProviderMilestone3AmountTotal);
                partyProviderMilestoneClawBackAmountTotalMap.put(party_provider+'-'+milestone,partyProviderMilestoneClawBackAmountTotal);
            }
            milestone1AmountTotalMap.put(milestone,milestone1AmountTotal);
            milestone2AmountTotalMap.put(milestone,milestone2AmountTotal);
            milestone3AmountTotalMap.put(milestone,milestone3AmountTotal);
            milestoneClawBackAmountTotalMap.put(milestone,milestoneClawBackAmountTotal);
            milestone1AmountActualPaidTotalMap.put(milestone,milestone1AmountActualPaidTotal);
            milestone2AmountActualPaidTotalMap.put(milestone,milestone2AmountActualPaidTotal);
            milestone3AmountActualPaidTotalMap.put(milestone,milestone3AmountActualPaidTotal);
            milestoneClawBackAmountActualPaidTotalMap.put(milestone,milestoneClawBackAmountActualPaidTotal);
        }
       
    }
    private void generateTableForCommissionToBeProcessed(List<Commission__c> commission_list, Map<string,Map<string,List<CommissionProcessed>>> commission_map)
    {
        for(Commission__c item:commission_list)
        {
            if(commission_map.containsKey(item.Milestone_Payments__c))
            {
                Map<string,List<CommissionProcessed>> temp_commission_map = commission_map.get(item.Milestone_Payments__c);
                if(temp_commission_map.containsKey(item.Opportunity__r.X3rd_Party_Partner__c))
                {
                    List<CommissionProcessed> temp_commission_list = temp_commission_map.get(item.Opportunity__r.X3rd_Party_Partner__c);
                    CommissionProcessed temp_commission_processed = new CommissionProcessed(false,item);
                    temp_commission_list.add(temp_commission_processed);
                }
                else
                {
                    List<CommissionProcessed> temp_commission_list = new List<CommissionProcessed>();
                    CommissionProcessed temp_commission_processed = new CommissionProcessed(false,item);
                    temp_commission_list.add(temp_commission_processed);
                    temp_commission_map.put(item.Opportunity__r.X3rd_Party_Partner__c,temp_commission_list);
                }
                
            }
            else
            {
                List<CommissionProcessed> temp_commission_list = new List<CommissionProcessed>();
                CommissionProcessed temp_commission_processed = new CommissionProcessed(false,item);
                temp_commission_list.add(temp_commission_processed);
                Map<string,List<CommissionProcessed>> temp_commission_map = new Map<string,List<CommissionProcessed>>();
                temp_commission_map.put(item.Opportunity__r.X3rd_Party_Partner__c,temp_commission_list);
                commission_map.put(item.Milestone_Payments__c,temp_commission_map);
            }
        }
    }
    
    public void processTrackerWhenSearch()
    {
        paidMileStone = true;
        //populateFilterPicklists();
        processTracker();
        
        commissionToBeProcessed.clear();
    }
    
    public void selectProcessedCommissionRecords()
    {
         for(string item:commissionProcessedWithCustomClass.keySet())
        {
            Map<string,List<CommissionProcessed>> temp_commission_map = commissionProcessedWithCustomClass.get(item);
            for(string party_provider:temp_commission_map.keySet())
            {
                List<CommissionProcessed> processed_list = temp_commission_map.get(party_provider);
                for(CommissionProcessed processed_record:processed_list)
                {
                    if(selectAllForProcessedCommission)
                    {
                        processed_record.isChecked = true;
                    }
                    else
                    {
                        processed_record.isChecked = false;
                    }
                }
           }
        }
    }
    
    public void selectCommissionToBeProcessedRecords()
    {
         for(string item:commissionToBeProcessed.keySet())
        {
            Map<string,List<CommissionProcessed>> temp_commission_map = commissionToBeProcessed.get(item);
            for(string party_provider:temp_commission_map.keySet())
            {
                List<CommissionProcessed> processed_list = temp_commission_map.get(party_provider);
                for(CommissionProcessed processed_record:processed_list)
                {
                    if(selectAllForCommissionToBeProcessed)
                    {
                        processed_record.isChecked = true;
                    }
                    else
                    {
                        processed_record.isChecked = false;
                    }
                }
           }
        }
    }
    public void processMilestone()
    {
        List<String> commission_id_list = new List<String>();
        Map<Id, String> mapCommissionIdToMileStone = new Map<Id, String>();
        for(string item:commissionToBeProcessed.keySet())
        {
            Map<string,List<CommissionProcessed>> temp_commission_map = commissionToBeProcessed.get(item);
            for(string party_provider:temp_commission_map.keySet())
            {
                List<CommissionProcessed> processed_list = temp_commission_map.get(party_provider);
                for(CommissionProcessed processed_record:processed_list)
                {
                    if(processed_record.isChecked)
                    {
                        //commission_id_list.add(processed_record.commission.id);
                        mapCommissionIdToMileStone.put(processed_record.commission.id, item);
                    }
                }
            }
        }
        
        if(commissionProcessedWithCustomClass != null){
            for(string item : commissionProcessedWithCustomClass.keySet())
            {
                Map<string,List<CommissionProcessed>> temp_commission_map = commissionProcessedWithCustomClass.get(item);
                for(string party_provider:temp_commission_map.keySet())
                {
                    List<CommissionProcessed> processed_list = temp_commission_map.get(party_provider);
                    for(CommissionProcessed processed_record : processed_list)
                    {
                        if(processed_record.isChecked)
                        {
                            //commission_id_list.add(processed_record.commission.id);
                            mapCommissionIdToMileStone.put(processed_record.commission.id, item);
                        }
                    }
                }
            }   
        }
        
        if(mapCommissionIdToMileStone.size() > 0)
        {
            List<Commission__c> all_commission_to_be_processed_list = new List<Commission__c>();
            all_commission_to_be_processed_list.addAll(ProcessM1MileStone(mapCommissionIdToMileStone));
            //all_commission_to_be_processed_list.addAll(ProcessM2MileStone(commission_id_list));
            //all_commission_to_be_processed_list.addAll(ProcessM3MileStone(commission_id_list));
            //all_commission_to_be_processed_list.addAll(ProcessClawBackMileStone(commission_id_list));
            update all_commission_to_be_processed_list;
            
            /*
            if(selectedCommission == 'Commission to be Processed')
            {
                commissionToBeProcessed(true);
            }
            else
            {
                 commissionToBeProcessed(false);
            }*/
           
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.INFO, 'Milestones are processed successfully.'));
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.INFO, 'No record is selected.'));
        }
       
    }
    
    private List<Commission__c> ProcessM1MileStone(Map<Id, String> mapCommissionIdToMileStone)
    {
        /*String M1 = '';
        string where_clause = '';
        DateTime start_date;
        DateTime end_date;
         
        if(selectedCommission == 'Commission to be Processed')
        {
            start_date = dateTime.newinstance(fromDate,Time.newInstance(0, 0, 0, 0));
            end_date = dateTime.newinstance(toDate,Time.newInstance(0, 0, 0, 0));
        }
        else
        {
            start_date = dateTime.now().addDays(-360);
            end_date = System.Datetime.now().addDays(-1);
        }
        
        where_clause = 'WHERE';
        string mile_stone_ids = setToDelimitedString(',',commission_id_list,true);
        M1 = string.format('((Milestone_1_Date_Calculated__c >={0} AND Milestone_1_Date_Calculated__c <= {1}) AND Opportunity__r.Contract_Received_Confirmed__c = true AND Opportunity__r.StageName != {2} AND Milestone_1_Processed__c = false AND Milestone_1_Paid__c = false AND Id IN({3}))',
                           new string[]{start_date.format('yyyy-MM-dd'),
                               end_date.format('yyyy-MM-dd'),
                               '\'Change Order Pending\'',
                               mile_stone_ids
                               }); 
         string soql = string.format('SELECT Milestone_1_Amount__c,Milestone_1_Amount_Actual_Paid__c,Milestone_1_Processed_Date__c from Commission__c {0} ({1})',new string[]
                                    {where_clause,M1});
         
         List<Commission__c> commission_list = (List<Commission__c>)Database.query(soql);
         system.debug('M1 Size:'+commission_list.size());
         */
         List<Commission__c> commission_list = [SELECT Milestone_1_Amount__c,Milestone_1_Amount_Actual_Paid__c,Milestone_1_Processed_Date__c, 
                     Milestone_2_Amount__c, Milestone_3_Amount__c
                     from Commission__c where Id IN :mapCommissionIdToMileStone.keyset()];
         
         for(Commission__c item : commission_list)
         {
             String milestone = mapCommissionIdToMileStone.get(item.Id);
             if(milestone == 'M1'){
                 item.Milestone_1_Processed_Date__c = System.date.today();
                 item.Milestone_1_Amount_Actual_Paid__c = item.Milestone_1_Amount__c;
                 item.Milestone_1_Processed__c = true;
             } else if(milestone == 'M2'){
                 item.Milestone_2_Processed_Date__c = System.date.today();
                 item.Milestone_2_Amount_Actual_Paid__c = item.Milestone_2_Amount__c;
                 item.Milestone_2_Processed__c = true;
             } else if(milestone == 'M3'){
                 item.Milestone_3_Processed_Date__c = System.date.today();
                 item.Milestone_3_Actual_Paid__c = item.Milestone_3_Amount__c;
                 item.Milestone_3_Processed__c = true;
             } else if(milestone == 'Cancellation Clawback'){
                 item.M1_Clawback_Processed_Date__c = System.date.today();
                 item.M1_Clawback_Complete__c = true;
             }
         }
        
         return commission_list;
    }
    /*
    private List<Commission__c> ProcessM2MileStone(List<String> commission_id_list)
    {
        String M2 = '';
        string where_clause = '';
        DateTime start_date;
        DateTime end_date; 
        if(selectedCommission == 'Commission to be Processed')
        {
            start_date = dateTime.newinstance(fromDate,Time.newInstance(0, 0, 0, 0));
            end_date = dateTime.newinstance(toDate,Time.newInstance(0, 0, 0, 0));
        }
        else
        {
            start_date = dateTime.now().addDays(-360);
            end_date = System.Datetime.now().addDays(-1);
        }
        where_clause = 'WHERE';
        string mile_stone_ids = setToDelimitedString(',',commission_id_list,true);
        M2 = string.format('((Milestone_2_Date__c >={0} AND Milestone_2_Date__c <={1} ) AND Milestone_1_Paid__c = true AND Milestone_2_Paid__c = false AND Milestone_2_Processed__c = false AND Id IN({2}))',
                               new string[]{
                                   start_date.format('yyyy-MM-dd'),
                                       end_date.format('yyyy-MM-dd'),
                                       mile_stone_ids
                                       });
        string soql = string.format('SELECT Milestone_2_Amount__c,Milestone_2_Amount_Actual_Paid__c,Milestone_2_Processed_Date__c' +
                                    ' from Commission__c {0} ({1})',new string[]
                                    {
                                        where_clause,M2
                                    });
       
       List<Commission__c> commission_list = (List<Commission__c>)Database.query(soql);
        system.debug('M2 Size:'+commission_list.size());
         for(Commission__c item:commission_list)
         {
           item.Milestone_2_Processed_Date__c = System.date.today();
           item.Milestone_2_Amount_Actual_Paid__c = item.Milestone_2_Amount__c;
           item.Milestone_2_Processed__c = true;
           
         }
        
         return commission_list;
    }
    
    private List<Commission__c> ProcessM3MileStone(List<String> commission_id_list)
    {
        String M3 = '';
        string where_clause = '';
        DateTime start_date;
        DateTime end_date; 
        if(selectedCommission == 'Commission to be Processed')
        {
            start_date = dateTime.newinstance(fromDate,Time.newInstance(0, 0, 0, 0));
            end_date = dateTime.newinstance(toDate,Time.newInstance(0, 0, 0, 0));
        }
        else
        {
            start_date = dateTime.now().addDays(-360);
            end_date = System.Datetime.now().addDays(-1);
        }
        where_clause = 'WHERE';
        string mile_stone_ids = setToDelimitedString(',',commission_id_list,true);
        M3 = string.format('((Milestone_3_Date_PTO_3_Days__c >={0} AND Milestone_3_Date_PTO_3_Days__c<={1} ) AND Milestone_3_Processed__c = false AND Milestone_3_Paid__c = false AND Milestone_2_Paid__c = true AND (M3__c != null AND M3__c != 0) AND Id IN({2}))',
                               new string[]{
                                   start_date.format('yyyy-MM-dd'),
                                       end_date.format('yyyy-MM-dd'),
                                       mile_stone_ids
                                       });
        string soql = string.format('SELECT Milestone_3_Amount__c,Milestone_3_Actual_Paid__c,Milestone_3_Processed_Date__c' +
                                    ' from Commission__c {0} ({1})',new string[]
                                    {
                                        where_clause,M3
                                    });
       List<Commission__c> commission_list = (List<Commission__c>)Database.query(soql);
        system.debug('M3 Size:'+commission_list.size());
        for(Commission__c item:commission_list)
        {
            item.Milestone_3_Processed_Date__c = System.date.today();
            item.Milestone_3_Actual_Paid__c = item.Milestone_3_Amount__c;
            item.Milestone_3_Processed__c = true;
            
        }
        
         return commission_list;
    }
    
    private List<Commission__c> ProcessClawBackMileStone(List<String> commission_id_list)
    {
         String claw_back = '';
        string where_clause = '';
        DateTime start_date;
        DateTime end_date; 
        if(selectedCommission == 'Commission to be Processed')
        {
            start_date = dateTime.newinstance(fromDate,Time.newInstance(0, 0, 0, 0));
            end_date = dateTime.newinstance(toDate,Time.newInstance(0, 0, 0, 0));
        }
        else
        {
            start_date = dateTime.now().addDays(-360);
            end_date = System.Datetime.now().addDays(-1);
        }
        where_clause = 'WHERE';
        string mile_stone_ids = setToDelimitedString(',',commission_id_list,true);
        claw_back = string.format(' ((Opportunity__r.Cancellation_Date__c >={0} AND Opportunity__r.Cancellation_Date__c<={1}) AND Milestone_1_Paid__c = true AND M1_Clawback_Complete__c = false AND Id IN({2}))'
                                      ,new string[]{
                                          start_date.format('yyyy-MM-dd'),
                                              end_date.format('yyyy-MM-dd'),
                                              mile_stone_ids
                                              }
                                     );
       string soql = string.format('SELECT M1_Clawback_Processed_Date__c from Commission__c {0} ({1})',new string[]
                                    {
                                        where_clause,claw_back
                                    });
        system.debug('soql:'+soql);
       List<Commission__c> commission_list = (List<Commission__c>)Database.query(soql);
       system.debug('claw_back Size:'+commission_list.size());
       for(Commission__c item:commission_list)
       {
          item.M1_Clawback_Processed_Date__c = System.date.today();
          item.M1_Clawback_Complete__c = true;
       }
        
         return commission_list;
    }*/
    public void assignDateToCommissionProcessed()
    {
        List<Commission__c> all_commission_list = new List<Commission__c>();
        for(string item:commissionProcessedWithCustomClass.keySet())
        {
            Map<string,List<CommissionProcessed>> temp_commission_map = commissionProcessedWithCustomClass.get(item);
            for(string party_provider:temp_commission_map.keySet())
            {
                List<CommissionProcessed> processed_list = temp_commission_map.get(party_provider);
                for(CommissionProcessed processed_record:processed_list)
                {
                    if(processed_record.isChecked)
                    {
                        if(item == 'M1' && processed_record.commission.Milestone_1_Paid_Date__c == null)
                        {
                            processed_record.commission.Milestone_1_Paid_Date__c = System.date.today();
                            processed_record.commission.Milestone_1_Paid__c = true;
                        }
                        else if(item == 'M2' && processed_record.commission.Milestone_2_Paid_Date__c == null)
                        {
                            processed_record.commission.Milestone_2_Paid_Date__c = System.date.today();
                            processed_record.commission.Milestone_2_Paid__c = true;
                        }
                        else if(item == 'M3' && processed_record.commission.Milestone_3_Paid_Date__c == null)
                        {
                            processed_record.commission.Milestone_3_Paid_Date__c = System.date.today();
                            processed_record.commission.Milestone_3_Paid__c = true;
                        }
                        else if(item == 'Cancellation Clawback' && processed_record.commission.M1_Clawback_Applied_to_Balance_Paid_Date__c == null)
                        {
                            processed_record.commission.M1_Clawback_Applied_to_Balance_Paid_Date__c = System.date.today();
                            processed_record.commission.M1_Clawback_Applied_Paid__c = true; 

                        }
                        all_commission_list.add(processed_record.commission);
                    }
                    
                }
            }
        }
        if(all_commission_list.size() > 0)
        {
            update all_commission_list;
            processTracker();
        }
    }
    public Map<string,Map<string,List<Commission__c>>> commissionProcessed{get;set;}
    public Map<string,Map<string,List<CommissionProcessed>>>  commissionProcessedWithCustomClass{get;set;}
    public Boolean isCommissionProcessed{get;set;}
    public void processTracker()
    {
        if(validate())
        {
            if(selectedCommission == 'Commission to be Processed')
            {
                paidMileStone = true;
                commissionToBeProcessed(true);
            }
            else
            {
                system.debug('Selected commission:'+selectedCommission);
            string soql = createSOQL(selectedCommission);
            system.debug('soql:'+soql);
            List<Commission__c> commission_list = (List<Commission__c>)Database.query(soql);
            system.debug('Process tracker list size:'+commission_list.size());
            if(selectedCommission == 'Processed Commissions')
            {
                commissionProcessedWithCustomClass = new Map<string,Map<string,List<CommissionProcessed>>>();
                generateTableForCommissionCustomClass(commission_list,commissionProcessedWithCustomClass);
                milestone1AmountActualPaidTotalMap = new Map<string,Decimal>();
                milestone2AmountActualPaidTotalMap = new Map<string,Decimal>();
                milestone3AmountActualPaidTotalMap = new Map<string,Decimal>();
                milestoneClawBackAmountActualPaidTotalMap = new Map<string,Decimal>();
                partyProviderMilestone1AmountActualPaidTotalMap = new Map<string,Decimal>();
                partyProviderMilestone2AmountActualPaidTotalMap = new Map<string,Decimal>();
                partyProviderMilestone3AmountActualPaidTotalMap = new Map<string,Decimal>();
                partyProviderMilestoneClawBackAmountActualPaidTotalMap = new Map<string,Decimal>();
                /***************************************/
                milestone1AmountTotalMap = new Map<string,Decimal>();
                milestone2AmountTotalMap = new Map<string,Decimal>();
                milestone3AmountTotalMap = new Map<string,Decimal>();
                milestoneClawBackAmountTotalMap = new Map<string,Decimal>();
                partyProviderMilestone1AmountTotalMap  = new Map<string,Decimal>();
                partyProviderMilestone2AmountTotalMap = new Map<string,Decimal>();
                partyProviderMilestone3AmountTotalMap = new Map<string,Decimal>();
                partyProviderMilestoneClawBackAmountTotalMap = new Map<string,Decimal>();
                
                for(string milestone:commissionProcessedWithCustomClass.keySet())
                {
                    Map<string,List<CommissionProcessed>> commission_to_be_processed_map = commissionProcessedWithCustomClass.get(milestone);
                    Decimal milestone1AmountActualPaidTotal = 0;
                    Decimal milestone2AmountActualPaidTotal = 0;
                    Decimal milestone3AmountActualPaidTotal = 0;
                    Decimal milestoneClawBackAmountActualPaidTotal = 0;
                    
                    Decimal milestone1AmountTotal = 0;
                    Decimal milestone2AmountTotal = 0;
                    Decimal milestone3AmountTotal = 0;
                    Decimal milestoneClawBackAmountTotal = 0;

                    for(string party_provider:commission_to_be_processed_map.keySet())
                    {
                        List<CommissionProcessed> commission_list_temp = commission_to_be_processed_map.get(party_provider);
                        Decimal partyProviderMilestone1AmountActualPaidTotal = 0;
                        Decimal partyProviderMilestone2AmountActualPaidTotal = 0;
                        Decimal partyProviderMilestone3AmountActualPaidTotal = 0;
                        Decimal partyProviderMilestoneClawBackAmountActualPaidTotal = 0;
                        
                        Decimal partyProviderMilestone1AmountTotal = 0;
                        Decimal partyProviderMilestone2AmountTotal = 0;
                        Decimal partyProviderMilestone3AmountTotal = 0;
                        Decimal partyProviderMilestoneClawBackAmountTotal = 0;
                        for(CommissionProcessed item:commission_list_temp)
                        {
                            if(item.commission.Milestone_1_Amount_Actual_Paid__c != null)
                            {
                                milestone1AmountActualPaidTotal += item.commission.Milestone_1_Amount_Actual_Paid__c;
                                partyProviderMilestone1AmountActualPaidTotal += item.commission.Milestone_1_Amount_Actual_Paid__c;
                            }
                            if(item.commission.Milestone_2_Amount_Actual_Paid__c != null)
                            {
                                milestone2AmountActualPaidTotal += item.commission.Milestone_2_Amount_Actual_Paid__c;
                                partyProviderMilestone2AmountActualPaidTotal += item.commission.Milestone_2_Amount_Actual_Paid__c;
                            }
                            if(item.commission.Milestone_3_Actual_Paid__c != null)
                            {
                                milestone3AmountActualPaidTotal += item.commission.Milestone_3_Actual_Paid__c;
                                partyProviderMilestone3AmountActualPaidTotal += item.commission.Milestone_3_Actual_Paid__c;
                            }
                            if(item.commission.Clawback_Amount_Actual__c != null)
                            {
                                milestoneClawBackAmountActualPaidTotal += item.commission.Clawback_Amount_Actual__c;
                                partyProviderMilestoneClawBackAmountActualPaidTotal += item.commission.Clawback_Amount_Actual__c;
                            }
                            
                            if(item.commission.Milestone_1_Amount__c != null)
                            {
                                milestone1AmountTotal +=item.commission.Milestone_1_Amount__c;
                                partyProviderMilestone1AmountTotal +=item.commission.Milestone_1_Amount__c;
                            }
                            
                            if(item.commission.Milestone_2_Amount__c != null)
                            {
                                milestone2AmountTotal +=item.commission.Milestone_2_Amount__c;
                                partyProviderMilestone2AmountTotal +=item.commission.Milestone_2_Amount__c;
                            }
                            if(item.commission.Milestone_3_Amount__c != null)
                            {
                                milestone3AmountTotal +=item.commission.Milestone_3_Amount__c;
                                partyProviderMilestone3AmountTotal +=item.commission.Milestone_3_Amount__c;
                            }
                            if(item.commission.M1_Clawback_Amount__c != null)
                            {
                                milestoneClawBackAmountTotal +=item.commission.M1_Clawback_Amount__c;
                                partyProviderMilestoneClawBackAmountTotal +=item.commission.M1_Clawback_Amount__c;
                            }
                        }
                        partyProviderMilestone1AmountActualPaidTotalMap.put(party_provider+'-'+milestone,partyProviderMilestone1AmountActualPaidTotal);
                        partyProviderMilestone2AmountActualPaidTotalMap.put(party_provider+'-'+milestone,partyProviderMilestone2AmountActualPaidTotal);
                        partyProviderMilestone3AmountActualPaidTotalMap.put(party_provider+'-'+milestone,partyProviderMilestone3AmountActualPaidTotal);
                        partyProviderMilestoneClawBackAmountActualPaidTotalMap.put(party_provider+'-'+milestone,partyProviderMilestoneClawBackAmountActualPaidTotal);
                        
                        partyProviderMilestone1AmountTotalMap.put(party_provider+'-'+milestone,partyProviderMilestone1AmountTotal);
                        partyProviderMilestone2AmountTotalMap.put(party_provider+'-'+milestone,partyProviderMilestone2AmountTotal);
                        partyProviderMilestone3AmountTotalMap.put(party_provider+'-'+milestone,partyProviderMilestone3AmountTotal);
                        partyProviderMilestoneClawBackAmountTotalMap.put(party_provider+'-'+milestone,partyProviderMilestoneClawBackAmountTotal);
                    
                    }
                    milestone1AmountActualPaidTotalMap.put(milestone,milestone1AmountActualPaidTotal);
                    milestone2AmountActualPaidTotalMap.put(milestone,milestone2AmountActualPaidTotal);
                    milestone3AmountActualPaidTotalMap.put(milestone,milestone3AmountActualPaidTotal);
                    milestoneClawBackAmountActualPaidTotalMap.put(milestone,milestoneClawBackAmountActualPaidTotal);
                    
                    milestone1AmountTotalMap.put(milestone,milestone1AmountTotal);
                    milestone2AmountTotalMap.put(milestone,milestone2AmountTotal);
                    milestone3AmountTotalMap.put(milestone,milestone3AmountTotal);
                    milestoneClawBackAmountTotalMap.put(milestone,milestoneClawBackAmountTotal);
                }
            }
            else
            {
                system.debug('Paid Commission:');
                commissionProcessed = new Map<string,Map<string,List<Commission__c>>>();
                CommissionTrackerUtility.generateTableForPaidCommission(commission_list,commissionProcessed,selectedMilestone,fromDate,toDate);
                milestone1AmountActualPaidTotalMap = new Map<string,Decimal>();
                milestone2AmountActualPaidTotalMap = new Map<string,Decimal>();
                milestone3AmountActualPaidTotalMap = new Map<string,Decimal>();
                milestoneClawBackAmountActualPaidTotalMap = new Map<string,Decimal>();
                partyProviderMilestone1AmountActualPaidTotalMap = new Map<string,Decimal>();
                partyProviderMilestone2AmountActualPaidTotalMap = new Map<string,Decimal>();
                partyProviderMilestone3AmountActualPaidTotalMap = new Map<string,Decimal>();
                partyProviderMilestoneClawBackAmountActualPaidTotalMap = new Map<string,Decimal>();
                /*******************************/
                milestone1AmountTotalMap = new Map<string,Decimal>();
                milestone2AmountTotalMap = new Map<string,Decimal>();
                milestone3AmountTotalMap = new Map<string,Decimal>();
                milestoneClawBackAmountTotalMap = new Map<string,Decimal>();
                partyProviderMilestone1AmountTotalMap  = new Map<string,Decimal>();
                partyProviderMilestone2AmountTotalMap = new Map<string,Decimal>();
                partyProviderMilestone3AmountTotalMap = new Map<string,Decimal>();
                partyProviderMilestoneClawBackAmountTotalMap = new Map<string,Decimal>();
                for(string milestone:commissionProcessed.keySet())
                {
                    Map<string,List<Commission__c>> commission_to_be_processed_map = commissionProcessed.get(milestone);
                    Decimal milestone1AmountActualPaidTotal = 0;
                    Decimal milestone2AmountActualPaidTotal = 0;
                    Decimal milestone3AmountActualPaidTotal = 0;
                    Decimal milestoneClawBackAmountActualPaidTotal = 0;
                    
                    Decimal milestone1AmountTotal = 0;
                    Decimal milestone2AmountTotal = 0;
                    Decimal milestone3AmountTotal = 0;
                    Decimal milestoneClawBackAmountTotal = 0;
                    for(string party_provider:commission_to_be_processed_map.keySet())
                    {
                        List<Commission__c> commission_list_temp = commission_to_be_processed_map.get(party_provider);
                        Decimal partyProviderMilestone1AmountActualPaidTotal = 0;
                        Decimal partyProviderMilestone2AmountActualPaidTotal = 0;
                        Decimal partyProviderMilestone3AmountActualPaidTotal = 0;
                        Decimal partyProviderMilestoneClawBackAmountActualPaidTotal = 0;
                        
                        Decimal partyProviderMilestone1AmountTotal = 0;
                        Decimal partyProviderMilestone2AmountTotal = 0;
                        Decimal partyProviderMilestone3AmountTotal = 0;
                        Decimal partyProviderMilestoneClawBackAmountTotal = 0;
                        for(Commission__c item:commission_list_temp)
                        {
                            if(item.Milestone_1_Amount_Actual_Paid__c != null)
                            {
                                milestone1AmountActualPaidTotal += item.Milestone_1_Amount_Actual_Paid__c;
                                partyProviderMilestone1AmountActualPaidTotal += item.Milestone_1_Amount_Actual_Paid__c;
                            }
                            if(item.Milestone_2_Amount_Actual_Paid__c != null)
                            {
                                milestone2AmountActualPaidTotal += item.Milestone_2_Amount_Actual_Paid__c;
                                partyProviderMilestone2AmountActualPaidTotal += item.Milestone_2_Amount_Actual_Paid__c;
                            }
                            if(item.Milestone_3_Actual_Paid__c != null)
                            {
                                milestone3AmountActualPaidTotal += item.Milestone_3_Actual_Paid__c;
                                partyProviderMilestone3AmountActualPaidTotal += item.Milestone_3_Actual_Paid__c;
                            }
                            if(item.Clawback_Amount_Actual__c != null)
                            {
                                milestoneClawBackAmountActualPaidTotal += item.Clawback_Amount_Actual__c;
                                partyProviderMilestoneClawBackAmountActualPaidTotal += item.Clawback_Amount_Actual__c;
                            }
                            
                            if(item.Milestone_1_Amount__c != null)
                            {
                                milestone1AmountTotal +=item.Milestone_1_Amount__c;
                                partyProviderMilestone1AmountTotal +=item.Milestone_1_Amount__c;
                            }
                            
                            if(item.Milestone_2_Amount__c != null)
                            {
                                milestone2AmountTotal +=item.Milestone_2_Amount__c;
                                partyProviderMilestone2AmountTotal +=item.Milestone_2_Amount__c;
                            }
                            if(item.Milestone_3_Amount__c != null)
                            {
                                milestone3AmountTotal +=item.Milestone_3_Amount__c;
                                partyProviderMilestone3AmountTotal +=item.Milestone_3_Amount__c;
                            }
                            if(item.M1_Clawback_Amount__c != null)
                            {
                                milestoneClawBackAmountTotal +=item.M1_Clawback_Amount__c;
                                partyProviderMilestoneClawBackAmountTotal +=item.M1_Clawback_Amount__c;
                            }

                        }
                        partyProviderMilestone1AmountActualPaidTotalMap.put(party_provider+'-'+milestone,partyProviderMilestone1AmountActualPaidTotal);
                        partyProviderMilestone2AmountActualPaidTotalMap.put(party_provider+'-'+milestone,partyProviderMilestone2AmountActualPaidTotal);
                        partyProviderMilestone3AmountActualPaidTotalMap.put(party_provider+'-'+milestone,partyProviderMilestone3AmountActualPaidTotal);
                        partyProviderMilestoneClawBackAmountActualPaidTotalMap.put(party_provider+'-'+milestone,partyProviderMilestoneClawBackAmountActualPaidTotal);
                        
                        partyProviderMilestone1AmountTotalMap.put(party_provider+'-'+milestone,partyProviderMilestone1AmountTotal);
                        partyProviderMilestone2AmountTotalMap.put(party_provider+'-'+milestone,partyProviderMilestone2AmountTotal);
                        partyProviderMilestone3AmountTotalMap.put(party_provider+'-'+milestone,partyProviderMilestone3AmountTotal);
                        partyProviderMilestoneClawBackAmountTotalMap.put(party_provider+'-'+milestone,partyProviderMilestoneClawBackAmountTotal);
                    }
                    milestone1AmountActualPaidTotalMap.put(milestone,milestone1AmountActualPaidTotal);
                    milestone2AmountActualPaidTotalMap.put(milestone,milestone2AmountActualPaidTotal);
                    milestone3AmountActualPaidTotalMap.put(milestone,milestone3AmountActualPaidTotal);
                    milestoneClawBackAmountActualPaidTotalMap.put(milestone,milestoneClawBackAmountActualPaidTotal);
                    
                    milestone1AmountTotalMap.put(milestone,milestone1AmountTotal);
                    milestone2AmountTotalMap.put(milestone,milestone2AmountTotal);
                    milestone3AmountTotalMap.put(milestone,milestone3AmountTotal);
                    milestoneClawBackAmountTotalMap.put(milestone,milestoneClawBackAmountTotal);
                }
            }
            isCommissionProcessed = true;
            isCommissionToBeProcessed = false;
            
            
        }
            }
            
        
    }
    
    private void generateTableForCommissionCustomClass(List<Commission__c> commission_list, Map<string,Map<string,List<CommissionProcessed>>> commission_map)
    {
        selectedMilestone = string.join(selectedAllMilestone,';');
        system.debug('generateTableForCommissionCustomClass-selected milestone:'+selectedMilestone);
        Set<String> excluded_stages = new Set<string>();
        excluded_stages.add('9. Change Order Pending');
        excluded_stages.add('Closed Lost');
        excluded_stages.add('Cancelled');
        for(Commission__c item:commission_list)
        {
            
            if(selectedMilestone.contains('M1') && (item.Milestone_1_Processed_Date__c >=fromDate && item.Milestone_1_Processed_Date__c <=toDate) && !excluded_stages.contains(item.Opportunity__r.StageName))
            {
                if(item.Milestone_1_Processed__c == true && commission_map.containsKey('M1'))
                {
                    Map<string,List<CommissionProcessed>> temp_commission_map = commission_map.get('M1');
                    if(temp_commission_map.containsKey(item.Opportunity__r.X3rd_Party_Partner__c))
                    {
                        List<CommissionProcessed> temp_commission_list = temp_commission_map.get(item.Opportunity__r.X3rd_Party_Partner__c);
                        CommissionProcessed temp_commission_processed = new CommissionProcessed(false,item);
                        temp_commission_list.add(temp_commission_processed);
                    }
                    else
                    {
                        List<CommissionProcessed> temp_commission_list = new List<CommissionProcessed>();
                        CommissionProcessed temp_commission_processed = new CommissionProcessed(false,item);
                        temp_commission_list.add(temp_commission_processed);
                        temp_commission_map.put(item.Opportunity__r.X3rd_Party_Partner__c,temp_commission_list);
                    }
                    
                }
                else if(item.Milestone_1_Processed__c == true)
                {
                    List<CommissionProcessed> temp_commission_list = new List<CommissionProcessed>();
                    CommissionProcessed temp_commission_processed = new CommissionProcessed(false,item);
                    temp_commission_list.add(temp_commission_processed);
                    Map<string,List<CommissionProcessed>> temp_commission_map = new Map<string,List<CommissionProcessed>>();
                    temp_commission_map.put(item.Opportunity__r.X3rd_Party_Partner__c,temp_commission_list);
                    commission_map.put('M1',temp_commission_map);
                }
            }
            
            if(selectedMilestone.contains('M2') && (item.Milestone_2_Processed_Date__c >=fromDate && item.Milestone_2_Processed_Date__c <=toDate) && !excluded_stages.contains(item.Opportunity__r.StageName))
            {
                
                if(item.Milestone_2_Processed__c == true && commission_map.containsKey('M2'))
                {
                    Map<string,List<CommissionProcessed>> temp_commission_map = commission_map.get('M2');
                    if(temp_commission_map.containsKey(item.Opportunity__r.X3rd_Party_Partner__c))
                    {
                        List<CommissionProcessed> temp_commission_list = temp_commission_map.get(item.Opportunity__r.X3rd_Party_Partner__c);
                        CommissionProcessed temp_commission_processed = new CommissionProcessed(false,item);
                        temp_commission_list.add(temp_commission_processed);
                    }
                    else
                    {
                        List<CommissionProcessed> temp_commission_list = new List<CommissionProcessed>();
                        CommissionProcessed temp_commission_processed = new CommissionProcessed(false,item);
                        temp_commission_list.add(temp_commission_processed);
                        temp_commission_map.put(item.Opportunity__r.X3rd_Party_Partner__c,temp_commission_list);
                    }
                    
                }
                else if(item.Milestone_2_Processed__c == true)
                {
                    List<CommissionProcessed> temp_commission_list = new List<CommissionProcessed>();
                    CommissionProcessed temp_commission_processed = new CommissionProcessed(false,item);
                    temp_commission_list.add(temp_commission_processed);
                    Map<string,List<CommissionProcessed>> temp_commission_map = new Map<string,List<CommissionProcessed>>();
                    temp_commission_map.put(item.Opportunity__r.X3rd_Party_Partner__c,temp_commission_list);
                    commission_map.put('M2',temp_commission_map);
                }
            }
            
            if(selectedMilestone.contains('M3') && (item.Milestone_3_Processed_Date__c >=fromDate && item.Milestone_3_Processed_Date__c <=toDate) && !excluded_stages.contains(item.Opportunity__r.StageName))
            {
                if(item.Milestone_3_Processed__c == true && commission_map.containsKey('M3'))
                {
                    Map<string,List<CommissionProcessed>> temp_commission_map = commission_map.get('M3');
                    if(temp_commission_map.containsKey(item.Opportunity__r.X3rd_Party_Partner__c))
                    {
                        List<CommissionProcessed> temp_commission_list = temp_commission_map.get(item.Opportunity__r.X3rd_Party_Partner__c);
                        CommissionProcessed temp_commission_processed = new CommissionProcessed(false,item);
                        temp_commission_list.add(temp_commission_processed);
                    }
                    else
                    {
                        List<CommissionProcessed> temp_commission_list = new List<CommissionProcessed>();
                        CommissionProcessed temp_commission_processed = new CommissionProcessed(false,item);
                        temp_commission_list.add(temp_commission_processed);
                        temp_commission_map.put(item.Opportunity__r.X3rd_Party_Partner__c,temp_commission_list);
                    }
                    
                }
                else if(item.Milestone_3_Processed__c == true)
                {
                    List<CommissionProcessed> temp_commission_list = new List<CommissionProcessed>();
                    CommissionProcessed temp_commission_processed = new CommissionProcessed(false,item);
                    temp_commission_list.add(temp_commission_processed);
                    Map<string,List<CommissionProcessed>> temp_commission_map = new Map<string,List<CommissionProcessed>>();
                    temp_commission_map.put(item.Opportunity__r.X3rd_Party_Partner__c,temp_commission_list);
                    commission_map.put('M3',temp_commission_map);
                }
            }
            
            if(selectedMilestone.contains('Clawbacks') && (item.M1_Clawback_Processed_Date__c >=fromDate && item.M1_Clawback_Processed_Date__c <=toDate))
            {
                system.debug('Clawbacks for commission processed');
                if(item.M1_Clawback_Complete__c == true && commission_map.containsKey('Cancellation Clawback'))
                {
                    Map<string,List<CommissionProcessed>> temp_commission_map = commission_map.get('Cancellation Clawback');
                    if(temp_commission_map.containsKey(item.Opportunity__r.X3rd_Party_Partner__c))
                    {
                        List<CommissionProcessed> temp_commission_list = temp_commission_map.get(item.Opportunity__r.X3rd_Party_Partner__c);
                        CommissionProcessed temp_commission_processed = new CommissionProcessed(false,item);
                        temp_commission_list.add(temp_commission_processed);
                    }
                    else
                    {
                        List<CommissionProcessed> temp_commission_list = new List<CommissionProcessed>();
                        CommissionProcessed temp_commission_processed = new CommissionProcessed(false,item);
                        temp_commission_list.add(temp_commission_processed);
                        temp_commission_map.put(item.Opportunity__r.X3rd_Party_Partner__c,temp_commission_list);
                    }
                    
                }
                else if(item.M1_Clawback_Complete__c == true)
                {
                    List<CommissionProcessed> temp_commission_list = new List<CommissionProcessed>();
                    CommissionProcessed temp_commission_processed = new CommissionProcessed(false,item);
                    temp_commission_list.add(temp_commission_processed);
                    Map<string,List<CommissionProcessed>> temp_commission_map = new Map<string,List<CommissionProcessed>>();
                    temp_commission_map.put(item.Opportunity__r.X3rd_Party_Partner__c,temp_commission_list);
                    commission_map.put('Cancellation Clawback',temp_commission_map);
                    system.debug('First item for Cancellation Clawback of commission processed');
                }
            }
 
        }
    }
    
    private boolean validate()
    {
        boolean is_valid = true;
        
        if(string.isEmpty(selectedCommission))
        {
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, 'Please select display type.'));
            is_valid = false;    
        }
        if(fromDate == null)
        {
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, 'Please select from date.'));
            is_valid = false;            
        }
        
        if(toDate == null)
        {
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, 'Please select to date.'));
            is_valid = false;            
        }
        if(fromDate < system.today() && toDate >System.Today())
        {
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, 'Date range should not be in future for this display.'));
            is_valid = false;
        }
        return is_valid;
    }
    @testVisible
    private string setToDelimitedString(string delimiter,List< string > inputList,boolean add_single_quotes)
    {
        string result = '';
        if ( inputList != null && delimiter != null )
        {
            for ( string s : inputList )
            {
                if(s != null)
                {
                    if ( result != '' )
                    {   
                        result += delimiter;
                    }
                    
                    if(add_single_quotes)
                    {
                        result += '\''+String.escapeSingleQuotes(s) +'\'';
                    }
                    else
                    {
                        result += String.escapeSingleQuotes(s);
                    }
                }
                
            }
        }
        return result;
    }
    public class ComissionToBeProcessed
    {
        
    }
    
    public PageReference commissionTrackerExport()
    {
        PageReference pf = new PageReference('/apex/CommissionTrackerExport');
        string selected_milestone = string.join(selectedAllMilestone,';');
        string selected_3rd_party_provider = setToDelimitedString(',',selectedAll3rdPartyProvider,true);
        pf.getParameters().put('startdate', EncodingUtil.urlEncode(fromDateExport.format(),'UTF-8'));
        pf.getParameters().put('enddate', EncodingUtil.urlEncode(toDateExport.format(),'UTF-8'));
        pf.getParameters().put('reporttype',string.valueOf(ReportType));
        pf.getParameters().put('milestone', EncodingUtil.urlEncode(selected_milestone,'UTF-8'));
        pf.getParameters().put('partprovider', EncodingUtil.urlEncode(selected_3rd_party_provider,'UTF-8'));
        pf.getParameters().put('paidmilestone', string.valueof(paidMileStone));
        pf.setRedirect(true);
        return pf;
    }
    public List<EmailToPartyProvider> partyProviderEmailList{get;set;}
    @TestVisible
    private void findPartyProvider()
    {
        isEmailSent = false;
        emailMessageStatus = '';
        if(selectedAll3rdPartyProviderForEmail !=null && selectedAll3rdPartyProviderForEmail.size() > 0)
        {
            ///selected3rdPartyProvider = setToDelimitedString(',',selectedAll3rdPartyProvider,true);
            Map<id,Account> account_map = new Map<id,Account>([SELECT id, Name, Channel_Partner_Status__c from Account where Name IN:selectedAll3rdPartyProviderForEmail]);
            set<id> account_id_set = new set<id>();
            for(id item:account_map.keyset())
            {
                account_id_set.add(item);
            }
            system.debug('Party Accounts:'+account_map.size());
            List<Contact> contact_list = [SELECT Name, Email,AccountId  from Contact where AccountId IN:account_id_set and Title ='Leadership'];
            system.debug('Party Account Contacts:'+contact_list.size());
            Map<id,List<Contact>> contact_map = new Map<id,List<Contact>>();
            for(contact item:contact_list)
            {
                if(contact_map.containsKey(item.accountId))
                {
                    List<Contact> temp_contact_list = contact_map.get(item.accountId);
                    temp_contact_list.add(item);
                }
                else
                {
                    List<Contact> temp_contact_list = new List<Contact>();
                    temp_contact_list.add(item);
                    contact_map.put(item.accountId,temp_contact_list);
                }
            }
            partyProviderEmailList = new List<EmailToPartyProvider>();
            Map<String, EmailToPartyProvider> mapTemp = new Map<String, EmailToPartyProvider>();
            List<String> lstTemp = new List<String>();
            for(id item:contact_map.keyset())
            {
                if(contact_map.containsKey(item) && account_map.containsKey(item))
                {
                    List<contact> temp_contact_list = contact_map.get(item);
                    EmailToPartyProvider temp_email_provider = new  EmailToPartyProvider();
                    temp_email_provider.emails = '';
                    temp_email_provider.names = '';
                    temp_email_provider.isChecked = false;
                    temp_email_provider.partyProvider = account_map.get(item).Name;
                    temp_email_provider.partnerStatus = account_map.get(item).Channel_Partner_Status__c;
                    for(Contact con:temp_contact_list)
                    {
                       
                       temp_email_provider.emails +=con.Email + ','; 
                       temp_email_provider.names += con.Name + ',';
                    }
                     temp_email_provider.emails = temp_email_provider.emails.removeEnd(',');
                     temp_email_provider.names = temp_email_provider.names.removeEnd(',');
                     //partyProviderEmailList.add(temp_email_provider);
                     
                     if(String.isNotBlank(temp_email_provider.partyProvider)){
                         temp_email_provider.partyProvider = temp_email_provider.partyProvider.capitalize();
                         
                         mapTemp.put(temp_email_provider.partyProvider, temp_email_provider);
                         lstTemp.add(temp_email_provider.partyProvider);
                     }
                }
            }
            //Code to sort the provider list.
            if(!lstTemp.isEmpty()){
                lstTemp.sort();
                
                for(String partyProvider : lstTemp){
                    if(mapTemp.containsKey(partyProvider)){
                        partyProviderEmailList.add(mapTemp.get(partyProvider));
                    }
                }
            } 
        }
    }
    
    private Boolean isDataExistForPartyProvider(string party_provider)
    {
        if(isCommissionProcessed && selectedCommission != 'Processed Commissions')
        {
            Map<string,List<Commission__c>> m1 = new Map<string,List<Commission__c>>();
            Map<string,List<Commission__c>> m2 = new Map<string,List<Commission__c>>();
            Map<string,List<Commission__c>> m3 = new Map<string,List<Commission__c>>(); 
            Map<string,List<Commission__c>> clawback = new Map<string,List<Commission__c>>(); 
            if(commissionProcessed.containsKey('M1'))
            {
                m1 = commissionProcessed.get('M1');
            }
            if(commissionProcessed.containsKey('M2'))
            {
                m2 = commissionProcessed.get('M2');
                
            }
            if(commissionProcessed.containsKey('M3'))
            {
                m3 = commissionProcessed.get('M3');
            }
            if(commissionProcessed.containsKey('Cancellation Clawback'))
            {
                clawback = commissionProcessed.get('Cancellation Clawback');
            } 
            if(m1.containsKey(party_provider))
            {
                return true;
            }
            if(m2.containsKey(party_provider))
            {
                return true;
            }
            if(m3.containsKey(party_provider))
            {
                return true;
            }
            if(clawback.containsKey(party_provider))
            {
                return true;
            }
        }
        else if(isCommissionProcessed && selectedCommission == 'Processed Commissions')
        {
            Map<string,List<CommissionProcessed>> m1 = new Map<string,List<CommissionProcessed>>();
            Map<string,List<CommissionProcessed>> m2 = new Map<string,List<CommissionProcessed>>();
            Map<string,List<CommissionProcessed>> m3 = new Map<string,List<CommissionProcessed>>(); 
            Map<string,List<CommissionProcessed>> clawback = new Map<string,List<CommissionProcessed>>(); 
            if(commissionProcessedWithCustomClass.containsKey('M1'))
            {
                m1 = commissionProcessedWithCustomClass.get('M1');
                
            }
            if(commissionProcessedWithCustomClass.containsKey('M2'))
            {
                m2 = commissionProcessedWithCustomClass.get('M2');
                
            }
            if(commissionProcessedWithCustomClass.containsKey('M3'))
            {
                m3 = commissionProcessedWithCustomClass.get('M3');
                
            }
            if(commissionProcessedWithCustomClass.containsKey('Cancellation Clawback'))
            {
                clawback = commissionProcessedWithCustomClass.get('Cancellation Clawback');
               
            } 
            if(m1.containsKey(party_provider))
            {
                return true;
            }
            if(m2.containsKey(party_provider))
            {
                return true;
            }
            if(m3.containsKey(party_provider))
            {
                return true;
            }
            if(clawback.containsKey(party_provider))
            {
                return true;
            }
        }
        
        return false;
    }
    //This method checks if commission is positive or negative for provider.
    private Boolean isPositiveCommission(string party_provider)
    {
        Decimal postiveCommission = 0, negativeCommission = 0;
        if(isCommissionProcessed && selectedCommission != 'Processed Commissions')
        {
            Map<string,List<Commission__c>> m1 = new Map<string,List<Commission__c>>();
            Map<string,List<Commission__c>> m2 = new Map<string,List<Commission__c>>();
            Map<string,List<Commission__c>> m3 = new Map<string,List<Commission__c>>(); 
            Map<string,List<Commission__c>> clawback = new Map<string,List<Commission__c>>(); 
            
            if(commissionProcessed.containsKey('M1'))
                m1 = commissionProcessed.get('M1');
            if(commissionProcessed.containsKey('M2'))
                m2 = commissionProcessed.get('M2');
            if(commissionProcessed.containsKey('M3'))
                m3 = commissionProcessed.get('M3');
            if(commissionProcessed.containsKey('Cancellation Clawback'))
                clawback = commissionProcessed.get('Cancellation Clawback');
                
            if(m1.containsKey(party_provider) && m1.get(party_provider) != null && !m1.get(party_provider).isEmpty())
            {
                for(Commission__c objCommission : m1.get(party_provider)){
                    postiveCommission += (objCommission.Milestone_1_Amount__c == null?0:objCommission.Milestone_1_Amount__c);
                }
            }
            if(m2.containsKey(party_provider) && m2.get(party_provider) != null && !m2.get(party_provider).isEmpty())
            {
                for(Commission__c objCommission : m2.get(party_provider)){
                    postiveCommission += (objCommission.Milestone_2_Amount__c == null?0:objCommission.Milestone_2_Amount__c);
                }
            }
            if(m3.containsKey(party_provider) && m3.get(party_provider) != null && !m3.get(party_provider).isEmpty())
            {
                for(Commission__c objCommission : m3.get(party_provider)){
                    postiveCommission += (objCommission.Milestone_3_Amount__c == null?0:objCommission.Milestone_3_Amount__c);
                }
            }
            if(clawback.containsKey(party_provider) && clawback.get(party_provider) != null && !clawback.get(party_provider).isEmpty())
            {
                for(Commission__c objCommission : clawback.get(party_provider)){
                    negativeCommission += (objCommission.Clawback_Amount_Actual__c == null?0:objCommission.Clawback_Amount_Actual__c);
                }
            }
        }
        else if(isCommissionProcessed && selectedCommission == 'Processed Commissions')
        {
            Map<string,List<CommissionProcessed>> m1 = new Map<string,List<CommissionProcessed>>();
            Map<string,List<CommissionProcessed>> m2 = new Map<string,List<CommissionProcessed>>();
            Map<string,List<CommissionProcessed>> m3 = new Map<string,List<CommissionProcessed>>(); 
            Map<string,List<CommissionProcessed>> clawback = new Map<string,List<CommissionProcessed>>(); 
            if(commissionProcessedWithCustomClass.containsKey('M1'))
                m1 = commissionProcessedWithCustomClass.get('M1');
            if(commissionProcessedWithCustomClass.containsKey('M2'))
                m2 = commissionProcessedWithCustomClass.get('M2');
            if(commissionProcessedWithCustomClass.containsKey('M3'))
                m3 = commissionProcessedWithCustomClass.get('M3');
            if(commissionProcessedWithCustomClass.containsKey('Cancellation Clawback'))
                clawback = commissionProcessedWithCustomClass.get('Cancellation Clawback');
                
            if(m1.containsKey(party_provider) && m1.get(party_provider) != null && !m1.get(party_provider).isEmpty())
            {
                for(CommissionProcessed objCommissionProcessed : m1.get(party_provider)){
                    postiveCommission += (objCommissionProcessed.commission.Milestone_1_Amount__c == null?0:objCommissionProcessed.commission.Milestone_1_Amount__c);
                }
            }
            if(m2.containsKey(party_provider) && m2.get(party_provider) != null && !m2.get(party_provider).isEmpty())
            {
                for(CommissionProcessed objCommissionProcessed : m2.get(party_provider)){
                    postiveCommission += (objCommissionProcessed.commission.Milestone_2_Amount__c == null?0:objCommissionProcessed.commission.Milestone_2_Amount__c);
                }
            }
            if(m3.containsKey(party_provider) && m3.get(party_provider) != null && !m3.get(party_provider).isEmpty())
            {
                for(CommissionProcessed objCommissionProcessed : m3.get(party_provider)){
                    postiveCommission += (objCommissionProcessed.commission.Milestone_3_Amount__c == null?0:objCommissionProcessed.commission.Milestone_3_Amount__c);
                }
            }
            if(clawback.containsKey(party_provider) && clawback.get(party_provider) != null && !clawback.get(party_provider).isEmpty())
            {
                for(CommissionProcessed objCommissionProcessed : clawback.get(party_provider)){
                    negativeCommission += (objCommissionProcessed.commission.Clawback_Amount_Actual__c == null?0:objCommissionProcessed.commission.Clawback_Amount_Actual__c);
                }
            }
        }
        
        Boolean isPositiveCommission = (postiveCommission > negativeCommission? true : false);
        
        return isPositiveCommission;
    }
    
    
    public boolean isEmailSent{get;set;}
    public String emailMessageStatus{get;set;}
    public void sendEmailToProviders()
    {
        try
        {
            isEmailSent = false;
            List<string> email_list = new List<string>();
            List<Messaging.SingleEmailMessage> send_email_list = new List<Messaging.SingleEmailMessage>();
            string email_body = 'Team, <br/>';
            email_body += '<p>Please find attached your weekly commissions report for commissions milestones from [' + fromDateExport.addDays(-7).format() + ' - ' + fromDateExport.addDays(-1).format() + ']. ';
            email_body += 'Your weekly payment will be made on Friday </p>';
            email_body += '<p>For any inquiries, please reach out directly to commissions@palmetto.com for the fastest response</p>';
            //email_body += 'Please find attached commissions report for today.<br/>For any inquiries, please reach out to commissions@palmetto.com<br/><br/>';
            email_body +='Thank you';
            //string subject = ' Palmetto Commissions - ['+string.valueOf(system.date.today())+']';
            
            String emailBody = 'Team, <br/>';
            emailBody += '<p>There were no projects eligible for a commissions milestone on this weeks commissions report. No commissions payment will be processed this week. </p>';
            emailBody += '<p>For any inquiries, please reach out directly to commissions@palmetto.com for the fastest response</p>';
            emailBody +='Thank you';
            
            String emailBody3 = 'Team, <br/>';
            emailBody3 += '<p>Please find attached your weekly commissions report for commissions milestones from [' + fromDateExport.addDays(-7).format() + ' - ' + fromDateExport.addDays(-1).format() + ']. ';
            emailBody3 += 'Due to the net negative balance, no commissions payment will be processed this week.</p>';
            emailBody3 += '<p>For any inquiries, please reach out directly to commissions@palmetto.com for the fastest response</p>';
            emailBody3 +='Thank you';
            
            string no_email_send_providers = '';
            Boolean isCommissionExist, isPositiveCommission;
            for(EmailToPartyProvider item: partyProviderEmailList)
            {
                if(item.isChecked && item.partnerStatus == 'Active')
                {
                    String subject = item.partyProvider + ' - Palmetto Weekly Commissions - [' + fromDateExport.addDays(-7).format() + ' - ' + fromDateExport.addDays(-1).format() + ']';
                    isCommissionExist = isDataExistForPartyProvider(item.partyProvider);
                    
                    if(isCommissionExist){
                        isPositiveCommission = isPositiveCommission(item.partyProvider);
                    }
                    
                    email_list = new List<string>();
                    string[] emails = item.emails.split(',');
                    for(string email:emails)
                    {
                        email_list.add(email);
                    }
                    email_list.add(System.Label.commission_report_Email);
                    Messaging.reserveSingleEmailCapacity( 1 );
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses( email_list );
                    mail.setReplyTo(System.Label.commission_report_Email);
                    mail.setSenderDisplayName( 'Palmetto Commissions' );
                    mail.setSubject( subject );
                    mail.setBccSender( false );
                    mail.setUseSignature( false );
                    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                    
                    if(isCommissionExist){
                        if(isPositiveCommission){
                            mail.setPlainTextBody( email_body );
                            mail.setHtmlBody( email_body );
                        } else{
                            mail.setPlainTextBody( emailBody3 );
                            mail.setHtmlBody( emailBody3 );
                        }
                        
                        PageReference pf = Page.CommissionTrackerExport;
                        string selected_milestone = string.join(selectedAllMilestone,';');
                        string selected_3rd_party_provider = '\'' +item.partyProvider + '\'';
                        pf.getParameters().put('startdate', EncodingUtil.urlEncode(fromDateExport.format(),'UTF-8'));
                        pf.getParameters().put('enddate', EncodingUtil.urlEncode(toDateExport.format(),'UTF-8'));
                        pf.getParameters().put('reporttype',string.valueOf(ReportType));
                        pf.getParameters().put('milestone', EncodingUtil.urlEncode(selected_milestone,'UTF-8'));
                        pf.getParameters().put('partprovider', EncodingUtil.urlEncode(selected_3rd_party_provider,'UTF-8'));
                        pf.getParameters().put('paidmilestone', string.valueof(paidMileStone));
                        Blob b = pf.getContent();
                        efa.setFileName('Commission Processing.csv');
                        efa.setBody(b);
                        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                    } else{
                        mail.setPlainTextBody( emailBody );
                        mail.setHtmlBody( emailBody );
                    }
                    send_email_list.add(mail);
                }
                /*
                else if(item.isChecked)
                {
                    no_email_send_providers +=item.partyProvider + ',';
                }
                */
            }
            
            if(send_email_list.size() > 0)
            {
                Messaging.sendEmail( send_email_list );
                if(string.isEmpty(no_email_send_providers))
                {
                    emailMessageStatus = 'Email sent successfully';
                }
                else
                {
                    emailMessageStatus = 'Email sent successfully to the selected channel partners except ' + no_email_send_providers.removeEnd(',') +' as data is unavailable';
                }

                
            }
            else if(!string.isEmpty(no_email_send_providers))
            {
                emailMessageStatus = 'Email cannot be sent for the selected '+no_email_send_providers.removeEnd(',') + ' as data is unavailable';
            }
            else
            {
                emailMessageStatus = 'No provider selected';
            }
            
            /*if(email_list.size() > 0)
            {
                string email_body = 'Team, <br/>';
                email_body += 'Please find attached commissions report for today.<br/><br/>';
                email_body +='Thank you';

                sendEmail(email_list,' Palmetto Commissions - ['+string.valueOf(system.date.today())+']',email_body); 
                
            }*/
            isEmailSent = true;
            
            
        }
        catch(Exception ex)
        {
            
            emailMessageStatus = ex.getMessage();
        }
        
       
    }
    
    /*private void sendEmail( List<string> emailAddress, string subject, string body )
    {
        try
        {
            if ( emailAddress == null )
            {
                return;
            }

            Messaging.reserveSingleEmailCapacity( 1 );
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses( emailAddress );
            mail.setReplyTo( 'accounting@palmetto.com' );
            mail.setSenderDisplayName( 'Palmetto Commissions' );
            mail.setSubject( subject );
            mail.setBccSender( false );
            mail.setUseSignature( false );
            mail.setPlainTextBody( body );
            mail.setHtmlBody( body );
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            PageReference pf = Page.CommissionTrackerExport;
            string selected_milestone = string.join(selectedAllMilestone,';');
            string selected_3rd_party_provider = setToDelimitedString(',',selectedAll3rdPartyProvider,true);
            pf.getParameters().put('startdate', EncodingUtil.urlEncode(fromDateExport.format(),'UTF-8'));
            pf.getParameters().put('enddate', EncodingUtil.urlEncode(toDateExport.format(),'UTF-8'));
            pf.getParameters().put('reporttype',string.valueOf(ReportType));
            pf.getParameters().put('milestone', EncodingUtil.urlEncode(selected_milestone,'UTF-8'));
            pf.getParameters().put('partprovider', EncodingUtil.urlEncode(selected_3rd_party_provider,'UTF-8'));
            pf.getParameters().put('paidmilestone', string.valueof(paidMileStone));
            Blob b = pf.getContent();
            efa.setFileName('Commission Processing.csv');
            efa.setBody(b);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            Messaging.sendEmail( new Messaging.SingleEmailMessage[] { mail } );
        }
        catch( Exception ex )
        {
            throw ex;
            
        }
    }
*/
    public boolean displayEmailPopup {get; set;}     
    
    public void closeEmailPopup() {        
        displayEmailPopup = false;
        displayUnprocessPopup = false;
        findPartyProvider();
    }     
    public void showEmailPopup() { 
        if(isCommissionToBeProcessed == true)
        {
           ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.INFO, 'Commission to be processed can\'t be Emailed.'));
           return ;
        }
        displayEmailPopup = true;    
    }
    
    public string companyName
    {
        get
        {
            User user_obj =[SELECT CompanyName,isActive from User where Id=:UserInfo.getUserId()];
            return UserInfo.getProfileId();
        }
    }
        
    private void find3rdPartyUser()
    {
        providerNameMap = new Map<string,string>();
        /*3rd Party Provider Contract*/
        if (UserInfo.getProfileId() == '00e1a000000i6ZvAAI')
        {
            try
            {
                User user_obj =[SELECT CompanyName,isActive from User where Id=:UserInfo.getUserId()];
                if(!string.isEmpty(user_obj.CompanyName))
                {
                    providerNameMap.put('account_name',user_obj.CompanyName);
                    providerNameMap.put('error','no');
                
                }
                else
                {
                    providerNameMap.put('error','yes');
                }
                
                //providerNameMap.put('active',user_obj.isActive == true);
            }
            Catch(Exception ex)
            {
                
            }
        }
        else
        {
            providerNameMap.put('error','no');
        }
        system.debug('USERPROFILE' +UserInfo.getProfileId());
    }
    
    public class UnprocessCommissionWrapper
    {
        public Boolean isSelected{get; set;}
        public Commission__c objCommission{get; set;}
        public String milestone{get; set;}
        
        public UnprocessCommissionWrapper(Commission__c commission, String milestone){
            isSelected = false;
            objCommission = commission;
            this.milestone = milestone;
        }
    }
    
    public class CommissionSummayWrapper{
        public String provideName {get; set;}
        public Decimal commissionAmount {get; set;}
        public Decimal milestone1Amount {get; set;}
        public Decimal milestone2Amount {get; set;}
        public Decimal milestone3Amount {get; set;}
        public Decimal clawBackAmount {get; set;}
    }
    
    public class CommissionProcessed
    {
        public Boolean isChecked{get;set;}
        public Commission__c commission{get;set;}
        public CommissionProcessed(){}
        public CommissionProcessed(Boolean isChecked, Commission__c commission)
        {
            this.isChecked = isChecked;
            this.commission = commission;
        }
    }
   
    public class EmailToPartyProvider
    {
        public string emails{get;set;}
        public string names{get;set;}
        public string partyProvider{get;set;}
        public Boolean isChecked{set;get;}
        public String partnerStatus;
    }
    
}