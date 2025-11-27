/**
 * MSTAR_AccountDataHelper_TEST
 * Test class for MSTAR_AccountDataHelper
 * 
 * Tests the following functionality:
 * - getAccounts with search key and pagination
 * - getContacts with pagination
 * - getTotalAccountCount with search filter
 * - getTotalContactCount
 */
@isTest
private class MSTAR_AccountDataHelper_TEST {
    
    /**
     * Setup test data
     * Create test Accounts and Contacts
     */
    @testSetup
    static void setupTestData() {
        // Create test Accounts
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 1; i <= 15; i++) {
            testAccounts.add(new Account(
                Name = 'Test Account ' + i,
                AccountNumber = 'ACC-' + String.valueOf(i).leftPad(5, '0'),
                Type = i <= 5 ? 'Prospect' : (i <= 10 ? 'Customer' : 'Partner'),
                AccountStatus__c = 'Active'
            ));
        }
        insert testAccounts;
        
        // Create test Contacts
        List<Contact> testContacts = new List<Contact>();
        for (Integer i = 0; i < 15; i++) {
            Account acc = testAccounts[i / 5]; // Distribute contacts across accounts
            testContacts.add(new Contact(
                FirstName = 'Test',
                LastName = 'Contact ' + i,
                Email = 'testcontact' + i + '@example.com',
                AccountId = acc.Id
            ));
        }
        insert testContacts;
    }
    
    /**
     * Test getAccounts returns 10 records on first page
     */
    @isTest
    static void testGetAccountsFirstPage() {
        Test.startTest();
        List<Account> accounts = MSTAR_AccountDataHelper.getAccounts('', 1);
        Test.stopTest();
        
        System.assertEquals(10, accounts.size(), 'Should return 10 accounts on first page');
        System.assertNotEquals(null, accounts[0].Id, 'Account should have Id');
    }
    
    /**
     * Test getAccounts with pagination
     */
    @isTest
    static void testGetAccountsPagination() {
        Test.startTest();
        List<Account> firstPage = MSTAR_AccountDataHelper.getAccounts('', 1);
        List<Account> secondPage = MSTAR_AccountDataHelper.getAccounts('', 2);
        Test.stopTest();
        
        System.assertEquals(10, firstPage.size(), 'First page should have 10 accounts');
        System.assertEquals(5, secondPage.size(), 'Second page should have 5 accounts');
        System.assertNotEquals(firstPage[0].Id, secondPage[0].Id, 'Pages should have different accounts');
    }
    
    /**
     * Test getAccounts with search key
     */
    @isTest
    static void testGetAccountsWithSearch() {
        Test.startTest();
        List<Account> results = MSTAR_AccountDataHelper.getAccounts('Test Account 1', 1);
        Test.stopTest();
        
        // Should return accounts with "Test Account 1" in the name
        System.assertNotEquals(0, results.size(), 'Should return accounts matching search criteria');
        for (Account acc : results) {
            System.assert(acc.Name.contains('Test Account 1'), 'Account name should contain search key');
        }
    }
    
    /**
     * Test getAccounts with null search key
     */
    @isTest
    static void testGetAccountsNullSearch() {
        Test.startTest();
        List<Account> accounts = MSTAR_AccountDataHelper.getAccounts(null, 1);
        Test.stopTest();
        
        System.assertEquals(10, accounts.size(), 'Should handle null search key gracefully');
    }
    
    /**
     * Test getAccounts with null page number
     */
    @isTest
    static void testGetAccountsNullPageNumber() {
        Test.startTest();
        List<Account> accounts = MSTAR_AccountDataHelper.getAccounts('', null);
        Test.stopTest();
        
        System.assertEquals(10, accounts.size(), 'Should default to page 1 when pageNumber is null');
    }
    
    /**
     * Test getContacts for selected account
     */
    @isTest
    static void testGetContacts() {
        // Get first account
        List<Account> accounts = [SELECT Id FROM Account LIMIT 1];
        String accountId = accounts[0].Id;
        
        Test.startTest();
        List<Contact> contacts = MSTAR_AccountDataHelper.getContacts(accountId, 1);
        Test.stopTest();
        
        System.assertNotEquals(0, contacts.size(), 'Should return contacts for the account');
        System.assertEquals('Test', contacts[0].FirstName, 'Contact should have correct first name');
    }
    
    /**
     * Test getContacts with invalid account ID
     */
    @isTest
    static void testGetContactsInvalidAccount() {
        Test.startTest();
        List<Contact> contacts = MSTAR_AccountDataHelper.getContacts('', 1);
        Test.stopTest();
        
        System.assertEquals(0, contacts.size(), 'Should return empty list for invalid account ID');
    }
    
    /**
     * Test getContacts with null account ID
     */
    @isTest
    static void testGetContactsNullAccount() {
        Test.startTest();
        List<Contact> contacts = MSTAR_AccountDataHelper.getContacts(null, 1);
        Test.stopTest();
        
        System.assertEquals(0, contacts.size(), 'Should return empty list for null account ID');
    }
    
    /**
     * Test getTotalAccountCount without filter
     */
    @isTest
    static void testGetTotalAccountCount() {
        Test.startTest();
        Integer count = MSTAR_AccountDataHelper.getTotalAccountCount('');
        Test.stopTest();
        
        System.assertEquals(15, count, 'Should return total count of 15 accounts');
    }
    
    /**
     * Test getTotalAccountCount with search filter
     */
    @isTest
    static void testGetTotalAccountCountWithFilter() {
        Test.startTest();
        Integer count = MSTAR_AccountDataHelper.getTotalAccountCount('Test Account 1');
        Test.stopTest();
        
        System.assertNotEquals(0, count, 'Should return count matching search criteria');
    }
    
    /**
     * Test getTotalAccountCount with null search key
     */
    @isTest
    static void testGetTotalAccountCountNull() {
        Test.startTest();
        Integer count = MSTAR_AccountDataHelper.getTotalAccountCount(null);
        Test.stopTest();
        
        System.assertEquals(15, count, 'Should handle null search key and return total count');
    }
    
    /**
     * Test getTotalContactCount for account
     */
    @isTest
    static void testGetTotalContactCount() {
        List<Account> accounts = [SELECT Id FROM Account LIMIT 1];
        String accountId = accounts[0].Id;
        
        Test.startTest();
        Integer count = MSTAR_AccountDataHelper.getTotalContactCount(accountId);
        Test.stopTest();
        
        System.assertNotEquals(0, count, 'Should return contact count for account');
    }
    
    /**
     * Test getTotalContactCount with invalid account ID
     */
    @isTest
    static void testGetTotalContactCountInvalidAccount() {
        Test.startTest();
        Integer count = MSTAR_AccountDataHelper.getTotalContactCount('invalid-id');
        Test.stopTest();
        
        System.assertEquals(0, count, 'Should return 0 for invalid account ID');
    }
    
    /**
     * Test getTotalContactCount with null account ID
     */
    @isTest
    static void testGetTotalContactCountNull() {
        Test.startTest();
        Integer count = MSTAR_AccountDataHelper.getTotalContactCount(null);
        Test.stopTest();
        
        System.assertEquals(0, count, 'Should return 0 for null account ID');
    }
    
    /**
     * Test column fields are returned correctly
     */
    @isTest
    static void testAccountColumnsReturned() {
        Test.startTest();
        List<Account> accounts = MSTAR_AccountDataHelper.getAccounts('', 1);
        Test.stopTest();
        
        Account acc = accounts[0];
        System.assertNotEquals(null, acc.Name, 'Should return Name field');
        System.assertNotEquals(null, acc.AccountNumber, 'Should return AccountNumber field');
        System.assertNotEquals(null, acc.Type, 'Should return Type field');
    }
    
    /**
     * Test contact columns are returned correctly
     */
    @isTest
    static void testContactColumnsReturned() {
        List<Account> accounts = [SELECT Id FROM Account LIMIT 1];
        String accountId = accounts[0].Id;
        
        Test.startTest();
        List<Contact> contacts = MSTAR_AccountDataHelper.getContacts(accountId, 1);
        Test.stopTest();
        
        Contact contact = contacts[0];
        System.assertNotEquals(null, contact.FirstName, 'Should return FirstName field');
        System.assertNotEquals(null, contact.LastName, 'Should return LastName field');
        System.assertNotEquals(null, contact.Email, 'Should return Email field');
    }
}
