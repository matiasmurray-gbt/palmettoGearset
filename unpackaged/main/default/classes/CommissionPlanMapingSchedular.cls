global class CommissionPlanMapingSchedular implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        try {
            CommissionPlanMapingHandler.assignCommissionToOpportunity();
        }
        finally {
            CommissionPlanMapingHandler.abortAllDeleted();
        }
    }
}