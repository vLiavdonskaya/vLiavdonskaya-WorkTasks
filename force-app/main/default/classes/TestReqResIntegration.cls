@isTest
private class TestReqResIntegration {
    private static List<Contact> setData() {
        List<Contact> contacts = new List<Contact>();
        for(integer i = 0; i < 5; i++){
            contacts.add(new Contact(FirstName = 'Test' + i, LastName = 'Test' + i));
        }
        insert contacts;
        return contacts;
    }
    
    @isTest
    private static void testCreateContact(){
        test.startTest();
        test.setMock(HttpCalloutMock.class, new CalloutMock(
            201, 
            '[{"name":"James"}, {"name":"Amily"}, {"name":"Aric"}]'));
        ReqResIntegration.createContacts(setData());
        test.stopTest();
    }
}