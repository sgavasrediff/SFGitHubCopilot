/**
 * @description Helper class for Account and Contact related operations.
 * Provides methods to fetch related contacts with pagination support.
 * @author MSTAR
 */
public class MSTAR_AccountContactHelper {
    
    /**
     * @description Fetches related contacts for a given account with pagination.
     * Returns FirstName, LastName, and Email fields for each contact.
     * @param accountId The ID of the account to fetch contacts for
     * @param pageSize Number of records to fetch per page (default: 10)
     * @param pageNumber Current page number (starts from 1)
     * @return Map containing contacts list and total record count
     * @throws AuraHandledException if account ID is invalid
     */
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getRelatedContacts(String accountId, Integer pageSize, Integer pageNumber) {
        try {
            // Validate input parameters
            if (String.isBlank(accountId)) {
                throw new AuraHandledException('Account ID cannot be null or empty');
            }
            
            if (pageSize == null || pageSize <= 0) {
                pageSize = 10;
            }
            
            if (pageNumber == null || pageNumber < 1) {
                pageNumber = 1;
            }
            
            // Calculate offset for pagination
            Integer offset = (pageNumber - 1) * pageSize;
            
            // Query to get total count of related contacts
            Integer totalRecords = [
                SELECT COUNT() 
                FROM Contact 
                WHERE AccountId = :accountId
            ];
            
            // Query to fetch paginated contacts
            List<Contact> contacts = [
                SELECT Id, FirstName, LastName, Email
                FROM Contact
                WHERE AccountId = :accountId
                ORDER BY LastName, FirstName
                LIMIT :pageSize
                OFFSET :offset
            ];
            
            // Calculate total pages
            Integer totalPages = (Integer) Math.ceil((Decimal) totalRecords / pageSize);
            
            // Build response map
            Map<String, Object> response = new Map<String, Object>();
            response.put('contacts', contacts);
            response.put('totalRecords', totalRecords);
            response.put('totalPages', totalPages);
            response.put('currentPage', pageNumber);
            response.put('pageSize', pageSize);
            
            return response;
        } catch (Exception ex) {
            throw new AuraHandledException('Error fetching related contacts: ' + ex.getMessage());
        }
    }
}
