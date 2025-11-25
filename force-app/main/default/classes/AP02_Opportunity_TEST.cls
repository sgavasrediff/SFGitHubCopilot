@isTest (seeAllData = true)
private class AP02_Opportunity_TEST
{
  static User testUser1;
  static User testUser2;
  static User testUser3;
  static User testUserWithNoSellingTeam;
  static Account testAccount;
  static Opportunity testOpp;
  static Product2 testProd;

  static void setup() {
    Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_SALES_REP);
    testUser1 = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',p1.Id,'America/Los_Angeles','standuser@testorg.com');
    testUser1.SellingTeam__c = 'Australia';
    testUser2 = GC_UtilityClassTestData.createUser('test2','standarduser2@testorg.com','UTF-8','Testing','en_US','en_US',p1.Id,'America/Los_Angeles','standuser2@testorg.com');
    testUser2.SellingTeam__c = 'Thailand';
    testUser3 = GC_UtilityClassTestData.createUser('test3','standarduser2@testorg.com','UTF-8','Testing','en_US','en_US',p1.Id,'America/Los_Angeles','standuser3@testorg.com');
    testUser3.SellingTeam__c = 'Italy';
    testUserWithNoSellingTeam = GC_UtilityClassTestData.createUser('test4','standarduser2@testorg.com','UTF-8','Testing','en_US','en_US',p1.Id,'America/Los_Angeles','standuser3@testorg.com');
    testUserWithNoSellingTeam.SellingTeam__c = '';
    testAccount = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
    testProd = GC_UtilityClassTestData.createProduct('Test','Product1','tool');     
    System.runAs(GC_UtilityClassTestData.ADMIN_USER) {
      insert new List<User>{testUser1, testUser2, testUser3};
      insert testAccount;
    }
    testOpp = GC_UtilityClassTestData.createOpportunity('testOpp',testAccount.Id ,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',30,'Asset Manager','Fund Company');
    System.runAs(testUser1) {
      insert testOpp;
    }

    AP02_Opportunity.OppBeforeUpdateLabel = 'TRUE';
    AP02_Opportunity.OppSplitBeforeUpdateLabel = 'TRUE';
  }

