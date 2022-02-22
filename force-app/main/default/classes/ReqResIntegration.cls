public class ReqResIntegration {
  private static HttpRequest createRequest(
    String endpoint,
    String method,
    String body
  ) {
    HttpRequest req = new HttpRequest();
    req.setEndpoint(endpoint);
    req.setMethod(method);
    if (String.isNotBlank(body))
      req.setBody(body);
    return req;
  }

  public static String get(String endpoint) {
    Http http = new Http();
    HttpResponse res = http.send(createRequest(endpoint, 'GET', ''));
    return res.getBody();
  }

  public static String post(String endpoint, String body) {
    Http http = new Http();
    HttpResponse res = http.send(createRequest(endpoint, 'POST', body));
    return res.getBody();
  }
}
