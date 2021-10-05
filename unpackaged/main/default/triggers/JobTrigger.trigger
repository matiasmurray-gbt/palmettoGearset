trigger JobTrigger on Job__c (before insert, before update, after insert, after update) {
    JobHandler objHandler = new JobHandler();
    if(trigger.isBefore && trigger.isInsert)
        objHandler.onBeforeInsert(trigger.new);
    if(trigger.isBefore && trigger.isUpdate)
        objHandler.onBeforeUpdate(trigger.new, trigger.oldMap);
    if(trigger.isAfter && trigger.isInsert)
        objHandler.onAfterInsert(trigger.new);
    if(trigger.isAfter && trigger.isUpdate)
        objHandler.onAfterUpdate(trigger.new, trigger.oldMap);
}