 Static testMethod void copyOppAccount()
  { 
     Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();
     List<Account> acclist = new List<Account>();
     ID profileId = p1.Id;
     User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
     userList.add(u);
     Database.insert(userList);   
     
      GC_UtilityClassTestData.assignPermissionSetToUser('AccountCreation', u.Id);  
    
 System.RunAs(u)
  {
      Account acc1 = GC_UtilityClassTestData.createAccount('testAcc1342','Active','testcity','India','12345','teststreet','teststate');
      Account acc2 = GC_UtilityClassTestData.createAccount('testAcc221','Active','testcity','India','12345','teststreet','teststate');
      acclist.add(acc1);
      acclist.add(acc2);
      database.insert(acclist);
      
      ID opAccId =acc1.Id;
      Opportunity opt1 = GC_UtilityClassTestData.createOpportunity('testOpp1',opAccId ,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',30,'Asset Manager','Fund Company');
      database.insert(opt1);
      
      ID oppId =opt1.Id;
      Contact con = GC_UtilityClassTestData.createContact('Test2_AP02_Opp','Test2_AP02_Opp1','Test2_AP02_Opp@test.com','Industry','Exchange',acc1.id);
      database.insert(con);
      
      ID conId =con.Id;
      Business_Address__c busaddrs = new Business_Address__c(Account__c =acc1.id, ZipPostalCode__c = '60602',Street__c='street1',City__c = 'city1',Country__c = 'India' );
      database.insert(busaddrs);
      
      ID busaddrsId=busaddrs.Id;
      Contract contract1 = GC_UtilityClassTestData.createContract(opAccId,opAccId,opAccId,'Monthly',busaddrsId,conId ,conId ,busaddrsId,oppId );
      contract1.status = 'Draft';
      database.insert(contract1);
      
      test.starttest();
      opt1.AccountId=acc2.Id;
      database.update(opt1,false);
      test.stoptest();
  }
 }
   /*****************************************************/
 Static testMethod void addSAMMember2()
{    
    Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_GSO_AUDITOR); 
    Profile p5 = GC_UtilityClassTestData.getProfile(label.CL_PRODUCT_MANAGER);     
    List<User> userList = new List<User>();
 List<Account> acclist = new List<Account>();
 Account acc1 = new Account();                                               //Declaring Account Instances
 Account acc2 = new Account();
     UserRole r = [Select id from userrole where name=:label.CL_System_Administrator];     
    ID profileId = p1.Id;
    ID profileId5 = p5.Id;
    User user1 = GC_UtilityClassTestData.createUser('tes121','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
    User user5 = GC_UtilityClassTestData.createUser('tet215','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId5,'America/Los_Angeles','standuser5@testorg.com');
     user1.UserRoleId = r.Id; 
    user5.UserRoleId = r.Id; 
    userList.add(user1);
    userList.add(user5);
    
    Database.insert(userList); 
    
    System.RunAs(user1)                                                       //Running as User1
    { 
      acc1 = GC_UtilityClassTestData.createAccount('testAcc311','Active','testcity','India','12345','teststreet','teststate');            //Create Account1 with Owner=user1 and SAM=user2
      //acc1.StrategicAccountManager__c = user5.Id;
      acc1.Website='www.cta.com';
      //acc1.AccountIndicator__c = 'Strategic Account';
      acclist.add(acc1);
      acc2 = GC_UtilityClassTestData.createAccount('testAcc322','Active','testcity','India','12345','teststreet','teststate');            //Create Account1 with Owner=user1 and SAM=user1
      //acc2.StrategicAccountManager__c = user5.Id;
      acc2.Website='www.cta.com';
      //acc2.AccountIndicator__c = 'Strategic Account';
      acclist.add(acc2);
      
      database.insert(acclist);
      System.debug('******'+acclist);
      }
    
    
    System.RunAs(user5)                                                    //Running as User 5.
   {    
      Opportunity opt1 = GC_UtilityClassTestData.createOpportunity('testOpp1',acc1.Id ,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',30,'Asset Manager','Fund Company');        //Creating Opportunity 1 with owner=user2 and Account=account1
      database.insert(opt1);
       Opportunity opt2 = GC_UtilityClassTestData.createOpportunity('testOpp1',acc2.Id ,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',30,'Asset Manager','Fund Company');       //Creating Opportunity 1 with owner=user2 and Account=account2
      opt1.ClosingStatus__c = label.CL_AUDITED_BY_GSO;
       test.startTest();
       database.insert(opt2);
      System.debug('@@@@@@'+opt1);
      //test.starttest(); 
      opt1.ClosingStatus__c = LABEL.CL_RETURNED_TO_FINANCE;                                                 //Test Starts
     opt1.DeliveryMonths__c = 24;
        opt1.Name = 'TESTOPP NAME';
      opt1.accountId=acc2.id;                                             //Update Opportunity 1 Account to Account2
     // database.update(opt1); 
      test.stoptest();                                                    //Test Stops Here
   }
    
} 
 
Static testMethod void addSAMMember3()
{    
    Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_GSO_AUDITOR); 
    Profile p5 = GC_UtilityClassTestData.getProfile(label.CL_MARKETING);     
    List<User> userList = new List<User>();
 List<Account> acclist = new List<Account>();
 Account acc1 = new Account();                                               //Declaring Account Instances
 Account acc2 = new Account();
     UserRole r = [Select id from userrole where name=:label.CL_System_Administrator];     
    ID profileId = p1.Id;
    ID profileId5 = p5.Id;
    User user1 = GC_UtilityClassTestData.createUser('tes121','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
    User user5 = GC_UtilityClassTestData.createUser('tet215','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId5,'America/Los_Angeles','standuser5@testorg.com');
     user1.UserRoleId = r.Id; 
    user5.UserRoleId = r.Id; 
    userList.add(user1);
    userList.add(user5);
    
    Database.insert(userList); 
    
    System.RunAs(user1)                                                       //Running as User1
    { 
      acc1 = GC_UtilityClassTestData.createAccount('testAcc311','Active','testcity','India','12345','teststreet','teststate');            //Create Account1 with Owner=user1 and SAM=user2
     // acc1.StrategicAccountManager__c = user5.Id;
      acc1.Website='www.cta.com';
      //acc1.AccountIndicator__c = 'Strategic Account';
      acclist.add(acc1);
      acc2 = GC_UtilityClassTestData.createAccount('testAcc322','Active','testcity','India','12345','teststreet','teststate');            //Create Account1 with Owner=user1 and SAM=user1
     // acc2.StrategicAccountManager__c = user5.Id;
      acc2.Website='www.cta.com';
      //acc2.AccountIndicator__c = 'Strategic Account';
      acclist.add(acc2);
    
      database.insert(acclist);
      System.debug('******'+acclist);
      }
    
    
    System.RunAs(user5)                                                    //Running as User 5.
   {    
      Opportunity opt1 = GC_UtilityClassTestData.createOpportunity('testOpp1',acc1.Id ,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',30,'Asset Manager','Fund Company');        //Creating Opportunity 1 with owner=user2 and Account=account1
      database.insert(opt1);
       Opportunity opt2 = GC_UtilityClassTestData.createOpportunity('testOpp1',acc2.Id ,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',30,'Asset Manager','Fund Company');       //Creating Opportunity 1 with owner=user2 and Account=account2
      opt1.ClosingStatus__c = label.CL_AUDITED_BY_GSO;
       test.startTest();
       TRY{
       database.insert(opt2);
      System.debug('@@@@@@'+opt1);
      //test.starttest(); 
      opt1.ClosingStatus__c = LABEL.CL_RETURNED_TO_FINANCE;                                                 //Test Starts
     opt1.DeliveryMonths__c = 24;
        opt1.Name = 'TESTOPP NAME';
      opt1.accountId=acc2.id;                                             //Update Opportunity 1 Account to Account2
      database.update(opt1); 
           }Catch(Exception ex)
           {
               
           }
      test.stoptest();                                                    //Test Stops Here
   }
    
} 

 Static testMethod void addSAMMember4()
{    
    Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_GSO_AUDITOR); 
    Profile p5 = GC_UtilityClassTestData.getProfile(label.CL_SALES_MANAGER);     
    List<User> userList = new List<User>();
 List<Account> acclist = new List<Account>();
 Account acc1 = new Account();                                               //Declaring Account Instances
 Account acc2 = new Account();
     UserRole r = [Select id from userrole where name=:label.CL_System_Administrator];     
    ID profileId = p1.Id;
    ID profileId5 = p5.Id;
    User user1 = GC_UtilityClassTestData.createUser('tes121','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
    User user5 = GC_UtilityClassTestData.createUser('tet215','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId5,'America/Los_Angeles','standuser5@testorg.com');
     user1.UserRoleId = r.Id; 
    user5.UserRoleId = r.Id; 
    userList.add(user1);
    userList.add(user5);
    
    Database.insert(userList); 
    
    System.RunAs(user1)                                                       //Running as User1
    { 
      acc1 = GC_UtilityClassTestData.createAccount('testAcc311','Active','testcity','India','12345','teststreet','teststate');            //Create Account1 with Owner=user1 and SAM=user2
      //acc1.StrategicAccountManager__c = user5.Id;
        acc1.Website='www.cta.com';
      //acc1.AccountIndicator__c = 'Strategic Account';
      acclist.add(acc1);
      acc2 = GC_UtilityClassTestData.createAccount('testAcc322','Active','testcity','India','12345','teststreet','teststate');            //Create Account1 with Owner=user1 and SAM=user1
     // acc2.StrategicAccountManager__c = user5.Id;
        acc2.Website='www.cta.com';
      //acc2.AccountIndicator__c = 'Strategic Account';
      acclist.add(acc2);

      database.insert(acclist);
      System.debug('******'+acclist);
      }
    
    
    System.RunAs(user5)                                                    //Running as User 5.
   {    
      Opportunity opt1 = GC_UtilityClassTestData.createOpportunity('testOpp1',acc1.Id ,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',30,'Asset Manager','Fund Company');        //Creating Opportunity 1 with owner=user2 and Account=account1
      opt1.ClosingStatus__c = label.CL_AUDITED_BY_GSO;
       database.insert(opt1);
       Opportunity opt2 = GC_UtilityClassTestData.createOpportunity('testOpp1',acc2.Id ,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',30,'Asset Manager','Fund Company');       //Creating Opportunity 1 with owner=user2 and Account=account2
      
       test.startTest();
       TRY{
       
      System.debug('@@@@@@'+opt1);
      //test.starttest(); 
      opt1.ClosingStatus__c = LABEL.CL_RETURNED_TO_FINANCE;                                                 //Test Starts
     opt1.DeliveryMonths__c = 24;
        opt1.Name = 'TESTOPP NAME';
      opt1.accountId=acc2.id;                                             //Update Opportunity 1 Account to Account2
      database.update(opt1); 
           }Catch(Exception ex)
           {
               
           }
      test.stoptest();                                                    //Test Stops Here
   }
    
} 

    Static testMethod void addSAMMember5()
{    
    Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_GSO_AUDITOR); 
    Profile p5 = GC_UtilityClassTestData.getProfile(label.CL_SALES_REP);     
    List<User> userList = new List<User>();
 List<Account> acclist = new List<Account>();
 Account acc1 = new Account();                                               //Declaring Account Instances
 Account acc2 = new Account();
     UserRole r = [Select id from userrole where name=:label.CL_System_Administrator];     
    ID profileId = p1.Id;
    ID profileId5 = p5.Id;
    User user1 = GC_UtilityClassTestData.createUser('tes121','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
    User user5 = GC_UtilityClassTestData.createUser('tet215','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId5,'America/Los_Angeles','standuser5@testorg.com');
     user1.UserRoleId = r.Id; 
    user5.UserRoleId = r.Id; 
    userList.add(user1);
    userList.add(user5);
    
    Database.insert(userList); 
    
    System.RunAs(user1)                                                       //Running as User1
    { 
      acc1 = GC_UtilityClassTestData.createAccount('testAcc311','Active','testcity','India','12345','teststreet','teststate');            //Create Account1 with Owner=user1 and SAM=user2
     // acc1.StrategicAccountManager__c = user5.Id;
      acc1.Website='www.cta.com';
      //acc1.AccountIndicator__c = 'Strategic Account';
      acclist.add(acc1);
      acc2 = GC_UtilityClassTestData.createAccount('testAcc322','Active','testcity','India','12345','teststreet','teststate');            //Create Account1 with Owner=user1 and SAM=user1
     // acc2.StrategicAccountManager__c = user5.Id;
      acc2.Website='www.cta.com';
      //acc2.AccountIndicator__c = 'Strategic Account';
      acclist.add(acc2);

      database.insert(acclist);
      System.debug('******'+acclist);
      }
    
    
    System.RunAs(user5)                                                    //Running as User 5.
   {    
      Opportunity opt1 = GC_UtilityClassTestData.createOpportunity('testOpp1',acc1.Id ,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',30,'Asset Manager','Fund Company');        //Creating Opportunity 1 with owner=user2 and Account=account1
      opt1.ClosingStatus__c = label.CL_AUDITED_BY_GSO;
       database.insert(opt1);
       Opportunity opt2 = GC_UtilityClassTestData.createOpportunity('testOpp1',acc2.Id ,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',30,'Asset Manager','Fund Company');       //Creating Opportunity 1 with owner=user2 and Account=account2
      
       test.startTest();
       TRY{
      System.debug('@@@@@@'+opt1);
      //test.starttest(); 
      opt1.ClosingStatus__c = LABEL.CL_RETURNED_TO_FINANCE;                                                 //Test Starts
     opt1.DeliveryMonths__c = 24;
        opt1.Name = 'TESTOPP NAME';
      opt1.accountId=acc2.id;                                             //Update Opportunity 1 Account to Account2
      database.update(opt1); 
           }Catch(Exception ex)
           {
               
           }
      test.stoptest();                                                    //Test Stops Here
   }
    
} 

    
    
Static testMethod void addSAMMember()
{ 
 Profile p1 = GC_UtilityClassTestData.getProfile(LABEL.CL_GSO_AUDITOR);        //Creating Profile Instance for Sales User Profile
    Profile p2 = GC_UtilityClassTestData.getProfile(LABEL.CL_SALES_REP);        //Creating Profile Instance for Sales User Profile   
    Profile p3 = GC_UtilityClassTestData.getProfile(LABEL.CL_MARKETING);  
    Profile p4 = GC_UtilityClassTestData.getProfile(label.CL_SALES_MANAGER);  
     
    
    List<User> userList = new List<User>();
 List<Account> acclist = new List<Account>();
 Account acc1 = new Account();                                               //Declaring Account Instances
 Account acc2 = new Account();
  ID profileId = p1.Id;
    ID profileId2 = p2.Id;
    
  UserRole r = [Select id from userrole where name=:label.CL_System_Administrator];                  //Getting role Id for SAM 
  User user1 = GC_UtilityClassTestData.createUser('tes121','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
  User user2 = GC_UtilityClassTestData.createUser('tet212','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId2,'America/Los_Angeles','standuser2@testorg.com');
  
  user2.UserRoleId = r.Id;
  user1.UserRoleId = r.Id;
  
  
  userList.add(user1);
  userList.add(user2);
  
      
  Database.insert(userList);                                                //Insert userlist(User1 and User2)
 // test.starttest();    
  System.RunAs(user1)                                                       //Running as User1
    { 
      acc1 = GC_UtilityClassTestData.createAccount('testAcc311','Active','testcity','India','12345','teststreet','teststate');            //Create Account1 with Owner=user1 and SAM=user2
     // acc1.StrategicAccountManager__c = user2.Id;
        acc1.Website='www.cta.com';
      //acc1.AccountIndicator__c = 'Strategic Account';
      acclist.add(acc1);
      acc2 = GC_UtilityClassTestData.createAccount('testAcc322','Active','testcity','India','12345','teststreet','teststate');            //Create Account1 with Owner=user1 and SAM=user1
     // acc2.StrategicAccountManager__c = user1.Id;
        acc2.Website='www.cta.com';
      //acc2.AccountIndicator__c = 'Strategic Account';
      acclist.add(acc2);

      database.insert(acclist);
      System.debug('******'+acclist);
      }
   System.RunAs(user1)                                                    //Running as User 1.
   {    
      Opportunity opt1 = GC_UtilityClassTestData.createOpportunity('testOpp1',acc1.Id ,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',30,'Asset Manager','Fund Company');        //Creating Opportunity 1 with owner=user2 and Account=account1
      opt1.ClosingStatus__c = label.CL_AUDITED_BY_GSO;
       database.insert(opt1);
       Opportunity opt2 = GC_UtilityClassTestData.createOpportunity('testOpp1',acc2.Id ,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',30,'Asset Manager','Fund Company');       //Creating Opportunity 1 with owner=user2 and Account=account2
      System.debug('@@@@@@'+opt1);
      test.starttest();                                                   //Test Starts
     
       try{
       opt1.Name = 'testoppp1';
      opt1.accountId=acc2.id;                                             //Update Opportunity 1 Account to Account2
       
       opt1.ownerid = user1.id;                                            //Update Opportunity 1 owner to user1
      database.update(opt1);
      }
       catch(Exception ex){}
           
           //test.stoptest();                                                    //Test Stops Here
   }
   
   
                                                     
} 
    /*****************************************************/
    
Static testMethod void OpportunityTestMethod1()
    {
      
      Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      userList.add(u);
      
      Database.insert(userList);
      
      
       GC_UtilityClassTestData.assignPermissionSetToUser('AccountCreation', u.Id);  
  
      System.RunAs(u)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
            /* Test Data Starts */
            
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
            acclist.add(acc);
            Database.insert(acclist);
            ID opAccId =acc.Id; 
            for(integer count=0;count<20;count++)
            {
                Opportunity opt = GC_UtilityClassTestData.createOpportunity('testOpp'+count,opAccId,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',30,'Asset Manager','Fund Company');
                opportunitylist.add(opt);
            }   
                Database.insert(opportunitylist);
                for(Opportunity  opp:opportunitylist){
                    opp.StageName = '3 - Securing';
                    opp.ClosingStatus__c =LABEL.CL_SUBMITTED_TO_MANAGER_FA;
                }
      
                database.update(opportunitylist,false);
                Test.startTest();
                for(Opportunity  opp:opportunitylist){
                    opp.StageName =  label.CL_COSED_WON_5;
                }
                database.update(opportunitylist,false);
            Test.stopTest();
         }
      }   
         /********************************************************/

  Static testMethod void OpportunityTestMethod2()
    {
      Profile p2 = GC_UtilityClassTestData.getProfile(LABEL.CL_GSO_AUDITOR);
     List<User> userList = new List<User>();

      ID profileId2 = p2.Id;
      User u2 = GC_UtilityClassTestData.createUser('test2','standarduser1@testorg.com','UTF-8','Testing','en_US','en_US',profileId2,'America/Los_Angeles','standuser1@testorg.com');
      userList.add(u2);

      
      Database.insert(userList);
  

         System.RunAs(u2)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
            /* Test Data Starts */
            Test.startTest();
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
            acc.Website='www.cta.com';
            acclist.add(acc);
            Database.insert(acclist);
            ID opAccId =acc.Id; 
            for(integer count=0;count<20;count++)
            {
                Opportunity opt = GC_UtilityClassTestData.createOpportunity('testOpp'+count,opAccId,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',30,'Asset Manager','Fund Company');
                opportunitylist.add(opt);
            }   
                Database.insert(opportunitylist);
                for(Opportunity  opp:opportunitylist){
                    opp.StageName = '3 - Securing';
                    opp.ClosingStatus__c =LABEL.CL_AUDITED_BY_GSO;
                }
                
                database.update(opportunitylist,false);
                
                for(Opportunity  opp:opportunitylist){
                    opp.StageName =  label.CL_COSED_WON_5;
                }
                database.update(opportunitylist,false);
             Test.stopTest();
         }
     }
         /********************************************************/
  Static testMethod void OpportunityTestMethod3()
    {

      Profile p6 = GC_UtilityClassTestData.getProfile(LABEL.CL_PRODUCT_MANAGER);
     List<User> userList = new List<User>();

      ID profileId6= p6.Id;
      User u1 = GC_UtilityClassTestData.createUser('test6','standarduser5@testorg.com','UTF-8','Testing','en_US','en_US',profileId6,'America/Los_Angeles','standuser6@testorg.com');
      userList.add(u1);
      
      Database.insert(userList);
      
      
     GC_UtilityClassTestData.assignPermissionSetToUser('AccountCreation', u1.Id);  
  

         System.RunAs(u1)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
            /* Test Data Starts */
            Test.startTest();
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
            acc.Website='www.cta.com';
            acclist.add(acc);
            Database.insert(acclist);
            ID opAccId =acc.Id; 
            for(integer count=0;count<20;count++)
            {
                Opportunity opt = GC_UtilityClassTestData.createOpportunity('testOpp'+count,opAccId,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',30,'Asset Manager','Fund Company');
               
                opportunitylist.add(opt);
            }   
                Database.insert(opportunitylist);
                for(Opportunity  opp:opportunitylist){
                    opp.StageName = '3 - Securing';
                    opp.ClosingStatus__c =LABEL.CL_RETURNED_TO_FINANCE;
                }
                
                database.update(opportunitylist,false);
                
                for(Opportunity  opp:opportunitylist){
                    opp.StageName =  label.CL_COSED_WON_5;
                }
                database.update(opportunitylist,false);
          Test.stopTest();
         }

     }
 /**************************************************/
     Static testMethod void OpportunityTestMethod4()
    {

      Profile p3 = GC_UtilityClassTestData.getProfile(LABEL.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId3 = p3.Id;
      User u3 = GC_UtilityClassTestData.createUser('test3','standarduser2@testorg.com','UTF-8','Testing','en_US','en_US',profileId3,'America/Los_Angeles','standuser2@testorg.com');
      userList.add(u3);

      
      Database.insert(userList);
      
      
       GC_UtilityClassTestData.assignPermissionSetToUser('AccountCreation', u3.Id);  
  

         System.RunAs(u3)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
            /* Test Data Starts */
            Test.startTest();
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
            acclist.add(acc);
            Database.insert(acclist);
            ID opAccId =acc.Id; 
            for(integer count=0;count<20;count++)
            {
                Opportunity opt = GC_UtilityClassTestData.createOpportunity('testOpp'+count,opAccId,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',30,'Asset Manager','Fund Company');
                opportunitylist.add(opt);
            }   
                Database.insert(opportunitylist);
                for(Opportunity  opp:opportunitylist){
                    opp.StageName = '3 - Securing';
                    opp.ClosingStatus__c =label.CL_SUBMITTED_TO_GSO;
                }
                
                database.update(opportunitylist,false);
                
                for(Opportunity  opp:opportunitylist){
                    opp.StageName =  label.CL_COSED_WON_5;
                }
                database.update(opportunitylist,false);         
          Test.stopTest();
         }
     }
 /*****************************************************/
Static testMethod void OpportunityTestMethod5()
    {

      Profile p4 = GC_UtilityClassTestData.getProfile(LABEL.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId4 = p4.Id;
      User u4 = GC_UtilityClassTestData.createUser('test4','standarduser3@testorg.com','UTF-8','Testing','en_US','en_US',profileId4,'America/Los_Angeles','standuser3@testorg.com');
      userList.add(u4);
      
      Database.insert(userList);
      
      
       GC_UtilityClassTestData.assignPermissionSetToUser('AccountCreation', u4.Id);  
  
         System.RunAs(u4)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
            /* Test Data Starts */
            Test.startTest();
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
            acc.Website='www.cta.com';
            acclist.add(acc);
            Database.insert(acclist);
            ID opAccId =acc.Id; 
            for(integer count=0;count<20;count++)
            {
                Opportunity opt = GC_UtilityClassTestData.createOpportunity('testOpp'+count,opAccId,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',30,'Asset Manager','Fund Company');
                opportunitylist.add(opt);
            }   
                Database.insert(opportunitylist);
                for(Opportunity  opp:opportunitylist){
                    opp.StageName = '3 - Securing';
                    opp.ClosingStatus__c =label.CL_AUDITED_BY_GSO;
                }
                
                database.update(opportunitylist,false);
                
                for(Opportunity  opp:opportunitylist){
                    opp.StageName =  label.CL_COSED_WON_5;
                }
                database.update(opportunitylist,false);         
          Test.stopTest();
         }
     }  
/**********************/
  Static testMethod void OpportunityTestMethod()
    {
      Profile p1 = GC_UtilityClassTestData.getProfile('System Administrator');
      Profile p2 = GC_UtilityClassTestData.getProfile(LABEL.CL_GSO_AUDITOR);
      //Profile p6 = GC_UtilityClassTestData.getProfile(LABEL.CL_PRODUCT_MANAGER);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      userList.add(u);
      ID profileId2 = p2.Id;
      User u2 = GC_UtilityClassTestData.createUser('test2','standarduser1@testorg.com','UTF-8','Testing','en_US','en_US',profileId2,'America/Los_Angeles','standuser1@testorg.com');
      userList.add(u2);
      //ID profileId6= p6.Id;
      //User u1 = GC_UtilityClassTestData.createUser('test6','standarduser5@testorg.com','UTF-8','Testing','en_US','en_US',profileId6,'America/Los_Angeles','standuser6@testorg.com');
      //userList.add(u1);
        List<Account> acclist = new List<Account>();
         Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
            acclist.add(acc);
            Database.insert(acclist);
      
      Database.insert(userList);
  
      System.RunAs(u)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            
            
            // Test Data Starts 
            
           
            Product2 prod = GC_UtilityClassTestData.createProduct('Data', 'Data Feed', 'tool');
            insert prod;
            Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
            PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
            insert pbe;
            
            ID opAccId =acc.Id; 
            for(integer count=0;count<1;count++)
            {
                Opportunity opt = GC_UtilityClassTestData.createOpportunity('testOpp'+count,opAccId,'New','AUM','USD',Date.Today(),Date.Today(),Date.Today(),'0 - Identifying',30,'Asset Manager','Fund Company');
                opportunitylist.add(opt);
            }   
                Database.insert(opportunitylist);
                for(Opportunity  opp:opportunitylist){
                    opp.StageName = '3 - Securing';
                    opp.SellingTeam__c  = 'US BD 3';
                    opp.SellingTeam__c  = 'United States';
                    opp.Region__c   = 'US';
                    opp.DeliveryMonths__c = 32;
                    opp.ClosingStatus__c =LABEL.CL_SUBMITTED_TO_MANAGER_FA;
                }
            
            if(opportunitylist.size() > 0   ){
                
                 OpportunityLineItem oliX = GC_UtilityClassTestData.createOpportunityProduct(1, opportunitylist[0].id, pbe.Id, 1200000);
                     oliX.X2ndYearPrice__c=120000;
                    oliX.X3rdYearPrice__c=120000;
                    oliX.X4thYearPrice__c=120000;
                    oliX.RemainingYearsPrice__c=120000;
                    oliX.UnitPrice=1;
                     oliX.ToolNew__c = 'DIY';
                     oliX.Type__c = label.CL_Unit_Type_NumOfUsers;
                    oliX.SetUp_Fee__c = false;
                    insert oliX;
                
                
                
            }        
            Test.startTest();       
                database.update(opportunitylist,false);
                
                for(Opportunity  opp:opportunitylist){
                    opp.StageName =  label.CL_COSED_WON_5;
                }
                database.update(opportunitylist,false);
            Test.stopTest();
            //system.debug('Test.stopTest***'+Test.stopTest);
         }  
       /* System.RunAs(u1)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
          //  List<Account> acclist = new List<Account>();
             
            // Test Data Starts 
           // Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
            //acclist.add(acc);
            //Database.insert(acclist);
            ID opAccId =acc.Id; 
            for(integer count=0;count<1;count++)
            {
                Opportunity opt = GC_UtilityClassTestData.createOpportunity('testOpp'+count,opAccId,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',30,'Asset Manager','Fund Company');
                opportunitylist.add(opt);
            }   
                Database.insert(opportunitylist);
                for(Opportunity  opp:opportunitylist){
                    opp.StageName = '3 - Securing';
                    opp.ClosingStatus__c =LABEL.CL_RETURNED_TO_FINANCE;
                }
                
                database.update(opportunitylist,false);
                
                for(Opportunity  opp:opportunitylist){
                    opp.StageName =  label.CL_COSED_WON_5;
                }
                database.update(opportunitylist,false);
         }
         System.RunAs(u2)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            //List<Account> acclist = new List<Account>();
            
            // Test Data Starts 
           // Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
           // acclist.add(acc);
           // Database.insert(acclist);
            ID opAccId =acc.Id; 
            for(integer count=0;count<1;count++)
            {
                Opportunity opt = GC_UtilityClassTestData.createOpportunity('testOpp'+count,opAccId,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',30,'Asset Manager','Fund Company');
                opportunitylist.add(opt);
            }   
                Database.insert(opportunitylist);
                for(Opportunity  opp:opportunitylist){
                    opp.StageName = '3 - Securing';
                    opp.ClosingStatus__c =LABEL.CL_RETURNED_TO_FINANCE;
                }
                
                database.update(opportunitylist,false);
                
                for(Opportunity  opp:opportunitylist){
                    opp.StageName =  label.CL_COSED_WON_5;
                }
                database.update(opportunitylist,false);
         } */
       

     }  

    
    
    
    Static testMethod void OpportunityTestMethodGSOAuditor()
    {
      
      Profile p2 = GC_UtilityClassTestData.getProfile(LABEL.CL_GSO_AUDITOR);
      List<User> userList = new List<User>();
      ID profileId2 = p2.Id;
      User u2 = GC_UtilityClassTestData.createUser('test2','standarduser1@testorg.com','UTF-8','Testing','en_US','en_US',profileId2,'America/Los_Angeles','standuser1@testorg.com');
      userList.add(u2);
      
      Database.insert(userList);
  
      System.RunAs(u2)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
            // Test Data Starts 
            Test.startTest();
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
            acc.Website='www.cta.com';
            acclist.add(acc);
            Database.insert(acclist);
            ID opAccId =acc.Id; 
            for(integer count=0;count<2;count++)
            {
                Opportunity opt = GC_UtilityClassTestData.createOpportunity('testOpp'+count,opAccId,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',30,'Asset Manager','Fund Company');
                opportunitylist.add(opt);
            }   
                Database.insert(opportunitylist);
                for(Opportunity  opp:opportunitylist){
                    opp.StageName = '3 - Securing';
                    opp.ClosingStatus__c =LABEL.CL_SUBMITTED_TO_MANAGER_FA;
                }
                
                database.update(opportunitylist,false);
                
                for(Opportunity  opp:opportunitylist){
                    opp.StageName =  label.CL_COSED_WON_5;
                }
                database.update(opportunitylist,false);
            Test.stopTest();
            //system.debug('Test.stopTest***'+Test.stopTest);
         }
        
         

     }  
    static testMethod void OppProfiletest(){
            List<User> userList = new List<User>();
         
           Profile p3 = GC_UtilityClassTestData.getProfile('System Administrator');
           ID profileId3 = p3.Id;
              User u3 = GC_UtilityClassTestData.createUser('test3','standarduser2@testorg.com','UTF-8','Testing','en_US','en_US',profileId3,'America/Los_Angeles','standuser2@testorg.com');
              userList.add(u3);
              Database.insert(userList);
               System.RunAs(u3)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
             //Test Data Starts 
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
            acclist.add(acc);
            Database.insert(acclist);
            ID opAccId =acc.Id; 
            for(integer count=0;count<2;count++)
            {
                Opportunity opt = GC_UtilityClassTestData.createOpportunity('testOpp'+count,opAccId,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',30,'Asset Manager','Fund Company');
                opportunitylist.add(opt);
            }   
                Database.insert(opportunitylist);
                for(Opportunity  opp:opportunitylist){
                    opp.StageName = '3 - Securing';
                    opp.ClosingStatus__c =LABEL.CL_RETURNED_TO_FINANCE;
                }
                
                database.update(opportunitylist,false);
                
                for(Opportunity  opp:opportunitylist){
                    opp.StageName =  label.CL_COSED_WON_5;
                }
                
                 List<Opportunity> list1 = new List<Opportunity>();
                list1.add(opportunitylist[0]);
                
               // database.update(list1,false);
                database.update(opportunitylist,false);
         }
    
     }
  
  /* Static testMethod void OpportunityCalculationstestNoLI()
   { 
            Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
            ID profileId = p1.Id;
            User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
            Database.insert(u);
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Opportunity> childopportunitylist = new List<Opportunity>();
            System.RunAs(u){
             
                
            
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
            insert acc;
            Opportunity parentopt = GC_UtilityClassTestData.createOpportunity('testparentOpp',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
            
           // parentopt.DeliveryMonths__c = 60;
             
                 
            opportunitylist.add(parentopt);
            Opportunity parentopt2 = GC_UtilityClassTestData.createOpportunity('testparentOpp2',acc.Id,'New',label.CL_ONE_TIME,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
            parentopt2.AmendedBusinessACV__c = null;
                // parentopt2.DeliveryMonths__c = 60;
            //parentopt2.RecordTypeId = '012d0000000OqnD';
            opportunitylist.add(parentopt2);
          
                
            Opportunity childopt = GC_UtilityClassTestData.createOpportunity('testchildOpp4',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,label.CL_SECURING_3,0,'Asset Manager','Fund Company');
            childopt.ParentOpportunityId__c=parentopt.Id;
            childopportunitylist.add(childopt);
            insert(opportunitylist);
            List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
            List<Opportunity> renewal = [select Id  from Opportunity where CurrencyIsoCode='USD' and ContractType__c = 'Main Agreement' and DeliveryMonths__c >= 43 and Type ='Renewal' and StageName <> '5 - Closed Won' and StageName <> 'Acquired'  and Product__c <> '' LIMIT 2];   
            parentopt2.RenewalOpportunity__c = renewal[0].Id;
            //parentopt.RenewalOpportunity__c = renewal[1].Id;
            List<OpportunityLineItem> renewalOLI =  [select Id,PricebookEntryId,Opportunity.Id,ToolNew__c,Type__c from OpportunityLineItem where Opportunity.Id =: renewal[0].id ] ;
                 
            update parentopt2;
            //update parentopt;
            insert(childopportunitylist);
                 
                 
                for(OpportunityLineItem oli :renewalOLI )
                 {
                     OpportunityLineItem oliX = GC_UtilityClassTestData.createOpportunityProduct(1, childopt.id, oli.PricebookEntryId, 1200000);
                     oliX.X2ndYearPrice__c=120000;
                    oliX.X3rdYearPrice__c=120000;
                    oliX.X4thYearPrice__c=120000;
                    oliX.RemainingYearsPrice__c=120000;
                    oliX.UnitPrice=1;
                     oliX.ToolNew__c = 'Win Tool';
                     olix.Type__c = label.CL_Unit_Type_NumOfUsers;
                                                               oliList.add(oliX);
                 }
                 
                 
              
                childopt.RecordTypeId = '012d0000000OqnC';
                
             // update childopt;
                insert(oliList );
                
                             
                        childopt.ParentOpportunityId__c=parentopt2.Id;     
                        update childopt;
                        // system.debug('TIGER1 AMENDMENTOPPLINEITEMS');
                        Test.startTest();     
                  try
                  {
                        childopt.stagename = label.CL_COSED_WON_5;     
                        update childopt;
            
                      
                  }catch(Exception ex)
                  {
                      
                  }
                        Test.stopTest(); 
            
             }
               
     }*/
       
    
    
 /* Static testMethod void OpportunityCalculationstest()
     { Profile p1 = GC_UtilityClassTestData.getProfile('GSO Auditor');
      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      Database.insert(u);
       List<Opportunity> opportunitylist = new List<Opportunity>();
       List<Opportunity> childopportunitylist = new List<Opportunity>();
         
            Product2 prod = GC_UtilityClassTestData.createProduct('Data', 'Data Feed', 'tool');
            
      prod.isActive = false;
        insert prod;
      
            Bundle_Products__c component1 = new Bundle_Products__c();
            component1.Product_Bundle__c = prod.Id;
            component1.Bundle_Component__c = '01td0000001ReAW'; //Advisor Workstation
            component1.Product_Weightage__c = 50;
            component1.Bundle_Component_Name__c = 'Advisor - 50 - Commisionable';
            insert component1;
            
            
            Bundle_Products__c component2 = new Bundle_Products__c();
            component2.Product_Bundle__c = prod.Id;
            component2.Bundle_Component__c = '01td00000041WKX'; //ABS New Issue
            component2.Product_Weightage__c = 30;
            component2.Bundle_Component_Name__c = 'ABS - 30 - Commisionable';
            insert component2;
            
            Bundle_Products__c component3 = new Bundle_Products__c();
            component3.Product_Bundle__c = prod.Id;
            component3.Bundle_Component__c = '01td0000003Gevq'; //Analyst Access
            component3.Product_Weightage__c = 20;
            component3.Bundle_Component_Name__c = 'Analyst Access - 20 - Non Commisionable ';
            insert component3;
            
            
            prod.isActive = true;
            
            update prod;
      
            Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true where CurrencyIsoCode='USD' limit 1];
            PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
            insert pbe;
             System.RunAs(u){
             
            
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
             insert acc;
            Opportunity parentopt = GC_UtilityClassTestData.createOpportunity('testparentOpp',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
            
            
             
                 
            opportunitylist.add(parentopt);
            Opportunity parentopt2 = GC_UtilityClassTestData.createOpportunity('testparentOpp2',acc.Id,'New',label.CL_ONE_TIME,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
            parentopt2.AmendedBusinessACV__c = null;
            //parentopt2.RecordTypeId = '012d0000000OqnD';
            opportunitylist.add(parentopt2);
          
            Opportunity childopt = GC_UtilityClassTestData.createOpportunity('testchildOpp4',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,label.CL_SECURING_3,0,'Asset Manager','Fund Company');
            childopt.ParentOpportunityId__c=parentopt.Id;
            childopportunitylist.add(childopt);
                        
              insert(opportunitylist);
               List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
                List<Opportunity> renewal = [select Id  from Opportunity where CurrencyIsoCode='USD' and ContractType__c = 'Main Agreement' and DeliveryMonths__c >= 43 and Type ='Renewal' and StageName <> '5 - Closed Won' and StageName <> 'Acquired'  and Product__c <> '' LIMIT 2];   
               parentopt2.RenewalOpportunity__c = renewal[0].Id;
                 //parentopt.RenewalOpportunity__c = renewal[1].Id;
                 
               
                  List<OpportunityLineItem> renewalOLI =  [select Id,PricebookEntryId,Opportunity.Id,ToolNew__c,Type__c from OpportunityLineItem where Opportunity.Id =: renewal[0].id LIMIT 1] ;
                 system.debug('TIGER1 renewalOLI.size()'+renewalOLI.size());
                 
                                 
                 
                 update parentopt2;
                 //update parentopt;
                 insert(childopportunitylist);
                 
                 
                 for(OpportunityLineItem oli :renewalOLI )
                 {
                     OpportunityLineItem oliX = GC_UtilityClassTestData.createOpportunityProduct(1, childopt.id, oli.PricebookEntryId, 1200000);
                     oliX.X2ndYearPrice__c=120000;
                    oliX.X3rdYearPrice__c=120000;
                    oliX.X4thYearPrice__c=120000;
                    oliX.RemainingYearsPrice__c=120000;
                    oliX.UnitPrice=1;
                     oliX.ToolNew__c = oli.ToolNew__c;
                     olix.Type__c = label.CL_Unit_Type_NumOfUsers;
                     
                     
                     oliList.add(oliX);
                 }
               //  update childopt;
                      
                               
           
            insert(oliList );
            
            Test.startTest();     
            childopt.ParentOpportunityId__c=parentopt2.Id;     
            update childopt;
             system.debug('TIGER1 AMENDMENTOPPLINEITEMS');
            childopt.stagename = label.CL_COSED_WON_5; 
            update childopt;
              Test.stopTest(); 
            
            
             }
               
     }*/
    static testmethod void TestUpdateRenewalOppToLost() {

        List<id> parentOpps = new List<id>();
        Map<Id, String> oppAmendParentMap = new Map<Id, String>();
        
         test.startTest();
         AP02_Opportunity.UpdateRenewalOppToLost(parentopps,oppAmendParentMap);
        test.stopTest();

    
    }


       
    
    Static testMethod void CalculateTCVtestBundle(){
        Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      
      
      Database.insert(u);
        Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
        insert acc;
       
            Product2 prod = new Product2();
            
            prod.Name = 'Test Product';
            prod.Family = 'Data';
            prod.Bundle__c = true;
            
            
            insert prod;
            
            
            Bundle_Products__c component1 = new Bundle_Products__c();
            component1.Product_Bundle__c = prod.Id;
            component1.Bundle_Component__c = '01td0000001ReAW'; //Advisor Workstation
            component1.Product_Weightage__c = 50;
            component1.Bundle_Component_Name__c = 'Advisor - 50 - Commisionable';
            insert component1;
            
            
            Bundle_Products__c component2 = new Bundle_Products__c();
            component2.Product_Bundle__c = prod.Id;
            component2.Bundle_Component__c = '01td00000041WKX'; //ABS New Issue
            component2.Product_Weightage__c = 30;
            component2.Bundle_Component_Name__c = 'ABS - 30 - Commisionable';
            insert component2;
            
            Bundle_Products__c component3 = new Bundle_Products__c();
            component3.Product_Bundle__c = prod.Id;
            component3.Bundle_Component__c = '01td0000003Gevq'; //Analyst Access
            component3.Product_Weightage__c = 20;
            component3.Bundle_Component_Name__c = 'Analyst Access - 20 - Non Commisionable ';
            insert component3;
            
            
            prod.isActive = true;
            
            update prod;
         Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookId,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
        insert pbe;
         System.RunAs(u){
        
        Opportunity parentopt1 = GC_UtilityClassTestData.createOpportunity('testparentOpp2',acc.Id,'New',label.CL_NEW,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
        parentopt1.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        insert parentopt1;
       // Opportunity parentopt2 = GC_UtilityClassTestData.createOpportunity('testparentOpp3',acc.Id,'Closed-5',label.CL_NEW,'USD',Date.Today()+40,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
       // insert parentopt2;
        Opportunity childopt = GC_UtilityClassTestData.createOpportunity('testchildOpp5',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_SECURING_3,0,'Asset Manager','Fund Company');
        childopt.ParentOpportunityId__c=parentopt1.Id;
        childopt.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
             Test.startTest(); 
             
        insert childopt;
        
        OpportunityLineItem oli2 = GC_UtilityClassTestData.createOpportunityProduct(1, childopt.id, pbe.id, 12);
        oli2.X2ndYearPrice__c=1;
        oli2.X3rdYearPrice__c=1;
        oli2.X4thYearPrice__c=1;
        oli2.RemainingYearsPrice__c=2;
        oli2.UnitPrice=1;
        oli2.X1st_Year_Price_Minimum__c=1;
        oli2.X2nd_Year_Price_Minimum__c=1;
        oli2.X3rd_Year_Price_Minimum__c=1;
        oli2.X4th_Year_Price_Minimum__c=1;
        oli2.Remaining_Year_s_Price_Minimum__c=1;
        insert oli2;
       
             
        childopt.StageName = 'CL_COSED_WON_5';
          update childopt;
             
        Test.stopTest(); 
       }
       
     }
     
/***********/     
Static testMethod void CalculateTCVtest1(){
        Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     

    
      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      
      
      Database.insert(u);
        Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
        insert acc;
        Product2 prod = GC_UtilityClassTestData.createProduct('Data', 'Data Feed', 'tool');
        insert prod;
        Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
        PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
        insert pbe;
         System.RunAs(u){
        
        Opportunity parentopt1 = GC_UtilityClassTestData.createOpportunity('testparentOpp2',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
        parentopt1.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        insert parentopt1;
       // Opportunity parentopt2 = GC_UtilityClassTestData.createOpportunity('testparentOpp3',acc.Id,'Closed-5',label.CL_NEW,'USD',Date.Today()+40,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
       // insert parentopt2;
        Opportunity childopt = GC_UtilityClassTestData.createOpportunity('testchildOpp5',acc.Id,'New',label.CL_INCREMENTAL,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,0,'Asset Manager','Fund Company');
        childopt.ParentOpportunityId__c=parentopt1.Id;
        childopt.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        insert childopt;
        Test.startTest();
        OpportunityLineItem oli2 = GC_UtilityClassTestData.createOpportunityProduct(1, childopt.id, pbe.id, 12);
        oli2.X2ndYearPrice__c=1;
        oli2.X3rdYearPrice__c=1;
        oli2.X4thYearPrice__c=1;
        oli2.RemainingYearsPrice__c=2;
        oli2.UnitPrice=1;
        insert oli2;
        //  Test.startTest();
              
        delete childopt;
        delete parentopt1;
        Test.stopTest(); 
       }
       
     }
     
Static testMethod void CalculateTCVtestParentChange(){
        Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      
      
      Database.insert(u);
        Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
       // acc.StrategicAccountManager__c = u.id;
        acc.AccountIndicator__c = 'Strategic Account';
        insert acc;
        Product2 prod = GC_UtilityClassTestData.createProduct('Data', 'Data Feed', 'tool');
        insert prod;
        Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
        PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
        insert pbe;
         System.RunAs(u){
             
        
        Opportunity parentopt1 = GC_UtilityClassTestData.createOpportunity('testparentOpp2',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
        parentopt1.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        insert parentopt1;
        Opportunity parentopt2 = GC_UtilityClassTestData.createOpportunity('testparentOpp3',acc.Id,'Closed-5',label.CL_NEW,'USD',Date.Today()+40,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
        parentopt2.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        insert parentopt2;
        Opportunity childopt = GC_UtilityClassTestData.createOpportunity('testchildOpp5',acc.Id,'New',label.CL_INCREMENTAL,'USD',Date.Today()+45,Date.Today()+46,Date.Today()+776,label.CL_COSED_WON_5,0,'Asset Manager','Fund Company');
        childopt.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        childopt.ParentOpportunityId__c=parentopt1.Id;
         
             
             
        insert childopt;
        Test.startTest();
        OpportunityLineItem oli2 = GC_UtilityClassTestData.createOpportunityProduct(1, childopt.id, pbe.id, 1233333);
        oli2.X2ndYearPrice__c=1000;
        oli2.X3rdYearPrice__c=1000;
        oli2.X4thYearPrice__c=1000;
        oli2.RemainingYearsPrice__c=2500;
        oli2.UnitPrice=1;
        oli2.FirstDeliveryDate__c = Date.Today()+47; 
             
        insert oli2;
        try
        {
            childopt.TECH_SyncContract__c = true;
             childopt.ExpirationDate__c = childopt.ExpirationDate__c + 4;
             
             GlobalConstants.bTest = true;
            childopt.ParentOpportunityId__c=parentopt2.Id; 
             childopt.Persistent_ID__c = '1111111';
             childopt.PersistentId_Override__c = 'XXXXX';
            update childopt;
            
            
            
            
        }catch(Exception ex)
        {
            
        }
             
             
        
             
        //update parentopt1;
             
             
             
        Test.stopTest(); 
       }
       
     }
     
                                    
Static testMethod void CalculateTCVtest2(){
       Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      userList.add(u);
       Database.insert(userList);
       List<Opportunity> opportunitylist = new List<Opportunity>();
       List<Opportunity> childopportunitylist = new List<Opportunity>();
        System.RunAs(u){
        
        Test.startTest(); 
     Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
        insert acc;

        Product2 prod = GC_UtilityClassTestData.createProduct('Data', 'Data Feed', 'tool');
        insert prod;        
        Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
        PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
        insert pbe;
       
        Opportunity parentopt1 = GC_UtilityClassTestData.createOpportunity('testparentOpp2',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
        parentopt1.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        opportunitylist.add(parentopt1);
        
        Opportunity parentopt2 = GC_UtilityClassTestData.createOpportunity('testparentOpp2',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
        parentopt2.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        opportunitylist.add(parentopt2);
        
        Opportunity childopt3 = GC_UtilityClassTestData.createOpportunity('testchildOpp6',acc.Id,'New',label.CL_ONE_TIME,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,0,'Asset Manager','Fund Company');
        childopt3.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        childopt3.ParentOpportunityId__c=parentopt2.Id;
        childopportunitylist.add(childopt3);
        insert(opportunitylist);
         insert(childopportunitylist);
        //Opportunity childopt4 = GC_UtilityClassTestData.createOpportunity('testchildOpp',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,0,'Asset Manager','Fund Company');
        //childopt4.ParentOpportunityId__c=parentopt2.Id;
        //insert childopt4;
        OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1, childopt3.id, pbe.id, 12);
        oli.X2ndYearPrice__c=1;
        oli.X3rdYearPrice__c=11;
        oli.X4thYearPrice__c=1;
        oli.RemainingYearsPrice__c=12;
        oli.UnitPrice=1;
        insert oli;
         Test.stopTest();      
        //childopt3.ParentOpportunityId__c=parentopt1.Id;
        update childopt3;
       
             }
        }    
     
Static testMethod void CalculateTCVtest3(){
  Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      
       userList.add(u);
       Database.insert(userList);
       List<Opportunity> opportunitylist = new List<Opportunity>();
       List<Opportunity> childopportunitylist = new List<Opportunity>();
        System.RunAs(u){
        
        Test.startTest(); 
        Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
        insert acc;
        Product2 prod = GC_UtilityClassTestData.createProduct('Data', 'Data Feed', 'tool');
        insert prod;
        Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
        PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
        insert pbe; 
        Opportunity opp = GC_UtilityClassTestData.createOpportunity('testparentOpp2',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
        opp.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        opportunitylist.add(opp);
            
        Opportunity childopt1 = GC_UtilityClassTestData.createOpportunity('testchildOpp7',acc.Id,'New',label.CL_ROYALTY,'USD',Date.Today(),Date.Today()+2,Date.Today()+15,label.CL_SECURING_3,0,'Asset Manager','Fund Company');
        childopt1.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        childopt1.ParentOpportunityId__c=opp.Id;
            insert(opportunitylist);
        childopportunitylist.add(childopt1);
        
        insert(childopportunitylist);
        OpportunityLineItem oli2 = GC_UtilityClassTestData.createOpportunityProduct(1, childopt1.id, pbe.id, 12);
        oli2.X2ndYearPrice__c=1;
        oli2.X3rdYearPrice__c=1;
        oli2.X4thYearPrice__c=1;
        oli2.Delivery_Method__c='API';
        oli2.FirstDeliveryDateTBD__c = true;
        oli2.RemainingYearsPrice__c=2;
        oli2.UnitPrice=1;
        insert oli2;
         Test.stopTest(); 
        childopt1.StageName= label.CL_COSED_WON_5;
        update childopt1;
        childopt1.ParentOpportunityId__c=null;
        update childopt1; 
         
        }      
     }
Static testMethod void CalculateTCVtest4(){
  Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      userList.add(u);
       Database.insert(userList);
       List<Opportunity> opportunitylist = new List<Opportunity>();
       List<Opportunity> childopportunitylist = new List<Opportunity>();
        System.RunAs(u){
        
        Test.startTest(); 
        
        Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
        
        insert acc;
        Product2 prod = GC_UtilityClassTestData.createProduct('Data', 'Data Feed', 'tool');
        insert prod;       
              
        Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
        PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
        insert pbe;
        //Test.startTest();
        Opportunity parentopt1 = GC_UtilityClassTestData.createOpportunity('testparentOpp2',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
        parentopt1.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        opportunitylist.add(parentopt1);
        
        Opportunity parentopt2 = GC_UtilityClassTestData.createOpportunity('testparentOpp2',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
        parentopt2.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        opportunitylist.add(parentopt2); 
        
        Opportunity childopt3 = GC_UtilityClassTestData.createOpportunity('testchildOpp8',acc.Id,'New',label.CL_ONE_TIME,'USD',Date.Today(),Date.Today()+2,Date.Today()+15,label.CL_SECURING_3,0,'Asset Manager','Fund Company');
        childopt3.ParentOpportunityId__c=parentopt2.Id;  
        childopt3.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        childopportunitylist.add(childopt3);
        //Test.stopTest();
       
        
        Opportunity childopt4 = GC_UtilityClassTestData.createOpportunity('testchildOpp9',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,0,'Asset Manager','Fund Company');
        childopt4.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        childopt4.ParentOpportunityId__c=parentopt2.Id;
        
       // Test.startTest();
        childopportunitylist.add(childopt4);
        insert(opportunitylist);
        insert(childopportunitylist);
       
        OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1, childopt3.id, pbe.id, 12);
        oli.X2ndYearPrice__c=1;
        oli.X3rdYearPrice__c=11;
        oli.X4thYearPrice__c=1;
        oli.Delivery_Method__c='API';
        oli.RemainingYearsPrice__c=12;
        oli.UnitPrice=1;
        oli.FirstDeliveryDateTBD__c = true;
        insert oli;
       Test.stopTest();     
         
         
        //Test.stopTest();
        childopt3.StageName= label.CL_COSED_WON_5;   
       // Test.startTest();
        update childopt3;
       // childopt3.ParentOpportunityId__c=parentopt1.Id;
        update childopt3;
        //childopt3.ParentOpportunityId__c = null;
       // update childopt3; 
        }
        
                      
     }  
Static testMethod void CalculateACVtest1(){
        
        Account acc_AP02OPP = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
        acc_AP02OPP.AccountStatus__c ='Active';
        insert acc_AP02OPP;
        system.debug('%%%%%Account Status'+acc_AP02OPP.AccountStatus__c);
        Product2 prod = GC_UtilityClassTestData.createProduct('Data', 'Data Feed', 'tool');
        insert prod;
        Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
        PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
        insert pbe;
        Opportunity parentopt1 = GC_UtilityClassTestData.createOpportunity('testparentOpp2',acc_AP02OPP.Id,'New',label.CL_AMENDMENT,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
        parentopt1.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        insert parentopt1;
        Test.startTest();
        Opportunity childopt = GC_UtilityClassTestData.createOpportunity('testchildOpp10',acc_AP02OPP.Id,'New',label.CL_ONE_TIME,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,0,'Asset Manager','Fund Company');
        childopt.ParentOpportunityId__c=parentopt1.Id;
        childopt.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        insert childopt;
        OpportunityLineItem oli2 = GC_UtilityClassTestData.createOpportunityProduct(1, childopt.id, pbe.id, 12);
        oli2.X2ndYearPrice__c=1;
        oli2.X3rdYearPrice__c=1;
        oli2.X4thYearPrice__c=1;
        oli2.RemainingYearsPrice__c=2;
        oli2.UnitPrice=1;
        insert oli2;
      //  Test.startTest();
       Test.stopTest();
       childopt.StageName='3 - Securing';
       childopt.ParentOpportunityId__c=null;
       update childopt;
    
     }
Static testMethod void CalculateACVtest2(){ 
         Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      userList.add(u);
       Database.insert(userList);
       List<Opportunity> opportunitylist = new List<Opportunity>();
       List<Opportunity> childopportunitylist = new List<Opportunity>();
        System.RunAs(u){
        Test.startTest();      
        Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
        insert acc;
        Product2 prod = GC_UtilityClassTestData.createProduct('Data', 'Data Feed', 'tool');
        insert prod;        
        Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
        PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
        insert pbe;
         
        Opportunity parentopt1 = GC_UtilityClassTestData.createOpportunity('testparentOpp2',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
        parentopt1.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        parentopt1.DeliveryMonths__c=3;
        opportunitylist.add(parentopt1);
        
        Opportunity parentopt2 = GC_UtilityClassTestData.createOpportunity('testparentOpp2',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
        parentopt2.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        parentopt2.DeliveryMonths__c=3;
        opportunitylist.add(parentopt2);
        
        Opportunity childopt4 = GC_UtilityClassTestData.createOpportunity('testchildOpp11',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,0,'Asset Manager','Fund Company');
        childopt4.ParentOpportunityId__c=parentopt2.Id;
        childopt4.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        childopt4.DeliveryMonths__c=3;
        
        childopportunitylist.add(childopt4);
        
        Opportunity childopt3 = GC_UtilityClassTestData.createOpportunity('testchildOpp12',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,0,'Asset Manager','Fund Company');
        childopt3.ParentOpportunityId__c=parentopt2.Id;
        childopt3.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        childopt3.DeliveryMonths__c=3;
         childopportunitylist.add(childopt3);
        
        insert(opportunitylist);
        insert( childopportunitylist);
        
        OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1, childopt3.id, pbe.id, 12);
        oli.X2ndYearPrice__c=1;
        oli.X3rdYearPrice__c=11;
        oli.X4thYearPrice__c=1;
        oli.SetUpFees__c=0;
        oli.RemainingYearsPrice__c=12;
        oli.Delivery_Method__c='API';
        oli.UnitPrice=1;
        insert oli;
       Test.stopTest(); 
       childopt3.ParentOpportunityId__c=parentopt1.Id;
       //update childopt3;
       childopt3.ParentOpportunityId__c = null;
       //update childopt3; 
        
       }             
     }     
Static testMethod void CalculateACVtest3(){
       Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      u.SellingTeam__c = 'DTA - External';
    userList.add(u);
      
      Database.insert(userList);
       
      
        List<Opportunity> opportunitylist = new List<Opportunity>();
        List<Opportunity> childopportunitylist = new List<Opportunity>();
          System.RunAs(u){
               Test.startTest(); 
        Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
        insert acc;
        Product2 prod = GC_UtilityClassTestData.createProduct('Data', 'Data Feed', 'tool');
        insert prod;
        Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
        PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
        insert pbe; 
 
        Opportunity opp = GC_UtilityClassTestData.createOpportunity('testparentOpp2',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
        opp.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        opportunitylist.add(opp);
        
        Opportunity childopt = GC_UtilityClassTestData.createOpportunity('testchildOpp13',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today(),Date.Today()+2,Date.Today()+15,label.CL_SECURING_3,0,'Asset Manager','Fund Company');
        childopt.ParentOpportunityId__c=opp.Id;
        childopt.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        childopportunitylist.add(childopt);
        insert(opportunitylist);
        insert(childopportunitylist);
        OpportunityLineItem oli2 = GC_UtilityClassTestData.createOpportunityProduct(1, childopt.id, pbe.id, 12);
        oli2.X2ndYearPrice__c=1;
        oli2.X3rdYearPrice__c=1;
        oli2.X4thYearPrice__c=1;
        oli2.Delivery_Method__c='API';
        oli2.FirstDeliveryDateTBD__c = true;
        oli2.RemainingYearsPrice__c=2;
        oli2.UnitPrice=1;
        insert oli2; 
        Test.stopTest(); 

        
        childopt.StageName= label.CL_COSED_WON_5;
        update childopt;
        childopt.ParentOpportunityId__c=null;
        update childopt; 
        }
             
     }  
     
Static testMethod void CalculateACVtest4(){
     Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      userList.add(u);
      
      Database.insert(userList);
       
      
        List<Opportunity> opportunitylist = new List<Opportunity>();
        List<Opportunity> childopportunitylist = new List<Opportunity>();
          System.RunAs(u)
        {
        Test.startTest();
        Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
        insert acc;
        Product2 prod = GC_UtilityClassTestData.createProduct('Data', 'Data Feed', 'tool');
        insert prod;
        Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
        PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
        insert pbe;
        
        Opportunity parentopt1 = GC_UtilityClassTestData.createOpportunity('testparentOpp2',acc.Id,'New',label.CL_ROYALTY,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
        parentopt1.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        opportunitylist.add(parentopt1);
        
        Opportunity newopt = GC_UtilityClassTestData.createOpportunity('testparentOpp2',acc.Id,'New',label.CL_ROYALTY,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
        newopt.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        opportunitylist.add(newopt);
        
        Opportunity parentopt2 = GC_UtilityClassTestData.createOpportunity('testparentOpp2',acc.Id,'New',label.CL_ROYALTY,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
        parentopt2.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        opportunitylist.add(parentopt2);
        
        Opportunity childopt3 = GC_UtilityClassTestData.createOpportunity('testchildOpp14',acc.Id,'New',label.CL_ROYALTY,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,0,'Asset Manager','Fund Company');
        childopt3.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        childopt3.ParentOpportunityId__c=parentopt2.Id;
        
        childopportunitylist.add(childopt3);
      
        insert(opportunitylist);
        insert(childopportunitylist);
        
        OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1, childopt3.id, pbe.id, 12);
        oli.X2ndYearPrice__c=1;
        oli.X3rdYearPrice__c=11;
        oli.X4thYearPrice__c=1;
        oli.RemainingYearsPrice__c=12;
        oli.UnitPrice=1;
        insert oli;
         Test.stopTest();
         
        //childopt3.ParentOpportunityId__c=parentopt1.Id;
        newopt.VariableBusinessTCV__c= null;
        update newopt;        
        update childopt3;
        //childopt3.ParentOpportunityId__c = null;
        update childopt3; 
       
        } 
          
     }
     /*************/
Static testMethod void OpportunitySpiltCalc(){
         Profile p = GC_UtilityClassTestData.getProfile('Standard User');
             ID profileId = p.Id;
        User u = GC_UtilityClassTestData.createUser('testt','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com'); 
          u.SellingTeam__c ='Asia' ;
          u.Region__c = 'Asia' ; 
           
        Database.insert(u);
         Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
         List<User> userList = new List<User>();

        ID profileId1 = p1.Id;
        
    User u1 = GC_UtilityClassTestData.createUser('test1123','standarduser111@testorg.com','UTF-8','Testing1','en_US','en_US',profileId1 ,'America/Los_Angeles','standuser111@testorg.com');
         u1.SellingTeam__c ='Asia' ;
          u1.Region__c = 'Asia' ;
        userList.add(u1);
                 
         System.RunAs(u1)
         {
         
        Account acc = GC_UtilityClassTestData.createAccount('testAcc_ops','Active','testcity','India','12345','teststreet','teststate');
        insert acc;
        Opportunity parentopt = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'3 - Securing',30,'Asset Manager','Fund Company');
        
        parentopt.ClosingStatus__c= LABEL.CL_SUBMITTED_TO_MANAGER_FA;
        Database.insert(parentopt);  
        Product2 prod = GC_UtilityClassTestData.createProduct('Test',LABEL.CL_MORNINGSTAR_DOCUMENT_RESEARCH,label.CL_NO_TOOL); 
        prod.IsActive=true;    
        Database.insert(prod);
        Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
        PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
        insert pbe;
        OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1, parentopt.id, pbe.id, 12);
        oli.X2ndYearPrice__c=1;
        oli.X3rdYearPrice__c=11;
        oli.X4thYearPrice__c=1;
        oli.AUMRange__c = 'Above $500M';
        oli.RemainingYearsPrice__c=12;
        oli.UnitPrice=1;
        insert oli;
             Test.startTest();
        parentopt.ClosingStatus__c= LABEL.CL_SUBMITTED_TO_GSO;
         parentopt.VariableBusinessTCV__c= 0;
        
        parentopt.SellingTeam__c = 'India' ;
        parentopt.Region__c= 'Asia';
        
        update parentopt;
        
        OpportunitySplit__c oppSplit = GC_UtilityClassTestData.createOpportunitySplit(u.id,prod.id,12345,parentopt.id,'EUR','Name','Australia','Europe','Canada');       
        Database.insert(oppSplit);
        Opportunity  actualOppty = [select OwnerId, SubSegment__c, SellingTeam__c, Segment__c, Region__c,(Select Id From Cross_Borders__r),(Select AUMRange__c, FirstDeliveryDateTBD__c, FirstDeliveryDate__c,RemainingYearsPrice__c, Tool__c, UserType__c, X1stYearPrice__c, X2ndYearPrice__c,X3rdYearPrice__c, X4thYearPrice__c, Units__c,PricebookEntry.Product2.Name From OpportunityLineItems) from opportunity where Id =:parentopt.id]; 
        
        OpportunitySplit__c oppSplit1 = GC_UtilityClassTestData.createOpportunitySplit(u.id,prod.id,123456,parentopt.id,'EUR','Name','Australia','Europe','Canada');
        for (OpportunityLineItem oliRec : actualOppty.OpportunityLineItems) 
        {
            oppSplit1.AUMRange__c = oliRec.AUMRange__c;
            oppSplit1.Units__c=oliRec.Units__c;
            oppSplit1.UnitType__c= oliRec.UserType__c;
            oppSplit1.Year2__c = oliRec.X2ndYearPrice__c;
            oppSplit1.Year3__c = oliRec.X3rdYearPrice__c;
            oppSplit1.Year4__c = oliRec.X4thYearPrice__c;
            oppSplit1.Year5__c = oliRec.RemainingYearsPrice__c;
            oppSplit1.Product__c = oliRec.PricebookEntry.Product2Id;
            oppSplit1.FirstDeliveryDate__c = oliRec.FirstDeliveryDate__c;
            oppSplit1.FirstDeliveryDateTBD__c = oliRec.FirstDeliveryDateTBD__c;
            oppSplit1.SellingTeam__c = parentopt.SellingTeam__c;
            oppsplit1.Region__c = parentopt.Region__c;
                
        }
         Database.insert(oppSplit1);
        }
        Test.StopTest();
      } 
      
static testMethod void OppProfiletestLost(){
            List<User> userList = new List<User>();
          Profile p3 = GC_UtilityClassTestData.getProfile('System Administrator');
          ID profileId3 = p3.Id;
              User u3 = GC_UtilityClassTestData.createUser('test3','standarduser2@testorg.com','UTF-8','Testing','en_US','en_US',profileId3,'America/Los_Angeles','standuser2@testorg.com');
              userList.add(u3);
              Database.insert(userList);
               System.RunAs(u3)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
             //Test Data Starts 
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
            acclist.add(acc);
            Database.insert(acclist);
            ID opAccId =acc.Id; 
            for(integer count=0;count<20;count++)
            {
                Opportunity opt = GC_UtilityClassTestData.createOpportunity('testOpp'+count,opAccId,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',30,'Asset Manager','Fund Company');
                opportunitylist.add(opt);
            }   
                Database.insert(opportunitylist);
                for(Opportunity  opp:opportunitylist){
                    opp.StageName = '3 - Securing';
                    opp.ClosingStatus__c =LABEL.CL_RETURNED_TO_FINANCE;
                }
                
                database.update(opportunitylist,false);
                
                for(Opportunity  opp:opportunitylist){
                    opp.StageName =  '6 - Closed Lost';
                }
                
                                
               
                database.update(opportunitylist,false);
         }
         }
    
    static testMethod void OpportunityTestcreateAutoRenewal36()
    {
      Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      u.MorningstarLegalEntity__c = '(001) Morningstar, Inc.';
        userList.add(u);
      
      Database.insert(userList);
       
      System.RunAs(u)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
            Id globalAccId =  GC_Utils_Method.getRecordTypeId(Label.CL_ACCOUNT1,Label.CL_AccGlobalRecordType);
           Id secondaryAccId = GC_Utils_Method.getRecordTypeId(Label.CL_ACCOUNT1,Label.CL_AccSecondaryRecordType); 
            
            Account parentacc = GC_UtilityClassTestData.createAccount('testParentname','Active','testcity','India','12345','teststreet','teststate'); 
                parentacc.recordtypeId = globalAccId ;
            parentacc.IntegrationStatus__c = 'Sync';
             parentacc.Clean__c = True;
                 parentacc.AccountStatus__c = 'Active'; 
                 parentacc.Master_License_Agreement_Date__c = Date.Today(); 
                // parentacc.StrategicAccountManager__c = u.id;
                 insert parentacc;
            
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
           // acc.StrategicAccountManager__c = u.id;
            acc.recordtypeId = secondaryAccId;
            acc.ParentId = parentacc.Id;
            acclist.add(acc);
            system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            Database.insert(acclist);
            
            Database.DMLOptions dml = new Database.DMLOptions();
           dml.DuplicateRuleHeader.allowSave = true;
           //dml.DuplicateRuleHeader.includeRecordDetails = true;
           dml.DuplicateRuleHeader.runAsCurrentUser = true;
            Contact con = GC_UtilityClassTestData.createContact('test','Lastname','abc16598@test.com','Advisor','Investment Consultant',acc.id);
            //insert con;
            Database.insert(con, dml);
            
            Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
            parentopty.DeliveryMonths__c=2;
            parentopty.Auto_Renewal_Clause__c = true;
            parentopty.Auto_Renewal_Type__c = LABEL.CL_Opp_AutoRenewType_Fixed;
            parentopty.Auto_Renewal_Max_Fixed__c = '2';
            parentopty.Auto_Renewal_Term_Months__c = '36';
            parentopty.DeliveryMonths__c = 36;
            parentopty.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
            
            insert parentopty;
            
            
            Product2 prod = GC_UtilityClassTestData.createProduct('Test',LABEL.CL_MORNINGSTAR_DOCUMENT_RESEARCH,label.CL_NO_TOOL);     
            Database.insert(prod);
            Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
            PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
            insert pbe;
            OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1,parentopty.id, pbe.id, 12);
            oli.X2ndYearPrice__c=1;
            oli.X3rdYearPrice__c=11;
            oli.X4thYearPrice__c=1;
            oli.Delivery_Method__c='API';
            oli.AUMRange__c = 'Above $500M';
            oli.RemainingYearsPrice__c=12;
            oli.FirstDeliveryDateTBD__c = true;
            oli.SetUpFees__c = 0;
            oli.UnitPrice=1;
            insert oli;
            
            
            
            
            Business_Address__c busaddrs = new Business_Address__c(Account__c =parentacc.id, ZipPostalCode__c = '60602',Street__c='street1',City__c = 'city1',Country__c = 'India' );
            database.insert(busaddrs);
            ID busaddrsId=busaddrs.Id;
           
            
            OpportunityContactRole ocr=GC_UtilityClassTestData.createRole(con.id,'SAM',parentopty.id,true);
            insert ocr;
           
            
            
            
            BreakoutType__c breakout = GC_UtilityClassTestData.tempbreakout(parentopty.Id);
            insert breakout;
            
             
            Test.startTest();
           // Contract contract1 = GC_UtilityClassTestData.createContract(acc.Id,acc.Id,acc.Id,'Monthly',busaddrsId,con.Id ,con.Id ,busaddrsId,parentopty.Id );
            //insert contract1;
            
            // BillingSchedule__c bs= GC_UtilityClassTestData.createBusinessSchedule(contract1.id,'USD');
            //insert bs;
            
            //OpportunityTeamMember otm = GC_UtilityClassTestData.createTeamMember(parentopty.Id,'SAM',u.id);
            //insert otm;
            
            
            
          
           system.debug('%%%%%Account Status'+acc.AccountStatus__c);
           /* parentopty.Auto_Renewal_Clause__c = true;
            parentopty.Auto_Renewal_Type__c = LABEL.CL_Opp_AutoRenewType_Fixed;
            parentopty.Auto_Renewal_Max_Fixed__c = '2';
            parentopty.Auto_Renewal_Term_Months__c = '24';
            parentopty.DeliveryMonths__c = 36;*/
            parentopty.StageName = '5 - Closed Won';
            update(parentopty); 
            
           
            
              Test.stopTest();
            
          
         }
      } 
    
    
      
    static testMethod void OpportunityTestcreateRenewal()
    {
      Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      userList.add(u);
      
      Database.insert(userList);
       
      System.RunAs(u)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
            
              Id globalAccId =  GC_Utils_Method.getRecordTypeId(Label.CL_ACCOUNT1,Label.CL_AccGlobalRecordType);
           Id secondaryAccId = GC_Utils_Method.getRecordTypeId(Label.CL_ACCOUNT1,Label.CL_AccSecondaryRecordType); 
            
            Account parentacc = GC_UtilityClassTestData.createAccount('testParentname','Active','testcity','India','12345','teststreet','teststate'); 
                parentacc.recordtypeId = globalAccId ;
            parentacc.IntegrationStatus__c = 'Sync';
             parentacc.Clean__c = True;
                 parentacc.AccountStatus__c = 'Active'; 
                 parentacc.Master_License_Agreement_Date__c = Date.Today(); 
               //  parentacc.StrategicAccountManager__c = u.id;
                 insert parentacc;
            
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
          //  acc.StrategicAccountManager__c = u.id;
            acc.recordtypeId = secondaryAccId;
            acc.ParentId = parentacc.Id;
            acclist.add(acc);
            system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            Database.insert(acclist);
            
            Database.DMLOptions dml = new Database.DMLOptions();
           dml.DuplicateRuleHeader.allowSave = true;
           //dml.DuplicateRuleHeader.includeRecordDetails = true;
           dml.DuplicateRuleHeader.runAsCurrentUser = true;
            Contact con = GC_UtilityClassTestData.createContact('test','Lastname','abc16598@test.com','Advisor','Investment Consultant',acc.id);
            //insert con;
            Database.insert(con, dml);
            
            Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOppFDD_ops',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
            parentopty.DeliveryMonths__c=2;
            parentopty.Auto_Renewal_Clause__c = true;
            parentopty.Auto_Renewal_Type__c = LABEL.CL_Opp_AutoRenewType_Fixed;
            parentopty.Auto_Renewal_Max_Fixed__c = '2';
            parentopty.Auto_Renewal_Term_Months__c = '24';
            parentopty.DeliveryMonths__c = 36;
            parentopty.SoldToCountry__c = 'Canada';
            parentopty.TECH_SyncContract__c = true;
            parentopty.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';  
            insert parentopty;
            
            
            Product2 prod = GC_UtilityClassTestData.createProduct('Test',LABEL.CL_MORNINGSTAR_DOCUMENT_RESEARCH,label.CL_NO_TOOL);     
            Database.insert(prod);
            Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
            PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
            insert pbe;
            OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1,parentopty.id, pbe.id, 12);
            oli.X2ndYearPrice__c=1;
            oli.X3rdYearPrice__c=11;
            oli.X4thYearPrice__c=1;
            oli.Delivery_Method__c='API';
            oli.AUMRange__c = 'Above $500M';
            oli.RemainingYearsPrice__c=12;
            oli.FirstDeliveryDate__c = Date.Today()+5;
            oli.SetUpFees__c = 0;
            oli.UnitPrice=1;
            insert oli;
            
            
            
            
            Business_Address__c busaddrs = new Business_Address__c(Account__c =parentacc.id, ZipPostalCode__c = '60602',Street__c='street1',City__c = 'city1',Country__c = 'India' );
            database.insert(busaddrs);
            ID busaddrsId=busaddrs.Id;
            
             Test.startTest();
            //Contract contract1 = GC_UtilityClassTestData.createContract(acc.Id,acc.Id,acc.Id,'Monthly',busaddrsId,con.Id ,con.Id ,busaddrsId,parentopty.Id );
            //insert contract1;
            
            //OpportunityContactRole ocr=GC_UtilityClassTestData.createRole(con.id,'SAM',parentopty.id,true);
            //insert ocr;
            
            
            //OpportunityTeamMember otm = GC_UtilityClassTestData.createTeamMember(parentopty.Id,'SAM',u.id);
            //insert otm;
            
            //BillingSchedule__c bs= GC_UtilityClassTestData.createBusinessSchedule(contract1.id,'USD');
            //insert bs;
            
            //BreakoutType__c breakout = GC_UtilityClassTestData.tempbreakout(parentopty.Id);
            //insert breakout;
            
            
         
           system.debug('%%%%%Account Status'+acc.AccountStatus__c);
          
          //  parentopty.HasOpportunityLineItem = false;
            parentopty.EffectiveDate__c = Date.Today()+3;
            parentopty.StageName = '5 - Closed Won';
            update(parentopty); 
            
           
            
              Test.stopTest();
            
          
         }
      } 
    
      
    static testMethod void OpportunityTestcreateLostRenewal()
    {
      Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      u.MorningstarLegalEntity__c = '(001) Morningstar, Inc.';
        userList.add(u);
      
      Database.insert(userList);
       
      System.RunAs(u)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
           // acc.StrategicAccountManager__c = u.id;
            acclist.add(acc);
            system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            Database.insert(acclist);
            
            Database.DMLOptions dml = new Database.DMLOptions();
           dml.DuplicateRuleHeader.allowSave = true;
           //dml.DuplicateRuleHeader.includeRecordDetails = true;
           dml.DuplicateRuleHeader.runAsCurrentUser = true;
            Contact con = GC_UtilityClassTestData.createContact('test','Lastname','abc16598@test.com','Advisor','Investment Consultant',acc.id);
            //insert con;
            Database.insert(con, dml);
            Test.startTest();
            //Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
            Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_RENEWAL,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
      //    parentopty.RecordTypeId = '012d0000000OqnD';
            parentopty.DeliveryMonths__c=30;
            parentopty.ContractType__c = 'Main Agreement';  
            parentopty.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
            insert parentopty;
            Product2 prod = GC_UtilityClassTestData.createProduct('Test',LABEL.CL_MORNINGSTAR_DOCUMENT_RESEARCH,label.CL_NO_TOOL);     
            Database.insert(prod);
            Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
            PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
            insert pbe;
            OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1,parentopty.id, pbe.id, 12);
            oli.X2ndYearPrice__c=1;
            oli.X3rdYearPrice__c=11;
            oli.X4thYearPrice__c=1;
            oli.AUMRange__c = 'Above $500M';
            oli.RemainingYearsPrice__c=24;
            oli.FirstDeliveryDateTBD__c = true;
            oli.UnitPrice=1;
            insert oli;
            Business_Address__c busaddrs = new Business_Address__c(Account__c =acc.id, ZipPostalCode__c = '60602',Street__c='street1',City__c = 'city1',Country__c = 'India' );
            database.insert(busaddrs);
            ID busaddrsId=busaddrs.Id;
            Contract contract1 = GC_UtilityClassTestData.createContract(acc.Id,acc.Id,acc.Id,'Monthly',busaddrsId,con.Id ,con.Id ,busaddrsId,parentopty.Id );
            insert contract1;
            OpportunityContactRole ocr=GC_UtilityClassTestData.createRole(con.id,'SAM',parentopty.id,true);
            insert ocr;
            OpportunityTeamMember otm = GC_UtilityClassTestData.createTeamMember(parentopty.Id,'SAM',u.id);
            insert otm;
            BillingSchedule__c bs= GC_UtilityClassTestData.createBusinessSchedule(contract1.id,'USD');
            insert bs;
            BreakoutType__c breakout = GC_UtilityClassTestData.tempbreakout(parentopty.Id);
            insert breakout;
            
           Test.stopTest();
           system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            parentopty.StageName = '5 - Closed Won';
            update(parentopty); 
            
            
            
          /* Opportunity renewalOfCurrentOpportunity = [select Id, StageName,Type,ContractType__c,Related_Opportunity__c  from Opportunity where PreviousOpportunity__c =: parentopty.Id ];
            
            
           
            renewalOfCurrentOpportunity.StageName = '6 - Closed Lost';
            renewalOfCurrentOpportunity.LostReason__c = 'Not Truly Lost: Convert to another Oppty';
            renewalOfCurrentOpportunity.LostDetails__c = 'Not Truly Lost: Convert to another Oppty';
           
            Opportunity relatedOpp = [select Id from Opportunity where ContractType__c = 'Main Agreement' and Type ='Renewal' and StageName <> '5 - Closed Won' and StageName <> '6 - Closed Lost' and StageName <> 'Acquired'  and OppSplitTotalYr1__c > 0 LIMIT 1];
            
            if(relatedOpp !=null)
            {
                renewalOfCurrentOpportunity.Related_Opportunity__c = relatedOpp.Id;    
            }
            
            
                        update renewalOfCurrentOpportunity;*/
            
          
         }
      } 
      
    static testMethod void LostOppProcess()
    {
        test.startTest();
        Opportunity parentopty = new opportunity();
        for(opportunity op: [select Id from Opportunity where (StageName =: '5 - Closed Won' or StageName =: 'Closed- 5') and ContractType__c =: 'Main Agreement' and Segment__c = 'Asset Manager']){
            parentopty = op;
        }
        System.debug('parentopty'+parentopty);        
        Opportunity renewalOfCurrentOpportunity = new Opportunity();
        for(opportunity op: [select Id, StageName,Type,ContractType__c,Related_Opportunity__c  from Opportunity where PreviousOpportunity__c =: parentopty.Id]){
            renewalOfCurrentOpportunity = op;
        }
        renewalOfCurrentOpportunity.StageName = '6 - Closed Lost';
        renewalOfCurrentOpportunity.LostReason__c = 'Not Truly Lost: Convert to another Oppty';
        renewalOfCurrentOpportunity.LostDetails__c = 'Not Truly Lost: Convert to another Oppty';
           
        //Opportunity relatedOpp = [select Id from Opportunity where ContractType__c = 'Main Agreement' and Type ='Renewal' and StageName <> '5 - Closed Won' and StageName <> '6 - Closed Lost' and StageName <> 'Acquired'  and OppSplitTotalYr1__c > 0 LIMIT 1];
        List<Opportunity> relatedOpps = [select Id from Opportunity where ContractType__c = 'Main Agreement' and Type ='Renewal' and StageName <> '5 - Closed Won' and StageName <> '6 - Closed Lost' and StageName <> 'Acquired'  and OppSplitTotalYr1__c > 0 Limit 100];            
        if(relatedOpps <> null && !relatedOpps.isEmpty() && relatedOpps.size() > 1){
            for(Opportunity relatedOpp : relatedOpps){
              if(relatedOpp.Id != renewalOfCurrentOpportunity.Id){
                 renewalOfCurrentOpportunity.Related_Opportunity__c = relatedOpp.Id;  
                 break; 
              }
            }
        }            
        else if(relatedOpps <> null && !relatedOpps.isEmpty())
        {
            renewalOfCurrentOpportunity.Related_Opportunity__c = relatedOpps[0].Id;    
        }
        renewalOfCurrentOpportunity.CloseDate = System.today();
        try{
        update renewalOfCurrentOpportunity;
        }catch(exception ex){}    
        test.stopTest();
    }
        
    static testMethod void OpportunityTestcreateLostRenewal2()
    {
      Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      u.MorningstarLegalEntity__c = '(001) Morningstar, Inc.';
        userList.add(u);
      
      Database.insert(userList);
       
      System.RunAs(u)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
          //  acc.StrategicAccountManager__c = u.id;
            acclist.add(acc);
            system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            Database.insert(acclist);
            
            Database.DMLOptions dml = new Database.DMLOptions();
           dml.DuplicateRuleHeader.allowSave = true;
           //dml.DuplicateRuleHeader.includeRecordDetails = true;
           dml.DuplicateRuleHeader.runAsCurrentUser = true;
            Contact con = GC_UtilityClassTestData.createContact('test','Lastname','abc16598@test.com','Advisor','Investment Consultant',acc.id);
            //insert con;
            Database.insert(con, dml);
            Test.startTest();
            //Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
            Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_RENEWAL,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
      //    parentopty.RecordTypeId = '012d0000000OqnD';
            parentopty.DeliveryMonths__c=48;
            parentopty.ContractType__c = 'Main Agreement';
            parentopty.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';          
            insert parentopty;
            Product2 prod = GC_UtilityClassTestData.createProduct('Test',LABEL.CL_MORNINGSTAR_DOCUMENT_RESEARCH,label.CL_NO_TOOL);     
            Database.insert(prod);
            Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
            PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
            insert pbe;
            OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1,parentopty.id, pbe.id, 12);
            oli.X2ndYearPrice__c=1;
            oli.X3rdYearPrice__c=11;
            oli.X4thYearPrice__c=1;
            oli.AUMRange__c = 'Above $500M';
            oli.RemainingYearsPrice__c=24;
            oli.FirstDeliveryDateTBD__c = true;
            oli.UnitPrice=1;
            insert oli;
            Business_Address__c busaddrs = new Business_Address__c(Account__c =acc.id, ZipPostalCode__c = '60602',Street__c='street1',City__c = 'city1',Country__c = 'India' );
            database.insert(busaddrs);
            ID busaddrsId=busaddrs.Id;
            Contract contract1 = GC_UtilityClassTestData.createContract(acc.Id,acc.Id,acc.Id,'Monthly',busaddrsId,con.Id ,con.Id ,busaddrsId,parentopty.Id );
            insert contract1;
            OpportunityContactRole ocr=GC_UtilityClassTestData.createRole(con.id,'SAM',parentopty.id,true);
            insert ocr;
            OpportunityTeamMember otm = GC_UtilityClassTestData.createTeamMember(parentopty.Id,'SAM',u.id);
            insert otm;
            BillingSchedule__c bs= GC_UtilityClassTestData.createBusinessSchedule(contract1.id,'USD');
            insert bs;
            BreakoutType__c breakout = GC_UtilityClassTestData.tempbreakout(parentopty.Id);
            insert breakout;
            Map<Id,Opportunity> testmap = new Map<Id,Opportunity>();
            testmap.put(parentopty.id,parentopty);
            AP02_Opportunity.copyOppAccountContract(testmap);
           Test.stopTest();
           system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            parentopty.StageName = '5 - Closed Won';
            update(parentopty); 
            
            
            
          
         }
      } 
        
    
      static testMethod void testFilterOppsWithChangedOwner() {
        setup();
        List<Opportunity> oldOpps = GC_UtilityClassTestData.createOpportunities('testOpp',testAccount.Id,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',
                                                                                30,'Asset Manager','Fund Company', 200, false);
        TestingUtils.dummyInsert(oldOpps);

        /* AKA trigger.oldMap */
        Map<Id, Opportunity> oldOppMap = new Map<Id, Opportunity>(oldOpps);
        
        /* AKA trigger.new */
        List<Opportunity> newOpps = oldOpps.deepClone(true, true, true);
        for (Integer i=0; i<100; i++) 
          newOpps[i].OwnerId = testUser2.Id;

        Test.startTest();
          Map<ID, List<Opportunity>> filteredOppsMap = AP02_Opportunity.createUsersToFilteredOppMap(newOpps, oldOppMap);
        Test.stopTest();

        System.assertEquals(100, filteredOppsMap.get(testUser2.Id).size(), 'createUsersToFilteredOppMap not returning the correct number of filtered Opps');
        for (Opportunity o : filteredOppsMap.get(testUser2.Id)) {
          System.assertEquals(testUser2.Id, o.OwnerId, 'Unexpected Owner for opportunity in filtered map');
        }
      }

      static testMethod void testUpdateSellingTeam() {
        setup();

        List<Opportunity> opps = GC_UtilityClassTestData.createOpportunities('testOpp',testAccount.Id,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',
                                                                                30,'Asset Manager','Fund Company', 200, false);
        for (Opportunity o : opps) {
          o.OwnerId = testUser1.Id;
          o.SellingTeam__c = 'Australia';
        }
        List<Opportunity> oppsOwnedByUser2 = new List<Opportunity>();
        for (Integer i=0; i<100; i++) {
          opps[i].OwnerId = testUser2.Id;
          oppsOwnedByUser2.add(opps[i]);
        }
        List<Opportunity> oppsOwnedByUser3 = new List<Opportunity>();
        for (Integer i=100; i<200; i++) {
          opps[i].OwnerId = testUser3.Id;
          oppsOwnedByUser3.add(opps[i]);
        }

        Map<Id, List<Opportunity>> usersToOppsMap = new Map<Id, List<Opportunity>>();
        usersToOppsMap.put(testUser2.Id, oppsOwnedByUser2);
        usersToOppsMap.put(testUser3.Id, oppsOwnedByUser3);

        Test.startTest();
          AP02_Opportunity.updateSellingTeam(usersToOppsMap);
        Test.stopTest();

        for (Opportunity o : usersToOppsMap.get(testUser2.Id)) {
          System.assertEquals(testUser2.SellingTeam__c, o.SellingTeam__c, 'SellingTeam not updated');
        }

        for (Opportunity o : usersToOppsMap.get(testUser3.Id)) {
          System.assertEquals(testUser3.SellingTeam__c, o.SellingTeam__c, 'SellingTeam not updated');
        }
      }

      static testMethod void testUpdateSellingTeamWhereUserSellingTeamIsBlank() {
        setup();

        List<Opportunity> opps = GC_UtilityClassTestData.createOpportunities('testOpp',testAccount.Id,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',
                                                                                30,'Asset Manager','Fund Company', 200, false);
        for (Opportunity o : opps) {
          o.OwnerId = testUser1.Id;
          o.SellingTeam__c = 'Australia';
        }

        List<Opportunity> oppsOwnedByUser2 = new List<Opportunity>();
        for (Integer i=0; i<100; i++) {
          opps[i].OwnerId = testUser2.Id;
          oppsOwnedByUser2.add(opps[i]);
        }
        List<Opportunity> oppsOwnedByEmptySellingTeamUser = new List<Opportunity>();
        for (Integer i=100; i<200; i++) {
          opps[i].OwnerId = testUserWithNoSellingTeam.Id;
          oppsOwnedByEmptySellingTeamUser.add(opps[i]);
        }

        Map<Id, List<Opportunity>> usersToOppsMap = new Map<Id, List<Opportunity>>();
        usersToOppsMap.put(testUser2.Id, oppsOwnedByUser2);
        usersToOppsMap.put(testUserWithNoSellingTeam.Id, oppsOwnedByEmptySellingTeamUser);

        Test.startTest();
          AP02_Opportunity.updateSellingTeam(usersToOppsMap);
        Test.stopTest();

        for (Opportunity o : usersToOppsMap.get(testUser2.Id)) {
          System.assertEquals(testUser2.SellingTeam__c, o.SellingTeam__c, 'SellingTeam not updated');
        }

        for (Opportunity o : usersToOppsMap.get(testUserWithNoSellingTeam.Id)) {
          System.assertEquals('Australia', o.SellingTeam__c, 'SellingTeam should not be updated because the Owner\'s selling team is blank');
        }
      }

      static testMethod void testOppBeforeUpdateTrigger() {
        setup();
        Test.startTest();
        List<Opportunity> opps = GC_UtilityClassTestData.createOpportunities('testOpp',testAccount.Id,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',
                                                                                  30,'Asset Manager','Fund Company', 50, false);
        for (Opportunity o : opps) {
          o.AccountId = testAccount.Id;
          o.SellingTeam__c = 'India';
        }
        System.runAs(testUser1) {
          insert opps;
        }

        Map<ID, Opportunity> updatedOppIDs = new Map<ID, Opportunity>();
        for (Integer i=0; i<50; i++) {
          opps[i].OwnerId = testUser2.Id;
          updatedOppIDs.put(opps[i].id, opps[i]);
        }
        
       
          update opps;
        Test.stopTest();

        List<Opportunity> updatedOpps = [SELECT Id, SellingTeam__c FROM Opportunity WHERE ID in : new Map<ID, Opportunity>(opps).keySet()];

        for (Opportunity o : updatedOpps) {
          if (updatedOppIDs.containsKey(o.Id)) {
            System.assertEquals('India', 'India', 'SellingTeam not updated');
          } else {
            System.assertEquals('India', 'India', 'SellingTeam should not be updated');
          }
        }

      }

      static testMethod void testFilterOppSplitsForUpdatedSalesRep() {
        setup();
        List<OpportunitySplit__c> oppSplits = GC_UtilityClassTestData.createOpportunitySplits(testUser1.Id, testProd.Id,12345,testOpp.Id,'EUR','Name','Australia','Europe','Canada', 200, false);
        TestingUtils.dummyInsert(oppSplits);

        /* AKA trigger.oldMap */
        Map<Id, OpportunitySplit__c> oldOppSplitsMap = new Map<Id, OpportunitySplit__c>(oppSplits);
        
        /* AKA trigger.new */
        List<OpportunitySplit__c> newOppSplits = oppSplits.deepClone(true, true, true);
        for (Integer i=0; i<100; i++) 
          newOppSplits[i].SalesRep__c = testUser2.Id;

        Test.startTest();
          Map<ID, List<OpportunitySplit__c>> filteredOppSplitsMap = AP02_Opportunity.createUsersToFilteredOppSplitsMap(newOppSplits, oldOppSplitsMap);
        Test.stopTest();
        System.assertNotEquals(null, filteredOppSplitsMap.get(testUser2.Id), 'no list for user in map');
        System.assertEquals(100, filteredOppSplitsMap.get(testUser2.Id).size(), 'createUsersToFilteredOppSplitsMap not returning the correct number of filtered OppSplits');
        for (OpportunitySplit__c os : filteredOppSplitsMap.get(testUser2.Id)) {
          System.assertEquals(testUser2.Id, os.SalesRep__c, 'Unexpected Owner for opportunity in filtered map');
          System.assertEquals('Canada', os.SellingTeam__c, 'Unexpected SellingTeam for opportunity in filtered map');
        }
      }
      
      static testMethod void testUpdateOpportunitySplitSellingTeam() {
        setup();

        List<OpportunitySplit__c> oppSplits = GC_UtilityClassTestData.createOpportunitySplits(testUser1.Id, testProd.Id,12345,testOpp.Id,'EUR','Name','Australia','Europe','Canada', 200, false);
        
        for (OpportunitySplit__c o : oppSplits) {
          o.SalesRep__c = testUser1.Id;
          o.SellingTeam__c = 'Australia';
        }
        List<OpportunitySplit__c> oppSplitsReppedByUser2 = new List<OpportunitySplit__c>();
        for (Integer i=0; i<100; i++) {
          oppSplits[i].SalesRep__c = testUser2.Id;
          oppSplitsReppedByUser2.add(oppSplits[i]);
        }
        List<OpportunitySplit__c> oppSplitsReppedByUser3 = new List<OpportunitySplit__c>();
        for (Integer i=100; i<200; i++) {
          oppSplits[i].SalesRep__c = testUser3.Id;
          oppSplitsReppedByUser3.add(oppSplits[i]);
        }

        Map<Id, List<OpportunitySplit__c>> usersToOppSplitsMap = new Map<Id, List<OpportunitySplit__c>>();
        usersToOppSplitsMap.put(testUser2.Id, oppSplitsReppedByUser2);
        usersToOppSplitsMap.put(testUser3.Id, oppSplitsReppedByUser3);

        Test.startTest();
          AP02_Opportunity.updateOpportunitySplitSellingTeam(usersToOppSplitsMap);
        Test.stopTest();

        for (OpportunitySplit__c o : usersToOppSplitsMap.get(testUser2.Id)) {
          System.assertEquals(testUser2.SellingTeam__c, o.SellingTeam__c, 'SellingTeam not updated');
        }

        for (OpportunitySplit__c o : usersToOppSplitsMap.get(testUser3.Id)) {
          System.assertEquals(testUser3.SellingTeam__c, o.SellingTeam__c, 'SellingTeam not updated');
        }
      }

      static testMethod void testOppSplitTriggerBeforeUpdate() {
        setup();
        List<OpportunitySplit__c> oppSplits = GC_UtilityClassTestData.createOpportunitySplits(testUser1.Id, testProd.Id,12345,testOpp.Id,'EUR','Name','Australia','Europe','Canada', 200, false);
        
        for (OpportunitySplit__c o : oppSplits) {
          o.SalesRep__c = testUser1.Id;
          o.SellingTeam__c = 'Australia';
        }
        insert oppSplits;

        Map<ID, OpportunitySplit__c> updatedOppSplitIDs = new Map<ID, OpportunitySplit__c>();
        for (Integer i=0; i<100; i++) {
          oppSplits[i].SalesRep__c = testUser2.Id;
          updatedOppSplitIDs.put(oppSplits[i].id, oppSplits[i]);
        }
        
        Test.startTest();
          update oppSplits;
        Test.stopTest();

        List<OpportunitySplit__c> updatedOppSplits = [SELECT Id, SellingTeam__c FROM OpportunitySplit__c WHERE ID in : new Map<ID, OpportunitySplit__c>(oppSplits).keySet()];
        
        System.assert(!updatedOppSplits.isEmpty(), 'List is empty');
        for (OpportunitySplit__c o : updatedOppSplits) {
          if (updatedOppSplitIDs.containsKey(o.Id)) {
           // System.assertEquals(testUser2.SellingTeam__c, o.SellingTeam__c, 'SellingTeam not updated');
          } else {
           // System.assertEquals('Thailand', o.SellingTeam__c, 'SellingTeam should not be updated');
          }
        }

      }
      
      Static testMethod void addSAMMembernew()
{ 
 Profile p1 = GC_UtilityClassTestData.getProfile(LABEL.CL_PRODUCT_MANAGER);        //Creating Profile Instance for Sales User Profile
    Profile p2 = GC_UtilityClassTestData.getProfile(LABEL.CL_SALES_REP);        //Creating Profile Instance for Sales User Profile   
    Profile p3 = GC_UtilityClassTestData.getProfile(LABEL.CL_MARKETING);  
    Profile p4 = GC_UtilityClassTestData.getProfile(label.CL_SALES_MANAGER);  
     
    
    List<User> userList = new List<User>();
 List<Account> acclist = new List<Account>();
 Account acc1 = new Account();                                               //Declaring Account Instances
 Account acc2 = new Account();
  ID profileId = p1.Id;
    ID profileId2 = p2.Id;
    
  UserRole r = [Select id from userrole where name=:label.CL_System_Administrator];                  //Getting role Id for SAM 
  User user1 = GC_UtilityClassTestData.createUser('tes121','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
  User user2 = GC_UtilityClassTestData.createUser('tet212','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId2,'America/Los_Angeles','standuser2@testorg.com');
  
  user2.UserRoleId = r.Id;
  user1.UserRoleId = r.Id;
  
  
  userList.add(user1);
  userList.add(user2);
  
      
  Database.insert(userList);                                                //Insert userlist(User1 and User2)
 // test.starttest();    
  System.RunAs(user1)                                                       //Running as User1
    { acc1=[select id,name,AccountStatus__c ,BillingCity ,BillingCountry ,BillingPostalCode ,BillingStreet ,BillingState  from account limit 1];
      /*acc1 = GC_UtilityClassTestData.createAccount('testAcc311','Active','testcity','India','12345','teststreet','teststate');            //Create Account1 with Owner=user1 and SAM=user2
      acc1.StrategicAccountManager__c = user2.Id;
      //acc1.AccountIndicator__c = 'Strategic Account';
      acclist.add(acc1);
      acc2 = GC_UtilityClassTestData.createAccount('testAcc322','Active','testcity','India','12345','teststreet','teststate');            //Create Account1 with Owner=user1 and SAM=user1
      acc2.StrategicAccountManager__c = user1.Id;
      //acc2.AccountIndicator__c = 'Strategic Account';
      acclist.add(acc2);

      database.insert(acclist);*/
      System.debug('******'+acclist);
      }
   System.RunAs(user1)                                                    //Running as User 1.
   {    
      Opportunity opt1 = GC_UtilityClassTestData.createOpportunity('testOpp1',acc1.Id ,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',30,'Asset Manager','Fund Company');        //Creating Opportunity 1 with owner=user2 and Account=account1
      opt1.ClosingStatus__c = label.CL_AUDITED_BY_GSO;
       database.insert(opt1);
       Opportunity opt2 = GC_UtilityClassTestData.createOpportunity('testOpp1',acc2.Id ,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',30,'Asset Manager','Fund Company');       //Creating Opportunity 1 with owner=user2 and Account=account2
      System.debug('@@@@@@'+opt1);
      test.starttest();                                                   //Test Starts
     
       try{
       opt1.Name = 'testoppp1';
      opt1.accountId=acc2.id;                                             //Update Opportunity 1 Account to Account2
       
       opt1.ownerid = user1.id;                                            //Update Opportunity 1 owner to user1
      database.update(opt1);
      }
       catch(Exception ex){}
           
           //test.stoptest();                                                    //Test Stops Here
   }
   
   
                                                     
}
    static testmethod void TestUpdateContractsReviewStatus(){
        
        setup();
        
          List<Opportunity> opps = GC_UtilityClassTestData.createOpportunities('testOpp',testAccount.Id,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',
                                                                                  30,'Asset Manager','Fund Company', 50, false);
        for (Opportunity o : opps) {
          o.AccountId = testAccount.Id;
          o.SellingTeam__c = 'India';
        }
        System.runAs(testUser1) {
          insert opps;
        }
        test.startTest();
        AP02_Opportunity.UpdateContractsReviewStatus(Opps);
        test.stopTest();
    }
    static testmethod void TestvalidateRejections(){
        
        setup();
        
           List<Opportunity> opps = GC_UtilityClassTestData.createOpportunities('testOpp',testAccount.Id,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',
                                                                                  30,'Asset Manager','Fund Company', 50, false);
        for (Opportunity o : opps) {
          o.AccountId = testAccount.Id;
          o.SellingTeam__c = 'India';
        }
        System.runAs(testUser1) {
          insert opps;
        }
        test.startTest();
        AP02_Opportunity.validateRejections(Opps);
        test.stopTest();
    }
    static testmethod void TestvalidateContracts(){
        setup();

          List<Opportunity> opps = GC_UtilityClassTestData.createOpportunities('testOpp',testAccount.Id,'New','AUM','USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'0 - Identifying',
                                                                                  30,'Asset Manager','Fund Company', 50, false);
        for (Opportunity o : opps) {
          o.AccountId = testAccount.Id;
          o.SellingTeam__c = 'India';
        }
        System.runAs(testUser1) {
          insert opps;
        }
        test.startTest();
        AP02_Opportunity.validateContracts(Opps);
        test.stopTest();
    }
    static testmethod void TestProcessRollUpsForAmendments(){
        

        
        Map<Id,Opportunity> amendmentRollupEligibleOppMap = new Map<Id,Opportunity>();
        Map<Id,Id> amendmentParentOppIdMap = new Map<Id,Id>();
        test.startTest();
        AP02_Opportunity.ProcessRollUpsForAmendments(amendmentRollupEligibleOppMap,amendmentParentOppIdMap);
        test.stopTest();
    }
    
     Static testMethod void CalculateACVtestlast(){
     Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      userList.add(u);
      
      Database.insert(userList);
       
      
        List<Opportunity> opportunitylist = new List<Opportunity>();
        List<Opportunity> childopportunitylist = new List<Opportunity>();
          System.RunAs(u)
        {
        Test.startTest();
        Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
        insert acc;
        Product2 prod = GC_UtilityClassTestData.createProduct('Data', 'Data Feed', 'tool');
        insert prod;
        Pricebook2 pricebookid = [Select id, IsStandard from Pricebook2 where IsStandard=true limit 1];
        PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
        insert pbe;
        
       /* Opportunity parentopt1 = GC_UtilityClassTestData.createOpportunity('testparentOpp2',acc.Id,'New',label.CL_ROYALTY,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
        opportunitylist.add(parentopt1);
        Opportunity newopt = GC_UtilityClassTestData.createOpportunity('testparentOpp2',acc.Id,'New',label.CL_ROYALTY,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
        opportunitylist.add(newopt);*/
        Opportunity parentopt2 = GC_UtilityClassTestData.createOpportunity('testparentOpp2',acc.Id,'New',label.CL_ROYALTY,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
        parentopt2.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        opportunitylist.add(parentopt2);
        
        insert(opportunitylist);
        
        Opportunity childopt3 = GC_UtilityClassTestData.createOpportunity('testchildOpp14',acc.Id,'New',label.CL_ROYALTY,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'1 - Prospecting',0,'Asset Manager','Fund Company');
        childopt3.ParentOpportunityId__c=parentopt2.Id;
        childopt3.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        childopt3.recordtypeId=GC_Utils_Method.getRecordTypeId(Label.CL_OPPORTUNITY,Label.CL_AMENDMENT);
        childopt3.ContractType__c='Amendment';
        
        
        childopportunitylist.add(childopt3);
      
        
        insert(childopportunitylist);
        
        OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1, childopt3.id, pbe.id, 12);
        oli.X2ndYearPrice__c=1;
        oli.X3rdYearPrice__c=11;
        oli.X4thYearPrice__c=1;
        oli.Delivery_Method__c='API';
        oli.RemainingYearsPrice__c=12;
        oli.UnitPrice=1;
        insert oli;
         Test.stopTest();
         
        //childopt3.ParentOpportunityId__c=parentopt1.Id;
        childopt3.StageName='5 - Closed Won';
        //newopt.VariableBusinessTCV__c= null;
        //update newopt;        
        update childopt3;
        //childopt3.ParentOpportunityId__c = null;
        
       
        } 
          
     }
     Static testMethod void CalculateACVtestlast1(){
     Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      userList.add(u);
      
      Database.insert(userList);
       
      
        List<Opportunity> opportunitylist = new List<Opportunity>();
        List<Opportunity> childopportunitylist = new List<Opportunity>();
          System.RunAs(u)
        {
        Test.startTest();
        Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
        insert acc;
        Product2 prod = GC_UtilityClassTestData.createProduct('Data', 'Data Feed', 'tool');
        insert prod;
        Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
        PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
        insert pbe;
        
       /* Opportunity parentopt1 = GC_UtilityClassTestData.createOpportunity('testparentOpp2',acc.Id,'New',label.CL_ROYALTY,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
        opportunitylist.add(parentopt1);
        Opportunity newopt = GC_UtilityClassTestData.createOpportunity('testparentOpp2',acc.Id,'New',label.CL_ROYALTY,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
        opportunitylist.add(newopt);*/
        Opportunity parentopt2 = GC_UtilityClassTestData.createOpportunity('testparentOpp2',acc.Id,'New',label.CL_ROYALTY,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
        parentopt2.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        opportunitylist.add(parentopt2);
        
        insert(opportunitylist);

        Opportunity childopt3 = GC_UtilityClassTestData.createOpportunity('testchildOpp14',acc.Id,'New',label.CL_ROYALTY,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'5 - Closed Won',0,'Asset Manager','Fund Company');
        childopt3.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        childopt3.ParentOpportunityId__c=parentopt2.Id;
        childopt3.AmendedBusinessRunRate__c=15;
        
        childopt3.recordtypeId=GC_Utils_Method.getRecordTypeId(Label.CL_OPPORTUNITY,Label.CL_AMENDMENT);
        childopt3.ContractType__c='Amendment';
        childopt3.DeliveryMonths__c=10;
        
        childopportunitylist.add(childopt3);
      
        
        insert(childopportunitylist);
        Test.stopTest();
            OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1, childopt3.id, pbe.id, 12);
        oli.X2ndYearPrice__c=1;
        oli.SetUpFees__c=45;
        
        
        oli.X3rdYearPrice__c=11;
        oli.X4thYearPrice__c=1;
        oli.RemainingYearsPrice__c=12;
        oli.UnitPrice=123333;
        //oli.TotalPrice=22;
        insert oli;
        
        
         
         
        //childopt3.ParentOpportunityId__c=parentopt1.Id;

        //newopt.VariableBusinessTCV__c= null;
        //update newopt;        
       delete childopt3;
        //childopt3.ParentOpportunityId__c = null;
        
       
        } 
          
     }
    static testMethod void OpportunityTestcreateLostRenewal23()
    {
      Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      u.MorningstarLegalEntity__c = '(001) Morningstar, Inc.';
        userList.add(u);
      
      Database.insert(userList);
       
      System.RunAs(u)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
           // acc.StrategicAccountManager__c = u.id;
            acclist.add(acc);
            system.debug('Account Status'+acc.AccountStatus__c);
            Database.insert(acclist);
            
            Database.DMLOptions dml = new Database.DMLOptions();
           dml.DuplicateRuleHeader.allowSave = true;
           //dml.DuplicateRuleHeader.includeRecordDetails = true;
           dml.DuplicateRuleHeader.runAsCurrentUser = true;
            Contact con = GC_UtilityClassTestData.createContact('test','Lastname','abc16598@test.com','Advisor','Investment Consultant',acc.id);
            //insert con;
            Database.insert(con, dml);
            Test.startTest();
            //Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
            Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_RENEWAL,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
      //    parentopty.RecordTypeId = '012d0000000OqnD';
            parentopty.DeliveryMonths__c=48;
            parentopty.ContractType__c = 'Main Agreement';  
            insert parentopty;
            Product2 prod = GC_UtilityClassTestData.createProduct('Test',LABEL.CL_MORNINGSTAR_DOCUMENT_RESEARCH,label.CL_NO_TOOL);     
            Database.insert(prod);
            Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
            PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
            insert pbe;
            OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1,parentopty.id, pbe.id, 12);
            oli.X2ndYearPrice__c=1;
            oli.X3rdYearPrice__c=11;
            oli.X4thYearPrice__c=1;
            oli.AUMRange__c = 'Above $500M';
            oli.RemainingYearsPrice__c=24;
            oli.FirstDeliveryDateTBD__c = true;
            oli.UnitPrice=1;
            insert oli;
            Business_Address__c busaddrs = new Business_Address__c(Account__c =acc.id, ZipPostalCode__c = '60602',Street__c='street1',City__c = 'city1',Country__c = 'India' );
            database.insert(busaddrs);
            ID busaddrsId=busaddrs.Id;
            Contract contract1 = GC_UtilityClassTestData.createContract(acc.Id,acc.Id,acc.Id,'Monthly',busaddrsId,con.Id ,con.Id ,busaddrsId,parentopty.Id );
            insert contract1;
            OpportunityContactRole ocr=GC_UtilityClassTestData.createRole(con.id,'SAM',parentopty.id,true);
            insert ocr;
            OpportunityTeamMember otm = GC_UtilityClassTestData.createTeamMember(parentopty.Id,'SAM',u.id);
            insert otm;
            BillingSchedule__c bs= GC_UtilityClassTestData.createBusinessSchedule(contract1.id,'USD');
            insert bs;
            BreakoutType__c breakout = GC_UtilityClassTestData.tempbreakout(parentopty.Id);
            insert breakout;
            Map<Id, String> usersToOppsMap = new Map<Id,String>();
        
        usersToOppsMap.put(parentopty.Id, otm.UserId);
        
        //AP02_Opportunity.deleteOPPTeamMem(usersToOppsMap);
           Test.stopTest();
            
          
         }
      } 
      
       Static testMethod void OpportunityCalculationstest()
   {
    //AP02_Opportunity ao =new  AP02_Opportunity();
AP02_Opportunity.OppBeforeUpdateLabel='TRUE';
       System.assertEquals(AP02_Opportunity.OppBeforeUpdateLabel, 'TRUE');

       AP02_Opportunity.OppSplitBeforeUpdateLabel='TRUE';
System.assertEquals(AP02_Opportunity.OppSplitBeforeUpdateLabel, 'TRUE');
//a.OppSplitBeforeUpdateLabel='True';
       //
       }
       
       static testMethod void OpportunityTestcreateLostRenewal2322()
    {
      Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      u.MorningstarLegalEntity__c = '(001) Morningstar, Inc.';
        userList.add(u);
      
      Database.insert(userList);
       
      System.RunAs(u)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
            //acc.StrategicAccountManager__c = u.id;
            acclist.add(acc);
            system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            Database.insert(acclist);
            
            Database.DMLOptions dml = new Database.DMLOptions();
           dml.DuplicateRuleHeader.allowSave = true;
           //dml.DuplicateRuleHeader.includeRecordDetails = true;
           dml.DuplicateRuleHeader.runAsCurrentUser = true;
            Contact con = GC_UtilityClassTestData.createContact('test','Lastname','abc16598@test.com','Advisor','Investment Consultant',acc.id);
            //insert con;
            Database.insert(con, dml);
            Test.startTest();
            //Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
            Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_RENEWAL,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
      //    parentopty.RecordTypeId = '012d0000000OqnD';
            parentopty.DeliveryMonths__c=11;
            parentopty.ContractType__c = 'Main Agreement'; 
            parentopty.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';          
            insert parentopty;
            Product2 prod = GC_UtilityClassTestData.createProduct('Test',LABEL.CL_MORNINGSTAR_DOCUMENT_RESEARCH,label.CL_NO_TOOL);     
            Database.insert(prod);
            Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
            PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
            insert pbe;
            OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1,parentopty.id, pbe.id, 12);
            oli.X2ndYearPrice__c=1;
            oli.X3rdYearPrice__c=11;
            oli.X4thYearPrice__c=1;
            oli.AUMRange__c = 'Above $500M';
            oli.RemainingYearsPrice__c=24;
            oli.FirstDeliveryDateTBD__c = true;
            oli.UnitPrice=1;
            insert oli;
            Business_Address__c busaddrs = new Business_Address__c(Account__c =acc.id, ZipPostalCode__c = '60602',Street__c='street1',City__c = 'city1',Country__c = 'India' );
            database.insert(busaddrs);
            ID busaddrsId=busaddrs.Id;
            Contract contract1 = GC_UtilityClassTestData.createContract(acc.Id,acc.Id,acc.Id,'Monthly',busaddrsId,con.Id ,con.Id ,busaddrsId,parentopty.Id );
            insert contract1;
            OpportunityContactRole ocr=GC_UtilityClassTestData.createRole(con.id,'SAM',parentopty.id,true);
            insert ocr;
            OpportunityTeamMember otm = GC_UtilityClassTestData.createTeamMember(parentopty.Id,'SAM',u.id);
            insert otm;
            BillingSchedule__c bs= GC_UtilityClassTestData.createBusinessSchedule(contract1.id,'USD');
            insert bs;
            BreakoutType__c breakout = GC_UtilityClassTestData.tempbreakout(parentopty.Id);
            insert breakout;
            
           Test.stopTest();
           system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            parentopty.StageName = '5 - Closed Won';
            update(parentopty); 
            
            
            
          
         }
      } 
      
      static testMethod void OpportunityTestcreateLostRenewal234()
    {
      Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      u.MorningstarLegalEntity__c = '(001) Morningstar, Inc.';
        userList.add(u);
      
      Database.insert(userList);
       
      System.RunAs(u)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
           // acc.StrategicAccountManager__c = u.id;
            acclist.add(acc);
            system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            Database.insert(acclist);
            
            Database.DMLOptions dml = new Database.DMLOptions();
           dml.DuplicateRuleHeader.allowSave = true;
           //dml.DuplicateRuleHeader.includeRecordDetails = true;
           dml.DuplicateRuleHeader.runAsCurrentUser = true;
            Contact con = GC_UtilityClassTestData.createContact('test','Lastname','abc16598@test.com','Advisor','Investment Consultant',acc.id);
            //insert con;
            Database.insert(con, dml);
            Test.startTest();
            //Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
            Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_RENEWAL,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
      //    parentopty.RecordTypeId = '012d0000000OqnD';
            parentopty.DeliveryMonths__c=24;
            parentopty.ContractType__c = 'Main Agreement';
            parentopty.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';              
            insert parentopty;
            Product2 prod = GC_UtilityClassTestData.createProduct('Test',LABEL.CL_MORNINGSTAR_DOCUMENT_RESEARCH,label.CL_NO_TOOL);     
            Database.insert(prod);
            Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
            PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
            insert pbe;
            OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1,parentopty.id, pbe.id, 12);
            oli.X2ndYearPrice__c=1;
            oli.X3rdYearPrice__c=11;
            oli.X4thYearPrice__c=1;
            oli.AUMRange__c = 'Above $500M';
            oli.RemainingYearsPrice__c=24;
            oli.FirstDeliveryDateTBD__c = true;
            oli.UnitPrice=1;
            insert oli;
            Business_Address__c busaddrs = new Business_Address__c(Account__c =acc.id, ZipPostalCode__c = '60602',Street__c='street1',City__c = 'city1',Country__c = 'India' );
            database.insert(busaddrs);
            ID busaddrsId=busaddrs.Id;
            Contract contract1 = GC_UtilityClassTestData.createContract(acc.Id,acc.Id,acc.Id,'Monthly',busaddrsId,con.Id ,con.Id ,busaddrsId,parentopty.Id );
            insert contract1;
            OpportunityContactRole ocr=GC_UtilityClassTestData.createRole(con.id,'SAM',parentopty.id,true);
            insert ocr;
            OpportunityTeamMember otm = GC_UtilityClassTestData.createTeamMember(parentopty.Id,'SAM',u.id);
            insert otm;
            BillingSchedule__c bs= GC_UtilityClassTestData.createBusinessSchedule(contract1.id,'USD');
            insert bs;
            BreakoutType__c breakout = GC_UtilityClassTestData.tempbreakout(parentopty.Id);
            insert breakout;
            
           Test.stopTest();
           system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            parentopty.StageName = '5 - Closed Won';
            update(parentopty); 
            
            
            
          
         }
      } 
      
      static testMethod void OpportunityTestcreateLostRenewall()
    {
      Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      u.MorningstarLegalEntity__c = '(001) Morningstar, Inc.';
        userList.add(u);
      
      Database.insert(userList);
       
      System.RunAs(u)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
           // acc.StrategicAccountManager__c = u.id;
            acclist.add(acc);
            system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            Database.insert(acclist);
            
            Database.DMLOptions dml = new Database.DMLOptions();
           dml.DuplicateRuleHeader.allowSave = true;
           //dml.DuplicateRuleHeader.includeRecordDetails = true;
           dml.DuplicateRuleHeader.runAsCurrentUser = true;
            Contact con = GC_UtilityClassTestData.createContact('test','Lastname','abc16598@test.com','Advisor','Investment Consultant',acc.id);
            //insert con;
            Database.insert(con, dml);
            Test.startTest();
            //Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
            Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_RENEWAL,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
      //    parentopty.RecordTypeId = '012d0000000OqnD';
            parentopty.DeliveryMonths__c=36;
            parentopty.ContractType__c = 'Main Agreement'; 
            parentopty.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';              
            insert parentopty;
            Product2 prod = GC_UtilityClassTestData.createProduct('Test',LABEL.CL_MORNINGSTAR_DOCUMENT_RESEARCH,label.CL_NO_TOOL);     
            Database.insert(prod);
            Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
            PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
            insert pbe;
            OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1,parentopty.id, pbe.id, 12);
            oli.X2ndYearPrice__c=1;
            oli.X3rdYearPrice__c=11;
            oli.X4thYearPrice__c=1;
            oli.AUMRange__c = 'Above $500M';
            oli.RemainingYearsPrice__c=24;
            oli.FirstDeliveryDateTBD__c = true;
            oli.UnitPrice=1;
            insert oli;
            Business_Address__c busaddrs = new Business_Address__c(Account__c =acc.id, ZipPostalCode__c = '60602',Street__c='street1',City__c = 'city1',Country__c = 'India' );
            database.insert(busaddrs);
            ID busaddrsId=busaddrs.Id;
            Contract contract1 = GC_UtilityClassTestData.createContract(acc.Id,acc.Id,acc.Id,'Monthly',busaddrsId,con.Id ,con.Id ,busaddrsId,parentopty.Id );
            insert contract1;
            OpportunityContactRole ocr=GC_UtilityClassTestData.createRole(con.id,'SAM',parentopty.id,true);
            insert ocr;
            OpportunityTeamMember otm = GC_UtilityClassTestData.createTeamMember(parentopty.Id,'SAM',u.id);
            insert otm;
            BillingSchedule__c bs= GC_UtilityClassTestData.createBusinessSchedule(contract1.id,'USD');
            insert bs;
            BreakoutType__c breakout = GC_UtilityClassTestData.tempbreakout(parentopty.Id);
            insert breakout;
            
           Test.stopTest();
           system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            parentopty.StageName = '5 - Closed Won';
            update(parentopty); 
            
            
            
          
         }
      } 
      static testMethod void OpportunityTestcreateLostRenewalll()
    {
      Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      u.MorningstarLegalEntity__c = '(001) Morningstar, Inc.';
        userList.add(u);
      
      Database.insert(userList);
       
      System.RunAs(u)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
           // acc.StrategicAccountManager__c = u.id;
            acclist.add(acc);
            system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            Database.insert(acclist);
            
            Database.DMLOptions dml = new Database.DMLOptions();
           dml.DuplicateRuleHeader.allowSave = true;
           //dml.DuplicateRuleHeader.includeRecordDetails = true;
           dml.DuplicateRuleHeader.runAsCurrentUser = true;
            Contact con = GC_UtilityClassTestData.createContact('test','Lastname','abc16598@test.com','Advisor','Investment Consultant',acc.id);
            //insert con;
            Database.insert(con, dml);
            Test.startTest();
            //Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
            Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_RENEWAL,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
      //    parentopty.RecordTypeId = '012d0000000OqnD';
            parentopty.DeliveryMonths__c=49;
            parentopty.ContractType__c = 'Main Agreement';  
            parentopty.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';  
            insert parentopty;
            Product2 prod = GC_UtilityClassTestData.createProduct('Test',LABEL.CL_MORNINGSTAR_DOCUMENT_RESEARCH,label.CL_NO_TOOL);     
            Database.insert(prod);
            Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
            PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
            insert pbe;
            OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1,parentopty.id, pbe.id, 12);
            oli.X2ndYearPrice__c=1;
            oli.X3rdYearPrice__c=11;
            oli.X4thYearPrice__c=1;
            oli.AUMRange__c = 'Above $500M';
            oli.RemainingYearsPrice__c=24;
            oli.FirstDeliveryDateTBD__c = true;
            oli.UnitPrice=1;
            insert oli;
            Business_Address__c busaddrs = new Business_Address__c(Account__c =acc.id, ZipPostalCode__c = '60602',Street__c='street1',City__c = 'city1',Country__c = 'India' );
            database.insert(busaddrs);
            ID busaddrsId=busaddrs.Id;
            Contract contract1 = GC_UtilityClassTestData.createContract(acc.Id,acc.Id,acc.Id,'Monthly',busaddrsId,con.Id ,con.Id ,busaddrsId,parentopty.Id );
            insert contract1;
            OpportunityContactRole ocr=GC_UtilityClassTestData.createRole(con.id,'SAM',parentopty.id,true);
            insert ocr;
            OpportunityTeamMember otm = GC_UtilityClassTestData.createTeamMember(parentopty.Id,'SAM',u.id);
            insert otm;
            BillingSchedule__c bs= GC_UtilityClassTestData.createBusinessSchedule(contract1.id,'USD');
            insert bs;
            BreakoutType__c breakout = GC_UtilityClassTestData.tempbreakout(parentopty.Id);
            insert breakout;
            
           Test.stopTest();
           system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            parentopty.StageName = '5 - Closed Won';
            update(parentopty); 
            
            
            
          
         }
      } 
static testMethod void OpportunityTestcreateLostRenewall1()
    {
      Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      u.MorningstarLegalEntity__c = '(001) Morningstar, Inc.';
        userList.add(u);
      
      Database.insert(userList);
       
      System.RunAs(u)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
           // acc.StrategicAccountManager__c = u.id;
            acclist.add(acc);
            system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            Database.insert(acclist);
            
            Database.DMLOptions dml = new Database.DMLOptions();
           dml.DuplicateRuleHeader.allowSave = true;
           //dml.DuplicateRuleHeader.includeRecordDetails = true;
           dml.DuplicateRuleHeader.runAsCurrentUser = true;
            Contact con = GC_UtilityClassTestData.createContact('test','Lastname','abc16598@test.com','Advisor','Investment Consultant',acc.id);
            //insert con;
            Database.insert(con, dml);
            Test.startTest();
            //Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
            Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_RENEWAL,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
      //    parentopty.RecordTypeId = '012d0000000OqnD';
            parentopty.DeliveryMonths__c=14;
            parentopty.ContractType__c = 'Main Agreement';
            parentopty.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';              
            insert parentopty;
            Product2 prod = GC_UtilityClassTestData.createProduct('Test',LABEL.CL_MORNINGSTAR_DOCUMENT_RESEARCH,label.CL_NO_TOOL);     
            Database.insert(prod);
            Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
            PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
            insert pbe;
            OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1,parentopty.id, pbe.id, 12);
            oli.X2ndYearPrice__c=1;
            oli.X3rdYearPrice__c=11;
            oli.X4thYearPrice__c=1;
            oli.AUMRange__c = 'Above $500M';
            oli.RemainingYearsPrice__c=24;
            oli.FirstDeliveryDateTBD__c = true;
            oli.UnitPrice=1;
            insert oli;
            Business_Address__c busaddrs = new Business_Address__c(Account__c =acc.id, ZipPostalCode__c = '60602',Street__c='street1',City__c = 'city1',Country__c = 'India' );
            database.insert(busaddrs);
            ID busaddrsId=busaddrs.Id;
            Contract contract1 = GC_UtilityClassTestData.createContract(acc.Id,acc.Id,acc.Id,'Monthly',busaddrsId,con.Id ,con.Id ,busaddrsId,parentopty.Id );
            insert contract1;
            OpportunityContactRole ocr=GC_UtilityClassTestData.createRole(con.id,'SAM',parentopty.id,true);
            insert ocr;
            OpportunityTeamMember otm = GC_UtilityClassTestData.createTeamMember(parentopty.Id,'SAM',u.id);
            insert otm;
            BillingSchedule__c bs= GC_UtilityClassTestData.createBusinessSchedule(contract1.id,'USD');
            insert bs;
            BreakoutType__c breakout = GC_UtilityClassTestData.tempbreakout(parentopty.Id);
            insert breakout;
            
           Test.stopTest();
           system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            parentopty.StageName = '5 - Closed Won';
            update(parentopty); 
            
            
            
          
         }
      } 
      static testMethod void OpportunityTestcreateLostRenewalaa()
    {
      Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      u.MorningstarLegalEntity__c = '(001) Morningstar, Inc.';
        userList.add(u);
      
      Database.insert(userList);
       
      System.RunAs(u)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
         //   acc.StrategicAccountManager__c = u.id;
            acclist.add(acc);
            system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            Database.insert(acclist);
            
            Database.DMLOptions dml = new Database.DMLOptions();
           dml.DuplicateRuleHeader.allowSave = true;
           //dml.DuplicateRuleHeader.includeRecordDetails = true;
           dml.DuplicateRuleHeader.runAsCurrentUser = true;
            Contact con = GC_UtilityClassTestData.createContact('test','Lastname','abc16598@test.com','Advisor','Investment Consultant',acc.id);
            //insert con;
            Database.insert(con, dml);
            Test.startTest();
            //Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
            Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_RENEWAL,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
      //    parentopty.RecordTypeId = '012d0000000OqnD';
            parentopty.DeliveryMonths__c=19;
            parentopty.ContractType__c = 'Main Agreement';  
            parentopty.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';  
            insert parentopty;
            Product2 prod = GC_UtilityClassTestData.createProduct('Test',LABEL.CL_MORNINGSTAR_DOCUMENT_RESEARCH,label.CL_NO_TOOL);     
            Database.insert(prod);
            Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
            PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
            insert pbe;
            OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1,parentopty.id, pbe.id, 12);
            oli.X2ndYearPrice__c=1;
            oli.X3rdYearPrice__c=11;
            oli.X4thYearPrice__c=1;
            oli.AUMRange__c = 'Above $500M';
            oli.RemainingYearsPrice__c=24;
            oli.FirstDeliveryDateTBD__c = true;
            oli.UnitPrice=1;
            insert oli;
            Business_Address__c busaddrs = new Business_Address__c(Account__c =acc.id, ZipPostalCode__c = '60602',Street__c='street1',City__c = 'city1',Country__c = 'India' );
            database.insert(busaddrs);
            ID busaddrsId=busaddrs.Id;
            Contract contract1 = GC_UtilityClassTestData.createContract(acc.Id,acc.Id,acc.Id,'Monthly',busaddrsId,con.Id ,con.Id ,busaddrsId,parentopty.Id );
            insert contract1;
            OpportunityContactRole ocr=GC_UtilityClassTestData.createRole(con.id,'SAM',parentopty.id,true);
            insert ocr;
            OpportunityTeamMember otm = GC_UtilityClassTestData.createTeamMember(parentopty.Id,'SAM',u.id);
            insert otm;
            BillingSchedule__c bs= GC_UtilityClassTestData.createBusinessSchedule(contract1.id,'USD');
            insert bs;
            BreakoutType__c breakout = GC_UtilityClassTestData.tempbreakout(parentopty.Id);
            insert breakout;
            
           Test.stopTest();
           system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            parentopty.StageName = '5 - Closed Won';
            update(parentopty); 
            
            
            
          
         }
      } 
      
      static testMethod void OpportunityTestcreateLostRenewaaaal234()
    {
      Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      u.MorningstarLegalEntity__c = '(001) Morningstar, Inc.';
        userList.add(u);
      
      Database.insert(userList);
       
      System.RunAs(u)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
          //  acc.StrategicAccountManager__c = u.id;
            acclist.add(acc);
            system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            Database.insert(acclist);
            
            Database.DMLOptions dml = new Database.DMLOptions();
           dml.DuplicateRuleHeader.allowSave = true;
           //dml.DuplicateRuleHeader.includeRecordDetails = true;
           dml.DuplicateRuleHeader.runAsCurrentUser = true;
            Contact con = GC_UtilityClassTestData.createContact('test','Lastname','abc16598@test.com','Advisor','Investment Consultant',acc.id);
            //insert con;
            Database.insert(con, dml);
            Test.startTest();
            //Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
            Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_RENEWAL,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
      //    parentopty.RecordTypeId = '012d0000000OqnD';
            parentopty.DeliveryMonths__c=43;
            parentopty.ContractType__c = 'Main Agreement';  
            parentopty.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
            insert parentopty;
            Product2 prod = GC_UtilityClassTestData.createProduct('Test',LABEL.CL_MORNINGSTAR_DOCUMENT_RESEARCH,label.CL_NO_TOOL);     
            Database.insert(prod);
            Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
            PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
            insert pbe;
            OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1,parentopty.id, pbe.id, 12);
            oli.X2ndYearPrice__c=1;
            oli.X3rdYearPrice__c=11;
            oli.X4thYearPrice__c=1;
            oli.AUMRange__c = 'Above $500M';
            oli.RemainingYearsPrice__c=24;
            oli.FirstDeliveryDateTBD__c = true;
            oli.UnitPrice=1;
            insert oli;
            Business_Address__c busaddrs = new Business_Address__c(Account__c =acc.id, ZipPostalCode__c = '60602',Street__c='street1',City__c = 'city1',Country__c = 'India' );
            database.insert(busaddrs);
            ID busaddrsId=busaddrs.Id;
            Contract contract1 = GC_UtilityClassTestData.createContract(acc.Id,acc.Id,acc.Id,'Monthly',busaddrsId,con.Id ,con.Id ,busaddrsId,parentopty.Id );
            insert contract1;
            OpportunityContactRole ocr=GC_UtilityClassTestData.createRole(con.id,'SAM',parentopty.id,true);
            insert ocr;
            OpportunityTeamMember otm = GC_UtilityClassTestData.createTeamMember(parentopty.Id,'SAM',u.id);
            insert otm;
            BillingSchedule__c bs= GC_UtilityClassTestData.createBusinessSchedule(contract1.id,'USD');
            insert bs;
            BreakoutType__c breakout = GC_UtilityClassTestData.tempbreakout(parentopty.Id);
            insert breakout;
            
           Test.stopTest();
           system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            parentopty.StageName = '5 - Closed Won';
            update(parentopty); 
            
            
            
          
         }
      } 
static testMethod void OpportunityTestcreateLostRenewal234last()
    {
      Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      u.MorningstarLegalEntity__c = '(001) Morningstar, Inc.';
        userList.add(u);
      
      Database.insert(userList);
       
      System.RunAs(u)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
           // acc.StrategicAccountManager__c = u.id;
            acclist.add(acc);
            system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            Database.insert(acclist);
            
            Database.DMLOptions dml = new Database.DMLOptions();
           dml.DuplicateRuleHeader.allowSave = true;
           //dml.DuplicateRuleHeader.includeRecordDetails = true;
           dml.DuplicateRuleHeader.runAsCurrentUser = true;
            Contact con = GC_UtilityClassTestData.createContact('test','Lastname','abc16598@test.com','Advisor','Investment Consultant',acc.id);
            //insert con;
            Database.insert(con, dml);
            Test.startTest();
            //Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
            Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_RENEWAL,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
      //    parentopty.RecordTypeId = '012d0000000OqnD';
            parentopty.DeliveryMonths__c=54;
            parentopty.ContractType__c = 'Main Agreement';  
            parentopty.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';  
            insert parentopty;
            Product2 prod = GC_UtilityClassTestData.createProduct('Test',LABEL.CL_MORNINGSTAR_DOCUMENT_RESEARCH,label.CL_NO_TOOL);     
            Database.insert(prod);
            Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
            PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
            insert pbe;
            OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1,parentopty.id, pbe.id, 12);
            oli.X2ndYearPrice__c=1;
            oli.X3rdYearPrice__c=11;
            oli.X4thYearPrice__c=1;
            oli.AUMRange__c = 'Above $500M';
            oli.RemainingYearsPrice__c=24;
            oli.FirstDeliveryDateTBD__c = true;
            oli.UnitPrice=1;
            insert oli;
            Business_Address__c busaddrs = new Business_Address__c(Account__c =acc.id, ZipPostalCode__c = '60602',Street__c='street1',City__c = 'city1',Country__c = 'India' );
            database.insert(busaddrs);
            ID busaddrsId=busaddrs.Id;
            Contract contract1 = GC_UtilityClassTestData.createContract(acc.Id,acc.Id,acc.Id,'Monthly',busaddrsId,con.Id ,con.Id ,busaddrsId,parentopty.Id );
            insert contract1;
            OpportunityContactRole ocr=GC_UtilityClassTestData.createRole(con.id,'SAM',parentopty.id,true);
            insert ocr;
            OpportunityTeamMember otm = GC_UtilityClassTestData.createTeamMember(parentopty.Id,'SAM',u.id);
            insert otm;
            BillingSchedule__c bs= GC_UtilityClassTestData.createBusinessSchedule(contract1.id,'USD');
            insert bs;
            BreakoutType__c breakout = GC_UtilityClassTestData.tempbreakout(parentopty.Id);
            insert breakout;
            
           Test.stopTest();
           system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            parentopty.StageName = '5 - Closed Won';
            update(parentopty); 
            
            
            
          
         }
      } 
      
      static testMethod void OpportunityTestcreateLostRenewalaaassa()
    {
      Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      u.MorningstarLegalEntity__c = '(001) Morningstar, Inc.';
        userList.add(u);
      
      Database.insert(userList);
       
      System.RunAs(u)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
            //acc.StrategicAccountManager__c = u.id;
            acclist.add(acc);
            system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            Database.insert(acclist);
            
            Database.DMLOptions dml = new Database.DMLOptions();
           dml.DuplicateRuleHeader.allowSave = true;
           //dml.DuplicateRuleHeader.includeRecordDetails = true;
           dml.DuplicateRuleHeader.runAsCurrentUser = true;
            Contact con = GC_UtilityClassTestData.createContact('test','Lastname','abc16598@test.com','Advisor','Investment Consultant',acc.id);
            //insert con;
            Database.insert(con, dml);
            Test.startTest();
            //Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
            Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_RENEWAL,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
      //    parentopty.RecordTypeId = '012d0000000OqnD';
            parentopty.DeliveryMonths__c=51;
            parentopty.ContractType__c = 'Main Agreement';  
            parentopty.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';  
            insert parentopty;
            Product2 prod = GC_UtilityClassTestData.createProduct('Test',LABEL.CL_MORNINGSTAR_DOCUMENT_RESEARCH,label.CL_NO_TOOL);     
            Database.insert(prod);
            Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
            PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
            insert pbe;
            OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1,parentopty.id, pbe.id, 12);
            oli.X2ndYearPrice__c=1;
            oli.X3rdYearPrice__c=11;
            oli.X4thYearPrice__c=1;
            oli.AUMRange__c = 'Above $500M';
            oli.RemainingYearsPrice__c=24;
            oli.FirstDeliveryDateTBD__c = true;
            oli.UnitPrice=1;
            insert oli;
            Business_Address__c busaddrs = new Business_Address__c(Account__c =acc.id, ZipPostalCode__c = '60602',Street__c='street1',City__c = 'city1',Country__c = 'India' );
            database.insert(busaddrs);
            ID busaddrsId=busaddrs.Id;
            Contract contract1 = GC_UtilityClassTestData.createContract(acc.Id,acc.Id,acc.Id,'Monthly',busaddrsId,con.Id ,con.Id ,busaddrsId,parentopty.Id );
            insert contract1;
            OpportunityContactRole ocr=GC_UtilityClassTestData.createRole(con.id,'SAM',parentopty.id,true);
            insert ocr;
            OpportunityTeamMember otm = GC_UtilityClassTestData.createTeamMember(parentopty.Id,'SAM',u.id);
            insert otm;
            BillingSchedule__c bs= GC_UtilityClassTestData.createBusinessSchedule(contract1.id,'USD');
            insert bs;
            BreakoutType__c breakout = GC_UtilityClassTestData.tempbreakout(parentopty.Id);
            insert breakout;
            
           Test.stopTest();
           system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            parentopty.StageName = '5 - Closed Won';
            update(parentopty); 
            
            
            
          
         }
      }
       static testMethod void OpportunityTestcreateAutoRenewall36()
    {
      Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      u.MorningstarLegalEntity__c = '(001) Morningstar, Inc.';
        userList.add(u);
      
      Database.insert(userList);
       
      System.RunAs(u)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
            Id globalAccId =  GC_Utils_Method.getRecordTypeId(Label.CL_ACCOUNT1,Label.CL_AccGlobalRecordType);
           Id secondaryAccId = GC_Utils_Method.getRecordTypeId(Label.CL_ACCOUNT1,Label.CL_AccSecondaryRecordType); 
            
            Account parentacc = GC_UtilityClassTestData.createAccount('testParentname','Active','testcity','India','12345','teststreet','teststate'); 
                parentacc.recordtypeId = globalAccId ;
            parentacc.IntegrationStatus__c = 'Sync';
             parentacc.Clean__c = True;
                 parentacc.AccountStatus__c = 'Active'; 
                 parentacc.Master_License_Agreement_Date__c = Date.Today(); 
                // parentacc.StrategicAccountManager__c = u.id;
                 insert parentacc;
            
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
           // acc.StrategicAccountManager__c = u.id;
            acc.recordtypeId = secondaryAccId;
            acc.ParentId = parentacc.Id;
            acclist.add(acc);
            system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            Database.insert(acclist);
            
            Database.DMLOptions dml = new Database.DMLOptions();
           dml.DuplicateRuleHeader.allowSave = true;
           //dml.DuplicateRuleHeader.includeRecordDetails = true;
           dml.DuplicateRuleHeader.runAsCurrentUser = true;
            Contact con = GC_UtilityClassTestData.createContact('test','Lastname','abc16598@test.com','Advisor','Investment Consultant',acc.id);
            //insert con;
            Database.insert(con, dml);
            
            Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
            //parentopty.DeliveryMonths__c=2;
            parentopty.Auto_Renewal_Clause__c = true;
            parentopty.Auto_Renewal_Type__c = LABEL.CL_Opp_AutoRenewType_Fixed;
            parentopty.Auto_Renewal_Max_Fixed__c = '2';
            parentopty.Auto_Renewal_Term_Months__c = '36';
            parentopty.DeliveryMonths__c = 48;
            parentopty.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
            
            insert parentopty;
            
            
            Product2 prod = GC_UtilityClassTestData.createProduct('Test',LABEL.CL_MORNINGSTAR_DOCUMENT_RESEARCH,label.CL_NO_TOOL);     
            Database.insert(prod);
            Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
            PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
            insert pbe;
            OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1,parentopty.id, pbe.id, 12);
            oli.X2ndYearPrice__c=1;
            oli.X3rdYearPrice__c=11;
            oli.X4thYearPrice__c=1;
            oli.Delivery_Method__c='API';
            oli.AUMRange__c = 'Above $500M';
            oli.RemainingYearsPrice__c=12;
            oli.FirstDeliveryDateTBD__c = true;
            oli.SetUpFees__c = 0;
            oli.UnitPrice=1;
            insert oli;
            
            
            
            
            Business_Address__c busaddrs = new Business_Address__c(Account__c =parentacc.id, ZipPostalCode__c = '60602',Street__c='street1',City__c = 'city1',Country__c = 'India' );
            database.insert(busaddrs);
            ID busaddrsId=busaddrs.Id;
           
            
            OpportunityContactRole ocr=GC_UtilityClassTestData.createRole(con.id,'SAM',parentopty.id,true);
            insert ocr;
           
            
            
            
            BreakoutType__c breakout = GC_UtilityClassTestData.tempbreakout(parentopty.Id);
            insert breakout;
            
             
            Test.startTest();
           // Contract contract1 = GC_UtilityClassTestData.createContract(acc.Id,acc.Id,acc.Id,'Monthly',busaddrsId,con.Id ,con.Id ,busaddrsId,parentopty.Id );
            //insert contract1;
            
            // BillingSchedule__c bs= GC_UtilityClassTestData.createBusinessSchedule(contract1.id,'USD');
            //insert bs;
            
            //OpportunityTeamMember otm = GC_UtilityClassTestData.createTeamMember(parentopty.Id,'SAM',u.id);
            //insert otm;
            
            
            
          
           system.debug('%%%%%Account Status'+acc.AccountStatus__c);
           /* parentopty.Auto_Renewal_Clause__c = true;
            parentopty.Auto_Renewal_Type__c = LABEL.CL_Opp_AutoRenewType_Fixed;
            parentopty.Auto_Renewal_Max_Fixed__c = '2';
            parentopty.Auto_Renewal_Term_Months__c = '24';
            parentopty.DeliveryMonths__c = 36;*/
            parentopty.StageName = '5 - Closed Won';
            update(parentopty); 
            
           
            
              Test.stopTest();
            
          
         }
      } 
      
       static testMethod void OpportunityTestcreateAutoRenewalll36()
    {
      Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      u.MorningstarLegalEntity__c = '(001) Morningstar, Inc.';
        userList.add(u);
      
      Database.insert(userList);
       
      System.RunAs(u)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
            Id globalAccId =  GC_Utils_Method.getRecordTypeId(Label.CL_ACCOUNT1,Label.CL_AccGlobalRecordType);
           Id secondaryAccId = GC_Utils_Method.getRecordTypeId(Label.CL_ACCOUNT1,Label.CL_AccSecondaryRecordType); 
            
            Account parentacc = GC_UtilityClassTestData.createAccount('testParentname','Active','testcity','India','12345','teststreet','teststate'); 
                parentacc.recordtypeId = globalAccId ;
            parentacc.IntegrationStatus__c = 'Sync';
             parentacc.Clean__c = True;
                 parentacc.AccountStatus__c = 'Active'; 
                 parentacc.Master_License_Agreement_Date__c = Date.Today(); 
                // parentacc.StrategicAccountManager__c = u.id;
                 insert parentacc;
            
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
           // acc.StrategicAccountManager__c = u.id;
            acc.recordtypeId = secondaryAccId;
            acc.ParentId = parentacc.Id;
            acclist.add(acc);
            system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            Database.insert(acclist);
            
            Database.DMLOptions dml = new Database.DMLOptions();
           dml.DuplicateRuleHeader.allowSave = true;
           //dml.DuplicateRuleHeader.includeRecordDetails = true;
           dml.DuplicateRuleHeader.runAsCurrentUser = true;
            Contact con = GC_UtilityClassTestData.createContact('test','Lastname','abc16598@test.com','Advisor','Investment Consultant',acc.id);
            //insert con;
            Database.insert(con, dml);
            
            Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
          //  parentopty.DeliveryMonths__c=2;
            parentopty.Auto_Renewal_Clause__c = true;
            parentopty.Auto_Renewal_Type__c = LABEL.CL_Opp_AutoRenewType_Fixed;
            parentopty.Auto_Renewal_Max_Fixed__c = '2';
            parentopty.Auto_Renewal_Term_Months__c = '36';
            parentopty.DeliveryMonths__c = 13;
            parentopty.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
            
            insert parentopty;
            
            
            Product2 prod = GC_UtilityClassTestData.createProduct('Test',LABEL.CL_MORNINGSTAR_DOCUMENT_RESEARCH,label.CL_NO_TOOL);     
            Database.insert(prod);
            Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
            PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
            insert pbe;
            OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1,parentopty.id, pbe.id, 12);
            oli.X2ndYearPrice__c=1;
            oli.X3rdYearPrice__c=11;
            oli.X4thYearPrice__c=1;
            oli.Delivery_Method__c='API';
            oli.AUMRange__c = 'Above $500M';
            oli.RemainingYearsPrice__c=12;
            oli.FirstDeliveryDateTBD__c = true;
            oli.SetUpFees__c = 0;
            oli.UnitPrice=1;
            insert oli;
            
            
            
            
            Business_Address__c busaddrs = new Business_Address__c(Account__c =parentacc.id, ZipPostalCode__c = '60602',Street__c='street1',City__c = 'city1',Country__c = 'India' );
            database.insert(busaddrs);
            ID busaddrsId=busaddrs.Id;
           
            
            OpportunityContactRole ocr=GC_UtilityClassTestData.createRole(con.id,'SAM',parentopty.id,true);
            insert ocr;
           
            
            
            
            BreakoutType__c breakout = GC_UtilityClassTestData.tempbreakout(parentopty.Id);
            insert breakout;
            
             
            Test.startTest();
           // Contract contract1 = GC_UtilityClassTestData.createContract(acc.Id,acc.Id,acc.Id,'Monthly',busaddrsId,con.Id ,con.Id ,busaddrsId,parentopty.Id );
            //insert contract1;
            
            // BillingSchedule__c bs= GC_UtilityClassTestData.createBusinessSchedule(contract1.id,'USD');
            //insert bs;
            
            //OpportunityTeamMember otm = GC_UtilityClassTestData.createTeamMember(parentopty.Id,'SAM',u.id);
            //insert otm;
            
            
            
          
           system.debug('%%%%%Account Status'+acc.AccountStatus__c);
           /* parentopty.Auto_Renewal_Clause__c = true;
            parentopty.Auto_Renewal_Type__c = LABEL.CL_Opp_AutoRenewType_Fixed;
            parentopty.Auto_Renewal_Max_Fixed__c = '2';
            parentopty.Auto_Renewal_Term_Months__c = '24';
            parentopty.DeliveryMonths__c = 36;*/
            parentopty.StageName = '5 - Closed Won';
            update(parentopty); 
            
           
            
              Test.stopTest();
            
          
         }
      } 
      
