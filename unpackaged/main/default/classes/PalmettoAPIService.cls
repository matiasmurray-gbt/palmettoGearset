//This class contains all the API related operations.
public class PalmettoAPIService
{
    public static HttpResponse sendData(String endPointAPI, String requestBody, String method, Map<String, String> mapHeaderParams){
        HttpRequest objHttpRequest = new HttpRequest();
        objHttpRequest.setEndPoint(endPointAPI);
        objHttpRequest.setBody(requestBody);
        objHttpRequest.setMethod(method);
        objHttpRequest.setTimeout(45000);
        if(mapHeaderParams != null){
            for(String headerKey : mapHeaderParams.keyset()){
                objHttpRequest.setHeader(headerKey, mapHeaderParams.get(headerKey));
            }
        }    
        System.debug('>>>>>>>>>'+objHttpRequest);
        System.debug('>>>>>>>>>'+objHttpRequest.getHeader('api_key'));
        System.debug('>>>>>>>>>'+objHttpRequest.getBody());
        
        Http objHttp = new Http();
        HttpResponse objHttpResponse;
        TriggerConfiguration__c configTestCallout = TriggerConfiguration__c.getInstance('Test send callouts');

        if(!Test.isRunningTest() || (configTestCallout != null && configTestCallout.Active__c)){
            try{
                objHttpResponse = objHttp.send(objHttpRequest);
            }
            catch(Exception ex){
                objHttpResponse = new HttpResponse();
                objHttpResponse.setStatusCode(599);
                objHttpResponse.setBody(ex.getMessage());
            }
        } else{
            objHttpResponse = new HttpResponse();
            objHttpResponse.setStatusCode(200);
            objHttpResponse.setBody('{"success": "true"}');
        }
        
        return objHttpResponse;
    }

    @future(callout=true)
    public static void sendOppData(Set<Id> setOppId){
        List<Opportunity> lstOpportunity = [select Id, X18_Character_Opportunity_ID__c, Name, StageName, X3rd_Party_Sales_Rep__c, 
                Sales_Rep_Email__c, Phone_Textey__c, Email__c, Utility__c, Financing_Tool__c, Loan_Term__c, CreatedDate, Site_Survey_Time__c,
                Contract_Received_Confirmed__c, Contract_Received_Confirmed_Date__c, Days_Since_Contract_Received__c, Site_Audit_Completed_Date__c, 
                Site_Audit_FieldCompleted_Date__c, Site_Approved_Date__c, Engineering_Complete_Date__c, Permit_Rec_d_Date__c, Installation_Start_Date__c, 
                Installation_Complete_Date__c, Inspection_Complete_Date__c, Net_Meter_Install_Date__c, System_Size_Calculated_kW__c, Est_First_Year_kWh__c, 
                Amount, Account.BillingState, Account.BillingPostalCode, Account.BillingStreet, Account.BillingCity 
                from Opportunity where Id in :setOppId];
    
        if(lstOpportunity != null && !lstOpportunity.isEmpty()){
            List<LGCY_API_Logs__c> lstAPILogs = new List<LGCY_API_Logs__c>();
            for(Opportunity objOpp : lstOpportunity){
                String jsonBody = JSON.serialize(objOpp);
                HttpResponse objHttpResponse = sendData(System.Label.LGCY_Endpoint, jsonBody, 'POST', null);
                
                LGCY_API_Logs__c objAPILog = new LGCY_API_Logs__c();
                objAPILog.Opportunity__c = objOpp.Id;
                String responseBody = objHttpResponse.getBody();
                if(objHttpResponse.getStatusCode() == 200){
                    Map<String, Object> mapResponseParams = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                    if(mapResponseParams.containsKey('success') && String.valueOf(mapResponseParams.get('success')) == 'true'){
                        objAPILog.Status__c = 'Success';
                    } else{
                        objAPILog.Status__c = 'Fail';
                    }
                } else{
                    objAPILog.Status__c = 'Fail';
                    objAPILog.Error_Reason__c = responseBody;
                }
                
                lstAPILogs.add(objAPILog);
            }       
            
            if(!lstAPILogs.isEmpty())
                insert lstAPILogs;
        }
    }
    
