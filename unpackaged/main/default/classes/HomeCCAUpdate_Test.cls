@isTest
private class HomeCCAUpdate_Test{
  @testSetup
  static void setupTestData(){
    test.startTest();
    Contact contact_Obj = new Contact(LastName = 'LastName524', HasOptedOutOfEmail = false, HasOptedOutOfFax = false, DoNotCall = false, May_Contact_Customer_After_6_PM__c = false, LinkedIn_Profile_Recorded__c = false, simplesms__DoNotSMS__c = false, Undeliverable_Email__c = false, Bad_Phone_Number__c = false, Opportunity_Fields_are_Completed__c = false);
    Insert contact_Obj; 
    
    Opportunity opportunity_Obj = new Opportunity(RecordTypeId = '0121a000000AWlj',Name = 'Name471', StageName = 'EM4 Payment/Contract Received', CloseDate = Date.today(), LeadSource = 'Energy Monitor', System_Installed__c = false, Contract_Signed__c = false, Contact__c = contact_Obj.id, Financier_Milestone1_Submitted__c = false, SA_Approved__c = false, X1_Mo_Utility_Bill__c = false, Homeowner_Install_Agreement_Signed__c = false, Net_Metering_Application__c = false, CA_Submitted_to_CPF__c = false, Test_Account__c = false, Net_Metering_Application_to_Utility__c = false, Signed_NMA_Rec_d__c = false, Permit_and_Site_Plan_to_Installers__c = false, String_Map_Complete__c = false, Milestone_Payment_1_Complete__c = false, IC_Approved__c = false, Attic_Photos__c = false, Inspection_Scheduled__c = false, Inspection_Comp_Permit_Closed__c = false, Electric_Panel_Photos__c = false, Utility_Rec_d_Permit_NM_Install_Sched__c = false, PTO_Net_Meter_Installed__c = false, Roof_Photos__c = false, System_Activation_Submitted_to_CPF__c = false, Site_Audit_Completed__c = false, Install_Completed__c = false, Dividend_Energy_Efficiency_Option__c = false, Electrical_Photos__c = false, Panel_Serial_Numbers__c = false, Inverter_Serial_Numbers__c = false, Project_On_Hold__c = false, Referral_Gift_Sent__c = false, Contract_Sent__c = false, Schedule_System_Activation_Walk_Through__c = false, Confirmation_Call_Completed__c = false, Appointment_Set__c = false, System_Activation_Walk_Through_Complete__c = false,   Interconnection_Sent__c = false, Interconnection_Agreement_Received__c = false, Partner_Account_Manager_Milestone_1__c = false, Copy_Drivers_License__c = false, Installation_Complete__c = false, Current_Energy_Usage_Input__c = false, Site_Estimated__c = false, Customer_Eligibility_Checked__c = false, Homeowners_Insurance_Docs_Attached__c = false, System_Price_Documented__c = false, Partner_Account_Manager_Milestone_2__c = false, System_Info_Match_Confirmed__c = false, W_9_Recieved_South_Carolina__c = false, Proposal_Created__c = false, Permits_Approved_For_Payment__c = false, Invoices_Ready_To_Send__c = false, Job_Invoice_Sent__c = false, Monitoring_Activated__c = false, Permit_Paid__c = false, New_Customer_Welcome_Call_Completed__c = false, HOA_Application_Fee_Approved_For_Pmt__c = false, Send_Automated_Review_Email__c = false, Site_Needs_Verification__c = false,HOA_Application_Sent__c = false, Cancel_Confirm_Operations__c = false, Cancel_Confirm_Accounting__c = false, Solar_Market_Confirmed__c = false, Cancel_Confirm_Direct_Channel_Sales__c = false, Interconnection_Kickback__c = false, HOA_Signature_Request__c = false, Revenue_Record_in_QB__c = false, Solar_Eligibility__c = false, Monitoring_Access_Sent_to_Customer__c = false, Installation_Field_Error__c = false, Photo__c = false, Inverter_Electrical_Meter_Pics_Attached__c = false, Conduit_Run_Through_Attic__c = false, Pre_Install_Payment_Received__c = false, Post_Install_Payment_Received__c = false, Final_Install_Payment_Received__c = false,  Installation_Field_Error_Resolved__c = false, Equipment_Ordered__c = false, Change_Order_Redesign_Complete__c = false, CEC_Application_submitted__c = false, Net_Meter_App_Received_By_Uitlity__c = false, LOI_Design_Confirmed__c = false, LOI_Field_Site_Audit_Required__c = false, Appointment_Rescheduled__c = false, Engineering_Created__c = false, Contract_Received_Confirmed__c = false, HOA_Approved__c = false, Warranty_Sun_Systems__c = false, ICA_Signature_Requested__c = false);
    Insert opportunity_Obj;
    
    
         String uniqueUserName = 'standarduserGFASFa@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User user_Obj = new User(Alias = 'standt', Email='standardus123123er@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',UserName=uniqueUserName);
        Insert user_Obj;     
    
    test.stopTest();
  }


