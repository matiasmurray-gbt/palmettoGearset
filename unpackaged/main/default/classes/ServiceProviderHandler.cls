public class ServiceProviderHandler
{
    //This method is called on after insert event of trigger.
    public void onAfterInsert(List<dispconn__Service_Provider__c> lstServiceProvider){
        createOperationInput(lstServiceProvider);
    }
    //This method is called to create operational input record.
    private void createOperationInput(List<dispconn__Service_Provider__c> lstServiceProvider){
        /*List<Operations_Input__c> lstOperationsInput = new List<Operations_Input__c>();
        for(dispconn__Service_Provider__c objServiceProvider : lstServiceProvider){
            Operations_Input__c objOperationsInput = new Operations_Input__c();
            objOperationsInput.Service_Agreement__c = objServiceProvider.Service_Agreement__c;
            lstOperationsInput.add(objOperationsInput);
        }
        
        if(!lstOperationsInput.isEmpty())
            insert lstOperationsInput;*/
    }
}