    @future(callout=true)
    public static void sendCommissionData(Set<Id> setCommissionId){
        List<Commission__c> lstCommission = [select Id, Name, Total_Commissions__c, CP_Base__c, CP_Base_Watt__c, 
                Dealer_Fees__c, Total_Adders_Upgrade_Incentives__c, Total_Commissions_Paid_To_Date__c, Balance_Due_Commissions__c, 
                Milestone_1_Date_Calculated__c, Milestone_1_Paid_Date__c, Milestone_1_Amount__c, Milestone_2_Date__c, Milestone_2_Paid_Date__c, 
                Milestone_2_Amount__c, Milestone_3_Date_PTO_3_Days__c, Milestone_3_Paid_Date__c, Milestone_3_Amount__c, Cancellation_Date__c, 
                CT_GreenBank_Adder__c, Structural_Electrical_Upgrade_Adder__c, Roofing_Adder__c, Electrical_Upgrade_Adder__c, 
                Structural_Upgrade_Adder__c, Tree_Removal_Other_Adder__c, Other_Misc_Adders__c, Total_Adders__c, Roof_Type_Adder__c, 
                Roof_Tilt_Adder__c, High_Roof_Adder__c, Panel_Type_Adder__c, Solar_Edge_Warranty_Adder__c, Appointment_Success_Fee__c, 
                Battery_Adder__c, Ground_Mount_Adder__c, Trenching_Distance_Adder__c, Opportunity__r.Est_First_Year_kWh__c, 
                CreatedDate, Opportunity__r.Loan_Term__c, Opportunity__r.Financing_Tool__c, Opportunity__r.Utility__c, 
                Opportunity__r.Email__c, Opportunity__r.X3rd_Party_Sales_Rep__c, Opportunity__r.Name, Opportunity__r.X18_Character_Opportunity_ID__c 
                from Commission__c where Id IN :setCommissionId];
                
        if(lstCommission != null && !lstCommission.isEmpty()){
            List<LGCY_API_Logs__c> lstAPILogs = new List<LGCY_API_Logs__c>();
            for(Commission__c objCommission : lstCommission){
                String jsonBody = JSON.serialize(objCommission);
                HttpResponse objHttpResponse = sendData(System.Label.LGCY_Endpoint, jsonBody, 'POST', null); 
                
                LGCY_API_Logs__c objAPILog = new LGCY_API_Logs__c();
                objAPILog.Commission__c = objCommission.Id;
                String responseBody = objHttpResponse.getBody();
                if(objHttpResponse.getStatusCode() == 200){
                    Map<String, Object> mapResponseParams = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                    if(mapResponseParams.containsKey('success') && String.valueOf(mapResponseParams.get('success')) == 'true'){
                        objAPILog.Status__c = 'Success';
                    } else{
                        objAPILog.Status__c = 'Fail';
                    }
                } else{
                    objAPILog.Status__c = 'Fail';
                    objAPILog.Error_Reason__c = responseBody;
                }
                
                lstAPILogs.add(objAPILog);
            }       
            
            if(!lstAPILogs.isEmpty())
                insert lstAPILogs;    
        }
    }
    
