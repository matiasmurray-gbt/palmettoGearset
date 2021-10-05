@isTest
private class testLeadEventProcess {
   
   @testSetup static void setupUpdateLeads() {
       List<lead> leadList = New List<lead>();
           for(integer i = 1; i < 101; i++){
               leadlist.add(
                   new lead(
                       company='update test account ' + i,
                       phone='555-555-5555',
                       street='123 Anywhere',
                       lastName = 'udtestingName' + i,
                       Appointment_Date_and_Time__c = system.now().addDays(i),
                       Customer_Type__c = 'Utility - Customer'
                   )
               
               );
           } 
       insert leadlist;
   }


    static testMethod void testInsert(){
       Test.startTest();
       List<lead> leadList = New List<lead>();
           for(integer i = 1; i < 101; i++){
               leadlist.add(
                   new lead(
                       company='testing account ' + i,
                       phone='555-555-5555',
                       street='123 Anywhere',
                       lastName = 'testingName' + i,
                       Appointment_Date_and_Time__c = system.now().addDays(i),
                       Customer_Type__c = 'Utility - Customer'
                   )
               
               );
           } 
       insert leadlist;
       Test.stopTest();
       
   
   }
   
   static testMethod void testupdate(){
       
       List<lead> leadList = New List<lead>([Select Id, company, lastName, Appointment_Date_and_Time__c, Customer_Type__c from Lead where lastName like '%udtestingName%']);
            
       Test.startTest();
       for(lead l : leadlist){
           l.Appointment_Date_and_Time__c = l.Appointment_Date_and_Time__c.addHours(1);
       }
       update leadlist;
       Test.stopTest();
       
   
   }
   
   static testMethod void testupdateB(){
       
       List<lead> leadList = New List<lead>();
           for(integer i = 1; i < 101; i++){
               leadlist.add(
                   new lead(
                       company='testing account ' + i,
                       phone='555-555-5555',
                       street='123 Anywhere',
                       lastName = 'testingName' + i,
                       Customer_Type__c = 'Utility - Customer'
                   )
               
               );
       } 
       insert leadlist;
       Test.startTest();
       for(lead l : leadlist){
           l.Appointment_Date_and_Time__c = system.now().addDays(2);
       }
       update leadlist;
       Test.stopTest();
       
   
   }
   
}