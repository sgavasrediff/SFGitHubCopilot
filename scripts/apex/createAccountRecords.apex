// Script to create 25 random account records
// Execute this in the Salesforce Developer Console

List<Account> accountsToCreate = new List<Account>();

// Array of random account name prefixes and suffixes
List<String> prefixes = new List<String>{
    'Acme', 'Global', 'Tech', 'Premier', 'Elite', 'Advanced', 'Dynamic', 'Future',
    'Smart', 'Digital', 'Cloud', 'Quantum', 'Cyber', 'Nexus', 'Synergy',
    'Vertex', 'Prism', 'Matrix', 'Summit', 'Catalyst', 'Compass', 'Zenith',
    'Apex', 'Horizon', 'Infinity'
};

List<String> suffixes = new List<String>{
    'Solutions', 'Technologies', 'Enterprises', 'Innovations', 'Systems',
    'Services', 'Consultants', 'Partners', 'Group', 'Corporation',
    'Industries', 'Analytics', 'Digital', 'Ventures', 'Labs'
};

List<String> industries = new List<String>{
    'Technology', 'Healthcare', 'Finance', 'Retail', 'Manufacturing',
    'Education', 'Energy', 'Telecommunications', 'Transportation', 'Media',
    'Real Estate', 'Agriculture', 'Construction', 'Insurance', 'Hospitality'
};

// Generate 25 random accounts
for (Integer i = 1; i <= 25; i++) {
    Integer prefixIndex = Math.mod(i - 1, prefixes.size());
    Integer suffixIndex = Math.mod(i, suffixes.size());
    Integer industryIndex = Math.mod(i, industries.size());
    
    String accountName = prefixes.get(prefixIndex) + ' ' + 
                        suffixes.get(suffixIndex) + ' ' + 
                        String.valueOf(i);
    
    Account newAccount = new Account();
    newAccount.Name = accountName;
    newAccount.Industry = industries.get(industryIndex);
    newAccount.Phone = '+1-' + String.valueOf(Math.mod(i * 1234567890, 1000000000)).leftPad(10, '0');
    newAccount.Website = 'www.' + accountName.replaceAll(' ', '-').toLowerCase() + '.com';
    newAccount.AnnualRevenue = (i * 1000000) + ((i * 500000) * Math.mod(i, 5));
    newAccount.NumberOfEmployees = (i * 50) + Math.mod(i, 1000);
    newAccount.BillingCity = 'New York';
    newAccount.BillingState = 'NY';
    newAccount.BillingCountry = 'USA';
    newAccount.BillingPostalCode = '10001';
    newAccount.BillingStreet = (1000 + i) + ' Main Street';
    
    accountsToCreate.add(newAccount);
}

// Insert the accounts
try {
    insert accountsToCreate;
    System.debug('✓ Successfully created ' + accountsToCreate.size() + ' account records');
    System.debug('Accounts created:');
    for (Account acc : accountsToCreate) {
        System.debug('  - ' + acc.Name);
    }
} catch (DmlException e) {
    System.debug('Error creating accounts: ' + e.getMessage());
}
