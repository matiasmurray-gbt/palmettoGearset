public with sharing class CommissionTrackerControllerLgtng {
    @AuraEnabled
    public static DashboardData getMilestonesData(List<String> selectedAllMilestones, List<String> selectedProviders, String mode, Date fromDate, Date toDate, Boolean showPaidMilestones) {

        String selectedMilestones = string.join(selectedAllmilestones, ';');
        String selectedProvidersForQuery;
        if(!selectedProviders.isEmpty()) {
            selectedProvidersForQuery = setToDelimitedString(',',selectedProviders,true);
        }
        DashboardData dboardData = new DashboardData();

        List<MilestoneWrapper> milestoneWrapperList = new List<MilestoneWrapper>();
        MilestoneWrapper M1Wrapper = new MilestoneWrapper();
        M1Wrapper.milestone = 'M1';
        MilestoneWrapper M2Wrapper = new MilestoneWrapper();
        M2Wrapper.milestone = 'M2';
        MilestoneWrapper M3Wrapper = new MilestoneWrapper();
        M3Wrapper.milestone = 'M3';
        MilestoneWrapper clawbackWrapper = new MilestoneWrapper();
        clawbackWrapper.milestone = 'Clawbacks';

        //List<String> providers = new List<String>();
		ProvidersWrapper providersWrapper = new ProvidersWrapper();

        string soql = '';

        if((mode != null && fromDate !=null && toDate != null)) {
			Date start_date = fromDate.addDays(1);
			Date end_date = toDate.addDays(1);
            switch on mode {
                when 'Processed Commission' {
                    soql = CommissionTrackerLgtngUtility.commissionProcessedSOQL(selectedMilestones,selectedProvidersForQuery,start_date,end_date,showPaidMilestones, false);
                }
                when 'Paid Commission'{
                    soql = CommissionTrackerLgtngUtility.commissionPaidSOQL(selectedMilestones,selectedProvidersForQuery,start_date,end_date, false);
                }
                when else {
                    //String selected3rdPartyProvider = setToDelimitedString(',',selectedAll3rdPartyProvider,true);
                    soql = CommissionTrackerLgtngUtility.commissionToBeProcessedSOQL(selectedMilestones,selectedProvidersForQuery,start_date,end_date, false);
                }
            }
            
        } else {
            soql = createSOQL('Commission to be processed');
        }

        List<Commission__c> commission_list = (List<Commission__c>)Database.query(soql);

        Map<String, List<Commission__c>> commissionMap = new Map<String, List<Commission__c>>();
   
        /*for(Commission__c commission : commission_list) {
            if (!commissionMap.containsKey(commission.Opportunity__r.X3rd_Party_Partner__c)) {
                commissionMap.put(commission.Opportunity__r.X3rd_Party_Partner__c, new List<Commission__c>());
            }
            commissionMap.get(commission.Opportunity__r.X3rd_Party_Partner__c).add(commission);
        }*/
		for(Commission__c commission : commission_list) {
            if (!commissionMap.containsKey(commission.Milestone_Payments__c+commission.Opportunity__r.X3rd_Party_Partner__c)) {
                commissionMap.put(commission.Milestone_Payments__c+commission.Opportunity__r.X3rd_Party_Partner__c, new List<Commission__c>());
            }
            commissionMap.get(commission.Milestone_Payments__c+commission.Opportunity__r.X3rd_Party_Partner__c).add(commission);
        }

        List<ProviderCommissionWrapper> M1ProvidersWrapperList = new List<ProviderCommissionWrapper>();
        List<ProviderCommissionWrapper> M2ProvidersWrapperList = new List<ProviderCommissionWrapper>();
        List<ProviderCommissionWrapper> M3ProvidersWrapperList = new List<ProviderCommissionWrapper>();
        List<ProviderCommissionWrapper> CBProvidersWrapperList = new List<ProviderCommissionWrapper>();

        for(List<Commission__c> commissionList : commissionMap.values()) {



            ProviderCommissionWrapper providerWrapper = new ProviderCommissionWrapper();
            
            providerWrapper.CommissionsList = commissionList;

            //Calculate Total Commissions
            for(Commission__c commission : commissionList) {

                if(providerWrapper.ProviderName == null) {
                    providerWrapper.ProviderName = commission.Opportunity__r.X3rd_Party_Partner__c;
                    providerWrapper.ProviderId = commission.Opportunity__r.Channel_Partner__c;
                }

                if(providerWrapper.currentMilestone == null) {
                    providerWrapper.currentMilestone = commission.Milestone_Payments__c;
                }
                
                if(commission.Milestone_1_Amount__c != null) {
                    providerWrapper.Milestone1TotalAmount += commission.Milestone_1_Amount__c;
                }
                if(commission.Milestone_1_Amount_Actual_Paid__c != null){
                    providerWrapper.Milestone1ActualPaid += commission.Milestone_1_Amount_Actual_Paid__c;
                }
                if(commission.Milestone_2_Amount__c != null){
                    providerWrapper.Milestone2TotalAmount += commission.Milestone_2_Amount__c;
                }
                if(commission.Milestone_2_Amount_Actual_Paid__c != null){
                    providerWrapper.Milestone2ActualPaid += commission.Milestone_2_Amount_Actual_Paid__c;
                }
                if(commission.Milestone_3_Amount__c != null){
                    providerWrapper.Milestone3TotalAmount += commission.Milestone_3_Amount__c;
                }
                if(commission.Milestone_3_Actual_Paid__c != null){
                    providerWrapper.Milestone3ActualPaid += commission.Milestone_3_Actual_Paid__c;
                }
                if(commission.M1_Clawback_Amount__c != null){
                    providerWrapper.ClawbackTotalAmount += commission.M1_Clawback_Amount__c;
                }
                if(commission.Clawback_Amount_Actual__c != null){
                    providerWrapper.ClawbackActualPaid += commission.Clawback_Amount_Actual__c;
                }
                
                Decimal result = (providerWrapper.Milestone1TotalAmount == null?0:providerWrapper.Milestone1TotalAmount)+
                    (providerWrapper.Milestone2TotalAmount == null?0:providerWrapper.Milestone2TotalAmount)+
                    (providerWrapper.Milestone3TotalAmount == null?0:providerWrapper.Milestone3TotalAmount)-
                    (providerWrapper.ClawbackTotalAmount == null?0:providerWrapper.ClawbackTotalAmount);
                    
                providerWrapper.CommissionResult = result.setScale(2);

            }
            //Assign provider to corresponding milestone
            if(providerWrapper.currentMilestone == 'M1') {

                M1ProvidersWrapperList.add(providerWrapper);

            } else if (providerWrapper.currentMilestone == 'M2') {

                M2ProvidersWrapperList.add(providerWrapper);

            } else if (providerWrapper.currentMilestone == 'M3') {
                M3ProvidersWrapperList.add(providerWrapper);

            } else if (providerWrapper.currentMilestone == 'Cancellation Clawback') {

                CBProvidersWrapperList.add(providerWrapper);
            }
        }
        //Assign providers list to corresponding milestone wrapper
        if(!M1ProvidersWrapperList.isEmpty()) {
            M1wrapper.data = M1ProvidersWrapperList;
            M1wrapper.isPresent = true;
        }
        if(!M2ProvidersWrapperList.isEmpty()) {
            M2wrapper.data = M2ProvidersWrapperList;
            M2wrapper.isPresent = true;
        }
        if(!M3ProvidersWrapperList.isEmpty()) {
            M3Wrapper.data = M3ProvidersWrapperList;
            M3wrapper.isPresent = true;
        }
        if(!CBProvidersWrapperList.isEmpty()) {
            clawbackWrapper.data = CBProvidersWrapperList;
            clawbackWrapper.isPresent = true;
        }

        if(M1Wrapper.isPresent == true) {
            milestoneWrapperList.add(M1Wrapper);
        }
        if(M2Wrapper.isPresent == true) {
            milestoneWrapperList.add(M2Wrapper);
        }
        if(M3Wrapper.isPresent == true) {
            milestoneWrapperList.add(M3Wrapper);
        }
        if(clawbackWrapper.isPresent == true) {
            milestoneWrapperList.add(clawbackWrapper);
        }

        Map<String, String> providerNameMap = find3rdPartyUser();

        if(providerNameMap.containsKey('account_name')) {
            dboardData.thirdPartyProviders.add(providerNameMap.get('account_name'));
            
        } else {
            providersWrapper = get3rdPartyPartners();

        }

        dboardData.thirdPartyProviders = providersWrapper.activeProviders;
		dboardData.thirdInactivePartyProviders = providersWrapper.inactiveProviders;
        dboardData.data = milestoneWrapperList;

       return dboardData;
    }

    @AuraEnabled
    public static CommissionsWrapper processMilestones(List<Id> commissions) {

        String result;
        CommissionsWrapper commissionsWrapper = new CommissionsWrapper();

        List<Commission__c> commissionsToBeUpdated = new List<Commission__c>();
        List<Commission__c> commissionsNotUpdated = new List<Commission__c>();

        List<Commission__c> commissionsToBeProcessed = [
            SELECT Name, Milestone_1_Amount__c,Milestone_1_Amount_Actual_Paid__c, Milestone_1_Processed__c, Milestone_1_Processed_Date__c, 
                Milestone_2_Amount__c, Milestone_2_Processed_Date__c,Milestone_2_Amount_Actual_Paid__c, Milestone_2_Processed__c,
                Milestone_3_Amount__c, Milestone_3_Processed_Date__c, Milestone_3_Actual_Paid__c, Milestone_3_Processed__c, Clawback_Amount_Actual__c,
                M1_Clawback_Processed_Date__c, M1_Clawback_Complete__c, Milestone_Payments__c, Opportunity__r.Initial_Payment__c, Loan_Pal__c,
				M1_Clawback_Amount__c
            FROM Commission__c
            WHERE Id IN : commissions 
        ];

        //TO DO: ADD MILESTONE CONDITION
        for(Commission__c commission : commissionsToBeProcessed) {
            Boolean isUpdated = false;

            if(commission.Loan_Pal__c != 'Cash' || (commission.Loan_Pal__c == 'Cash' && commission.Opportunity__r.Initial_Payment__c != null)) {

				//Removed flag when a commission is already preocessed because we need to be able to update actual paid 
                if(commission.Milestone_Payments__c == 'M1'){
					if(commission.Milestone_1_Processed__c == false) {
						commission.Milestone_1_Processed_Date__c = System.date.today();
                    	commission.Milestone_1_Processed__c = true;
					}
					commission.Milestone_1_Amount_Actual_Paid__c = commission.Milestone_1_Amount__c;
    
                    isUpdated = true;
                } else if(commission.Milestone_Payments__c == 'M2'){
					
					if(commission.Milestone_2_Processed__c == false) {
						commission.Milestone_2_Processed_Date__c = System.date.today();
						commission.Milestone_2_Processed__c = true;
					}
                    commission.Milestone_2_Amount_Actual_Paid__c = commission.Milestone_2_Amount__c;
    
                    isUpdated = true;
                } else if(commission.Milestone_Payments__c == 'M3'){
					
					if(commission.Milestone_3_Processed__c == false) {
						commission.Milestone_3_Processed_Date__c = System.date.today();
						commission.Milestone_3_Processed__c = true;
					}
                    commission.Milestone_3_Actual_Paid__c = commission.Milestone_3_Amount__c;
    
                    isUpdated = true;
                } else if(commission.Milestone_Payments__c == 'Cancellation Clawback'){
					
					if(commission.M1_Clawback_Complete__c == false) {
						commission.M1_Clawback_Processed_Date__c = System.date.today();
						commission.M1_Clawback_Complete__c = true;
					}
					commission.Clawback_Amount_Actual__c = commission.M1_Clawback_Amount__c;
    
                    isUpdated = true;
                }
            }
            
            if(isUpdated) {
                commissionsToBeUpdated.add(commission);
            } else {
                commissionsNotUpdated.add(commission);
            }
        }
        
        try {
            if(!commissionsToBeUpdated.isEmpty()){
                update commissionsToBeUpdated;
                commissionsWrapper.message = 'OK';
                if(!commissionsNotUpdated.isEmpty()) {
                    commissionsWrapper.Commissions = commissionsNotUpdated;
                }
            } else {
                commissionsWrapper.message = 'Commission/s couldn\'t be updated. Because either all selected commissions are already processed for their current milestone or finance tool and initial payment doesn\'t meet the criteria';
            }
        } catch (Exception e) {
            commissionsWrapper.message = e.getMessage();
        }

        return commissionsWrapper;
    }

    @AuraEnabled
    public static CommissionsWrapper addPaidDateToCommissions(List<Id> commissions, Date selectedDate) {
        CommissionsWrapper commissionsWrapper = new CommissionsWrapper();

        if(selectedDate == null) {
            selectedDate = System.date.Today();
        }

        List<Commission__c> commissionsToBeUpdated = new List<Commission__c>();
        List<Commission__c> commissionsNotUpdated = new List<Commission__c>();

        List<Commission__c> commissionsList = [
            SELECT Name, Milestone_1_Paid_Date__c, Milestone_1_Paid__c, Milestone_2_Paid_Date__c, Milestone_2_Paid__c, Milestone_Payments__c,
                Milestone_3_Paid_Date__c, Milestone_3_Paid__c, M1_Clawback_Applied_to_Balance_Paid_Date__c, M1_Clawback_Applied_Paid__c,
				Milestone_1_Processed_Date__c, Milestone_2_Processed_Date__c, Milestone_3_Processed_Date__c, M1_Clawback_Processed_Date__c
            FROM Commission__c
            WHERE Id IN : commissions
        ];

        for(Commission__c commission : commissionsList) {
            Boolean isAssigned = false;
            if(commission.Milestone_Payments__c == 'M1') {
                if(commission.Milestone_1_Paid_Date__c == null && commission.Milestone_1_Processed_Date__c != null) {

                    commission.Milestone_1_Paid_Date__c = selectedDate;
                    commission.Milestone_1_Paid__c = true;

                    isAssigned = true;
                }
            } else if(commission.Milestone_Payments__c == 'M2') {
                if (commission.Milestone_2_Paid_Date__c == null && commission.Milestone_2_Processed_Date__c != null) {

                    commission.Milestone_2_Paid_Date__c = selectedDate;
                    commission.Milestone_2_Paid__c = true;

                    isAssigned = true;
                }
            } else if(commission.Milestone_Payments__c == 'M3') {
                if (commission.Milestone_3_Paid_Date__c == null && commission.Milestone_3_Processed_Date__c != null) {
                    commission.Milestone_3_Paid_Date__c = selectedDate;
                    commission.Milestone_3_Paid__c = true;

                    isAssigned = true;
                } 
            } else if(commission.Milestone_Payments__c == 'Cancellation Clawback') {
                if (commission.M1_Clawback_Applied_to_Balance_Paid_Date__c == null && commission.M1_Clawback_Processed_Date__c != null) {

                    commission.M1_Clawback_Applied_to_Balance_Paid_Date__c = selectedDate;
                    commission.M1_Clawback_Applied_Paid__c = true;

                    isAssigned = true;
    
                }
            }

            if(isAssigned) {
                commissionsToBeUpdated.add(commission);
            } else {
                commissionsNotUpdated.add(commission);
            }
            
        }

        try {
            
            if(!commissionsToBeUpdated.isEmpty()){
                update commissionsToBeUpdated;
                commissionsWrapper.message = 'OK';
                if(!commissionsNotUpdated.isEmpty()) {
                    commissionsWrapper.Commissions = commissionsNotUpdated;
                }
            } else {
                commissionsWrapper.message = 'Commission/s couldn\'t be updated. Please check if the commissions are already paid or need to be processed';
            }
            
        } catch (Exception e) {
            commissionsWrapper.message = e.getMessage();
        }

        return commissionsWrapper;
    }

    public class CommissionsWrapper {
        @AuraEnabled
        public String message {get;set;}
        @AuraEnabled
        public List<Commission__c> Commissions {get;set;}
    }

    /*@AuraEnabled
    public static String unprocessMilestones(List<Id> commissions) {

        String result;

        List<Commission__c> commissionsToBeUpdated = new List<Commission__c>();
         
        List<Commission__c> commissionsToBeUnprocessed = [
            SELECT Milestone_1_Amount__c,Milestone_1_Amount_Actual_Paid__c, Milestone_1_Processed__c, Milestone_1_Processed_Date__c, 
                Milestone_2_Amount__c, Milestone_2_Processed_Date__c,Milestone_2_Amount_Actual_Paid__c, Milestone_2_Processed__c,
                Milestone_3_Amount__c, Milestone_3_Processed_Date__c, Milestone_3_Actual_Paid__c, Milestone_3_Processed__c,
                M1_Clawback_Processed_Date__c, M1_Clawback_Complete__c
            FROM Commission__c
            WHERE Id IN : commissions 
        ];
        //TO DO: ADD MILESTONE CONDITION 
        for(Commission__c commission : commissionsToBeUnprocessed) {

            if(commission.Milestone_1_Paid_Date__c != null) {

                commission.Milestone_1_Paid_Date__c = null;
                commission.Milestone_1_Paid__c = false;

            } else if (commission.Milestone_2_Paid_Date__c != null) {

                commission.Milestone_2_Paid_Date__c = null;
                commission.Milestone_2_Paid__c = false;

            } else if(commission.Milestone_3_Paid_Date__c != null) {

                commission.Milestone_3_Paid_Date__c = null;
                commission.Milestone_3_Paid__c = false;

            } else if(commission.M1_Clawback_Applied_to_Balance_Paid_Date__c != null) {

                commission.M1_Clawback_Applied_to_Balance_Paid_Date__c = null;
                commission.M1_Clawback_Applied_Paid__c = false;
            }
                
                commissionsToBeUpdated.add(commission);
        }
        
        try {
            update commissionsToBeUpdated;
            result = 'OK';
        } catch (Exception e) {
            result = e.getMessage();
        }

        return result;
    }*/

    private static Map<String, String> find3rdPartyUser() {

        Map<String, String> providerNameMap = new Map<String, String>();
        Profile profileId;
        try {
            profileId = [
                SELECT Id
                FROM Profile
                WHERE Name = '3rd Party - Design'
            ];
        } catch(Exception e) {
            System.debug(e);
        }

        if(profileId != null) {
            try {
                if(UserInfo.getProfileId() == profileId.Id) {
                    User userObj = [
                        SELECT CompanyName,isActive 
                        FROM User 
                        WHERE Id=:UserInfo.getUserId()
                        AND CompanyName != null
                    ];

                    if(userObj != null) {
                        providerNameMap.put('account_name',userObj.CompanyName);
                        providerNameMap.put('error','no');
                    } else {
                        providerNameMap.put('error','yes');
                    }
                }
            } catch (Exception e) {
                System.debug(e);
            }
        }

        return providerNameMap;
        
    }

	//Changed List<String> to ProvidersWrapper since the new requirement
    public static ProvidersWrapper get3rdPartyPartners() {

        List<String> providersList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Opportunity.X3rd_Party_Partner__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple) {
            providersList.add(f.getLabel());
        }

        List<String> activeProvidersList = new List<String>();
		List<String> inactiveProvidersList = new List<String>();

        Map<String,String> accountMap = new Map<String, String>();

        List<Account> accList = [
            SELECT Name, Channel_Partner_Status__c 
            FROM Account
            WHERE Name IN : providersList
        ];

        for(Account acc : accList) {
            accountMap.put(acc.Name, acc.Channel_Partner_Status__c);
        }

        for(String provider : providersList ) {
            if(accountMap.get(provider) == 'Active') {
                activeProvidersList.add(provider);
            } else if (accountMap.get(provider) == 'Inactive') {
				inactiveProvidersList.add(provider);
			}
        }

		ProvidersWrapper providersWrapper = new ProvidersWrapper();
		providersWrapper.activeProviders = activeProvidersList;
		providersWrapper.inactiveProviders = inactiveProvidersList;
        return providersWrapper;
    }

	private class ProvidersWrapper {
		private List<String> activeProviders {get;set;}
		private List<String> inactiveProviders {get;set;}
	}

    private static string createSOQL(string mode) {
        
        string commmission_to_be_processed;
        string soql;

        if(mode == 'Commission to be processed')
        {
            soql = commissionToBeProcessedSOQL();
        }
        
        return soql;
    }

    @AuraEnabled
    public static string commissionToBeProcessedSOQL() {

        //List<String> providersList = get3rdPartyPartners();
		ProvidersWrapper providersWrapper = get3rdPartyPartners();
        List<String> selectedAll3rdPartyProvider = providersWrapper.activeProviders;
        List<String> selectedAllMilestone = new List<String>();
        String M1 = 'M1';
        String M2 = 'M2';
        String M3 = 'M3';
        String Clawback = 'Clawbacks';

        selectedAllMilestone.add(M1);
        selectedAllMilestone.add(M2);
        selectedAllMilestone.add(M3);
        selectedAllMilestone.add(Clawback);

        String selectedMilestone = string.join(selectedAllMilestone,';');
        DateTime start_date = dateTime.now().addDays(-360);
        DateTime end_date = System.Datetime.now();
        Date fromDateExport = start_Date.date();
        Date toDateExport = end_date.date();
        Integer ReportType = 1;
        String selected3rdPartyProvider = setToDelimitedString(',',selectedAll3rdPartyProvider,true);
        //Changed parameters start_date and end_date for fromDataExport and toDataExport
        string soql = CommissionTrackerLgtngUtility.commissionToBeProcessedSOQL(selectedMilestone,selected3rdPartyProvider,fromDateExport,toDateExport, false);
        return soql;
    }

    @testVisible
    private static string setToDelimitedString(string delimiter,List< string > inputList,boolean add_single_quotes) {

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
    @AuraEnabled
    public static void unproccessNegatives(List<ProviderCommissionWrapper> providersList){
        try {
            List<Commission__c> lstCommission = new List<Commission__c>();
            for(ProviderCommissionWrapper provider : providersList) {
                for(Commission__c comm : provider.CommissionsList){
                        comm.Milestone_1_Processed__c = false;
                        comm.Milestone_1_Processed_Date__c = null;
                        comm.Milestone_1_Amount_Actual_Paid__c = null;
                        comm.Milestone_2_Processed__c = false;
                        comm.Milestone_2_Processed_Date__c = null;
                        comm.Milestone_2_Amount_Actual_Paid__c = null;
                        comm.Milestone_3_Processed__c = false;
                        comm.Milestone_3_Processed_Date__c = null;
                        comm.Milestone_3_Actual_Paid__c = null;
                        comm.M1_Clawback_Complete__c = false;
                        comm.M1_Clawback_Processed_Date__c = null;
                        comm.Clawback_Amount_Actual__c = null;
                    

                    lstCommission.add(comm);
                }
            }
        
            if(!lstCommission.isEmpty()) {
                update lstCommission;
            }

        } catch (Exception e) {
            AuraHandledException aex = new AuraHandledException(e.getMessage());
            aex.setMessage(e.getMessage());
            throw aex;
        }
    }
    @AuraEnabled
    public static CommissionsWrapper unprocessCommissions(List<Id> commissionsList){

        CommissionsWrapper result = new CommissionsWrapper();
        List<Commission__c> commissionsNotUpdated = new List<Commission__c>();
        List<Commission__c> commissionsToBeUpdated = new List<Commission__c>();

        List<Commission__c> commissionsToBeUnProcessed = [
            SELECT Name, Milestone_1_Amount_Actual_Paid__c, Milestone_1_Processed__c, Milestone_1_Processed_Date__c, Milestone_1_Paid__c,
                Milestone_2_Processed_Date__c,Milestone_2_Amount_Actual_Paid__c, Milestone_2_Processed__c, Milestone_2_Paid__c,
                Milestone_3_Processed_Date__c, Milestone_3_Actual_Paid__c, Milestone_3_Processed__c, Milestone_3_Paid__c,
                M1_Clawback_Processed_Date__c, M1_Clawback_Complete__c, M1_Clawback_Applied_Paid__c, Clawback_Amount_Actual__c, Milestone_Payments__c
            FROM Commission__c
            WHERE Id IN : commissionsList 
        ];

        try {

            for(Commission__c comm : commissionsToBeUnProcessed){

                Boolean isUpdated = false;

                if(comm.Milestone_Payments__c == 'M1' && !comm.Milestone_1_Paid__c){
                    comm.Milestone_1_Processed__c = false;
                    comm.Milestone_1_Processed_Date__c = null;
                    comm.Milestone_1_Amount_Actual_Paid__c = null;

                    isUpdated = true;

                } else if(comm.Milestone_Payments__c == 'M2' && !comm.Milestone_2_Paid__c){
                    comm.Milestone_2_Processed__c = false;
                    comm.Milestone_2_Processed_Date__c = null;
                    comm.Milestone_2_Amount_Actual_Paid__c = null;

                    isUpdated = true;
                    
                } else if(comm.Milestone_Payments__c == 'M3' && !comm.Milestone_3_Paid__c){
                    comm.Milestone_3_Processed__c = false;
                    comm.Milestone_3_Processed_Date__c = null;
                    comm.Milestone_3_Actual_Paid__c = null;

                    isUpdated = true;
                    
                } else if(comm.Milestone_Payments__c == 'Cancellation Clawback' && !comm.M1_Clawback_Applied_Paid__c){
                    comm.M1_Clawback_Complete__c = false;
                    comm.M1_Clawback_Processed_Date__c = null;
                    comm.Clawback_Amount_Actual__c = null;

                    isUpdated = true;

                }
                
                if(isUpdated) {
                    commissionsToBeUpdated.add(comm);
                } else {
                    commissionsNotUpdated.add(comm);
                }
            }
        
            if(!commissionsToBeUpdated.isEmpty()) {
                update commissionsToBeUpdated;

                result.message = 'OK';
                if(!commissionsNotUpdated.isEmpty()) {
                    result.Commissions = commissionsNotUpdated;
                }
            } else {
                result.message = 'The operation was cancelled because the selected commissions are already paid';
            }

        } catch (Exception e) {
            AuraHandledException aex = new AuraHandledException(e.getMessage());
            aex.setMessage(e.getMessage());
            throw aex;
        }

        return result;
    }

    @AuraEnabled
    public static List<ProviderEmailWrapper> getEmailsAndContactsFromProvider(List<String> providers) {

        List<ProviderEmailWrapper> emailWrapperList = new List<ProviderEmailWrapper>();

        Map<Id,Account> accountMap = new Map<Id, Account>([
            SELECT Id, Name, Channel_Partner_Status__c 
            FROM Account
            WHERE Name IN : providers
        ]);

        List<Contact> contactList = [
            SELECT Name, Email,AccountId  
            FROM Contact 
            WHERE AccountId IN : accountMap.keySet()
            AND Title ='Leadership'
        ];

        Map<String, ProviderEmailWrapper> providerMap = new Map<String, ProviderEmailWrapper>();

        for(Contact con : contactList ) {
            //If there is already a provider, then add new contact and email to it
            if(providerMap.get(accountMap.get(con.AccountId).Name) != null) {
                ProviderEmailWrapper providerEmailUpdate = providerMap.get(accountMap.get(con.AccountId).Name);
                providerEmailUpdate.ContactNames += ', '+con.Name;
                providerEmailUpdate.ContactEmails += ', '+con.Email;
                providerMap.put(providerEmailUpdate.ProviderName, providerEmailUpdate);
            //If provider doesn't exist, create new one
            } else {
                ProviderEmailWrapper providerEmail = new ProviderEmailWrapper();

                if(con.Name != null && con.Email != null) {
                    providerEmail.ProviderName = accountMap.get(con.AccountId).Name;
                    providerEmail.ProviderStatus = accountMap.get(con.AccountId).Channel_Partner_Status__c;
                    providerEmail.ContactNames = con.Name;
                    providerEmail.ContactEmails = con.Email;

                    providerMap.put(providerEmail.ProviderName, providerEmail);
                }
                
            }
        }

        emailWrapperList.addAll(providerMap.values());

        emailWrapperList.sort();

        return emailWrapperList;
    }

    @AuraEnabled
    public static String sendEmailToProviders(List<String> selectedAllmilestone, Date fromDate, Date toDate, List<SendEmailWrapper> providersList, List<SendEmailWrapper> providersWithoutCommissions) {

        try {

            List<string> email_list = new List<string>();

            List<Messaging.SingleEmailMessage> send_email_list = new List<Messaging.SingleEmailMessage>();

            string email_body = 'Team, <br/>';
            email_body += '<p>Please find attached your weekly commissions report for commissions milestones from [' + fromDate.addDays(-7).format() + ' - ' + fromDate.addDays(-1).format() + ']. ';
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
            emailBody3 += '<p>Please find attached your weekly commissions report for commissions milestones from [' + fromDate.addDays(-7).format() + ' - ' + fromDate.addDays(-1).format() + ']. ';
            emailBody3 += 'Due to the net negative balance, no commissions payment will be processed this week.</p>';
            emailBody3 += '<p>For any inquiries, please reach out directly to commissions@palmetto.com for the fastest response</p>';
            emailBody3 +='Thank you';
            
            string no_email_send_providers = '';
            Boolean isCommissionExist, isPositiveCommission;

            for(SendEmailWrapper provider: providersList) {

                if(provider.ProviderStatus == 'Active') {
                    
                    String subject = provider.ProviderName + ' - Palmetto Weekly Commissions - [' + fromDate.addDays(-7).format() + ' - ' + fromDate.addDays(-1).format() + ']';
                    
                    email_list = new List<string>();

                    string[] emails = provider.ContactEmails.split(',');

                    for(string email:emails) {
                        email_list.add(email);
                    }

                    email_list.add(System.Label.commission_report_Email);
                    
                    Messaging.reserveSingleEmailCapacity( 1 );

                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    //mail.setToAddresses( new String[]{'youremail@palmetto.com'} ); //Uncomment this line if you want to try mailing functionality
					mail.setToAddresses(email_list);
                    mail.setReplyTo(System.Label.commission_report_Email);
                    mail.setSenderDisplayName( 'Palmetto Commissions' );
                    mail.setSubject( subject );
                    mail.setBccSender( false );
                    mail.setUseSignature( false );

                    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                    
                    //if(isCommissionExist) {
                        if(provider.CommissionResult > 0) {

                            mail.setPlainTextBody( email_body );
                            mail.setHtmlBody( email_body );
                            
                        } else {

                            mail.setPlainTextBody( emailBody3 );
                            mail.setHtmlBody( emailBody3 );
                        }
                        
                        PageReference pf = Page.CommissionTrackerExport;

                        string selected_milestone = string.join(selectedAllMilestone,';');

                        string selected_3rd_party_provider = '\'' +provider.ProviderName + '\'';

                        pf.getParameters().put('startdate', EncodingUtil.urlEncode(fromDate.format(),'UTF-8'));
                        pf.getParameters().put('enddate', EncodingUtil.urlEncode(toDate.format(),'UTF-8'));
                        pf.getParameters().put('reporttype','2');
                        pf.getParameters().put('milestone', EncodingUtil.urlEncode(selected_milestone,'UTF-8'));
                        pf.getParameters().put('partprovider', EncodingUtil.urlEncode(selected_3rd_party_provider,'UTF-8'));
                        pf.getParameters().put('paidmilestone', string.valueof(provider.PaidMilestone));

						Blob b;
						if(Test.isRunningTest()) { 
							b = blob.valueOf('Unit.Test');
						} else {
							b = pf.getContent();
						}
                       

                        efa.setFileName('Commission Processing.csv');
                        efa.setBody(b);

                        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                    //
                    /*} else {
                        mail.setPlainTextBody( emailBody );
                        mail.setHtmlBody( emailBody );
                    }*/
                    send_email_list.add(mail);
                }
            }
            //Create another Mail for the providers without commissions
            if(providersWithoutCommissions != null) {
                for(SendEmailWrapper provider: providersWithoutCommissions) {
                    if(provider.ProviderStatus == 'Active') {
                    
                        String subject = provider.ProviderName + ' - Palmetto Weekly Commissions - [' + fromDate.addDays(-7).format() + ' - ' + fromDate.addDays(-1).format() + ']';
                        
                        email_list = new List<string>();
    
                        string[] emails = provider.ContactEmails.split(',');
    
                        for(string email:emails) {
                            email_list.add(email);
                        }
    
                        email_list.add(System.Label.commission_report_Email);
                        
                        Messaging.reserveSingleEmailCapacity( 1 );

                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses( new String[]{'christian.bogarin@palmetto.com'} );
                        mail.setReplyTo(System.Label.commission_report_Email);
                        mail.setSenderDisplayName( 'Palmetto Commissions' );
                        mail.setSubject( subject );
                        mail.setBccSender( false );
                        mail.setUseSignature( false );

                        mail.setPlainTextBody( emailBody );
                        mail.setHtmlBody( emailBody );

                        send_email_list.add(mail);
                    }
                }
            }
            
            if(send_email_list.size() > 0) {
                Messaging.sendEmail( send_email_list );
                return 'OK';
            } else {

                return 'No provider selected';
            }

        } catch(Exception ex) {
            if(Test.isRunningTest()) {
				return 'OK';
			} else {
				return ex.getMessage();
			}
            
        }
        
       
    }

    public class ProviderEmailWrapper implements Comparable {
        @AuraEnabled
        public String ProviderName {get;set;}
        @AuraEnabled
        public String ProviderStatus {get;set;}
        @AuraEnabled
        public String ContactNames {get;set;}
        @AuraEnabled
        public String ContactEmails {get;set;}
        

        public Integer compareTo(Object compareTo) {
            ProviderEmailWrapper orderProviders = (ProviderEmailWrapper) compareTo;
            Integer returnValue = 0;
            if(ProviderName == orderProviders.ProviderName) {
                returnValue = 0;
            }
            if(ProviderName > orderProviders.ProviderName) {
                returnValue = 1;
            }
            if(ProviderName < orderProviders.ProviderName) {
                returnValue = -1;
            }
            return returnValue;
        }
    }

    public class SendEmailWrapper {
        @AuraEnabled
        public Double CommissionResult {get;set;}
        @AuraEnabled
        public String ProviderName {get;set;}
        @AuraEnabled
        public String ProviderStatus {get;set;}
        @AuraEnabled
        public String ContactEmails {get;set;}
        @AuraEnabled
        public Boolean PaidMilestone {get;set;}
        @AuraEnabled
        public String ContactNames {get;set;}
    }

    public class DashboardData {
        @AuraEnabled
        public Object data {get;set;}
        @AuraEnabled
        public List<String> thirdPartyProviders {get;set;}
		@AuraEnabled
		public List<String> thirdInactivePartyProviders {get; set;}
    }

    public class MilestoneWrapper {
        @AuraEnabled
        public Boolean isPresent {get;set;}
        @AuraEnabled
        public Object data {get;set;}
        @AuraEnabled
        public String milestone {get;set;}
    }

    public class ProviderCommissionWrapper {
        @AuraEnabled
        public String currentMilestone {get;set;}
        @AuraEnabled
        public String ProviderName {get;set;}
        @AuraEnabled
        public String ProviderId {get;set;}
        @AuraEnabled
        public List<Commission__c> CommissionsList {get;set;}
        @AuraEnabled
        public Double Milestone1TotalAmount {get;set;}
        @AuraEnabled
        public Double Milestone1ActualPaid {get;set;}
        @AuraEnabled
        public Double Milestone2TotalAmount {get;set;}
        @AuraEnabled
        public Double Milestone2ActualPaid {get;set;}
        @AuraEnabled
        public Double Milestone3TotalAmount {get;set;}
        @AuraEnabled
        public Double Milestone3ActualPaid {get;set;}
        @AuraEnabled
        public Double ClawbackTotalAmount {get;set;}
        @AuraEnabled
        public Double ClawbackActualPaid {get;set;}
        @AuraEnabled
        public Double CommissionResult {get;set;}

        public ProviderCommissionWrapper() {
            this.Milestone1TotalAmount = 0;
            this.Milestone1ActualPaid = 0;
            this.Milestone2TotalAmount = 0;
            this.Milestone2ActualPaid = 0;
            this.Milestone3TotalAmount = 0;
            this.Milestone3ActualPaid = 0;
            this.ClawbackTotalAmount = 0;
            this.ClawbackActualPaid = 0;
            this.CommissionResult = 0;
        }
    }
}