/**
 * @description Helper class to handle Account-related operations for LWC components
 * @author Salesforce Developer
 * @date 2024
 */
public with sharing class MSTAR_AccountHelper {
    
    /**
     * @description Fetches Account records with optional search filter
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
            if (String.isNotBlank(searchTerm)) {
                query += ' WHERE Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\'';
            }
            
            // Add ordering and limit
            query += ' ORDER BY CreatedDate DESC LIMIT ' + limitCount;
            
            // Execute query and return results
            return Database.query(query);
            
        } catch (Exception ex) {
            // Log exception for debugging
            System.debug('Error in MSTAR_AccountHelper.getAccounts: ' + ex.getMessage());
            throw new AuraHandledException('Error fetching accounts: ' + ex.getMessage());
        }
    }
}
