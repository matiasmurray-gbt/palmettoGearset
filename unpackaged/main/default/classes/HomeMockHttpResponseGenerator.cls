@isTest
global class HomeMockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('https://www.palmettoenergydashboard.com/api/upgradeuser', req.getEndpoint());
        //System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status":true,"code":1,"message":"Success.","result":"0030U000006LwFTQA0"}');
        res.setStatusCode(200);
        return res;
    }
}