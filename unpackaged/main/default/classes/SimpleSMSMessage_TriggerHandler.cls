/**
* @author Bhargav Rentala
* @date 2018
* @description Trigger Handler on SMS message object to update Opportunity records based on Incoming SMS message from Textey Application
*/

public class SimpleSMSMessage_TriggerHandler {
    public static void updateSMSmessage(List<simplesms__SMS_Message__c> SMSMessageUpdate)
    {
        Set<Id> SMSMessageId1 = new Set<Id>();
        Set<Id> SMSMessageId2 = new Set<Id>();
        Set<Id> SMSMessageId3 = new Set<Id>();
        Set<Id> SMSMessageId4 = new Set<Id>();
       Set<Id> SMSMessageId5 = new Set<Id>(); 
        List<Opportunity> OpportunityList = new List<Opportunity>();
        for(simplesms__SMS_Message__c SMSMessage:([select simplesms__Opportunity__c,simplesms__From_Phone__c,simplesms__Message__c,simplesms__SMS_Message__c.simplesms__Opportunity__r.Phone_Textey__c from simplesms__SMS_Message__c
              where id in : SMSMessageUpdate and simplesms__Type__c ='Incoming' and simplesms__Message__c != '' ]))
            {
           
                if(SMSMessage.simplesms__Message__c.contains('1')  )
                {
                    
              SMSMessageId1.add(SMSMessage.simplesms__Opportunity__c);
                }
               if(SMSMessage.simplesms__Message__c.contains('2')  )
                {
              SMSMessageId2.add(SMSMessage.simplesms__Opportunity__c);
                }
                 if(SMSMessage.simplesms__Message__c.contains('3')  )
                {
              SMSMessageId3.add(SMSMessage.simplesms__Opportunity__c);
                }
               if (SMSMessage.simplesms__Message__c.contains('4')  )
                {
              SMSMessageId4.add(SMSMessage.simplesms__Opportunity__c);
                    
                }
                if (SMSMessage.simplesms__Message__c.contains('5')  )
                {
              SMSMessageId5.add(SMSMessage.simplesms__Opportunity__c);
                }
                
            }
    
        for(Opportunity OpportunitySet1 : [select Customer_Satisfaction__c from Opportunity where id IN : SMSMessageId1])
        {
            OpportunitySet1.Customer_Satisfaction__c = 'Very Dissatisfied';
            OpportunityList.add(OpportunitySet1);
        }
        for(Opportunity OpportunitySet2 : [select Customer_Satisfaction__c from Opportunity where id IN : SMSMessageId2])
        {
            OpportunitySet2.Customer_Satisfaction__c = 'Dissatisfied';
            OpportunityList.add(OpportunitySet2);
        }
        for(Opportunity OpportunitySet3 : [select Customer_Satisfaction__c from Opportunity where id IN : SMSMessageId3])
        {
            OpportunitySet3.Customer_Satisfaction__c = 'Neutral';
            OpportunityList.add(OpportunitySet3);
        }
        for(Opportunity OpportunitySet4 : [select Customer_Satisfaction__c from Opportunity where id IN : SMSMessageId4])
        {
            OpportunitySet4.Customer_Satisfaction__c = 'Satisfied';
            OpportunityList.add(OpportunitySet4);
        }
        for(Opportunity OpportunitySet5 : [select Customer_Satisfaction__c from Opportunity where id IN : SMSMessageId5])
        {
            OpportunitySet5.Customer_Satisfaction__c = 'Very Satisfied';
            OpportunityList.add(OpportunitySet5);
        }
		Update OpportunityList;
       

    }

}