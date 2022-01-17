@isTest
private class TestAccountPreviewController {
    
    @testSetup
    private static void setup() {
        Account account = new Account(Name='TestAccount', 
                                      Industry = 'Media', 
                                      Type = 'Prospect');
        insert account;
    }
    
    @isTest
    private static void testGetAccounts() {
        User user = [SELECT Id 
                     FROM User 
                     WHERE UserName = '1641990950086_test-dxoqre4um68h@example.com'];
        System.runAs(user) {
            Account account = new Account(Name='TestAccount', 
                                          Industry = 'Media', 
                                          Type = 'Prospect');
            insert account;
            List<Account> actual = AccountPreviewController.getAccounts();
            system.assertEquals(account.Id, actual[0].Id);
        }
    }
    
    @isTest
    private static void testFindAccounts() {
        Account account = new Account(Name='TestAccount', 
                                      Industry = 'Media', 
                                      Type = 'Prospect');
        insert account;
        Id [] fixedSearchResults = new Id[] {account.id};
            Test.setFixedSearchResults(fixedSearchResults);
        
        List<Account> actual = AccountPreviewController.findAccounts('TestAccount');
        system.assertEquals(account.Id, actual[0].Id);
    }
    
    @isTest
    private static void testUpdateAccounts() {
        Account account = [SELECT Name FROM Account LIMIT 1];
        account.Name = 'UpdatedAccount';
        List<Account> updatedAccount = AccountPreviewController.updateAccounts(new List<Account>{account});
        system.assertEquals([SELECT Name 
                             FROM Account 
                             WHERE Id =: account.Id].Name, updatedAccount[0].Name);
    }
    
    @isTest
    private static void testSendAccounts() {
        test.startTest();
        test.setMock(HttpCalloutMock.class, new CalloutMock(
            201, 
            '{"name":"Account"}'));
        Integer actual = AccountPreviewController.sendAccounts([SELECT Id FROM Account LIMIT 1].Id);
        test.stopTest();
    }
}