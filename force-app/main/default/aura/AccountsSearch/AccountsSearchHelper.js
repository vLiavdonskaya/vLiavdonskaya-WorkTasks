({
  passSearchQuery: function (cmp, query) {
    var component = cmp.get("v.component");
    component.getSearchQuery(query);
  }
});
