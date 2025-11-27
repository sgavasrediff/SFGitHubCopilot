/**
 * MSTAR Account Data Display Component
 * 
 * Displays Account records in a Lightning Datatable with search and pagination functionality.
 * Upon selecting an Account, displays related Contacts in another Datatable.
 * 
 * Features:
 * - Display 10 Account records by default
 * - Search Accounts by name
 * - Single Account selection
 * - Display related Contacts for selected Account
 * - Pagination for both Account and Contact tables (10 records per page)
 */

import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccounts from '@salesforce/apex/MSTAR_AccountDataHelper.getAccounts';
import getContacts from '@salesforce/apex/MSTAR_AccountDataHelper.getContacts';
import getTotalAccountCount from '@salesforce/apex/MSTAR_AccountDataHelper.getTotalAccountCount';
import getTotalContactCount from '@salesforce/apex/MSTAR_AccountDataHelper.getTotalContactCount';

// Constants
const PAGE_SIZE = 10;

// Account Datatable Columns Definition
const ACCOUNT_COLUMNS = [
    { label: 'Name', fieldName: 'Name', type: 'text', sortable: true },
    { label: 'Account Number', fieldName: 'AccountNumber', type: 'text' },
    { label: 'Type', fieldName: 'Type', type: 'text' },
    { label: 'Status', fieldName: 'AccountStatus__c', type: 'text' },
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'date', typeAttributes: { year: 'numeric', month: '2-digit', day: '2-digit' } }
];

// Contact Datatable Columns Definition
const CONTACT_COLUMNS = [
    { label: 'First Name', fieldName: 'FirstName', type: 'text' },
    { label: 'Last Name', fieldName: 'LastName', type: 'text' },
    { label: 'Email', fieldName: 'Email', type: 'email' }
];

export default class MstarAccountDataDisplay extends LightningElement {
    // Account Properties
    @track accountList = [];
    @track accountColumns = ACCOUNT_COLUMNS;
    @track currentAccountPage = 1;
    @track totalAccountPages = 1;
    @track totalAccountCount = 0;
    @track isLoadingAccounts = false;
    @track selectedAccountRows = [];
    @track selectedAccountId = null;
    @track selectedAccountName = '';
    
    // Contact Properties
    @track contactList = [];
    @track contactColumns = CONTACT_COLUMNS;
    @track currentContactPage = 1;
    @track totalContactPages = 1;
    @track totalContactCount = 0;
    @track isLoadingContacts = false;
    
    // Search Property
    @track searchKey = '';
    
    /**
     * Component initialization
     * Load initial Accounts on component mount
     */
    connectedCallback() {
        this.loadAccounts();
    }
    
    /**
     * loadAccounts
     * Fetch Accounts based on current search key and page number
     */
    async loadAccounts() {
        this.isLoadingAccounts = true;
        try {
            // Fetch total count for pagination
            this.totalAccountCount = await getTotalAccountCount({ 
                searchKey: this.searchKey 
            });
            
            // Calculate total pages
            this.totalAccountPages = Math.ceil(this.totalAccountCount / PAGE_SIZE) || 1;
            
            // Fetch accounts for current page
            this.accountList = await getAccounts({ 
                searchKey: this.searchKey,
                pageNumber: this.currentAccountPage
            });
            
            // Clear selected rows and contacts when search changes
            this.selectedAccountRows = [];
            this.selectedAccountId = null;
            this.contactList = [];
            
        } catch (error) {
            this.showErrorToast('Error loading accounts: ' + error.body.message);
        } finally {
            this.isLoadingAccounts = false;
        }
    }
    
    /**
     * loadContacts
     * Fetch Contacts for the selected Account
     * 
     * @param {string} accountId - The Id of the selected Account
     */
    async loadContacts(accountId) {
        this.isLoadingContacts = true;
        try {
            // Fetch total count for pagination
            this.totalContactCount = await getTotalContactCount({ 
                accountId: accountId 
            });
            
            // Calculate total pages
            this.totalContactPages = Math.ceil(this.totalContactCount / PAGE_SIZE) || 1;
            
            // Fetch contacts for current page
            this.contactList = await getContacts({ 
                accountId: accountId,
                pageNumber: this.currentContactPage
            });
            
            // Reset to first page
            this.currentContactPage = 1;
            
        } catch (error) {
            this.showErrorToast('Error loading contacts: ' + error.body.message);
        } finally {
            this.isLoadingContacts = false;
        }
    }
    
    /**
     * handleSearchChange
     * Handle search input change and reset pagination
     */
    handleSearchChange(event) {
        this.searchKey = event.detail.value;
        this.currentAccountPage = 1;
        this.loadAccounts();
    }
    
    /**
     * handleAccountSelection
     * Handle Account row selection and load related Contacts
     */
    handleAccountSelection(event) {
        const selectedRows = event.detail.selectedRows;
        
        if (selectedRows.length > 0) {
            const selectedAccount = selectedRows[0];
            this.selectedAccountId = selectedAccount.Id;
            this.selectedAccountName = selectedAccount.Name;
            this.currentContactPage = 1;
            this.loadContacts(selectedAccount.Id);
        } else {
            this.selectedAccountId = null;
            this.selectedAccountName = '';
            this.contactList = [];
        }
    }
    
    /**
     * handlePreviousAccounts
     * Navigate to previous page of Accounts
     */
    handlePreviousAccounts() {
        if (this.currentAccountPage > 1) {
            this.currentAccountPage--;
            this.loadAccounts();
            // Clear contact selection when changing pages
            this.selectedAccountRows = [];
            this.selectedAccountId = null;
            this.contactList = [];
        }
    }
    
    /**
     * handleNextAccounts
     * Navigate to next page of Accounts
     */
    handleNextAccounts() {
        if (this.currentAccountPage < this.totalAccountPages) {
            this.currentAccountPage++;
            this.loadAccounts();
            // Clear contact selection when changing pages
            this.selectedAccountRows = [];
            this.selectedAccountId = null;
            this.contactList = [];
        }
    }
    
    /**
     * handlePreviousContacts
     * Navigate to previous page of Contacts
     */
    handlePreviousContacts() {
        if (this.currentContactPage > 1) {
            this.currentContactPage--;
            this.loadContacts(this.selectedAccountId);
        }
    }
    
    /**
     * handleNextContacts
     * Navigate to next page of Contacts
     */
    handleNextContacts() {
        if (this.currentContactPage < this.totalContactPages) {
            this.currentContactPage++;
            this.loadContacts(this.selectedAccountId);
        }
    }
    
    /**
     * Computed Properties for Pagination States
     */
    get isFirstAccountPage() {
        return this.currentAccountPage === 1;
    }
    
    get isLastAccountPage() {
        return this.currentAccountPage >= this.totalAccountPages;
    }
    
    get isFirstContactPage() {
        return this.currentContactPage === 1;
    }
    
    get isLastContactPage() {
        return this.currentContactPage >= this.totalContactPages;
    }
    
    /**
     * showErrorToast
     * Display error message to user
     * 
     * @param {string} message - Error message to display
     */
    showErrorToast(message) {
        const event = new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error'
        });
        this.dispatchEvent(event);
    }
}
