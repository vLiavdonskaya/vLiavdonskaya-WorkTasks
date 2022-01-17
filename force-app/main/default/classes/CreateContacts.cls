public class CreateContacts {
    
    private static List<ContactWrapper> users = new List<ContactWrapper>();
    
    private static List<ContactWrapper> parseUsers() {
        String jsonString = ReqResIntegration.getUsers();
        jsonString = '[' + jsonString.substringBetween('[', ']') + ']';
        List<ContactWrapper> parsedUsers = (List<ContactWrapper>)
            JSON.deserialize(jsonString, List<ContactWrapper>.class);
        for(ContactWrapper parsedUser : parsedUsers) {
            ContactWrapper user = parsedUser;
            user.avatarBlob = ReqResIntegration.getUserAvatar(user.avatar);
            users.add(user);
        }
        return users;
    }
    
    public static void insertContacts() {
        parseUsers();
        List<Contact> contacts = new List<Contact>();
        for(ContactWrapper user : users) {
            Id cv = CreateDocuments.createContentVersion(
                user.avatarBlob, 
                user.first_name + '_' + user.last_name, 
                user.first_name + '_' + user.last_name + '.jpg').Id;
            
            contacts.add(new Contact(
                FirstName = user.first_name, 
                LastName = user.last_name, 
                Email = user.Email,
                DocumentId__c = cv));
        }
        INSERT contacts;
        insertAvatar(contacts);
    }
    
    private static void insertAvatar(List<Contact> contacts) {
        List<Contact> contactsToUpdate = new List<Contact>();
        for(Contact contact : contacts) {
            ContentDocumentLink cdl = CreateDocuments.linkDocumentToRecord(contact.Id, contact.DocumentId__c);
            contactsToUpdate.add(new Contact(
                Id = contact.Id, 
                DocumentId__c = cdl.ContentDocumentId));           
        }
        UPDATE contactsToUpdate;
    }
    
    public class ContactWrapper {
        String id;
        String first_name;
        String last_name;
        String email;
        String avatar;
        Blob avatarBlob;
        
        public ContactWrapper(
            String id,
            String first_name,
            String last_name,
            String email,
            String avatar, 
            Blob avatarBlob) {
                this.id = id;
                this.first_name = first_name;
                this.last_name = last_name;
                this.email = email;
                this.avatar = avatar;
                this.avatarBlob = avatarBlob;
            }
    }
}