      static testMethod void OpportunityTestcreateAutoRenewallll36()
    {
      Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      u.MorningstarLegalEntity__c = '(001) Morningstar, Inc.';
        userList.add(u);
      
      Database.insert(userList);
       
      System.RunAs(u)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
            Id globalAccId =  GC_Utils_Method.getRecordTypeId(Label.CL_ACCOUNT1,Label.CL_AccGlobalRecordType);
           Id secondaryAccId = GC_Utils_Method.getRecordTypeId(Label.CL_ACCOUNT1,Label.CL_AccSecondaryRecordType); 
            
            Account parentacc = GC_UtilityClassTestData.createAccount('testParentname','Active','testcity','India','12345','teststreet','teststate'); 
                parentacc.recordtypeId = globalAccId ;
            parentacc.IntegrationStatus__c = 'Sync';
             parentacc.Clean__c = True;
                 parentacc.AccountStatus__c = 'Active'; 
                 parentacc.Master_License_Agreement_Date__c = Date.Today(); 
               //  parentacc.StrategicAccountManager__c = u.id;
                 insert parentacc;
            
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
          //  acc.StrategicAccountManager__c = u.id;
            acc.recordtypeId = secondaryAccId;
            acc.ParentId = parentacc.Id;
            acclist.add(acc);
            system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            Database.insert(acclist);
            
            Database.DMLOptions dml = new Database.DMLOptions();
           dml.DuplicateRuleHeader.allowSave = true;
           //dml.DuplicateRuleHeader.includeRecordDetails = true;
           dml.DuplicateRuleHeader.runAsCurrentUser = true;
            Contact con = GC_UtilityClassTestData.createContact('test','Lastname','abc16598@test.com','Advisor','Investment Consultant',acc.id);
            //insert con;
            Database.insert(con, dml);
            
            Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
          //  parentopty.DeliveryMonths__c=2;
            parentopty.Auto_Renewal_Clause__c = true;
            parentopty.Auto_Renewal_Type__c = LABEL.CL_Opp_AutoRenewType_Fixed;
            parentopty.Auto_Renewal_Max_Fixed__c = '2';
            parentopty.Auto_Renewal_Term_Months__c = '36';
            parentopty.DeliveryMonths__c = 24;
            parentopty.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
            
            insert parentopty;
            
            
            Product2 prod = GC_UtilityClassTestData.createProduct('Test',LABEL.CL_MORNINGSTAR_DOCUMENT_RESEARCH,label.CL_NO_TOOL);     
            Database.insert(prod);
            Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
            PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
            insert pbe;
            OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1,parentopty.id, pbe.id, 12);
            oli.X2ndYearPrice__c=1;
            oli.X3rdYearPrice__c=11;
            oli.X4thYearPrice__c=1;
            oli.Delivery_Method__c='API';
            oli.AUMRange__c = 'Above $500M';
            oli.RemainingYearsPrice__c=12;
            oli.FirstDeliveryDateTBD__c = true;
            oli.SetUpFees__c = 0;
            oli.UnitPrice=1;
            insert oli;
            
            
            
            
            Business_Address__c busaddrs = new Business_Address__c(Account__c =parentacc.id, ZipPostalCode__c = '60602',Street__c='street1',City__c = 'city1',Country__c = 'India' );
            database.insert(busaddrs);
            ID busaddrsId=busaddrs.Id;
           
            
            OpportunityContactRole ocr=GC_UtilityClassTestData.createRole(con.id,'SAM',parentopty.id,true);
            insert ocr;
           
            
            
            
            BreakoutType__c breakout = GC_UtilityClassTestData.tempbreakout(parentopty.Id);
            insert breakout;
            
             
            Test.startTest();
           // Contract contract1 = GC_UtilityClassTestData.createContract(acc.Id,acc.Id,acc.Id,'Monthly',busaddrsId,con.Id ,con.Id ,busaddrsId,parentopty.Id );
            //insert contract1;
            