  static testMethod void testCCUpdate_UseCase1(){
    // Set mock callout class 
    Test.startTest();
    List<Opportunity> opportunity_Obj  =  [SELECT RecordTypeId,Name,StageName,CloseDate,LeadSource,System_Installed__c,Contract_Signed__c,Contact__c,Financier_Milestone1_Submitted__c,SA_Approved__c,X1_Mo_Utility_Bill__c,Homeowner_Install_Agreement_Signed__c,Net_Metering_Application__c,CA_Submitted_to_CPF__c,Test_Account__c,Net_Metering_Application_to_Utility__c,Signed_NMA_Rec_d__c,Permit_and_Site_Plan_to_Installers__c,String_Map_Complete__c,Milestone_Payment_1_Complete__c,IC_Approved__c,Attic_Photos__c,Inspection_Scheduled__c,Inspection_Comp_Permit_Closed__c,Electric_Panel_Photos__c,Utility_Rec_d_Permit_NM_Install_Sched__c,PTO_Net_Meter_Installed__c,Roof_Photos__c,System_Activation_Submitted_to_CPF__c,Site_Audit_Completed__c,Install_Completed__c,Dividend_Energy_Efficiency_Option__c,Electrical_Photos__c,Panel_Serial_Numbers__c,Inverter_Serial_Numbers__c,Project_On_Hold__c,Referral_Gift_Sent__c,Contract_Sent__c,Schedule_System_Activation_Walk_Through__c,Confirmation_Call_Completed__c,Appointment_Set__c,System_Activation_Walk_Through_Complete__c,Interconnection_Sent__c,Interconnection_Agreement_Received__c,Partner_Account_Manager_Milestone_1__c,Copy_Drivers_License__c,Installation_Complete__c,Current_Energy_Usage_Input__c,Site_Estimated__c,Customer_Eligibility_Checked__c,Homeowners_Insurance_Docs_Attached__c,System_Price_Documented__c,Partner_Account_Manager_Milestone_2__c,System_Info_Match_Confirmed__c,W_9_Recieved_South_Carolina__c,Proposal_Created__c,Permits_Approved_For_Payment__c,Invoices_Ready_To_Send__c,Job_Invoice_Sent__c,Monitoring_Activated__c,Permit_Paid__c,New_Customer_Welcome_Call_Completed__c,HOA_Application_Fee_Approved_For_Pmt__c,Send_Automated_Review_Email__c,Site_Needs_Verification__c,HOA_Application_Sent__c,Cancel_Confirm_Operations__c,Cancel_Confirm_Accounting__c,Solar_Market_Confirmed__c,Cancel_Confirm_Direct_Channel_Sales__c,Interconnection_Kickback__c,HOA_Signature_Request__c,Revenue_Record_in_QB__c,Solar_Eligibility__c,Monitoring_Access_Sent_to_Customer__c,Installation_Field_Error__c,Photo__c,Inverter_Electrical_Meter_Pics_Attached__c,Conduit_Run_Through_Attic__c,Pre_Install_Payment_Received__c,Post_Install_Payment_Received__c,Final_Install_Payment_Received__c,Installation_Field_Error_Resolved__c,Equipment_Ordered__c,Change_Order_Redesign_Complete__c,CEC_Application_submitted__c,Net_Meter_App_Received_By_Uitlity__c,LOI_Design_Confirmed__c,LOI_Field_Site_Audit_Required__c,Appointment_Rescheduled__c,Engineering_Created__c,Contract_Received_Confirmed__c,HOA_Approved__c,Warranty_Sun_Systems__c from Opportunity];
    System.assertEquals(true,opportunity_Obj.size()>0);

    List<Contact> contact_Obj  =  [SELECT Id,LastName,HasOptedOutOfEmail,HasOptedOutOfFax,DoNotCall,May_Contact_Customer_After_6_PM__c,LinkedIn_Profile_Recorded__c,simplesms__DoNotSMS__c,Undeliverable_Email__c,Bad_Phone_Number__c,Opportunity_Fields_are_Completed__c from Contact];
    System.assertEquals(true,contact_Obj.size()>0);

    List<User> user_Obj  =  [SELECT Id, MobilePhone,FullPhotoUrl,Email FROM User];
    System.assertEquals(true,user_Obj.size()>0);


    //HttpResponse res = HomeCustomerUpdate.getInfoFromExternalService('test data');

    HomeCCAUpdate obj01 = new HomeCCAUpdate();    
    HomeCCAUpdate.SendEmail('test data');
    Test.setMock(HttpCalloutMock.class, new HomeMockHttpResponseGenerator());
    
    HomeCCAUpdate.CCAUpdate('005q00000050bZE');
    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setBody('{"status":true,"code":1,"message":"Success.","result":"0030U000006LwFTQA0"}');
    res.setStatusCode(200);

//    HomeCCAUpdate.CheckResponse('status', res);
    Test.stopTest();
  }
  
  
}