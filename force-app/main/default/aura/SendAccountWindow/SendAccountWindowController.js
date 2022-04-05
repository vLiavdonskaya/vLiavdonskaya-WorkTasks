({
  passClose: function (cmp, event, helper) {
    var component = cmp.get("v.component");
    component.closeModal(false);
  },

  sendAccountHandler: function (cmp, event, helper) {
    helper.sendAccount(cmp, cmp.get("v.recordId"));
  }
});