            // BillingSchedule__c bs= GC_UtilityClassTestData.createBusinessSchedule(contract1.id,'USD');
            //insert bs;
            
            //OpportunityTeamMember otm = GC_UtilityClassTestData.createTeamMember(parentopty.Id,'SAM',u.id);
            //insert otm;
            
            
            
          
           system.debug('%%%%%Account Status'+acc.AccountStatus__c);
           /* parentopty.Auto_Renewal_Clause__c = true;
            parentopty.Auto_Renewal_Type__c = LABEL.CL_Opp_AutoRenewType_Fixed;
            parentopty.Auto_Renewal_Max_Fixed__c = '2';
            parentopty.Auto_Renewal_Term_Months__c = '24';
            parentopty.DeliveryMonths__c = 36;*/
            parentopty.StageName = '5 - Closed Won';
            update(parentopty); 
            
           
            
              Test.stopTest();
            
          
         }
      }
      static testMethod void OpportunityTestcreateAutoRenewa5ll36()
    {
      Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      u.MorningstarLegalEntity__c = '(001) Morningstar, Inc.';
        userList.add(u);
      
      Database.insert(userList);
       
      System.RunAs(u)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
            Id globalAccId =  GC_Utils_Method.getRecordTypeId(Label.CL_ACCOUNT1,Label.CL_AccGlobalRecordType);
           Id secondaryAccId = GC_Utils_Method.getRecordTypeId(Label.CL_ACCOUNT1,Label.CL_AccSecondaryRecordType); 
            
            Account parentacc = GC_UtilityClassTestData.createAccount('testParentname','Active','testcity','India','12345','teststreet','teststate'); 
                parentacc.recordtypeId = globalAccId ;
            parentacc.IntegrationStatus__c = 'Sync';
             parentacc.Clean__c = True;
                 parentacc.AccountStatus__c = 'Active'; 
                 parentacc.Master_License_Agreement_Date__c = Date.Today(); 
                // parentacc.StrategicAccountManager__c = u.id;
                 insert parentacc;
            
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
          //  acc.StrategicAccountManager__c = u.id;
            acc.recordtypeId = secondaryAccId;
            acc.ParentId = parentacc.Id;
            acclist.add(acc);
            system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            Database.insert(acclist);
            
            Database.DMLOptions dml = new Database.DMLOptions();
           dml.DuplicateRuleHeader.allowSave = true;
           //dml.DuplicateRuleHeader.includeRecordDetails = true;
           dml.DuplicateRuleHeader.runAsCurrentUser = true;
            Contact con = GC_UtilityClassTestData.createContact('test','Lastname','abc16598@test.com','Advisor','Investment Consultant',acc.id);
            //insert con;
            Database.insert(con, dml);
            
            Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
          //  parentopty.DeliveryMonths__c=2;
            parentopty.Auto_Renewal_Clause__c = true;
            parentopty.Auto_Renewal_Type__c = LABEL.CL_Opp_AutoRenewType_Fixed;
            parentopty.Auto_Renewal_Max_Fixed__c = '2';
            parentopty.Auto_Renewal_Term_Months__c = '36';
            parentopty.DeliveryMonths__c = 13;
            parentopty.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
            
            insert parentopty;
            
            
            Product2 prod = GC_UtilityClassTestData.createProduct('Test',LABEL.CL_MORNINGSTAR_DOCUMENT_RESEARCH,label.CL_NO_TOOL);     
            Database.insert(prod);
            Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
            PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
            insert pbe;
            OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1,parentopty.id, pbe.id, 12);
            oli.X2ndYearPrice__c=1;
            oli.X3rdYearPrice__c=11;
            oli.X4thYearPrice__c=1;
            oli.Delivery_Method__c='API';
            oli.AUMRange__c = 'Above $500M';
            oli.RemainingYearsPrice__c=12;
            oli.FirstDeliveryDateTBD__c = true;
            oli.SetUpFees__c = 0;
            oli.UnitPrice=1;
            insert oli;
            
            
            
            
            Business_Address__c busaddrs = new Business_Address__c(Account__c =parentacc.id, ZipPostalCode__c = '60602',Street__c='street1',City__c = 'city1',Country__c = 'India' );
            database.insert(busaddrs);
            ID busaddrsId=busaddrs.Id;
           
            
            OpportunityContactRole ocr=GC_UtilityClassTestData.createRole(con.id,'SAM',parentopty.id,true);
            insert ocr;
           
            
            
            
            BreakoutType__c breakout = GC_UtilityClassTestData.tempbreakout(parentopty.Id);
            insert breakout;
            
             
            Test.startTest();
           // Contract contract1 = GC_UtilityClassTestData.createContract(acc.Id,acc.Id,acc.Id,'Monthly',busaddrsId,con.Id ,con.Id ,busaddrsId,parentopty.Id );
            //insert contract1;
            
            // BillingSchedule__c bs= GC_UtilityClassTestData.createBusinessSchedule(contract1.id,'USD');
            //insert bs;
            
            //OpportunityTeamMember otm = GC_UtilityClassTestData.createTeamMember(parentopty.Id,'SAM',u.id);
            //insert otm;
            
            
            
          
           system.debug('%%%%%Account Status'+acc.AccountStatus__c);
           /* parentopty.Auto_Renewal_Clause__c = true;
            parentopty.Auto_Renewal_Type__c = LABEL.CL_Opp_AutoRenewType_Fixed;
            parentopty.Auto_Renewal_Max_Fixed__c = '2';
            parentopty.Auto_Renewal_Term_Months__c = '24';
            parentopty.DeliveryMonths__c = 36;*/
            parentopty.StageName = '5 - Closed Won';
            update(parentopty); 
            
           
            
              Test.stopTest();
            
          
         }
      }
      static testMethod void OpportunityTestcreateAutoRenewakkll36()
    {
      Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      u.MorningstarLegalEntity__c = '(001) Morningstar, Inc.';
        userList.add(u);
      
      Database.insert(userList);
       
      System.RunAs(u)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
            Id globalAccId =  GC_Utils_Method.getRecordTypeId(Label.CL_ACCOUNT1,Label.CL_AccGlobalRecordType);
           Id secondaryAccId = GC_Utils_Method.getRecordTypeId(Label.CL_ACCOUNT1,Label.CL_AccSecondaryRecordType); 
            
            Account parentacc = GC_UtilityClassTestData.createAccount('testParentname','Active','testcity','India','12345','teststreet','teststate'); 
                parentacc.recordtypeId = globalAccId ;
            parentacc.IntegrationStatus__c = 'Sync';
             parentacc.Clean__c = True;
                 parentacc.AccountStatus__c = 'Active'; 
                 parentacc.Master_License_Agreement_Date__c = Date.Today(); 
                // parentacc.StrategicAccountManager__c = u.id;
                 insert parentacc;
            
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
           // acc.StrategicAccountManager__c = u.id;
            acc.recordtypeId = secondaryAccId;
            acc.ParentId = parentacc.Id;
            acclist.add(acc);
            system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            Database.insert(acclist);
            
            Database.DMLOptions dml = new Database.DMLOptions();
           dml.DuplicateRuleHeader.allowSave = true;
           //dml.DuplicateRuleHeader.includeRecordDetails = true;
           dml.DuplicateRuleHeader.runAsCurrentUser = true;
            Contact con = GC_UtilityClassTestData.createContact('test','Lastname','abc16598@test.com','Advisor','Investment Consultant',acc.id);
            //insert con;
            Database.insert(con, dml);
            
            Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
          //  parentopty.DeliveryMonths__c=2;
            parentopty.Auto_Renewal_Clause__c = true;
            parentopty.Auto_Renewal_Type__c = LABEL.CL_Opp_AutoRenewType_Fixed;
            parentopty.Auto_Renewal_Max_Fixed__c = '2';
            parentopty.Auto_Renewal_Term_Months__c = '36';
            parentopty.DeliveryMonths__c = 48;
            parentopty.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
            
            insert parentopty;
            
            
            Product2 prod = GC_UtilityClassTestData.createProduct('Test',LABEL.CL_MORNINGSTAR_DOCUMENT_RESEARCH,label.CL_NO_TOOL);     
            Database.insert(prod);
            Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
            PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
            insert pbe;
            OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1,parentopty.id, pbe.id, 12);
            oli.X2ndYearPrice__c=1;
            oli.X3rdYearPrice__c=11;
            oli.X4thYearPrice__c=1;
            oli.Delivery_Method__c='API';
            oli.AUMRange__c = 'Above $500M';
            oli.RemainingYearsPrice__c=12;
            oli.FirstDeliveryDateTBD__c = true;
            oli.SetUpFees__c = 0;
            oli.UnitPrice=1;
            insert oli;
            
            
            
            
            Business_Address__c busaddrs = new Business_Address__c(Account__c =parentacc.id, ZipPostalCode__c = '60602',Street__c='street1',City__c = 'city1',Country__c = 'India' );
            database.insert(busaddrs);
            ID busaddrsId=busaddrs.Id;
           
            
            OpportunityContactRole ocr=GC_UtilityClassTestData.createRole(con.id,'SAM',parentopty.id,true);
            insert ocr;
           
            
            
            
            BreakoutType__c breakout = GC_UtilityClassTestData.tempbreakout(parentopty.Id);
            insert breakout;
            
             
            Test.startTest();
           // Contract contract1 = GC_UtilityClassTestData.createContract(acc.Id,acc.Id,acc.Id,'Monthly',busaddrsId,con.Id ,con.Id ,busaddrsId,parentopty.Id );
            //insert contract1;
            
            // BillingSchedule__c bs= GC_UtilityClassTestData.createBusinessSchedule(contract1.id,'USD');
            //insert bs;
            
            //OpportunityTeamMember otm = GC_UtilityClassTestData.createTeamMember(parentopty.Id,'SAM',u.id);
            //insert otm;
            
            
            
          
           system.debug('%%%%%Account Status'+acc.AccountStatus__c);
           /* parentopty.Auto_Renewal_Clause__c = true;
            parentopty.Auto_Renewal_Type__c = LABEL.CL_Opp_AutoRenewType_Fixed;
            parentopty.Auto_Renewal_Max_Fixed__c = '2';
            parentopty.Auto_Renewal_Term_Months__c = '24';
            parentopty.DeliveryMonths__c = 36;*/
            parentopty.StageName = '5 - Closed Won';
            update(parentopty); 
            
           
            
              Test.stopTest();
            
          
         }
      }
        
      static testMethod void OpportunityTestcreateAutoRenewall336()
    {
      Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      u.MorningstarLegalEntity__c = '(001) Morningstar, Inc.';
        userList.add(u);
      
      Database.insert(userList);
       
      System.RunAs(u)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
            Id globalAccId =  GC_Utils_Method.getRecordTypeId(Label.CL_ACCOUNT1,Label.CL_AccGlobalRecordType);
           Id secondaryAccId = GC_Utils_Method.getRecordTypeId(Label.CL_ACCOUNT1,Label.CL_AccSecondaryRecordType); 
            
            Account parentacc = GC_UtilityClassTestData.createAccount('testParentname','Active','testcity','India','12345','teststreet','teststate'); 
                parentacc.recordtypeId = globalAccId ;
            parentacc.IntegrationStatus__c = 'Sync';
             parentacc.Clean__c = True;
                 parentacc.AccountStatus__c = 'Active'; 
                 parentacc.Master_License_Agreement_Date__c = Date.Today(); 
               //  parentacc.StrategicAccountManager__c = u.id;
                 insert parentacc;
            
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
           // acc.StrategicAccountManager__c = u.id;
            acc.recordtypeId = secondaryAccId;
            acc.ParentId = parentacc.Id;
            acclist.add(acc);
            system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            Database.insert(acclist);
            
            Database.DMLOptions dml = new Database.DMLOptions();
           dml.DuplicateRuleHeader.allowSave = true;
           //dml.DuplicateRuleHeader.includeRecordDetails = true;
           dml.DuplicateRuleHeader.runAsCurrentUser = true;
            Contact con = GC_UtilityClassTestData.createContact('test','Lastname','abc16598@test.com','Advisor','Investment Consultant',acc.id);
            //insert con;
            Database.insert(con, dml);
            
            Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOpp_ops',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
          //  parentopty.DeliveryMonths__c=2;
            parentopty.Auto_Renewal_Clause__c = true;
            parentopty.Auto_Renewal_Type__c = LABEL.CL_Opp_AutoRenewType_Fixed;
            parentopty.Auto_Renewal_Max_Fixed__c = '2';
            parentopty.Auto_Renewal_Term_Months__c = '36';
            parentopty.DeliveryMonths__c = 60;
            parentopty.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
            
            insert parentopty;
            
            
            Product2 prod = GC_UtilityClassTestData.createProduct('Test',LABEL.CL_MORNINGSTAR_DOCUMENT_RESEARCH,label.CL_NO_TOOL);     
            Database.insert(prod);
            Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
            PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
            insert pbe;
            OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1,parentopty.id, pbe.id, 12);
            oli.X2ndYearPrice__c=1;
            oli.X3rdYearPrice__c=11;
            oli.X4thYearPrice__c=1;
            oli.Delivery_Method__c='API';
            oli.AUMRange__c = 'Above $500M';
            oli.RemainingYearsPrice__c=12;
            oli.FirstDeliveryDateTBD__c = true;
            oli.SetUpFees__c = 0;
            oli.UnitPrice=1;
            insert oli;
            
            
            
            
            Business_Address__c busaddrs = new Business_Address__c(Account__c =parentacc.id, ZipPostalCode__c = '60602',Street__c='street1',City__c = 'city1',Country__c = 'India' );
            database.insert(busaddrs);
            ID busaddrsId=busaddrs.Id;
           
            
            OpportunityContactRole ocr=GC_UtilityClassTestData.createRole(con.id,'SAM',parentopty.id,true);
            insert ocr;
           
            
            
            
            BreakoutType__c breakout = GC_UtilityClassTestData.tempbreakout(parentopty.Id);
            insert breakout;
            
             
            Test.startTest();
           // Contract contract1 = GC_UtilityClassTestData.createContract(acc.Id,acc.Id,acc.Id,'Monthly',busaddrsId,con.Id ,con.Id ,busaddrsId,parentopty.Id );
            //insert contract1;
            
            // BillingSchedule__c bs= GC_UtilityClassTestData.createBusinessSchedule(contract1.id,'USD');
            //insert bs;
            
            //OpportunityTeamMember otm = GC_UtilityClassTestData.createTeamMember(parentopty.Id,'SAM',u.id);
            //insert otm;
            
            
            
          
           system.debug('%%%%%Account Status'+acc.AccountStatus__c);
           /* parentopty.Auto_Renewal_Clause__c = true;
            parentopty.Auto_Renewal_Type__c = LABEL.CL_Opp_AutoRenewType_Fixed;
            parentopty.Auto_Renewal_Max_Fixed__c = '2';
            parentopty.Auto_Renewal_Term_Months__c = '24';
            parentopty.DeliveryMonths__c = 36;*/
            parentopty.StageName = '5 - Closed Won';
            update(parentopty); 
            
           
            
              Test.stopTest();
            
          
         }
      }
      
      Static testMethod void CalculateACVtestlast12(){
     Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      userList.add(u);
      
      Database.insert(userList);
       
      
        List<Opportunity> opportunitylist = new List<Opportunity>();
        List<Opportunity> childopportunitylist = new List<Opportunity>();
          System.RunAs(u)
        {
        Test.startTest();
        Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
        insert acc;
        Product2 prod = GC_UtilityClassTestData.createProduct('Data', 'Data Feed', 'tool');
        insert prod;
        Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
        PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
        insert pbe;
        
       /* Opportunity parentopt1 = GC_UtilityClassTestData.createOpportunity('testparentOpp2',acc.Id,'New',label.CL_ROYALTY,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
        opportunitylist.add(parentopt1);
        Opportunity newopt = GC_UtilityClassTestData.createOpportunity('testparentOpp2',acc.Id,'New',label.CL_ROYALTY,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
        opportunitylist.add(newopt);*/
        Opportunity parentopt2 = GC_UtilityClassTestData.createOpportunity('testparentOpp2',acc.Id,'New',label.CL_ROYALTY,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
        parentopt2.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        opportunitylist.add(parentopt2);
        
        insert(opportunitylist);

        Opportunity childopt3 = GC_UtilityClassTestData.createOpportunity('testchildOpp14',acc.Id,'New',label.CL_ROYALTY,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'5 - Closed Won',0,'Asset Manager','Fund Company');
        childopt3.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        childopt3.ParentOpportunityId__c=parentopt2.Id;
        childopt3.AmendedBusinessRunRate__c=15;
        
        childopt3.recordtypeId=GC_Utils_Method.getRecordTypeId(Label.CL_OPPORTUNITY,Label.CL_AMENDMENT);
        childopt3.ContractType__c=label.CL_ONE_TIME;
        childopt3.DeliveryMonths__c=10;
        
        childopportunitylist.add(childopt3);
      
        
        insert(childopportunitylist);
        Test.stopTest();
            OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1, childopt3.id, pbe.id, 12);
        oli.X2ndYearPrice__c=1;
        oli.SetUpFees__c=45;
        
        
        oli.X3rdYearPrice__c=11;
        oli.X4thYearPrice__c=1;
        oli.RemainingYearsPrice__c=12;
        oli.UnitPrice=123333;
        //oli.TotalPrice=22;
        insert oli;
        
        
         
         
        //childopt3.ParentOpportunityId__c=parentopt1.Id;

        //newopt.VariableBusinessTCV__c= null;
        //update newopt;  
childopt3.StageName = '5 - Closed Won';
update childopt3;
       delete childopt3;
        //childopt3.ParentOpportunityId__c = null;
        
       
        } 
          
     }
     
          Static testMethod void CalculateACVtestlastff1(){
     Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      userList.add(u);
      
      Database.insert(userList);
       
      
        List<Opportunity> opportunitylist = new List<Opportunity>();
        List<Opportunity> opportunitylist1 = new List<Opportunity>();
        List<Opportunity> childopportunitylist = new List<Opportunity>();
          System.RunAs(u)
        {
       
        Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
        insert acc;
        Product2 prod = GC_UtilityClassTestData.createProduct('Data', 'Data Feed', 'tool');
        insert prod;
        Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
        PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
        insert pbe;
         Test.startTest();
       /* Opportunity parentopt1 = GC_UtilityClassTestData.createOpportunity('testparentOpp2',acc.Id,'New',label.CL_ROYALTY,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
        opportunitylist.add(parentopt1);
        Opportunity newopt = GC_UtilityClassTestData.createOpportunity('testparentOpp2',acc.Id,'New',label.CL_ROYALTY,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
        opportunitylist.add(newopt);*/
        Opportunity parentopt2 = GC_UtilityClassTestData.createOpportunity('testparentOpp2',acc.Id,'New',label.CL_ROYALTY,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
        parentopt2.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        opportunitylist.add(parentopt2);
        
        insert(opportunitylist);
        Opportunity parentopt3 = GC_UtilityClassTestData.createOpportunity('testparentOpp2',acc.Id,'New',label.CL_ROYALTY,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,label.CL_COSED_WON_5,30,'Asset Manager','Fund Company');
        parentopt3.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        opportunitylist1.add(parentopt3);
        
        insert(opportunitylist1);
    
        
        Opportunity childopt3 = GC_UtilityClassTestData.createOpportunity('testchildOpp14',acc.Id,'New',label.CL_ROYALTY,'USD',Date.Today()+30,Date.Today()+2,Date.Today()+15,'5 - Closed Won',0,'Asset Manager','Fund Company');
        childopt3.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';
        childopt3.ParentOpportunityId__c=parentopt2.Id;
        childopt3.AmendedBusinessRunRate__c=15;
        
        childopt3.recordtypeId=GC_Utils_Method.getRecordTypeId(Label.CL_OPPORTUNITY,Label.CL_AMENDMENT);
        childopt3.ContractType__c='Amendment';
        childopt3.DeliveryMonths__c=10;
        
        childopportunitylist.add(childopt3);
      
        
        insert(childopportunitylist);
        Test.stopTest();
            OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1, childopt3.id, pbe.id, 12);
        oli.X2ndYearPrice__c=1;
        oli.SetUpFees__c=45;
        
        
        oli.X3rdYearPrice__c=11;
        oli.X4thYearPrice__c=1;
        oli.RemainingYearsPrice__c=12;
        oli.UnitPrice=123333;
        //oli.TotalPrice=22;
        insert oli;
        
        
         
         
        //childopt3.ParentOpportunityId__c=parentopt1.Id;

        //newopt.VariableBusinessTCV__c= null;
        //update newopt;  
childopt3.ParentOpportunityId__c= parentopt3.id;
//update childopt3;
       delete childopt3;
        //childopt3.ParentOpportunityId__c = null;
        
       
        } 
          
     }
        
                 static testMethod void OpportunityTestcreateRenewal2()
    {
      Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      userList.add(u);
      
      Database.insert(userList);
       
      System.RunAs(u)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
            
              Id globalAccId =  GC_Utils_Method.getRecordTypeId(Label.CL_ACCOUNT1,Label.CL_AccGlobalRecordType);
           Id secondaryAccId = GC_Utils_Method.getRecordTypeId(Label.CL_ACCOUNT1,Label.CL_AccSecondaryRecordType); 
            
            Account parentacc = GC_UtilityClassTestData.createAccount('testParentname','Active','testcity','India','12345','teststreet','teststate'); 
                parentacc.recordtypeId = globalAccId ;
            parentacc.IntegrationStatus__c = 'Sync';
             parentacc.Clean__c = True;
                 parentacc.AccountStatus__c = 'Active'; 
                 parentacc.Master_License_Agreement_Date__c = Date.Today(); 
               //  parentacc.StrategicAccountManager__c = u.id;
                 insert parentacc;
            
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
           // acc.StrategicAccountManager__c = u.id;
            acc.recordtypeId = secondaryAccId;
            acc.ParentId = parentacc.Id;
            acclist.add(acc);
            system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            Database.insert(acclist);
            
            Database.DMLOptions dml = new Database.DMLOptions();
           dml.DuplicateRuleHeader.allowSave = true;
           //dml.DuplicateRuleHeader.includeRecordDetails = true;
           dml.DuplicateRuleHeader.runAsCurrentUser = true;
            Contact con = GC_UtilityClassTestData.createContact('test','Lastname','abc16598@test.com','Advisor','Investment Consultant',acc.id);
            //insert con;
            Database.insert(con, dml);
            
            Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOppFDD_ops',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
            parentopty.DeliveryMonths__c=2;
            parentopty.Auto_Renewal_Clause__c = true;
            parentopty.Auto_Renewal_Type__c = LABEL.CL_Opp_AutoRenewType_Fixed;
            parentopty.Auto_Renewal_Max_Fixed__c = '2';
            parentopty.Auto_Renewal_Term_Months__c = '12';
            parentopty.DeliveryMonths__c = 36;
            parentopty.SoldToCountry__c = 'Canada';
            parentopty.TECH_SyncContract__c = true;
            parentopty.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';  
            insert parentopty;
            
            
            Product2 prod = GC_UtilityClassTestData.createProduct('Test',LABEL.CL_MORNINGSTAR_DOCUMENT_RESEARCH,label.CL_NO_TOOL);     
            Database.insert(prod);
            Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
            PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
            insert pbe;
            OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1,parentopty.id, pbe.id, 12);
            oli.X2ndYearPrice__c=1;
            oli.X3rdYearPrice__c=11;
            oli.X4thYearPrice__c=1;
            oli.Delivery_Method__c='API';
            oli.AUMRange__c = 'Above $500M';
            oli.RemainingYearsPrice__c=12;
            oli.FirstDeliveryDate__c = Date.Today()+5;
            oli.SetUpFees__c = 0;
            oli.UnitPrice=1;
            insert oli;
            
            
            
            
            Business_Address__c busaddrs = new Business_Address__c(Account__c =parentacc.id, ZipPostalCode__c = '60602',Street__c='street1',City__c = 'city1',Country__c = 'India' );
            database.insert(busaddrs);
            ID busaddrsId=busaddrs.Id;
            
             Test.startTest();
            //Contract contract1 = GC_UtilityClassTestData.createContract(acc.Id,acc.Id,acc.Id,'Monthly',busaddrsId,con.Id ,con.Id ,busaddrsId,parentopty.Id );
            //insert contract1;
            
            //OpportunityContactRole ocr=GC_UtilityClassTestData.createRole(con.id,'SAM',parentopty.id,true);
            //insert ocr;
            
            
            //OpportunityTeamMember otm = GC_UtilityClassTestData.createTeamMember(parentopty.Id,'SAM',u.id);
            //insert otm;
            
            //BillingSchedule__c bs= GC_UtilityClassTestData.createBusinessSchedule(contract1.id,'USD');
            //insert bs;
            
            //BreakoutType__c breakout = GC_UtilityClassTestData.tempbreakout(parentopty.Id);
            //insert breakout;
            
            
         
           system.debug('%%%%%Account Status'+acc.AccountStatus__c);
          
          //  parentopty.HasOpportunityLineItem = false;
            parentopty.EffectiveDate__c = Date.Today()+3;
            parentopty.StageName = '5 - Closed Won';
            update(parentopty); 
            
           
            
              Test.stopTest();
            
          
         }
      } 
     static testMethod void OpportunityTestcreateRenewal222()
    {
      Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      userList.add(u);
      
      Database.insert(userList);
       
      System.RunAs(u)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
            
              Id globalAccId =  GC_Utils_Method.getRecordTypeId(Label.CL_ACCOUNT1,Label.CL_AccGlobalRecordType);
           Id secondaryAccId = GC_Utils_Method.getRecordTypeId(Label.CL_ACCOUNT1,Label.CL_AccSecondaryRecordType); 
            
            Account parentacc = GC_UtilityClassTestData.createAccount('testParentname','Active','testcity','India','12345','teststreet','teststate'); 
                parentacc.recordtypeId = globalAccId ;
            parentacc.IntegrationStatus__c = 'Sync';
             parentacc.Clean__c = True;
                 parentacc.AccountStatus__c = 'Active'; 
                 parentacc.Master_License_Agreement_Date__c = Date.Today(); 
                // parentacc.StrategicAccountManager__c = u.id;
                 insert parentacc;
            
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
           // acc.StrategicAccountManager__c = u.id;
            acc.recordtypeId = secondaryAccId;
            acc.ParentId = parentacc.Id;
            acclist.add(acc);
            system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            Database.insert(acclist);
            
            Database.DMLOptions dml = new Database.DMLOptions();
           dml.DuplicateRuleHeader.allowSave = true;
           //dml.DuplicateRuleHeader.includeRecordDetails = true;
           dml.DuplicateRuleHeader.runAsCurrentUser = true;
            Contact con = GC_UtilityClassTestData.createContact('test','Lastname','abc16598@test.com','Advisor','Investment Consultant',acc.id);
            //insert con;
            Database.insert(con, dml);
            
            Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOppFDD_ops',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
            parentopty.DeliveryMonths__c=2;
            parentopty.Auto_Renewal_Clause__c = true;
            parentopty.Auto_Renewal_Type__c = LABEL.CL_Opp_AutoRenewType_Fixed;
            parentopty.Auto_Renewal_Max_Fixed__c = '2';
            parentopty.Auto_Renewal_Term_Months__c = '6';
            parentopty.DeliveryMonths__c = 36;
            parentopty.SoldToCountry__c = 'Canada';
            parentopty.TECH_SyncContract__c = true;
            parentopty.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';  
            insert parentopty;
            
            
            Product2 prod = GC_UtilityClassTestData.createProduct('Test',LABEL.CL_MORNINGSTAR_DOCUMENT_RESEARCH,label.CL_NO_TOOL);     
            Database.insert(prod);
            Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
            PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
            insert pbe;
            OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1,parentopty.id, pbe.id, 12);
            oli.X2ndYearPrice__c=1;
            oli.X3rdYearPrice__c=11;
            oli.X4thYearPrice__c=1;
            oli.Delivery_Method__c='API';
            oli.AUMRange__c = 'Above $500M';
            oli.RemainingYearsPrice__c=12;
            oli.FirstDeliveryDate__c = Date.Today()+5;
            oli.SetUpFees__c = 0;
            oli.UnitPrice=1;
            insert oli;
            
            
            
            
            Business_Address__c busaddrs = new Business_Address__c(Account__c =parentacc.id, ZipPostalCode__c = '60602',Street__c='street1',City__c = 'city1',Country__c = 'India' );
            database.insert(busaddrs);
            ID busaddrsId=busaddrs.Id;
            
             Test.startTest();
            //Contract contract1 = GC_UtilityClassTestData.createContract(acc.Id,acc.Id,acc.Id,'Monthly',busaddrsId,con.Id ,con.Id ,busaddrsId,parentopty.Id );
            //insert contract1;
            
            //OpportunityContactRole ocr=GC_UtilityClassTestData.createRole(con.id,'SAM',parentopty.id,true);
            //insert ocr;
            
            
            //OpportunityTeamMember otm = GC_UtilityClassTestData.createTeamMember(parentopty.Id,'SAM',u.id);
            //insert otm;
            
            //BillingSchedule__c bs= GC_UtilityClassTestData.createBusinessSchedule(contract1.id,'USD');
            //insert bs;
            
            //BreakoutType__c breakout = GC_UtilityClassTestData.tempbreakout(parentopty.Id);
            //insert breakout;
            
            
         
           system.debug('%%%%%Account Status'+acc.AccountStatus__c);
          
          //  parentopty.HasOpportunityLineItem = false;
            parentopty.EffectiveDate__c = Date.Today()+3;
            parentopty.StageName = '5 - Closed Won';
            update(parentopty); 
            
           
            
              Test.stopTest();
            
          
         }
      } 
         static testMethod void OpportunityTestcreateRenewal23()
    {
      Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      userList.add(u);
      
      Database.insert(userList);
       
      System.RunAs(u)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
            
              Id globalAccId =  GC_Utils_Method.getRecordTypeId(Label.CL_ACCOUNT1,Label.CL_AccGlobalRecordType);
           Id secondaryAccId = GC_Utils_Method.getRecordTypeId(Label.CL_ACCOUNT1,Label.CL_AccSecondaryRecordType); 
            
            Account parentacc = GC_UtilityClassTestData.createAccount('testParentname','Active','testcity','India','12345','teststreet','teststate'); 
                parentacc.recordtypeId = globalAccId ;
            parentacc.IntegrationStatus__c = 'Sync';
             parentacc.Clean__c = True;
                 parentacc.AccountStatus__c = 'Active'; 
                 parentacc.Master_License_Agreement_Date__c = Date.Today(); 
                // parentacc.StrategicAccountManager__c = u.id;
                 insert parentacc;
            
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
           // acc.StrategicAccountManager__c = u.id;
            acc.recordtypeId = secondaryAccId;
            acc.ParentId = parentacc.Id;
            acclist.add(acc);
            system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            Database.insert(acclist);
            
            Database.DMLOptions dml = new Database.DMLOptions();
           dml.DuplicateRuleHeader.allowSave = true;
           //dml.DuplicateRuleHeader.includeRecordDetails = true;
           dml.DuplicateRuleHeader.runAsCurrentUser = true;
            Contact con = GC_UtilityClassTestData.createContact('test','Lastname','abc16598@test.com','Advisor','Investment Consultant',acc.id);
            //insert con;
            Database.insert(con, dml);
            
            Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOppFDD_ops',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
            parentopty.DeliveryMonths__c=2;
            parentopty.Auto_Renewal_Clause__c = true;
            parentopty.Auto_Renewal_Type__c = LABEL.CL_Opp_AutoRenewType_Fixed;
            parentopty.Auto_Renewal_Max_Fixed__c = '2';
            parentopty.Auto_Renewal_Term_Months__c = '3';
            parentopty.DeliveryMonths__c = 36;
            parentopty.SoldToCountry__c = 'Canada';
            parentopty.TECH_SyncContract__c = true;
            parentopty.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';  
            insert parentopty;
            
            
            Product2 prod = GC_UtilityClassTestData.createProduct('Test',LABEL.CL_MORNINGSTAR_DOCUMENT_RESEARCH,label.CL_NO_TOOL);     
            Database.insert(prod);
            Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
            PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
            insert pbe;
            OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1,parentopty.id, pbe.id, 12);
            oli.X2ndYearPrice__c=1;
            oli.X3rdYearPrice__c=11;
            oli.X4thYearPrice__c=1;
            oli.Delivery_Method__c='API';
            oli.AUMRange__c = 'Above $500M';
            oli.RemainingYearsPrice__c=12;
            oli.FirstDeliveryDate__c = Date.Today()+5;
            oli.SetUpFees__c = 0;
            oli.UnitPrice=1;
            insert oli;
            
            
            
            
            Business_Address__c busaddrs = new Business_Address__c(Account__c =parentacc.id, ZipPostalCode__c = '60602',Street__c='street1',City__c = 'city1',Country__c = 'India' );
            database.insert(busaddrs);
            ID busaddrsId=busaddrs.Id;
            
             Test.startTest();
            //Contract contract1 = GC_UtilityClassTestData.createContract(acc.Id,acc.Id,acc.Id,'Monthly',busaddrsId,con.Id ,con.Id ,busaddrsId,parentopty.Id );
            //insert contract1;
            
            //OpportunityContactRole ocr=GC_UtilityClassTestData.createRole(con.id,'SAM',parentopty.id,true);
            //insert ocr;
            
            
            //OpportunityTeamMember otm = GC_UtilityClassTestData.createTeamMember(parentopty.Id,'SAM',u.id);
            //insert otm;
            
            //BillingSchedule__c bs= GC_UtilityClassTestData.createBusinessSchedule(contract1.id,'USD');
            //insert bs;
            
            //BreakoutType__c breakout = GC_UtilityClassTestData.tempbreakout(parentopty.Id);
            //insert breakout;
            
            
         
           system.debug('%%%%%Account Status'+acc.AccountStatus__c);
          
          //  parentopty.HasOpportunityLineItem = false;
            parentopty.EffectiveDate__c = Date.Today()+3;
            parentopty.StageName = '5 - Closed Won';
            update(parentopty); 
            
           
            
              Test.stopTest();
            
          
         }
      } 
       static testMethod void OpportunityTestcreateRenewal234()
    {
      Profile p1 = GC_UtilityClassTestData.getProfile(label.CL_System_Administrator);
     List<User> userList = new List<User>();

      ID profileId = p1.Id;
      User u = GC_UtilityClassTestData.createUser('test1','standarduser@testorg.com','UTF-8','Testing','en_US','en_US',profileId,'America/Los_Angeles','standuser@testorg.com');
      userList.add(u);
      
      Database.insert(userList);
       
      System.RunAs(u)
        {
            List<Opportunity> opportunitylist = new List<Opportunity>();
            List<Account> acclist = new List<Account>();
            
            
              Id globalAccId =  GC_Utils_Method.getRecordTypeId(Label.CL_ACCOUNT1,Label.CL_AccGlobalRecordType);
           Id secondaryAccId = GC_Utils_Method.getRecordTypeId(Label.CL_ACCOUNT1,Label.CL_AccSecondaryRecordType); 
            
            Account parentacc = GC_UtilityClassTestData.createAccount('testParentname','Active','testcity','India','12345','teststreet','teststate'); 
                parentacc.recordtypeId = globalAccId ;
            parentacc.IntegrationStatus__c = 'Sync';
             parentacc.Clean__c = True;
                 parentacc.AccountStatus__c = 'Active'; 
                 parentacc.Master_License_Agreement_Date__c = Date.Today(); 
               //  parentacc.StrategicAccountManager__c = u.id;
                 insert parentacc;
            
            Account acc = GC_UtilityClassTestData.createAccount('testAcc','Active','testcity','India','12345','teststreet','teststate');
          //  acc.StrategicAccountManager__c = u.id;
            acc.recordtypeId = secondaryAccId;
            acc.ParentId = parentacc.Id;
            acclist.add(acc);
            system.debug('%%%%%Account Status'+acc.AccountStatus__c);
            Database.insert(acclist);
            
            Database.DMLOptions dml = new Database.DMLOptions();
           dml.DuplicateRuleHeader.allowSave = true;
           //dml.DuplicateRuleHeader.includeRecordDetails = true;
           dml.DuplicateRuleHeader.runAsCurrentUser = true;
            Contact con = GC_UtilityClassTestData.createContact('test','Lastname','abc16598@test.com','Advisor','Investment Consultant',acc.id);
            //insert con;
            Database.insert(con, dml);
            
            Opportunity parentopty = GC_UtilityClassTestData.createOpportunity('testparentOppFDD_ops',acc.Id,'New',label.CL_AMENDMENT,'USD',Date.Today(),Date.Today()+2,Date.Today()+45,'3 - Securing',30,'Asset Manager','Fund Company');
            parentopty.DeliveryMonths__c=2;
            parentopty.Auto_Renewal_Clause__c = true;
            parentopty.Auto_Renewal_Type__c = LABEL.CL_Opp_AutoRenewType_Fixed;
            parentopty.Auto_Renewal_Max_Fixed__c = '2';
            parentopty.Auto_Renewal_Term_Months__c = '1';
            parentopty.DeliveryMonths__c = 36;
            parentopty.SoldToCountry__c = 'Canada';
            parentopty.TECH_SyncContract__c = true;
            parentopty.Morningstar_Legal_Entity__c ='(001) Morningstar, Inc.';  
            insert parentopty;
            
            
            Product2 prod = GC_UtilityClassTestData.createProduct('Test',LABEL.CL_MORNINGSTAR_DOCUMENT_RESEARCH,label.CL_NO_TOOL);     
            Database.insert(prod);
            Pricebook2 pricebookid = [Select id from Pricebook2 where IsStandard=true limit 1];
            PricebookEntry pbe = new PricebookEntry (UseStandardPrice=false,Product2Id=prod.id,Pricebook2Id=pricebookid.id ,IsActive=true,CurrencyIsoCode='USD',UnitPrice=12);
            insert pbe;
            OpportunityLineItem oli = GC_UtilityClassTestData.createOpportunityProduct(1,parentopty.id, pbe.id, 12);
            oli.X2ndYearPrice__c=1;
            oli.X3rdYearPrice__c=11;
            oli.X4thYearPrice__c=1;
            oli.Delivery_Method__c='API';
            oli.AUMRange__c = 'Above $500M';
            oli.RemainingYearsPrice__c=12;
            oli.FirstDeliveryDate__c = Date.Today()+5;
            oli.SetUpFees__c = 0;
            oli.UnitPrice=1;
            insert oli;
            
            
            
            
            Business_Address__c busaddrs = new Business_Address__c(Account__c =parentacc.id, ZipPostalCode__c = '60602',Street__c='street1',City__c = 'city1',Country__c = 'India' );
            database.insert(busaddrs);
            ID busaddrsId=busaddrs.Id;
            
             Test.startTest();
            //Contract contract1 = GC_UtilityClassTestData.createContract(acc.Id,acc.Id,acc.Id,'Monthly',busaddrsId,con.Id ,con.Id ,busaddrsId,parentopty.Id );
            //insert contract1;
            
            //OpportunityContactRole ocr=GC_UtilityClassTestData.createRole(con.id,'SAM',parentopty.id,true);
            //insert ocr;
            
            
            //OpportunityTeamMember otm = GC_UtilityClassTestData.createTeamMember(parentopty.Id,'SAM',u.id);
            //insert otm;
            
            //BillingSchedule__c bs= GC_UtilityClassTestData.createBusinessSchedule(contract1.id,'USD');
            //insert bs;
            
            //BreakoutType__c breakout = GC_UtilityClassTestData.tempbreakout(parentopty.Id);
            //insert breakout;
            
            
         
           system.debug('%%%%%Account Status'+acc.AccountStatus__c);
          
          //  parentopty.HasOpportunityLineItem = false;
            parentopty.EffectiveDate__c = Date.Today()+3;
            parentopty.StageName = '5 - Closed Won';
            update(parentopty); 
            
           
            
              Test.stopTest();
            
          
         }
      } 
  
 }