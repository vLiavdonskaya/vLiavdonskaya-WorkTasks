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
    private static void testCreateContact() {
        test.startTest();
        test.setMock(HttpCalloutMock.class, new CalloutMock(
            201, 
            '[{"name":"James"}, {"name":"Amily"}, {"name":"Aric"}]'));
        ReqResIntegration.createContacts(setData());
        test.stopTest();
    }
    
    @isTest
    private static void testGetUsers() {
        test.startTest();
        test.setMock(HttpCalloutMock.class, new CalloutMock(
            200, 
            '[{"name":"TestName", "email":"test@gmail.com"}]'
        ));
        String actual = ReqResIntegration.getUsers();
        system.assertEquals('[{"name":"TestName", "email":"test@gmail.com"}]', actual);
        test.stopTest();
    }
    
    @isTest
    private static void testGetUserAvatar() {
        test.startTest();
        test.setMock(HttpCalloutMock.class, new CalloutMock(
            200, 
            Blob.valueOf('test')
        ));
        Blob actual = ReqResIntegration.getUserAvatar('https://reqres.in/img/faces/7-image.jpg');
        system.assertEquals(Blob.valueOf('test'), actual);
        test.stopTest();
    }
}