@isTest
global class ContactCalloutMock implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(201);
        res.setBody('[{"name":"James"}, {"name":"Amily"}, {"name":"Harry"}]');
        return res;
    }
}