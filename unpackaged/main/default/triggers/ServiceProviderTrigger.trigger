trigger ServiceProviderTrigger on dispconn__Service_Provider__c (after insert) {
    ServiceProviderHandler objHandler = new ServiceProviderHandler();
    if(trigger.isAfter && trigger.isInsert)
        objHandler.onAfterInsert(trigger.new);
}