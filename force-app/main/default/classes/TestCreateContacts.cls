@isTest
private class TestCreateContacts {
    
    @isTest
    private static void testInsertContacts() {
        test.startTest();        
        test.setMock(HttpCalloutMock.class, new CalloutMock(
            200, 
            '[{"id": 7,' + 
            '"email":"michael.lawson@reqres.in",' + 
            '"first_name":"Michael",' +
            '"last_name": "Lawson",' +
            '"avatar": "https://reqres.in/img/faces/7-image.jpg"}]'
        ));
        CreateContacts.insertContacts();
        system.assert([SELECT FirstName, LastName, Email FROM Contact
                            WHERE Email = 'michael.lawson@reqres.in' LIMIT 1].size() != 0);
        test.stopTest();
    }
    
}