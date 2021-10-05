global class BatchToUpdateDealerProduct implements Database.Batchable<SObject>
{   
    /*****************Batchable Interface Methods*****************/
    global Database.QueryLocator start(Database.BatchableContext context) {
        String query = System.Label.Opp_Commission_Query;
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext context, List<Opportunity> lstOpp) 
    {    
        Set<String> setUniqueCombo = new Set<String>();
        Set<String> setCashUniqueCombo = new Set<String>();
        List<Opportunity> lstOppToProcess = new List<Opportunity>();
        List<Opportunity> lstCashOppToProcess = new List<Opportunity>();
        for(Opportunity objOpp : lstOpp){
            String uniqueCombo = objOpp.Financing_Tool__c + ':' + objOpp.APR__c + ':' +  objOpp.Loan_Term__c;
            if(String.isNotBlank(objOpp.Financing_Tool__c) && String.isNotBlank(objOpp.Location__c))
            {
                if(objOpp.Financing_Tool__c == 'Cash' || objOpp.Financing_Tool__c == 'SunRun' 
                            || objOpp.Financing_Tool__c == 'Sunnova Lease')
                {
                    lstCashOppToProcess.add(objOpp);
                    setCashUniqueCombo.add(objOpp.Financing_Tool__c);
                } else if(String.isNotBlank(objOpp.APR__c) && String.isNotBlank(objOpp.Loan_Term__c)){
                    lstOppToProcess.add(objOpp);
                    setUniqueCombo.add(uniqueCombo);
                }
            }
        }
        
        if(!lstOppToProcess.isEmpty()){
            List<Opportunity> lstOppToUpdate = new List<Opportunity>();
            Map<String, List<Dealer_Fee_Product__c>> mapUniqueComboToLstProduct = new Map<String, List<Dealer_Fee_Product__c>>();
            for(Dealer_Fee_Product__c objProduct : [SELECT Id, Unique_Combo__c, State__c, Classification__c, Start_Date__c, End_Date__c, Channel_Partner__c
                    FROM Dealer_Fee_Product__c
                    WHERE Unique_Combo__c IN :setUniqueCombo
                    ORDER BY Start_Date__c])
            {
                String uniqueCombo = objProduct.Unique_Combo__c;
                if(objProduct.Channel_Partner__c != null){
                    uniqueCombo += ':' + objProduct.Channel_Partner__c;
                }
                
                if(mapUniqueComboToLstProduct.containsKey(uniqueCombo)){
                    mapUniqueComboToLstProduct.get(uniqueCombo).add(objProduct);
                } else{
                    mapUniqueComboToLstProduct.put(uniqueCombo, new List<Dealer_Fee_Product__c>{objProduct});
                }
            }
            
            System.debug('>>>>>>>'+mapUniqueComboToLstProduct);
            for(Opportunity objOpp : lstOppToProcess){
                String uniqueCombo1 = objOpp.Financing_Tool__c + ':' + objOpp.APR__c + ':' +  objOpp.Loan_Term__c;
                String uniqueCombo2 = uniqueCombo1 + ':' + objOpp.Channel_Partner__c;
                Id internalDealerId;
                //Code to populate internal dealer.
                if(mapUniqueComboToLstProduct.containsKey(uniqueCombo2))
                    internalDealerId = populateDealerId(objOpp, mapUniqueComboToLstProduct.get(uniqueCombo2), 'Internal');
                if(internalDealerId == null && mapUniqueComboToLstProduct.containsKey(uniqueCombo1))
                    internalDealerId = populateDealerId(objOpp, mapUniqueComboToLstProduct.get(uniqueCombo1), 'Internal');
                
                if(internalDealerId != null){
                    objOpp.Internal_Dealer_Fee_Product2__c = internalDealerId;
                    lstOppToUpdate.add(objOpp);
                }
            }

            if(!lstOppToUpdate.isEmpty())
                update lstOppToUpdate;
        }
        
        //Code for Cash/Sunrun and Sunnova Lease Opps.
        if(!lstCashOppToProcess.isEmpty()){
            List<Opportunity> lstOppToUpdate = new List<Opportunity>();
            Map<String, List<Dealer_Fee_Product__c>> mapUniqueComboToLstProduct = new Map<String, List<Dealer_Fee_Product__c>>();
            for(Dealer_Fee_Product__c objProduct : [
                    SELECT Id, State__c, Classification__c, Start_Date__c, End_Date__c, Channel_Partner__c, Financing_Tool__c
                    FROM Dealer_Fee_Product__c
                    WHERE Financing_Tool__c IN :setCashUniqueCombo
                    ORDER BY Start_Date__c])
            {
                String uniqueCombo = objProduct.Financing_Tool__c;
                if(objProduct.Channel_Partner__c != null){
                    uniqueCombo += ':' + objProduct.Channel_Partner__c;
                }
                
                if(mapUniqueComboToLstProduct.containsKey(uniqueCombo)){
                    mapUniqueComboToLstProduct.get(uniqueCombo).add(objProduct);
                } else{
                    mapUniqueComboToLstProduct.put(uniqueCombo, new List<Dealer_Fee_Product__c>{objProduct});
                }
            }
            
            System.debug('>>>>>>>'+mapUniqueComboToLstProduct);
            for(Opportunity objOpp : lstCashOppToProcess){
                String uniqueCombo1 = objOpp.Financing_Tool__c;
                String uniqueCombo2 = uniqueCombo1 + ':' + objOpp.Channel_Partner__c;
                Id internalDealerId;
                //Code to populate internal dealer.
                if(mapUniqueComboToLstProduct.containsKey(uniqueCombo2))
                    internalDealerId = populateDealerId(objOpp, mapUniqueComboToLstProduct.get(uniqueCombo2), 'Internal');
                if(internalDealerId == null && mapUniqueComboToLstProduct.containsKey(uniqueCombo1))
                    internalDealerId = populateDealerId(objOpp, mapUniqueComboToLstProduct.get(uniqueCombo1), 'Internal');
                
                if(internalDealerId != null){
                    objOpp.Internal_Dealer_Fee_Product2__c = internalDealerId;
                    lstOppToUpdate.add(objOpp);
                }
            }

            if(!lstOppToUpdate.isEmpty())
                update lstOppToUpdate;
        }
    }

    //This method is used to find out the dealer fee commission record.
    private Id populateDealerId(Opportunity objOpp, List<Dealer_Fee_Product__c> lstProduct, String classification){
        Id dealerId;
        for(Dealer_Fee_Product__c objProduct : lstProduct){
            if(String.isNotBlank(objProduct.State__c) && objProduct.State__c.containsIgnoreCase(objOpp.Location__c)){
                if(((objProduct.Start_Date__c == null || objProduct.Start_Date__c <= objOpp.Contract_Received_Date__c) && (objProduct.End_Date__c == null || objProduct.End_Date__c >= objOpp.Contract_Received_Date__c)) || (objProduct.Start_Date__c != null && objProduct.End_Date__c != null && objOpp.Contract_Received_Date__c >= objProduct.Start_Date__c && objOpp.Contract_Received_Date__c <= objProduct.End_Date__c)){
                    if(objProduct.Classification__c == classification){
                        dealerId = objProduct.Id;  
                    } 
                }
            }
        }  
        
        return dealerId;      
    }
    
    global void finish(Database.BatchableContext context) {
        
    }
}