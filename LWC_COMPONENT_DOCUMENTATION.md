# MSTAR Account Data Display Component

## Overview
The MSTAR Account Data Display component is a Lightning Web Component (LWC) that provides a comprehensive interface for viewing and managing Account records with related Contacts. It includes search functionality, pagination, and single-select account capability.

## Features

### 1. Account Display
- Displays Account records in a Lightning Datatable
- Shows the following columns:
  - **Name**: Account name
  - **AccountNumber**: Unique account number
  - **Type**: Account type (Prospect, Customer, Partner, etc.)
  - **AccountStatus__c**: Current account status
  - **CreatedDate**: Account creation date

### 2. Search Functionality
- Search Accounts by name using a text input field
- Real-time search with pagination reset
- Handles null/empty search gracefully

### 3. Account Selection
- Single-select capability (only one account can be selected at a time)
- Selected account highlights in the datatable
- Clicking a different account automatically deselects the previous one

### 4. Related Contacts Display
- Upon selecting an Account, displays all related Contacts
- Shows the following contact columns:
  - **FirstName**: Contact first name
  - **LastName**: Contact last name
  - **Email**: Contact email address
- Displayed in a separate section below the accounts table

### 5. Pagination
- **Page Size**: 10 records per page for both tables
- **Previous Button**: Navigate to the previous page (disabled on first page)
- **Next Button**: Navigate to the next page (disabled on last page)
- **Page Indicator**: Shows current page and total pages
- Independent pagination for Accounts and Contacts

## Architecture

### Backend (Apex)
**Class**: `MSTAR_AccountDataHelper`

#### Methods

##### `getAccounts(String searchKey, Integer pageNumber)`
- **Purpose**: Fetch Account records with search and pagination
- **Parameters**:
  - `searchKey`: Search string to filter by account name (supports partial match)
  - `pageNumber`: Page number for pagination (1-based indexing)
- **Returns**: `List<Account>` - Up to 10 Account records

##### `getContacts(String accountId, Integer pageNumber)`
- **Purpose**: Fetch Contact records related to an Account
- **Parameters**:
  - `accountId`: The Id of the Account to fetch Contacts for
  - `pageNumber`: Page number for pagination
- **Returns**: `List<Contact>` - Up to 10 Contact records

##### `getTotalAccountCount(String searchKey)`
- **Purpose**: Get the total count of Accounts matching search criteria
- **Parameters**:
  - `searchKey`: Search string to filter by account name
- **Returns**: `Integer` - Total number of matching Accounts

##### `getTotalContactCount(String accountId)`
- **Purpose**: Get the total count of Contacts for an Account
- **Parameters**:
  - `accountId`: The Id of the Account
- **Returns**: `Integer` - Total number of Contacts for the Account

### Frontend (LWC)
**Component**: `mstarAccountDataDisplay`

#### Key Properties
- `searchKey`: Current search input value
- `accountList`: Array of Account records for current page
- `contactList`: Array of Contact records for current page
- `currentAccountPage`: Current page number for Accounts
- `currentContactPage`: Current page number for Contacts
- `totalAccountPages`: Total number of pages for Accounts
- `totalContactPages`: Total number of pages for Contacts
- `selectedAccountId`: Id of the currently selected Account
- `selectedAccountName`: Name of the currently selected Account

#### Key Methods
- `connectedCallback()`: Initialize component and load first page of Accounts
- `loadAccounts()`: Fetch Accounts for current page and search criteria
- `loadContacts(accountId)`: Fetch Contacts for selected Account
- `handleSearchChange()`: Handle search input changes
- `handleAccountSelection()`: Handle Account row selection
- `handlePreviousAccounts()`: Navigate to previous Account page
- `handleNextAccounts()`: Navigate to next Account page
- `handlePreviousContacts()`: Navigate to previous Contact page
- `handleNextContacts()`: Navigate to next Contact page

## Usage

### Adding to a Page
1. In a Lightning App page, add the component from the component list
2. Search for "MSTAR Account Data Display"
3. Add it to the page
4. Configure any necessary properties if needed

### Component Behavior
1. **Initial Load**: Component loads with the first 10 Accounts on page load
2. **Search**: Enter text in the search field to filter Accounts by name
3. **Selection**: Click on a row to select an Account
4. **View Contacts**: Upon selection, related Contacts appear in the lower section
5. **Pagination**: Use Previous/Next buttons to navigate through pages

## Governor Limits Consideration
- **SOQL Queries**: Each method uses dynamic SOQL with proper escaping
- **Query Efficiency**: Implements offset-based pagination to fetch only required records
- **Cacheable Methods**: Uses `@AuraEnabled(cacheable=true)` for performance

## Testing
Comprehensive test class included: `MSTAR_AccountDataHelper_TEST`

### Test Coverage
- ✅ Account retrieval with pagination
- ✅ Account search functionality
- ✅ Contact retrieval for selected Accounts
- ✅ Total count calculations
- ✅ Edge cases (null parameters, invalid IDs)
- ✅ Column field validation

### Running Tests
```bash
sf apex run test --test-class MSTAR_AccountDataHelper_TEST
```

## Field Requirements
The component requires the following fields to be present in your Salesforce org:

### Account Fields
- `Name` (Standard)
- `AccountNumber` (Standard)
- `Type` (Standard)
- `AccountStatus__c` (Custom field required - create if not exists)
- `CreatedDate` (Standard)

### Contact Fields
- `FirstName` (Standard)
- `LastName` (Standard)
- `Email` (Standard)
- `AccountId` (Standard relationship field)

## Styling
The component uses Salesforce Lightning Design System (SLDS) classes for consistent styling. Custom CSS included for:
- Responsive layout
- Mobile-friendly pagination
- Loading states
- Empty states

## Error Handling
- All Apex methods include try-catch error handling
- User-friendly error messages displayed via Lightning Toast
- Graceful handling of null/empty parameters

## Future Enhancements
- Export data functionality
- Inline editing capabilities
- Advanced filters (Type, Status, etc.)
- Batch contact operations
- Custom column visibility toggle

## Version
- **Component Version**: 1.0
- **Salesforce API Version**: 59.0
- **Last Updated**: November 2025

## Support
For issues or feature requests, please contact the development team or create an issue in the repository.
