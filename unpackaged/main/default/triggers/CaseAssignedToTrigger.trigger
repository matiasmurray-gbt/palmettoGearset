trigger CaseAssignedToTrigger on Case_Assigned_To__c (before insert, before update,after insert,after update) {
    CaseAssignedToHandler objHandler = new CaseAssignedToHandler();
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            objHandler.onBeforeInsert(Trigger.new);
        }else if(Trigger.isUpdate){
            objHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }else{
        if(Trigger.isInsert){
            objHandler.onAfterInsert(Trigger.new);
        }else if(Trigger.isUpdate){
            objHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}