({
  openModal: function (cmp, event, helper) {
    cmp.set("v.isOpen", true);
  },

  closeModal: function (cmp, event, helper) {
    var params = event.getParam("arguments");
    if (params) {
      cmp.set("v.isOpen", params.isClose);
    }
  },

  getRecordId: function (cmp, event, helper) {
    var params = event.getParam("arguments");
    if (params) {
      cmp.set("v.recordId", params.recordId);
    }
  }
});
