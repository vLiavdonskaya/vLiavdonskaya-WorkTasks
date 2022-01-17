({
  init: function (cmp, event, helper) {
    var columns = [
      { label: "Name", fieldName: "Name", type: "text", editable: true },
      {
        label: "Type",
        fieldName: "Type",
        type: "text",
        cellAttributes: {
          alignment: "left"
        },
        editable: true
      },
      {
        label: "Industry",
        fieldName: "Industry",
        type: "text",
        cellAttributes: {
          alignment: "left"
        },
        editable: true
      },
      {
        label: "Contacts",
        fieldName: "Contacts_Count__c",
        type: "number",
        cellAttributes: {
          alignment: "center"
        },
        editable: false
      },
      {
        label: "Created Date",
        fieldName: "CreatedDate",
        type: "date",
        cellAttributes: {
          alignment: "right"
        },
        editable: false
      }
    ];

    cmp.set("v.columns", columns);
    helper.fetchAccounts(cmp);
  },

  getSearchQuery: function (cmp, event, helper) {
    var params = event.getParam("arguments");
    if (params.query) {
      helper.fetchFoundAcconts(cmp, params.query);
    } else {
      helper.fetchAccounts(cmp);
    }
  },

  handleSave: function (cmp, event, helper) {
    var draftValues = event.getParam("draftValues");
    helper.fetchUpdatedAccounts(cmp, draftValues);
  },

  getRowId: function (cmp, event, helper) {
    var selectedRows = event.getParam("selectedRows");
    var component = cmp.get("v.component");
    selectedRows.forEach((row) => component.getRecordId(row.Id));
  }
});
