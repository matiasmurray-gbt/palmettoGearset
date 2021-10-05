trigger ProjectMilestoneTrigger on Project_Milestone__c (before update, after update) {
    RadiusHandler objHandler = new RadiusHandler();
    if(trigger.isBefore && trigger.isUpdate)
        objHandler.onBeforeUpdate(trigger.new, trigger.oldMap);
    if(trigger.isAfter && trigger.isUpdate)
        objHandler.onAfterUpdate(trigger.new, trigger.oldMap);
}