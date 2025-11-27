/**
 * MSTAR_AccountDataHelper
 * Helper class to manage Account and Contact data retrieval for the Account Data Display component
 * 
 * Methods:
 * - getAccounts: Fetches Account records based on search key and pagination
 * - getContacts: Fetches related Contacts for a given Account with pagination
 */
public with sharing class MSTAR_AccountDataHelper {
    
    // Constants
    private static final Integer PAGE_SIZE = 10;
    
    /**
     * getAccounts
     * Fetches Account records based on search key and pagination parameters
     * 
     * @param searchKey - String to search in Account Name (can be empty for all records)
     * @param pageNumber - Page number for pagination (1-based)
     * @return List<Account> - List of Account records for the requested page
     */
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(String searchKey, Integer pageNumber) {
        try {
            // Validate input parameters
            if (pageNumber == null || pageNumber < 1) {
                pageNumber = 1;
            }
            
            if (searchKey == null) {
                searchKey = '';
            }
            
            // Calculate offset for pagination
            Integer offset = (pageNumber - 1) * PAGE_SIZE;
            
            // Build SOQL query with search filter
            String query = 'SELECT Id, Name, AccountNumber, Type, AccountStatus__c, CreatedDate ' +
                          'FROM Account ';
            
            if (String.isNotBlank(searchKey)) {
                query += 'WHERE Name LIKE \'%' + String.escapeSingleQuotes(searchKey) + '%\' ';
            }
            
            query += 'ORDER BY CreatedDate DESC LIMIT ' + PAGE_SIZE + ' OFFSET ' + offset;
            
            return Database.query(query);
            
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching accounts: ' + e.getMessage());
        }
    }
    
    /**
     * getContacts
     * Fetches related Contacts for a specific Account with pagination
     * 
     * @param accountId - Id of the Account to fetch Contacts for
     * @param pageNumber - Page number for pagination (1-based)
     * @return List<Contact> - List of Contact records for the requested page
     */
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(String accountId, Integer pageNumber) {
        try {
            // Validate input parameters
            if (String.isBlank(accountId)) {
                return new List<Contact>();
            }
            
            if (pageNumber == null || pageNumber < 1) {
                pageNumber = 1;
            }
            
            // Calculate offset for pagination
            Integer offset = (pageNumber - 1) * PAGE_SIZE;
            
            // Query Contacts related to the Account
            String query = 'SELECT Id, FirstName, LastName, Email ' +
                          'FROM Contact ' +
                          'WHERE AccountId = \'' + String.escapeSingleQuotes(accountId) + '\' ' +
                          'ORDER BY CreatedDate DESC LIMIT ' + PAGE_SIZE + ' OFFSET ' + offset;
            
            return Database.query(query);
            
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching contacts: ' + e.getMessage());
        }
    }
    
    /**
     * getTotalAccountCount
     * Gets the total count of Accounts matching the search criteria
     * Used for determining total pages available
     * 
     * @param searchKey - String to search in Account Name
     * @return Integer - Total number of matching Accounts
     */
    @AuraEnabled(cacheable=true)
    public static Integer getTotalAccountCount(String searchKey) {
        try {
            if (searchKey == null) {
                searchKey = '';
            }
            
            String query = 'SELECT COUNT() FROM Account ';
            
            if (String.isNotBlank(searchKey)) {
                query += 'WHERE Name LIKE \'%' + String.escapeSingleQuotes(searchKey) + '%\'';
            }
            
            return Database.countQuery(query);
            
        } catch (Exception e) {
            throw new AuraHandledException('Error getting account count: ' + e.getMessage());
        }
    }
    
    /**
     * getTotalContactCount
     * Gets the total count of Contacts for an Account
     * Used for determining total pages available
     * 
     * @param accountId - Id of the Account
     * @return Integer - Total number of Contacts for the Account
     */
    @AuraEnabled(cacheable=true)
    public static Integer getTotalContactCount(String accountId) {
        try {
            if (String.isBlank(accountId)) {
                return 0;
            }
            
            // Validate that accountId is a valid Salesforce ID format
            if (!isValidSalesforceId(accountId)) {
                return 0;
            }
            
            String query = 'SELECT COUNT() FROM Contact WHERE AccountId = \'' + 
                          String.escapeSingleQuotes(accountId) + '\'';
            
            return Database.countQuery(query);
            
        } catch (Exception e) {
            // Return 0 for invalid IDs instead of throwing exception
            return 0;
        }
    }
    
    /**
     * isValidSalesforceId
     * Validates if a string is a valid Salesforce ID format
     * 
     * @param idToValidate - String to validate
     * @return Boolean - true if valid Salesforce ID, false otherwise
     */
    private static Boolean isValidSalesforceId(String idToValidate) {
        if (String.isBlank(idToValidate)) {
            return false;
        }
        // Salesforce IDs are 15 or 18 characters
        return (idToValidate.length() == 15 || idToValidate.length() == 18);
    }
}
