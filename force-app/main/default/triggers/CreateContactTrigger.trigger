trigger CreateContactTrigger on Contact (after insert) {
    List<string> contacts = new List<string>();
    for(Contact contact : Trigger.New){
        contacts.add(contact.FirstName + ' ' +  contact.LastName);
    }
    ContactCallout.createContact(contacts);
}