public class RCTIntegration {
  private static final String USER_NAME = UsernameToken__c.getInstance(
      UserInfo.getUserId()
    )
    .USER_NAME__c;
  private static final String PASSWORD = UsernameToken__c.getInstance(
      UserInfo.getUserId()
    )
    .PASSWORD__c;

  private static final String ENDPOINT = 'https://rcttest7.msbexpress.net/inspector/inspection/ConfigurationService.asmx';

  private static final String SOAP_PREFIX = 'soap';
  private static final String WSSE_PREFIX = 'wsse';
  private static final String XSI_NAMESPACE = 'http://www.w3.org/2001/XMLSchema-instance';
  private static final String XSD_NAMESPACE = 'http://www.w3.org/2001/XMLSchema';
  private static final String SOAP_NAMESPACE = 'http://schemas.xmlsoap.org/soap/envelope/';
  private static final String WSSE_NAMESPACE = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd';
  private static final String PSW_TYPE_VALUE = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText';
  private static final String MSB_NAMESPACE = 'http://www.msbinfo.com/residential/inspection/service/configurationservice';

  private static final String HEADER_SOAPACTION_VALUE = 'http://www.msbinfo.com/residential/inspection/service/configurationservice/GetInspectionQuestionConfigurations';
  private static final String HEADER_COOKIE_VALUE = 'visid_incap_2017272=IRd4ILC0TzWShD7D/n1H3UlcEmEAAAAAQUIPAAAAAABU7vIurOK8yEB/6gksbNkO; incap_ses_533_2017272=qaeeIds8VkMonfkUSZllB3oVFmIAAAAA4TVDj0nC43Rgrtr7vgP/+w==; incap_ses_523_2017272=zz9SM8ABahny2gvyXxJCB/4VFmIAAAAAfuDVUHdXSKEIzztDhl3HAw==';

  private static final String MSB_MODEL_NAMESPACE = 'http://www.msbinfo.com/residential/inspection/model';

  private static final String FAULT_NAMESPACE = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd';

  public List<InspectionQuestion> inspectionQuestions = new List<InspectionQuestion>();

  public Map<String, String> fault = new Map<String, String>();

  public DOM.Document buildRequestBody() {
    DOM.Document doc = new DOM.Document();

    DOM.XmlNode envelopeNode = doc.createRootElement(
      'Envelope',
      SOAP_NAMESPACE,
      SOAP_PREFIX
    );
    envelopeNode.setNamespace('xsi', XSI_NAMESPACE);
    envelopeNode.setNamespace('xsd', XSD_NAMESPACE);

    DOM.XmlNode headerNode = envelopeNode.addChildElement(
      'Header',
      SOAP_NAMESPACE,
      SOAP_PREFIX
    );
    DOM.XmlNode securityNode = headerNode.addChildElement(
      'Security',
      WSSE_NAMESPACE,
      WSSE_PREFIX
    );

    DOM.XmlNode userNameTokenNode = securityNode.addChildElement(
      'UsernameToken',
      WSSE_NAMESPACE,
      WSSE_PREFIX
    );
    userNameTokenNode
      .addChildElement('Username', WSSE_NAMESPACE, WSSE_PREFIX)
      .addTextNode(USER_NAME);

    DOM.XmlNode passwordNode = userNameTokenNode.addChildElement(
      'Password',
      WSSE_NAMESPACE,
      WSSE_PREFIX
    );
    passwordNode.addTextNode(PASSWORD);
    passwordNode.setAttribute('Type', PSW_TYPE_VALUE);

    DOM.XmlNode bodyNode = envelopeNode.addChildElement(
      'Body',
      SOAP_NAMESPACE,
      SOAP_PREFIX
    );
    bodyNode.addChildElement(
      'GetInspectionQuestionConfigurations',
      MSB_NAMESPACE,
      ''
    );

    system.debug(doc.toXmlString());
    return doc;
  }

  private HttpRequest createRequest(
    String endpoint,
    String method,
    Map<String, String> headers,
    String body
  ) {
    HttpRequest req = new HttpRequest();
    req.setEndpoint(endpoint);
    req.setMethod(method);
    if (!headers.isEmpty()) {
      for (String key : headers.keySet()) {
        req.setHeader(key, headers.get(key));
      }
    }
    if (String.isNotBlank(body))
      req.setBody(body);
    return req;
  }

  private void parceFault(DOM.Document xml) {
    List<DOM.XmlNode> faultNode = xml.getRootElement()
      .getChildElement('Body', SOAP_NAMESPACE)
      .getChildElement('Fault', SOAP_NAMESPACE)
      .getChildElements();

    for (DOM.XmlNode field : faultNode) {
      fault.put(field.getName(), field.getText());
    }

    system.debug('FAULT' + fault);
  }

  private void parceInspectQnConfigs(DOM.Document doc) {
    List<DOM.XMLNode> inspQnConfigsNode = doc
      .getRootElement()
      .getChildElement('Body', SOAP_NAMESPACE)
      .getChildElement(
        'GetInspectionQuestionConfigurationsResponse',
        MSB_NAMESPACE
      )
      .getChildElement(
        'GetInspectionQuestionConfigurationsResult',
        MSB_NAMESPACE
      )
      .getChildElements();

    for (DOM.XMLNode qnConfigNode : inspQnConfigsNode) {
      InspectionQuestion iq = new InspectionQuestion();
      iq.code = qnConfigNode.getChildElement('Code', MSB_MODEL_NAMESPACE)
        .getText();
      iq.text = qnConfigNode.getChildElement('Text', MSB_MODEL_NAMESPACE)
        .getText();

      List<DOM.XMLNode> qnConfigNodeFields = qnConfigNode.getChildElements();
      for (DOM.XmlNode qnConfigField : qnConfigNodeFields)
        if (qnConfigField.getName() == 'Answers')
          iq.answers.add(
            qnConfigField.getChildElement('Text', MSB_MODEL_NAMESPACE).getText()
          );

      inspectionQuestions.add(iq);
    }

    system.debug('INSPECTION QUESTIONS:' + inspectionQuestions);
  }

  public void getInspQnConfig(String body) {
    HttpRequest req = createRequest(
      ENDPOINT,
      'POST',
      new Map<String, String>{
        'Content-Type' => 'text/xml',
        'SOAPAction' => HEADER_SOAPACTION_VALUE,
        'Cookie' => HEADER_COOKIE_VALUE
      },
      buildRequestBody().toXmlString()
    );

    HttpResponse response = new Http().send(req);

    if (response.getStatusCode() == 200) {
      parceInspectQnConfigs(response.getBodyDocument());
    } else {
      parceFault(response.getBodyDocument());
    }

    system.debug(response.getBody());
    system.debug(response);
  }

  public class InspectionQuestion {
    public String code = '';
    public String text = '';
    public List<String> answers = new List<String>();
  }
}
