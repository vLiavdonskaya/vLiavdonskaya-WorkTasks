public class ReqResIntegration {
    
    private static HttpRequest createRequest(
        String endpoint, 
        String method, 
        String contentType, 
        String body) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod(method);
            req.setHeader('Content-Type', contentType);
            if(String.isNotBlank(body)){
                req.setBody(body);
            }
            return req;
        }
    
    @future(callout = true)
    private static void sendRequest(
        String endpoint, 
        String method, 
        String contentType, 
        String body) {
            Http http = new Http();
            HttpResponse res = http.send(createRequest(endpoint, method, contentType, body));
            system.debug(res.getStatusCode());
            system.debug(res.getBody());
        }
    
    public static void createContacts(List<Contact> contacts) {
        sendRequest(
            'https://reqres.in/api/users', 
            'POST', 
            'application/json',
            getContactNamesList(contacts));
    }
    
    public static String getUsers(){
        Http http = new Http();
        HttpResponse res = http.send(createRequest(
            'https://reqres.in/api/users?page=2',
            'GET', 
            'application/json', 
            ''));
        return res.getBody();
    }
    
    public static Blob getUserAvatar(String endpoint) {
        Http http = new Http();
        HttpResponse res = http.send(createRequest(
            endpoint,
            'GET', 
            'image/jpeg', 
            ''));
        return res.getBodyAsBlob();
    }
    
    private static String getContactNamesList(List<Contact> contacts) {
        List<Map<String, String>> names = new List<Map<String, String>>();
        for(Contact contact : contacts) {
            names.add(new Map<String, String>{'name' => contact.FirstName + ' ' + contact.LastName});
        }
        return JSON.serialize(names);
    }
}