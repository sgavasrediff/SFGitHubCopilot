import { LightningElement, track } from 'lwc';
import getAccounts from '@salesforce/apex/MSTAR_AccountHelper.getAccounts';
import getRelatedContacts from '@salesforce/apex/MSTAR_AccountContactHelper.getRelatedContacts';

/**
 * @description LWC Component to display Account records in a datatable
 * Provides search functionality to filter accounts by name
 */
export default class MstarAccountDatatable extends LightningElement {
    
    // Track reactive properties
    @track accounts = [];
    @track searchTerm = '';
    @track isLoading = false;
    @track isLoadingContacts = false;
    @track columns = [
        {
            label: 'Account Name',
            fieldName: 'Name',
            type: 'text',
            sortable: true
        },
        {
            label: 'Account ID',
            fieldName: 'Id',
            type: 'text',
            sortable: true
        },
        {
            label: 'Record Type ID',
            fieldName: 'RecordTypeId',
            type: 'text',
            sortable: false
        },
        {
            label: 'Created Date',
            fieldName: 'CreatedDate',
            type: 'date',
            typeAttributes: {
                year: 'numeric',
                month: '2-digit',
                day: '2-digit'
            },
            sortable: true
        }
    ];
    
    // Contact related properties
    @track contactData = [];
    @track contactColumns = [
        { label: 'First Name', fieldName: 'FirstName', type: 'text' },
        { label: 'Last Name', fieldName: 'LastName', type: 'text' },
        { label: 'Email', fieldName: 'Email', type: 'email' }
    ];
    
    @track selectedAccountId = null;
    @track selectedAccountName = '';
    @track isContactsVisible = false;
    @track currentPage = 1;
    @track pageSize = 10;
    @track totalPages = 0;
    @track totalRecords = 0;
    @track errorMessage = '';

    /**
     * @description Lifecycle hook - Called when component is inserted into DOM
     * Fetches initial set of 10 accounts
     */
    connectedCallback() {
        this.loadAccounts();
    }

    /**
     * @description Fetches accounts from Apex helper class
     * @param searchValue Optional search term to filter accounts
     */
    loadAccounts(searchValue = '') {
        this.isLoading = true;
        
        // Call Apex method to fetch accounts
        getAccounts({ searchTerm: searchValue, limitCount: 10 })
            .then(result => {
                // Map the result to format CreatedDate properly
                this.accounts = result.map(account => ({
                    ...account,
                    CreatedDate: new Date(account.CreatedDate).toLocaleDateString()
                }));
                this.isLoading = false;
            })
            .catch(error => {
                console.error('Error loading accounts:', error);
                this.isLoading = false;
                
                // Display error notification
                this.showErrorToast('Error loading accounts');
            });
    }

    /**
     * @description Handles search input change event
     * @param event Change event from input field
     */
    handleSearchChange(event) {
        this.searchTerm = event.target.value;
        // Load accounts when search term changes
        this.loadAccounts(this.searchTerm);
    }

    /**
     * @description Displays error toast notification
     * @param message Error message to display
     */
    showErrorToast(message) {
        // Toast notification can be added here using lightning-notification
        console.error(message);
    }

    /**
     * @description Handle account row selection
     * @param event - Row selection event from datatable
     */
    handleAccountRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        
        if (selectedRows.length > 0) {
            this.selectedAccountId = selectedRows[0].Id;
            this.selectedAccountName = selectedRows[0].Name;
            this.currentPage = 1;
            this.errorMessage = '';
            this.loadContactsForAccount();
        }
    }

    /**
     * @description Load related contacts for selected account
     */
    loadContactsForAccount() {
        this.isLoadingContacts = true;
        
        getRelatedContacts({
            accountId: this.selectedAccountId,
            pageSize: this.pageSize,
            pageNumber: this.currentPage
        })
            .then((result) => {
                this.contactData = result.contacts;
                this.totalRecords = result.totalRecords;
                this.totalPages = result.totalPages;
                this.isContactsVisible = true;
                this.isLoadingContacts = false;
            })
            .catch((error) => {
                this.errorMessage = 'Error loading contacts: ' + error.body.message;
                this.isLoadingContacts = false;
            });
    }

    /**
     * @description Handle next button click for pagination
     */
    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.loadContactsForAccount();
        }
    }

    /**
     * @description Handle previous button click for pagination
     */
    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.loadContactsForAccount();
        }
    }

    /**
     * @description Check if next button should be disabled
     */
    get isNextDisabled() {
        return this.currentPage >= this.totalPages;
    }

    /**
     * @description Check if previous button should be disabled
     */
    get isPreviousDisabled() {
        return this.currentPage <= 1;
    }

    /**
     * @description Get pagination info text
     */
    get paginationInfo() {
        if (this.totalRecords === 0) {
            return 'No contacts found';
        }
        return `Page ${this.currentPage} of ${this.totalPages} (Total: ${this.totalRecords} records)`;
    }
}
