({
  init: function (component, event, helper) {
    component.set("v.columns", [
      { label: "Name", fieldName: "Name", type: "text" },
      {
        label: "Type",
        fieldName: "Type",
        type: "text",
        cellAttributes: {
          alignment: "center"
        }
      },
      {
        label: "Industry",
        fieldName: "Industry",
        type: "text",
        cellAttributes: {
          alignment: "center"
        }
      },
      {
        label: "Contacts",
        fieldName: "Contacts_Count__c",
        type: "number",
        cellAttributes: {
          alignment: "center"
        }
      },
      {
        label: "Created Date",
        fieldName: "CreatedDate",
        type: "date",
        cellAttributes: {
          alignment: "right"
        }
      }
    ]);

    helper.fetchData(component);
  }
});
