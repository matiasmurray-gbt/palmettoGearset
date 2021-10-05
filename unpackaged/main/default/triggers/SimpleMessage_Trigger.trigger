trigger SimpleMessage_Trigger on simplesms__SMS_Message__c (before insert, after insert,
        before update, after update,
        before delete, after delete) {
            
            if (trigger.isAfter) {
        if (trigger.isInsert || trigger.isUpdate) {
           SimpleSMSMessage_TriggerHandler.updateSMSmessage(trigger.new);
            
                             } 

                                  }
       }