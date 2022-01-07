@isTest
global class CalloutMock implements HttpCalloutMock{
    Integer statusCode;
    String body;
    public CalloutMock(Integer statusCode, String body) {
        this.statusCode = statusCode;
        this.body = body;
    }
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(statusCode);
        res.setBody(body);
        return res;
    }
}