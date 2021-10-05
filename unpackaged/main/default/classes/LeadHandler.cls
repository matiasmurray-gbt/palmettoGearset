public class LeadHandler
{
    //This method is executed on before insert event of trigger.
    public void onBeforeInsert(List<Lead> lstLead){
        populateCompany(lstLead);
    }
    //This method is executed on after insert event of trigger.
    public void onAfterInsert(List<Lead> lstLead){
        convertLead(lstLead);
    }
    //This method is executed on after update event of trigger.
    public void onAfterUpdate(List<Lead> lstLead, Map<Id, Lead> mapIdToOldLead){
        updateOpportunity(lstLead, mapIdToOldLead);
    }
    
    //This method is used to populate the company name before conversion.
    private void populateCompany(List<Lead> lstLead){
        Id buildOnlyLeadId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Build Only').getRecordTypeId();
        for(Lead objLead : lstLead){
            if(objLead.RecordTypeId == buildOnlyLeadId && objLead.Company == 'X'){
                objLead.Company = (objLead.FirstName == null?'':objLead.FirstName) + ' ' + objLead.LastName + ' - Account';
            }
        }
    }
    
    
    //This method is used to convert lead.
    
    private void convertLead(List<Lead> lstLead){
        Id buildOnlyLeadId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Build Only').getRecordTypeId();
        List<Database.LeadConvert> lstLeadConvert = new List<Database.LeadConvert>();
        Map<Id, Lead> mapIdToLead = new Map<Id, Lead>();
        for(Lead objLead : lstLead){
            if(objLead.RecordTypeId == buildOnlyLeadId && String.isNotBlank(objLead.Scope_of_Work__c) && objLead.Scope_of_Work__c.containsIgnoreCase('Installation') && !objLead.Scope_of_Work__c.containsIgnoreCase('PV Installation')){
                Database.LeadConvert objLeadConvert = new Database.LeadConvert();
                objLeadConvert.setLeadId(objLead.Id);
                objLeadConvert.setConvertedStatus('Qualified');
                lstLeadConvert.add(objLeadConvert);
                mapIdToLead.put(objLead.Id, objLead);
            }
        }
        System.debug('>>>>lstLeadConvert>>>>'+lstLeadConvert);
        if(!lstLeadConvert.isEmpty()){
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true;
            List<Database.LeadConvertResult> lstResult = Database.convertLead(lstLeadConvert, dml);
            
            for(Database.LeadConvertResult objresult : lstResult){
                if(!objresult.isSuccess()){
                    Id leadId = objresult.getLeadId();
                    String errorMsg = '';
                    for(Database.Error objError : objresult.getErrors()){
                        errorMsg += objError.getMessage() + ', ';
                    }
                    if(mapIdToLead.containsKey(leadId)){
                        mapIdToLead.get(leadId).addError(errorMsg);
                    }
                }
            }
        }
    }
	
    
    //This method is used to opp name after lead conversion.
    private void updateOpportunity(List<Lead> lstLead, Map<Id, Lead> mapIdToOldLead){
        Map<Id, Opportunity> mapIdToOpp = new Map<Id, Opportunity>();
        Map<Id, Account> mapIdToAcc = new Map<Id, Account>();
        
        Id buildOnlyAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Build Only').getRecordTypeId();
        Id buildOnlyLeadId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Build Only').getRecordTypeId();
        Id buildOnlyOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Build Only').getRecordTypeId();

        
        for(Lead objLead : lstLead){
            Lead objOldLead = mapIdToOldLead.get(objLead.Id);
            if(objLead.RecordTypeId == buildOnlyLeadId  && objLead.IsConverted != objOldLead.IsConverted && objLead.IsConverted == true
                && String.isNotBlank(objLead.Scope_of_Work__c) && objLead.Scope_of_Work__c.containsIgnoreCase('Installation') && !objLead.Scope_of_Work__c.containsIgnoreCase('PV Installation')){
                Opportunity objOpp = new Opportunity();
                objOpp.Id = objLead.ConvertedOpportunityId;
                objOpp.RecordTypeId = buildOnlyOppId;
                objOpp.Name = (objLead.FirstName == null?'':objLead.FirstName) + ' ' + objLead.LastName + ' - Account - Opportunity';
                objOpp.Contact__c = objLead.ConvertedContactId;
                objOpp.AHJ_Assumed__c = objLead.AHJ_Assumed__c;
                objOpp.Partner_Job_ID__c = objLead.Partner_Job_ID__c;
               
                if(objlead.Scope_of_Work__c.containsIgnoreCase('Permit and Installation')){
                    objOpp.StageName = '13. Engineering Design Complete';
                } else{
                    objOpp.StageName = '18. Installation';
                }
                mapIdToOpp.put(objOpp.Id, objOpp);
                
                Account objAccount = new Account();
                objAccount.Id = objLead.ConvertedAccountId;
                objAccount.recordTypeId = buildOnlyAccountId;
                mapIdToAcc.put(objAccount.Id, objAccount);
            }
        }
        
        if(!mapIdToOpp.isEmpty())
            update mapIdToOpp.values();
        if(!mapIdToAcc.isEmpty())
            update mapIdToAcc.values();
    }
}