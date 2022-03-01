public abstract class Constants {
  protected final String USER_NAME = UsernameToken__c.getInstance(
      UserInfo.getUserId()
    )
    .USER_NAME__c;
  protected final String PASSWORD = UsernameToken__c.getInstance(
      UserInfo.getUserId()
    )
    .PASSWORD__c;

  protected final String ENDPOINT = 'https://rcttest7.msbexpress.net/inspector/inspection/ConfigurationService.asmx';

  protected final String SOAP_PREFIX = 'soap';
  protected final String WSSE_PREFIX = 'wsse';
  protected final String XSI_NAMESPACE = 'http://www.w3.org/2001/XMLSchema-instance';
  protected final String XSD_NAMESPACE = 'http://www.w3.org/2001/XMLSchema';
  protected final String SOAP_NAMESPACE = 'http://schemas.xmlsoap.org/soap/envelope/';
  protected final String WSSE_NAMESPACE = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd';
  protected final String PSW_TYPE_VALUE = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText';
  protected final String MSB_NAMESPACE = 'http://www.msbinfo.com/residential/inspection/service/configurationservice';

  protected final String HEADER_SOAPACTION_VALUE = 'http://www.msbinfo.com/residential/inspection/service/configurationservice/GetInspectionQuestionConfigurations';
  protected final String HEADER_COOKIE_VALUE = 'visid_incap_2017272=IRd4ILC0TzWShD7D/n1H3UlcEmEAAAAAQUIPAAAAAABU7vIurOK8yEB/6gksbNkO; incap_ses_533_2017272=qaeeIds8VkMonfkUSZllB3oVFmIAAAAA4TVDj0nC43Rgrtr7vgP/+w==; incap_ses_523_2017272=zz9SM8ABahny2gvyXxJCB/4VFmIAAAAAfuDVUHdXSKEIzztDhl3HAw==';

  protected final String MSB_MODEL_NAMESPACE = 'http://www.msbinfo.com/residential/inspection/model';

  protected final String FAULT_NAMESPACE = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd';
}
