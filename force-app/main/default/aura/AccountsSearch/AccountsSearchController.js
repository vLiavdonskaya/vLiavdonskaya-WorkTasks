({
  handleKeyUp: function (cmp, event, helper) {
    var isEnterKey = event.keyCode === 13;
    if (isEnterKey) {
      var query = cmp.find("search-input").get("v.value");
    }
    helper.passSearchQuery(cmp, query);
  }
});
