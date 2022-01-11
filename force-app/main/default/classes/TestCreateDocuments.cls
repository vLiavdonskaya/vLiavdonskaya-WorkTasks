@isTest
private class TestCreateDocuments {
    
    @isTest
    private static void testLinkDocumentToRecord() {
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Test');
        insert contact;
        
        Blob doc = Blob.valueOf('test');
        Id cvId = CreateDocuments.createContentVersion(doc, 'TestTitle', 'TestTitle').Id;
        Id cdlId = CreateDocuments.linkDocumentToRecord(contact.Id, cvId).Id;
        
        system.assertEquals([SELECT Id FROM ContentVersion WHERE Id =: cvId].Id, cvId);
        system.assertEquals([SELECT Id FROM ContentDocumentLink WHERE Id =: cdlId].Id, cdlId);
    }
}