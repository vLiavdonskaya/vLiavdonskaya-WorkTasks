public class CreateDocuments {
    
    public static ContentVersion createContentVersion(Blob document, String title, String fileName) {
        ContentVersion cv = new ContentVersion();
        cv.IsMajorVersion = true;
        cv.Title = title;
        cv.PathOnClient = fileName;
        cv.VersionData = document;
        INSERT cv;
        return cv;
    }
    
    public static ContentDocumentLink linkDocumentToRecord(Id recordId, Id contentVersion) {
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT ContentDocumentId 
                                 FROM ContentVersion 
                                 WHERE Id =: contentVersion].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';
        INSERT cdl;
        return cdl;
    }
}