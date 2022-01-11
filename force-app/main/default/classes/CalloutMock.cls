@isTest
global class CalloutMock implements HttpCalloutMock {
    Integer statusCode = 0;
    String body = '';
    Blob blobBody = Blob.valueOf('');
    
    public CalloutMock(Integer statusCode, String body) {
        this.statusCode = statusCode;
        this.body = body;
    }
    
    public CalloutMock(Integer statusCode, Blob body) {
        this.statusCode = statusCode;
        this.blobBody = body;
    }
    
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(statusCode);
        if(String.isNotBlank(body)){
            res.setBody(body);
        }
        if(blobBody.size() != 0) {
            res.setBodyAsBlob(blobBody);
        }
        return res;
    }
}