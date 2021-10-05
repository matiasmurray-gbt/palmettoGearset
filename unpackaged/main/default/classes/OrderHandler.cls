public class OrderHandler
{
    //This method is called on before insert event of trigger.
    public void onBeforeInsert(List<Order> lstOrder){
        populateFields(lstOrder);
    }
    
    //This method is used to populate the fields.
    private void populateFields(List<Order> lstOrder){
        Map<Id, Opportunity> mapIdToOpp = new Map<Id, Opportunity>();
        for(Order objOrder : lstOrder){
            if(objOrder.OpportunityId != null){
                mapIdToOpp.put(objOrder.OpportunityId, null);
            }
        }
        
        if(!mapIdToOpp.isEmpty()){
            
            for(Opportunity objOpp : [
                    SELECT Id, Amount, Customer_Name__c, Address__c,
                        (SELECT Id, Installation_Start_Date__c, Installation_Complete_Date__c 
                        FROM Jobs__r
                        WHERE RecordType.DeveloperName = 'Installation_Scheduling')
                    FROM Opportunity
                    WHERE Id IN :mapIdToOpp.keyset()])
            {
                mapIdToOpp.put(objOpp.Id, objOpp);
            }
            
            
            for(Order objOrder : lstOrder){
                if(objOrder.OpportunityId != null && mapIdToOpp.get(objOrder.OpportunityId) != null){
                    Opportunity objOpp = mapIdToOpp.get(objOrder.OpportunityId);
                    objOrder.Project_Price__c = objOpp.Amount;
                    objOrder.Customer_Name__c = objOpp.Customer_Name__c;
                    if(String.isNotBlank(objOpp.Address__c)){
                        String address = objOpp.Address__c.replaceAll('<br>', '\n');
                        objOrder.Project_Address__c = address;
                    }
                    
                    if(objOpp.Jobs__r != null && !objOpp.Jobs__r.isEmpty()){
                        Job__c objJob = objOpp.Jobs__r[0];
                        
                        objOrder.Project_Date__c = objJob.Installation_Start_Date__c;
                        objOrder.Guaranteed_Substantial_Completion_Date__c = objJob.Installation_Complete_Date__c;
                    }
                }
            }
        }
    }
}