@isTest
public class SimpleSMSMessage_TestClass {
    
    public static testmethod void OpportunityUpdate()
    {
        Opportunity Opp = new Opportunity(Name = 'TestOpportunity',CloseDate =Date.newInstance(2021,01,01),StageName = 'CR2 - Qualified Lead - Interested',Customer_Satisfaction__c = Null);
        insert Opp;
        simplesms__SMS_Message__c sms1 = new simplesms__SMS_Message__c(simplesms__Message_Date__c = Date.newInstance(2021,01,01),simplesms__Type__c ='Incoming',simplesms__Message__c = '1',
                                                                     simplesms__Opportunity__c = Opp.id);
        insert sms1;
        Opp = [Select Customer_Satisfaction__c from Opportunity where id =: Opp.Id];
        //system.assertEquals('Very Dissatisfied',Opp.Customer_Satisfaction__c);
        simplesms__SMS_Message__c sms2 = new simplesms__SMS_Message__c(simplesms__Message_Date__c = Date.newInstance(2021,01,01),simplesms__Type__c ='Incoming',simplesms__Message__c = '2',
                                                                     simplesms__Opportunity__c = Opp.id);
        insert sms2;
        Opp = [Select Customer_Satisfaction__c from Opportunity where id =: Opp.Id];
        //system.assertEquals('Dissatisfied', Opp.Customer_Satisfaction__c);
        simplesms__SMS_Message__c sms3 = new simplesms__SMS_Message__c(simplesms__Message_Date__c = Date.newInstance(2021,01,01),simplesms__Type__c ='Incoming',simplesms__Message__c = '3',
                                                                     simplesms__Opportunity__c = Opp.id);
        insert sms3;
        Opp = [Select Customer_Satisfaction__c from Opportunity where id =: Opp.Id];
       // system.assertEquals('Neutral', Opp.Customer_Satisfaction__c);
        simplesms__SMS_Message__c sms4 = new simplesms__SMS_Message__c(simplesms__Message_Date__c = Date.newInstance(2021,01,01),simplesms__Type__c ='Incoming',simplesms__Message__c = '4',
                                                                     simplesms__Opportunity__c = Opp.id);
        insert sms4;
        Opp = [Select Customer_Satisfaction__c from Opportunity where id =: Opp.Id]; 
        //system.assertEquals('Satisfied', Opp.Customer_Satisfaction__c);
        simplesms__SMS_Message__c sms5 = new simplesms__SMS_Message__c(simplesms__Message_Date__c = Date.newInstance(2021,01,01),simplesms__Type__c ='Incoming',simplesms__Message__c = '5',
                                                                     simplesms__Opportunity__c = Opp.id);
    	insert sms5;
        Opp = [Select Customer_Satisfaction__c from Opportunity where id =: Opp.Id];
       // system.assertEquals('Very Satisfied', Opp.Customer_Satisfaction__c);
    }

}