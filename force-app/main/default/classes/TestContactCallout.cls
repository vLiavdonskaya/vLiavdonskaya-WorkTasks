@isTest
private class TestContactCallout {
    private static List<string> setData(){
        List<Contact> contacts = new List<Contact>();
        List<string> names = new List<string>();
        for(integer i = 0; i < 5; i++){
            contacts.add(new Contact(FirstName = 'Test' + i, LastName = 'Test' + i));
        }
        for(Contact contact : contacts){
            names.add(contact.FirstName + ' ' + contact.LastName);
        }
        insert contacts;
        return names;
    }
    @isTest
    private static void testCreateContact(){
        test.startTest();
        List<String> names = setData();
        Test.setMock(HttpCalloutMock.class, new ContactCalloutMock());
        ContactCallout.createContact(names);
        test.stopTest();
    }
}