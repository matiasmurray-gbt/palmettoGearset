trigger CommissionTrigger on Commission__c (after update) {
    
    CommissionTriggerHandler objHandler = new CommissionTriggerHandler();
    if(trigger.isAfter && trigger.isUpdate){
        objHandler.onAfterUpdate(trigger.new, trigger.oldMap);
    }
}