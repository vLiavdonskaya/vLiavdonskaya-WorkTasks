({
  fetchAccounts: function (cmp) {
    var action = cmp.get("c.getAccounts");
    action.setCallback(this, function (response) {
      if (response.getState() === "SUCCESS") {
        cmp.set("v.accounts", response.getReturnValue());
      }
    });

    $A.enqueueAction(action);
  },

  fetchFoundAcconts: function (cmp, query) {
    var action = cmp.get("c.findAccounts");
    action.setParams({
      query: query
    });
    action.setCallback(this, function (response) {
      if (response.getState() === "SUCCESS") {
        cmp.set("v.accounts", response.getReturnValue());
      }
    });

    $A.enqueueAction(action);
  },

  fetchUpdatedAccounts: function (cmp, draftValues) {
    var action = cmp.get("c.updateAccounts");
    action.setParams({
      accounts: draftValues
    });
    action.setCallback(this, function (response) {
      if (response.getState() === "SUCCESS") {
        cmp.set("v.accounts", response.getReturnValue());
        this.showToast("Success", "Your changes are saved!", "success");
      }
    });

    $A.enqueueAction(action);
  },

  showToast: function (title, message, type) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: title,
      message: message,
      duration: "3000",
      type: type,
      mode: "dismissible"
    });
    toastEvent.fire();
    $A.get("e.force:refreshView").fire();
  }
});