    @future(callout=true)
    public static void sendOrderStatus(Map<Id, String> mapOppIdToStatus)
    {
        Map<String, String> mapStatusToMilestoneField = new Map<String, String>();
        mapStatusToMilestoneField.put('contractSigned', 'Contract_Signed_Milestone__c');
        mapStatusToMilestoneField.put('contractReceived', 'Contract_Received_Milestone__c');
        mapStatusToMilestoneField.put('surveyCompleted', 'Site_Survey_Completed_Milestone__c');
        mapStatusToMilestoneField.put('engineeringDesignComplete', 'Design_Completed_Milestone__c');
        mapStatusToMilestoneField.put('permitReceived', 'Permit_Received_Milestone__c');
        mapStatusToMilestoneField.put('installStarted', 'Installation_Started_Milestone__c');
        mapStatusToMilestoneField.put('installComplete', 'Installation_Completed_Milestone__c');
        mapStatusToMilestoneField.put('townInspectionComplete', 'Inspection_Complete_Milestone__c');
        mapStatusToMilestoneField.put('permissionToOperateApproved', 'PTO_Complete_Milestone__c');
        mapStatusToMilestoneField.put('interconnectionSubmitted', 'Interconnection_Application_Submitted__c');
        mapStatusToMilestoneField.put('interconnectionApproved', 'Interconnection_Application_Approved__c');
        mapStatusToMilestoneField.put('installScheduled', 'Installation_Scheduled_Milestone__c');
        mapStatusToMilestoneField.put('installReady', 'Installation_Ready_Milestone__c');
    
        
        List<Project_Milestone__c> lstProjectMilestone = [SELECT Id, Contract_Signed_Milestone__c, Contract_Received_Milestone__c,
                Design_Queued_Milestone__c, Design_Completed_Milestone__c, Permit_Received_Milestone__c, Installation_Started_Milestone__c,
                Installation_Completed_Milestone__c, Inspection_Complete_Milestone__c, PTO_Complete_Milestone__c, Interconnection_Application_Submitted__c,
                Interconnection_Application_Approved__c, Installation_Scheduled_Milestone__c, Opportunity__c, Site_Survey_Completed_Milestone__c,Installation_Ready_Milestone__c
                FROM Project_Milestone__c WHERE Opportunity__c IN :mapOppIdToStatus.keyset()];
                
        if(lstProjectMilestone != null && !lstProjectMilestone.isEmpty()){
            List<LGCY_API_Logs__c> lstAPILogs = new List<LGCY_API_Logs__c>();
            Map<String, String> mapHeaderParams = new Map<String, String>();
            mapHeaderParams.put('api_key', System.Label.API_Key);
            mapHeaderParams.put('Content-Type','application/json');
            Map<String, Object> mapRequestParam;
            for(Project_Milestone__c objProjectMilestone : lstProjectMilestone){
                String orderStatus = mapOppIdToStatus.get(objProjectMilestone.Opportunity__c);
                String fieldAPI = mapStatusToMilestoneField.get(orderStatus);
                
                mapRequestParam = new Map<String, Object>();
                mapRequestParam.put('opportunityId', objProjectMilestone.Opportunity__c);
                mapRequestParam.put('orderStatus', orderStatus);
                mapRequestParam.put('timestamp', objProjectMilestone.get(fieldAPI));
                mapRequestParam.put('source', 'salesforce');
                String jsonBody = JSON.serialize(mapRequestParam);
                
                HttpResponse objHttpResponse = sendData(System.Label.ORDER_STATUS_API, jsonBody, 'POST', mapHeaderParams);
                LGCY_API_Logs__c objAPILog = new LGCY_API_Logs__c();
                objAPILog.Opportunity__c = objProjectMilestone.Opportunity__c;
                String responseBody = objHttpResponse.getBody();
                if(objHttpResponse.getStatusCode() == 200){
                    objAPILog.Status__c = 'Success';
                } else{
                    objAPILog.Status__c = 'Fail';
                    objAPILog.Error_Reason__c = responseBody;
                }
                
                lstAPILogs.add(objAPILog);
            }
            
            if(!lstAPILogs.isEmpty())
                insert lstAPILogs; 
        }
    }
    
    @future(callout=true)
    public static void sendOrderStatusFromOpp(Set<Id> setOppId)
    {            
        List<Opportunity> lstOpportunity = [SELECT Id FROM Opportunity WHERE Id IN :setOppId];
                
        if(lstOpportunity != null && !lstOpportunity.isEmpty()){
            List<LGCY_API_Logs__c> lstAPILogs = new List<LGCY_API_Logs__c>();
            Map<String, String> mapHeaderParams = new Map<String, String>();
            mapHeaderParams.put('api_key', System.Label.API_Key);
            mapHeaderParams.put('Content-Type','application/json');
            Map<String, Object> mapRequestParam;
            for(Opportunity objOpp : lstOpportunity){                
                mapRequestParam = new Map<String, Object>();
                mapRequestParam.put('opportunityId', objOpp.Id);
                mapRequestParam.put('orderStatus', 'systemActivated');
                mapRequestParam.put('timestamp', Datetime.now());
                mapRequestParam.put('source', 'salesforce');
                String jsonBody = JSON.serialize(mapRequestParam);
                
                HttpResponse objHttpResponse = sendData(System.Label.ORDER_STATUS_API, jsonBody, 'POST', mapHeaderParams);
                LGCY_API_Logs__c objAPILog = new LGCY_API_Logs__c();
                objAPILog.Opportunity__c = objOpp.Id;
                String responseBody = objHttpResponse.getBody();
                if(objHttpResponse.getStatusCode() == 200){
                    objAPILog.Status__c = 'Success';
                } else{
                    objAPILog.Status__c = 'Fail';
                    objAPILog.Error_Reason__c = responseBody;
                }
                
                lstAPILogs.add(objAPILog);
            }
            
            if(!lstAPILogs.isEmpty())
                insert lstAPILogs; 
        }
    }
    
