global  class CommissionToBeProcessedSchedular implements Schedulable {

    global void execute(SchedulableContext ctx) {

        Datetime dt = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        String day_of_week=dt.format('EEEE');
        
        if(day_of_week == 'Tuesday' || Test.isRunningTest())
        {
            CommissionHandler.ProcessM1MileStone();
            CommissionHandler.ProcessM2MileStone();
            CommissionHandler.ProcessM3MileStone();
            CommissionHandler.ProcessClawBackMileStone();
        }        
        if(day_of_week == 'Friday' || test.isRunningTest())
        {
            CommissionHandler.ProcessM1MileStone();
            CommissionHandler.ProcessM2MileStone();
            CommissionHandler.ProcessM3MileStone();
            CommissionHandler.ProcessClawBackMileStone();
        }
    }
}