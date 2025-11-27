/**
 * @description Helper class to handle Account-related operations for LWC components
 * @author Salesforce Developer
 * @date 2024
 */
public with sharing class MSTAR_AccountHelper {
    
    /**
     * @description Fetches Account records with optional search filter and pagination support
     * @param searchTerm Search term to filter accounts by name (can be null or empty)
     * @param limitCount Number of records to return (default 10)
     * @return List of Account records with Name, Id, RecordTypeId, and CreatedDate fields
     */
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(String searchTerm, Integer limitCount) {
        try {
            // Validate input parameters
            if (limitCount == null || limitCount <= 0) {
                limitCount = 10;
            }
            
            // Build SOQL query with dynamic search filter
            String query = 'SELECT Id, Name, RecordTypeId, CreatedDate FROM Account';
            
            // Add search filter if search term is provided
            List<Account> accounts;
            if (String.isNotBlank(searchTerm)) {
                accounts = [SELECT Id, Name, RecordTypeId, CreatedDate 
                            FROM Account 
                            WHERE Name LIKE :('%' + searchTerm + '%')
                            ORDER BY CreatedDate DESC
                            LIMIT :limitCount];
            } else {
                accounts = [SELECT Id, Name, RecordTypeId, CreatedDate 
                            FROM Account 
                            ORDER BY CreatedDate DESC
                            LIMIT :limitCount];
            }
            
            // Execute query and return results
            return accounts;
            
        } catch (Exception ex) {
            // Log exception for internal debugging
            System.debug('Error in MSTAR_AccountHelper.getAccounts: ' + ex.getMessage());
            // Throw a generic error message to the user
            throw new AuraHandledException('An unexpected error occurred while fetching accounts. Please contact your administrator.');
        }
    }

    /**
     * @description Fetches Account records with pagination support
     * Returns FirstName, LastName, and Email fields for each account.
     * @param searchTerm Search term to filter accounts by name (can be null or empty)
     * @param pageSize Number of records to fetch per page (default: 10)
     * @param pageNumber Current page number (starts from 1)
     * @return Map containing accounts list and total record count
     * @throws AuraHandledException if parameters are invalid
     */
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getAccountsWithPagination(String searchTerm, Integer pageSize, Integer pageNumber) {
        try {
            // Validate input parameters
            if (pageSize == null || pageSize <= 0) {
                pageSize = 10;
            }
            
            if (pageNumber == null || pageNumber < 1) {
                pageNumber = 1;
            }
            
            // Calculate offset for pagination
            Integer offset = (pageNumber - 1) * pageSize;
            
            // Query to get total count of accounts
            Integer totalRecords;
            if (String.isNotBlank(searchTerm)) {
                totalRecords = [
                    SELECT COUNT() 
                    FROM Account 
                    WHERE Name LIKE :('%' + searchTerm + '%')
                ];
            } else {
                totalRecords = [
                    SELECT COUNT() 
                    FROM Account
                ];
            }
            
            // Query to fetch paginated accounts
            List<Account> accounts;
            if (String.isNotBlank(searchTerm)) {
                accounts = [
                    SELECT Id, Name, RecordTypeId, CreatedDate
                    FROM Account
                    WHERE Name LIKE :('%' + searchTerm + '%')
                    ORDER BY CreatedDate DESC
                    LIMIT :pageSize
                    OFFSET :offset
                ];
            } else {
                accounts = [
                    SELECT Id, Name, RecordTypeId, CreatedDate
                    FROM Account
                    ORDER BY CreatedDate DESC
                    LIMIT :pageSize
                    OFFSET :offset
                ];
            }
            
            // Calculate total pages
            Integer totalPages = (Integer) Math.ceil((Decimal) totalRecords / pageSize);
            
            // Build response map
            Map<String, Object> response = new Map<String, Object>();
            response.put('accounts', accounts);
            response.put('totalRecords', totalRecords);
            response.put('totalPages', totalPages);
            response.put('currentPage', pageNumber);
            response.put('pageSize', pageSize);
            
            return response;
        } catch (Exception ex) {
            throw new AuraHandledException('Error fetching accounts: ' + ex.getMessage());
        }
    }
}