    @future(callout=true)
    public static void sendJobAssignmentData(Set<Id> jobsAssignedToIds){
        TriggerConfiguration__c configJobAPI = TriggerConfiguration__c.getInstance('Job Assignment API Trigger');
        if(configJobAPI.Active__c){
            List<Job_Assigned_To__c> lstJobsAssignment = [SELECT Id, Capability__c, Job__c, Job__r.Name, Job__r.Opportunity__c, Job__r.Build_partner__c, Job__r.RecordType.Name, Vendor__c FROM Job_Assigned_To__c WHERE Id IN :jobsAssignedToIds];
                    
            if(lstJobsAssignment != null && !lstJobsAssignment.isEmpty()){
                List<LGCY_API_Logs__c> lstAPILogs = new List<LGCY_API_Logs__c>();
                Map<String, String> mapHeaderParams = new Map<String, String>();
                mapHeaderParams.put('api_key', System.Label.API_Key);
                mapHeaderParams.put('Content-Type','application/json');
                for(Job_Assigned_To__c objJobAssignment : lstJobsAssignment){
                    Map<String,String> jsonBody = new Map<String,String>();
                    jsonBody.put('opportunityId', objJobAssignment.Job__r.Opportunity__c);
                    jsonBody.put('jobId', objJobAssignment.Job__c);
                    jsonBody.put('jobName', objJobAssignment.Job__r.Name);
                    jsonBody.put('jobRecordType', objJobAssignment.Job__r.RecordType.Name);
                    jsonBody.put('capability', objJobAssignment.Capability__c);
                    jsonBody.put('assignedTo', objJobAssignment.Vendor__c);
    
                    String jsonString = JSON.serialize(jsonBody);
                    System.debug(jsonString);
    
                    HttpResponse objHttpResponse = sendData(System.Label.JOB_ASSIGNMENT_API, jsonString, 'POST', mapHeaderParams);
                    
                    LGCY_API_Logs__c objAPILog = new LGCY_API_Logs__c();
                    objAPILog.Opportunity__c = objJobAssignment.Job__r.Opportunity__c;
                    String responseBody = objHttpResponse.getBody();
                    if(objHttpResponse.getStatusCode() == 200){
                        objAPILog.Status__c = 'Success';
                    } else{
                        objAPILog.Status__c = 'Fail';
                        objAPILog.Error_Reason__c = responseBody;
                    }
                    lstAPILogs.add(objAPILog);
                }
                if(!lstAPILogs.isEmpty()){
                    insert lstAPILogs;
                }
            }
        }
    }

