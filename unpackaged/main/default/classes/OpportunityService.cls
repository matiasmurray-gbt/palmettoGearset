public class OpportunityService
{
    public static void refreshCommission(Set<Id> setOppId){
        List<Commission__c> lstCommissionToUpdate = new List<Commission__c>();
        for(Commission__c objCommission : [
                SELECT Id, X5_Watt_Total_Commissions_Value__c, X5_Watt_Total_Commissions__c, Total_Commissions__c, X5_watt_M1_Amount__c,
                Opportunity__r.StageName, M1_Clawback_Applied_Paid__c, Milestone_1_Amount_Actual_Paid__c, M1_Clawback_Complete__c,
                Lead_Source_Type__c, Total_Commissions_Value__c, Commission_Plan__r.Milestone_1_Percent__c, Balance_Due_Commissions__c,
                CP_Base_5kW_Program__c, CP_Base_6kW_Program__c, Dividend_Dealer_Fees__c, IA_M3_Paid__c, IA_M1_Amount__c, IA_M2_Amount__c,
                IA_M3_Amount__c, IA_Total_Commisions__c, IA_M1_Paid__c, IA_M2_Paid__c, Loan_Pal__c, Milestone_2_Paid__c,
                Opportunity__r.Financing_Tool__c, Opportunity__r.Contract_Received_Confirmed_Date__c, Loan_Pal_Dealer_Fees__c,
                Process_Early_M3_Payment__c, Milestone_3_Amount__c
                FROM Commission__c 
                WHERE Opportunity__c IN :setOppId])
        {
            objCommission.X5_Watt_Total_Commissions_Value__c = objCommission.X5_Watt_Total_Commissions__c;
            objCommission.Total_Commissions_Value__c = objCommission.Total_Commissions__c;
            objCommission.X5_watt_M1_Value__c = objCommission.X5_watt_M1_Amount__c;
            objCommission.CP_Base_5kW_Program_Value__c = objCommission.CP_Base_5kW_Program__c;
            objCommission.CP_Base_6kW_Program_Value__c = objCommission.CP_Base_6kW_Program__c;
            objCommission.Dividend_Dealer_Value__c = objCommission.Dividend_Dealer_Fees__c;
            objCommission.Loan_Pal_Dealer_Value__c = objCommission.Loan_Pal_Dealer_Fees__c;
            
            if(objCommission.Opportunity__r.StageName == 'Cancelled'){
                objCommission.M1_Clawback_Amount__c = objCommission.Milestone_1_Amount_Actual_Paid__c;
            }
            if(objCommission.M1_Clawback_Applied_Paid__c == true && 
                (objCommission.Opportunity__r.StageName == 'Cancelled' || objCommission.Opportunity__r.StageName == '9. Change Order Pending') )
            {
                objCommission.Milestone_1_Amount_Actual_Paid__c = null;
            }
            if(objCommission.M1_Clawback_Complete__c == true && objCommission.M1_Clawback_Applied_Paid__c == false &&
                (objCommission.Opportunity__r.StageName == 'Cancelled' || objCommission.Opportunity__r.StageName == '9. Change Order Pending') )
            {
                objCommission.Clawback_Amount_Actual__c = objCommission.Milestone_1_Amount_Actual_Paid__c;
            }
            if(objCommission.Lead_Source_Type__c == 'Channel'){
                objCommission.CP_Milestone_1_Value__c = (objCommission.Total_Commissions_Value__c == null?0:objCommission.Total_Commissions_Value__c) * (objCommission.Commission_Plan__r.Milestone_1_Percent__c == null?0:objCommission.Commission_Plan__r.Milestone_1_Percent__c);
                objCommission.Commissions_Payable_Value__c = objCommission.Balance_Due_Commissions__c;
            }
            if(objCommission.IA_M3_Paid__c == true){
                //objCommission.IA_M3_Paid_Date__c = Date.today();
            }
            if(objCommission.Lead_Source_Type__c == 'Independent'){
                objCommission.IA_M1_Amount_Value__c = objCommission.IA_M1_Amount__c;
                objCommission.IA_M2_Amount_Value__c = objCommission.IA_M2_Amount__c;
                objCommission.IA_M3_Amount_Value__c = objCommission.IA_M3_Amount__c;
                objCommission.IA_Total_Commissions_Value__c = objCommission.IA_Total_Commisions__c;
                objCommission.Commissions_Payable_Value__c = objCommission.Balance_Due_Commissions__c;
            }
            if(objCommission.IA_M1_Paid__c == true){
                //objCommission.IA_M1_Paid_Date__c = Date.today();
            }
            if(objCommission.IA_M2_Paid__c == true){
                //objCommission.IA_M2_Paid_Date__c = Date.today();
            }
            
            if(objCommission.Milestone_2_Paid__c == true && (objCommission.Opportunity__r.Financing_Tool__c == 'Loan Pal' || objCommission.Opportunity__r.Financing_Tool__c == 'Loanpal')
                && objCommission.Opportunity__r.Contract_Received_Confirmed_Date__c <= Date.newInstance(2019, 3, 15))
            {
                objCommission.Milestone_3_Processed__c = true;
                objCommission.Milestone_3_Paid__c = true;
            }
            
            if(objCommission.M1_Clawback_Complete__c == true && (objCommission.Loan_Pal__c == 'Loan Pal' || objCommission.Loan_Pal__c == 'Loanpal') &&
                objCommission.Milestone_1_Amount_Actual_Paid__c == null)
            {
                objCommission.M1_Clawback_Applied_Paid__c = true;
            }
            
            if(objCommission.M1_Clawback_Complete__c == true){
                //objCommission.M1_Clawback_Processed_Date__c = Date.today();
            }
                       
            if(objCommission.Process_Early_M3_Payment__c == true){
                objCommission.M3_Early_Payment_Fee__c = (0.1 * (objCommission.Balance_Due_Commissions__c == null?0:objCommission.Balance_Due_Commissions__c));
                objCommission.Milestone_3_Processed__c = true;
                objCommission.Milestone_3_Actual_Paid__c = objCommission.Milestone_3_Amount__c;
                //objCommission.Milestone_3_Processed_Date__c = Date.today();
            }
             
                
            lstCommissionToUpdate.add(objCommission);
        }
        
        if(!lstCommissionToUpdate.isEmpty())
            update lstCommissionToUpdate;
    }
}