global class ContactCallout {
    global class RequestBody{
        public string name;
    }
    @future(callout=true)
    public static void createContact(List<string> names){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://reqres.in/api/users');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(getBodyObjectsList(names)));
        Http http = new Http();
        HttpResponse response = http.send(req);
        if(response.getStatusCode() == 201){
            system.debug(response.getBody());
        }
    }
    private static List<Object> getBodyObjectsList(List<string> names){
        List<Object> bodyObjects = new List<Object>();
        for(String name : names){
            RequestBody body = new RequestBody();
            body.name = name;
            bodyObjects.add(body);
        }
        return bodyObjects;
    }
}