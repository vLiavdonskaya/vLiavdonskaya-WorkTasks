public class XMLWrappers {
  public class Envelope extends XMLSerialize {
    public Envelope() {
      this.nodeName = 'Envelope';
      this.nodeNamespace = this.SOAP_NAMESPACE;
      this.nodePrefix = this.SOAP_PREFIX;
    }
    public Envelope(String namespace, String prefix) {
      this.nodeName = 'Envelope';
      this.nodeNamespace = namespace;
      this.nodePrefix = prefix;
    }
    public override void createNode() {
      this.addNamespace(
        new Map<String, String>{
          'xsi' => this.XSI_NAMESPACE,
          'xsd' => this.XSD_NAMESPACE
        }
      );

      XMLWrappers.Header hdr = new XMLWrappers.Header(
        this.nodeNamespace,
        this.nodePrefix
      );
      this.createChildNode(hdr);
      hdr.createNode();

      XMLWrappers.Body bd = new XMLWrappers.Body(
        this.nodeNamespace,
        this.nodePrefix
      );
      this.createChildNode(bd);
      bd.createNode();
    }
  }

  public class Header extends XMLSerialize {
    public Header() {
    }
    public Header(String namespace, String prefix) {
      this.nodeName = 'Header';
      this.nodeNamespace = namespace;
      this.nodePrefix = prefix;
    }
    public override void createNode() {
      XMLWrappers.Security scrty = new XMLWrappers.Security();
      this.createChildNode(scrty);
      scrty.createNode();
    }
  }

  public class Body extends XMLSerialize {
    public Body() {
    }
    public Body(String namespace, String prefix) {
      this.nodeName = 'Body';
      this.nodeNamespace = namespace;
      this.nodePrefix = prefix;
    }
    public override void createNode() {
      this.createChildNode(
        'GetInspectionQuestionConfigurations',
        this.MSB_NAMESPACE,
        ''
      );
    }
  }

  public class Security extends XMLSerialize {
    public Security() {
      this.nodeName = 'Security';
      this.nodeNamespace = this.WSSE_NAMESPACE;
      this.nodePrefix = this.WSSE_PREFIX;
    }

    public Security(
      String namespace,
      String prefix,
      String attrName,
      String attribute,
      String atrrValue
    ) {
      this.nodeName = 'Security';
      this.nodeNamespace = namespace;
      this.nodePrefix = prefix;
    }

    public override void createNode() {
      UsernameToken usrToken = new UsernameToken();
      this.createChildNode(usrToken);
      usrToken.createNode();
    }
  }

  public class UsernameToken extends XMLSerialize {
    private String attribute = '';
    private String attrValue = '';

    public UsernameToken() {
      this.nodeName = 'UsernameToken';
      this.nodeNamespace = this.WSSE_NAMESPACE;
      this.nodePrefix = this.WSSE_PREFIX;
      this.attribute = 'Type';
      this.attrValue = this.PSW_TYPE_VALUE;
    }

    public UsernameToken(
      String namespace,
      String prefix,
      String attrName,
      String attribute,
      String atrrValue
    ) {
      this.nodeName = 'UsernameToken';
      this.nodeNamespace = this.WSSE_NAMESPACE;
      this.nodePrefix = this.WSSE_PREFIX;
      this.attribute = 'Type';
      this.attrValue = this.PSW_TYPE_VALUE;
    }

    public override void createNode() {
      this.createTextNode(this.USER_NAME, 'Username');
      this.setAttribute(
        attribute,
        attrValue,
        this.createTextNode(this.PASSWORD, 'Password')
      );
    }
  }
}
