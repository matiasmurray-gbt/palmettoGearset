global class PalmettoAPIServiceCalloutMocks{

    global class InterconnectionSubmittedMockImp implements HttpCalloutMock{
        global HttpResponse respond(HTTPRequest req) {

            System.debug(req.getBody());
            System.assert(req.getHeader('Content-Type').contains('application/json'), 'The callout didnt contain content-type header');
            System.assert(req.getBody().contains('interconnectionSubmitted'), 'The callout didnt contain the expected field');

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            //res.setBody('{"status":true,"code":1,"message":"Success.","result":"0030U000006LwFTQA0"}');
            res.setStatusCode(200);
            return res;
        }
    }
    global class InterconnectionApprovedMockImp implements HttpCalloutMock{
        global HttpResponse respond(HTTPRequest req) {

            System.debug(req.getBody());    
            System.assert(req.getHeader('Content-Type').contains('application/json'), 'The callout didnt contain content-type header');        
            System.assert(req.getBody().contains('interconnectionApproved'), 'The callout didnt contain the expected field');

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            //res.setBody('{"status":true,"code":1,"message":"Success.","result":"0030U000006LwFTQA0"}');
            res.setStatusCode(200);
            return res;
        }
    }
    global class InstallScheduledMockImp implements HttpCalloutMock{
        global HttpResponse respond(HTTPRequest req) {

            System.debug(req.getBody());
            System.assert(req.getHeader('Content-Type').contains('application/json'), 'The callout didnt contain content-type header');
            System.assert(req.getBody().contains('installScheduled'), 'The callout didnt contain the expected field');

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            //res.setBody('{"status":true,"code":1,"message":"Success.","result":"0030U000006LwFTQA0"}');
            res.setStatusCode(200);
            return res;
        }
    }
    global class SurveyCompletedMockImp implements HttpCalloutMock{
        global HttpResponse respond(HTTPRequest req) {

            System.debug(req.getBody());
            System.assert(req.getHeader('Content-Type').contains('application/json'), 'The callout didnt contain content-type header'); 
            System.assert(req.getBody().contains('surveyCompleted'), 'The callout didnt contain the expected field');

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            //res.setBody('{"status":true,"code":1,"message":"Success.","result":"0030U000006LwFTQA0"}');
            res.setStatusCode(200);
            return res;
        }
    }
    global class OrderStatusFromOppMockImp implements HttpCalloutMock{
        Id opportunityId;

        global OrderStatusFromOppMockImp(Id oppId){
            this.opportunityId = oppId;
        }

        global HttpResponse respond(HTTPRequest req) {

            System.debug(req.getBody());
            System.assert(req.getHeader('Content-Type').contains('application/json'), 'The callout didnt contain content-type header');
            System.assert(req.getBody().contains(this.opportunityId), 'The callout didnt contain the expected field');

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            //res.setBody('{"status":true,"code":1,"message":"success.","result":"0030U000006LwFTQA0"}');
            res.setStatusCode(200);
            return res;
        }
    }
    global class InstallReadyMockImp implements HttpCalloutMock{
        global HttpResponse respond(HTTPRequest req) {

            System.debug(req.getBody());
            System.assert(req.getHeader('Content-Type').contains('application/json'), 'The callout didnt contain content-type header'); 
            System.assert(req.getBody().contains('installReady'), 'The callout didnt contain the expected field');

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            //res.setBody('{"status":true,"code":1,"message":"Success.","result":"0030U000006LwFTQA0"}');
            res.setStatusCode(200);
            return res;
        }
    }

    global class BuildPartnerUpdateMockImp implements HttpCalloutMock{
        Id bpId;
        global BuildPartnerUpdateMockImp(Id buildPartner){
            this.bpId = buildPartner;
        }
        global HttpResponse respond(HTTPRequest req) {

            System.debug(req.getBody());
            System.assert(req.getHeader('Content-Type').contains('application/json'), 'The callout didnt contain content-type header');
            System.assert(req.getBody().contains(bpId), 'The callout didnt contain the expected field');

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            //res.setBody('{"status":true,"code":1,"message":"success.","result":"0030U000006LwFTQA0"}');
            res.setStatusCode(200);
            return res;
        }
    }

    global class JobAssignmentUpdateMockImp implements HttpCalloutMock{
        Id accId;
        Id objJobId;
        global JobAssignmentUpdateMockImp(Id accountId, Id jobId){
            this.accId = accountId;
            this.objJobId = jobId;
        }
        global HttpResponse respond(HTTPRequest req) {

            System.debug(req.getBody());
            System.assert(req.getHeader('Content-Type').contains('application/json'), 'The callout didnt contain content-type header');
            System.assert(req.getBody().contains(accId), 'The callout didnt contain the expected field');
            System.assert(req.getBody().contains(objJobId), 'The callout didnt contain the expected field');

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            //res.setBody('{"status":true,"code":1,"message":"success.","result":"0030U000006LwFTQA0"}');
            res.setStatusCode(200);
            return res;
        }
    }

    global class CaseAssignmentUpdateMockImp implements HttpCalloutMock{
        Id accId;
        Id objCaseId;
        global CaseAssignmentUpdateMockImp(Id accountId, Id caseId){
            this.accId = accountId;
            this.objCaseId = caseId;
        }
        global HttpResponse respond(HTTPRequest req) {

            System.debug(req.getBody());
            System.assert(req.getHeader('Content-Type').contains('application/json'), 'The callout didnt contain content-type header');
            System.assert(req.getBody().contains(accId), 'The callout didnt contain the expected field');
            System.assert(req.getBody().contains(objCaseId), 'The callout didnt contain the expected field');

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            //res.setBody('{"status":true,"code":1,"message":"success.","result":"0030U000006LwFTQA0"}');
            res.setStatusCode(200);
            return res;
        }
    }
}