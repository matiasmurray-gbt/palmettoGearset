trigger OpportunityTrigger on Opportunity (before insert, before update, after update, after insert) {
    OpportunityHandler objHandler = new OpportunityHandler();
    if(trigger.isBefore && trigger.isInsert)
        objHandler.onBeforeInsert(trigger.new);
    else if(trigger.isBefore && trigger.isUpdate)
        objHandler.onBeforeUpdate(trigger.new, trigger.oldMap);
    else if(trigger.isAfter && trigger.isInsert)
        objHandler.onAfterInsert(trigger.new);
    else if(trigger.isAfter && trigger.isUpdate)
        objHandler.onAfterUpdate(trigger.new, trigger.oldMap);
}