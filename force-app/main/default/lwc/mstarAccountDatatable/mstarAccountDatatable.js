import { LightningElement, track } from 'lwc';
import getAccounts from '@salesforce/apex/MSTAR_AccountHelper.getAccounts';

/**
 * @description LWC Component to display Account records in a datatable
 * Provides search functionality to filter accounts by name
 */
export default class MstarAccountDatatable extends LightningElement {
    
    // Track reactive properties
    @track accounts = [];
    @track searchTerm = '';
    @track isLoading = false;
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
}
