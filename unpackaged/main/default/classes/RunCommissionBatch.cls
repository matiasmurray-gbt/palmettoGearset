public class RunCommissionBatch
{
    public RunCommissionBatch(){}
    
    public void runBatch(){
        try {
            CommissionPlanMapingHandler.assignCommissionToOpportunity();
        }
        finally{
            CommissionPlanMapingHandler.abortAllDeleted();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Commission Batch Executed Successfully'));
        }
    }
}