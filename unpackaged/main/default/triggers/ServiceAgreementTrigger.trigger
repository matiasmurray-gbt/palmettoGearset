trigger ServiceAgreementTrigger on Service_Agreement__c (after insert, after update) {
    ServiceAgreementHandler objHandler = new ServiceAgreementHandler();
    if(trigger.isAfter && trigger.isInsert)
        objHandler.onAfterInsert(trigger.new);
    if(trigger.isAfter && trigger.isUpdate)
        objHandler.onAfterUpdate(trigger.new, trigger.oldMap);
}