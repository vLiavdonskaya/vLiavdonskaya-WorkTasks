public class NumberToWordsIntegration {
  private static final String ENDPOINT = 'https://www.dataaccess.com/webservicesserver/NumberConversion.wso';
  private static final String DA_NAMESPACE = 'http://schemas.xmlsoap.org/soap/envelope/';
  private static final String DA_PREFIX = 'soap';
  private static final String NTW_NAMESPACE = 'http://www.dataaccess.com/webservicesserver/';

  private HttpRequest createRequest(
    String endpoint,
    String method,
    String headerValue,
    String body
  ) {
    HttpRequest req = new HttpRequest();
    req.setEndpoint(endpoint);
    req.setMethod(method);
    req.setHeader('Content-Type', headerValue);
    if (String.isNotBlank(body))
      req.setBody(body);
    return req;
  }

  private DOM.Document createXMLDocument(Integer digit) {
    DOM.Document doc = new DOM.Document();

    DOM.XmlNode envelope = doc
      .createRootElement('Envelope', DA_NAMESPACE, DA_PREFIX)
      .addChildElement('Body', DA_NAMESPACE, DA_PREFIX)
      .addChildElement('NumberToWords', NTW_NAMESPACE, '')
      .addChildElement('ubiNum', null, null)
      .addTextNode(String.valueOf(digit));

    return doc;
  }

  private String readXMLDocument(DOM.Document xml) {
    String result = '';
    DOM.Document doc = xml;

    List<DOM.XMLNode> bodyChildrenList = doc
      .getRootElement()
      .getChildElement('Body', DA_NAMESPACE)
      .getChildElements();

    for (DOM.XMLNode elem : bodyChildrenList) {
      List<DOM.XMLNode> elemChildrenList = elem.getChildElements();

      for (DOM.XMLNode subElem : elemChildrenList) {
        result = subElem.getText();
      }
    }

    return result;
  }

  public void getDigit(Integer digit) {
    HttpRequest req = createRequest(
      ENDPOINT,
      'POST',
      'text/xml',
      createXMLDocument(digit).toXmlString()
    );

    HttpResponse response = new Http().send(req);

    system.debug(readXMLDocument(response.getBodyDocument()));
  }
}
