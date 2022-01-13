({
  init: function (component, event, helper) {
    component.set("v.columns", [
      { label: "Name", fieldName: "Name", type: "text" },
      { label: "Type", fieldName: "Type", type: "text" },
      { label: "Industry", fieldName: "Industry", type: "text" },
      { label: "Contacts", fieldName: "Contacts_Count__c", type: "number" },
      { label: "Created Date", fieldName: "CreatedDate", type: "date" }
    ]);

    helper.fetchData(component);
  }
});
