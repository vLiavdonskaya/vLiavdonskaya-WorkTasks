({
  sendAccount: function (cmp, accId) {
    var action = cmp.get("c.sendAccounts");
    action.setParams({
      accId: accId
    });
    action.setCallback(this, function (response) {
      if (
        response.getState() === "SUCCESS" &&
        response.getReturnValue() === 201
      ) {
        this.showToast("Success", "Account has been send", "success");
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
