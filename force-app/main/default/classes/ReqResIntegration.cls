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
            req.setBody(body);
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
    
    private static String getContactNamesList(List<Contact> contacts) {
        List<Map<String, String>> names = new List<Map<String, String>>();
        for(Contact contact : contacts){
            names.add(new Map<String, String>{'name' => contact.FirstName + ' ' + contact.LastName});
        }
        return JSON.serialize(names);
    }
}