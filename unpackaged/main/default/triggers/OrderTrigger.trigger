trigger OrderTrigger on Order (before insert) {
    OrderHandler objHandler = new OrderHandler();
    if(trigger.isBefore && trigger.isInsert)
        objHandler.onBeforeInsert(trigger.new);
}