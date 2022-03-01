public abstract class XMLSerialize extends Constants {
  protected String nodeName = '';
  protected String nodeNamespace = '';
  protected String nodePrefix = '';

  protected DOM.XmlNode node;

  public abstract void createNode();

  protected void setFields(
    String nodeName,
    String nodeNamespace,
    String nodePrefix
  ) {
    this.nodeName = nodeName;
    this.nodeNamespace = nodeNamespace;
    this.nodePrefix = nodePrefix;
  }

  public void createChildNode(XMLSerialize childNode) {
    childNode.node = this.node.addChildElement(
      childNode.nodeName,
      childNode.nodeNamespace,
      childNode.nodePrefix
    );
  }

  public XMLSerialize createChildNode(
    String name,
    String namespace,
    String prefix
  ) {
    this.node.addChildElement(name, namespace, prefix);
    return this;
  }

  public void createChildNodes(List<XMLSerialize> childNodes) {
    if (childNodes != null && childNodes.size() > 0) {
      for (XMLSerialize childNode : childNodes) {
        childNode.node = this.node.addChildElement(
          childNode.nodeName,
          childNode.nodeNamespace,
          childNode.nodePrefix
        );
      }
    }
  }

  public DOM.XmlNode createTextNode(String text, String name) {
    DOM.XmlNode txtNode = this.node.addChildElement(
      name,
      this.nodeNamespace,
      this.nodePrefix
    );
    txtNode.addTextNode(text);
    return txtNode;
  }

  public XMLSerialize setAttribute(
    String key,
    String value,
    DOM.XmlNode attrNode
  ) {
    attrNode.setAttribute(key, value);
    return this;
  }

  public XMLSerialize addNamespace(Map<String, String> namespaces) {
    if (namespaces.size() > 0) {
      for (String key : namespaces.keySet()) {
        this.node.setNamespace(key, namespaces.get(key));
      }
    }
    return this;
  }

  public DOM.Document createRootNode() {
    DOM.Document doc = new DOM.Document();
    this.node = doc.createRootElement(nodeName, nodeNamespace, nodePrefix);
    return doc;
  }
}
