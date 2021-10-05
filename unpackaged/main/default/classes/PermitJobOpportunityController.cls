public with sharing class PermitJobOpportunityController {
    @AuraEnabled(cacheable=true)
    public static Opportunity getOpportunities(Id recordId) {
        return [
            SELECT Id, Authority_Having_Jurisdiction__c, of_Solar_Panels__c, Email__c, Phone__c, Open_Retention_Case__c,
                Inverter_1__c, Inverter_2__c, Contract.Amount__c, Number_of_Solar_Panels__c,
                (
                    SELECT Id, Name, Url
                    FROM GoogleDocs
                ),
                (
                    SELECT Id, Name, dsfs__DocuSign_Envelope_ID__c
                    FROM dsfs__R00N80000002fD9vEAE__r
                )
            FROM Opportunity
            WHERE Id IN (SELECT Opportunity__c FROM Job__c WHERE ID = :recordId)
            LIMIT 1
        ];
    }
}