    @future(callout=true)
    public static void sendJobData(Set<Id> jobsIds){
        TriggerConfiguration__c configJobAPI = TriggerConfiguration__c.getInstance('Job Assignment API Trigger');
        if(configJobAPI.Active__c){
            List<Job__c> lstJobs = [SELECT Id, Opportunity__c, Name, RecordTypeId, Build_Partner__c, RecordType.Name FROM Job__c WHERE Id IN :jobsIds];
            if(lstJobs != null && !lstJobs.isEmpty()){
                Map<Id,String> capabilityMap = new Map<Id,String>();
                capabilityMap.put(Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('HOA').getRecordTypeId(),'Sales');
                capabilityMap.put(Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Permitting').getRecordTypeId(),'Permitting');
                capabilityMap.put(Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Installation Scheduling').getRecordTypeId(),'Installation');
                capabilityMap.put(Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Inspection').getRecordTypeId(),'Inspection');
                capabilityMap.put(Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Job Close Out').getRecordTypeId(),'Inspection');
                capabilityMap.put(Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Site Approval').getRecordTypeId(),'Site Survey');
                capabilityMap.put(Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Site Survey').getRecordTypeId(),'Site Survey');
    
                List<LGCY_API_Logs__c> lstAPILogs = new List<LGCY_API_Logs__c>();
                Map<String, String> mapHeaderParams = new Map<String, String>();
                mapHeaderParams.put('api_key', System.Label.API_Key);
                mapHeaderParams.put('Content-Type','application/json');
                for(Job__c objJob : lstJobs){
                    Map<String,String> jsonBody = new Map<String,String>();
    
                    jsonBody.put('opportunityId', objJob.Id);
                    jsonBody.put('jobId', objJob.Opportunity__c);
                    jsonBody.put('jobName', objJob.Name);
                    jsonBody.put('jobRecordType', objJob.RecordType.Name);
                    jsonBody.put('capability', capabilityMap.containsKey(objJob.RecordTypeId) ? capabilityMap.get(objJob.RecordTypeId) : '');
                    jsonBody.put('assignedTo', objJob.Build_Partner__c);
    
                    String jsonString = JSON.serialize(jsonBody);
                    System.debug(jsonString);
    
                    HttpResponse objHttpResponse = sendData(System.Label.JOB_ASSIGNMENT_API, jsonString, 'POST', mapHeaderParams);
                    
                    LGCY_API_Logs__c objAPILog = new LGCY_API_Logs__c();
                    objAPILog.Opportunity__c = objJob.Opportunity__c;
                    String responseBody = objHttpResponse.getBody();
                    if(objHttpResponse.getStatusCode() == 200){
                        objAPILog.Status__c = 'Success';
                    } else{
                        objAPILog.Status__c = 'Fail';
                        objAPILog.Error_Reason__c = responseBody;
                    }
                    lstAPILogs.add(objAPILog);
                }
                if(!lstAPILogs.isEmpty()){
                    insert lstAPILogs;
                }
            }
        }
    }
    
    @future(callout=true)
    public static void sendCaseAssignmentData(Set<Id> casesAssignedToIds){
        TriggerConfiguration__c configCaseAPI = TriggerConfiguration__c.getInstance('Case Assignment API Trigger');
        if(configCaseAPI.Active__c){

            List<Case_Assigned_To__c> lstCasesAssignment = [SELECT Id, Capability__c, Case__c, Case__r.CaseNumber, Case__r.Opportunity__c, Case__r.RecordType.Name, Vendor__c FROM Case_Assigned_To__c WHERE Id IN :casesAssignedToIds];
                    
            if(lstCasesAssignment != null && !lstCasesAssignment.isEmpty()){
                List<LGCY_API_Logs__c> lstAPILogs = new List<LGCY_API_Logs__c>();
                Map<String, String> mapHeaderParams = new Map<String, String>();
                mapHeaderParams.put('api_key', System.Label.API_Key);
                mapHeaderParams.put('Content-Type','application/json');
                for(Case_Assigned_To__c objCaseAssignment : lstCasesAssignment){
                    Map<String,String> jsonBody = new Map<String,String>();
                    jsonBody.put('opportunityId', objCaseAssignment.Case__r.Opportunity__c);
                    jsonBody.put('caseId', objCaseAssignment.Case__c);
                    jsonBody.put('caseCaseNumber', objCaseAssignment.Case__r.CaseNumber);
                    jsonBody.put('caseRecordType', objCaseAssignment.Case__r.RecordType.Name);
                    jsonBody.put('capability', objCaseAssignment.Capability__c);
                    jsonBody.put('assignedTo', objCaseAssignment.Vendor__c);
    
                    String jsonString = JSON.serialize(jsonBody);
                    System.debug(jsonString);
    
                    HttpResponse objHttpResponse = sendData(System.Label.CASE_ASSIGNMENT_API, jsonString, 'POST', mapHeaderParams);
                    
                    LGCY_API_Logs__c objAPILog = new LGCY_API_Logs__c();
                    objAPILog.Opportunity__c = objCaseAssignment.Case__r.Opportunity__c;
                    String responseBody = objHttpResponse.getBody();
                    if(objHttpResponse.getStatusCode() == 200){
                        objAPILog.Status__c = 'Success';
                    } else{
                        objAPILog.Status__c = 'Fail';
                        objAPILog.Error_Reason__c = responseBody;
                    }
                    lstAPILogs.add(objAPILog);
                }
                if(!lstAPILogs.isEmpty()){
                    insert lstAPILogs;
                }
            }
        }
    }
}