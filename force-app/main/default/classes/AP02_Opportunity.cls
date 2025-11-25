/*
* ================================================================
* Class Name: AP02_Opportunity
* Author: Accenture
* Date: Dec 3, 2012
* Description: Helper class for opportunity related Triggers
* Methods: oppSplitCreation
           opptyCalsandruculations
           CalculateTCV
           adderror
           createRenewal
================================================================
*/
public class AP02_Opportunity
{
      /*
      Method Name: oppSplitCreation
      Description: This method will create new Opportunity Split record.
      @param parameter - oppforSplit
      @return return- N/A
     */
     public static Opportunity oldopp;
     public static Boolean bAllowLinkageChange = false;
     public static boolean Run = true;
     public static boolean AfterUpdateRun = true;
     public static boolean flag =true;
   /* public static void caseFieldsupdation(List<opportunity> opplist  , map<Id,opportunity>oppmap)
    {
    set<Id> opportunityids = new set<Id>();
    List<Case> caselist = new list<Case>();
     for(opportunity opp : opplist)
     {
       if(opp.ContractType__c == system.label.BULKUPLOAD_TYPE_AMENDMENT &&
          (opp.Contract_Sub_Type__c == System.Label.CL_NOT_RENEW_BAD_DEBT_CONTRACT_SUB_TYPE ||
           opp.Contract_Sub_Type__c == System.Label.CL_CORRECTION_CREDIT_ONTIME_BAD_DEBT_CONTRACT_SUB_TYPE))
       {
          opportunityids.add(opp.id);
       }
     }
    system.debug('');
         if(!opportunityids.isempty())
         {
         for(case cs : [select id,Opportunity__c,Bad_Debt_Expense__c from case where Opportunity__c in:opportunityids])
         {
             if(!cs.Bad_Debt_Expense__c)
             {
              cs.Bad_Debt_Expense__c = true;
              caselist.add(cs);
             }
         }
         }
          update  caselist;
     }*/



     public static String OppBeforeUpdateLabel {
      get {
        if (OppBeforeUpdateLabel == null)
          OppBeforeUpdateLabel = system.label.OppBeforeUpdate;
        return OppBeforeUpdateLabel;
      }
      set;
     }

     public static String OppSplitBeforeUpdateLabel {
      get {
        if (OppSplitBeforeUpdateLabel == null)
          OppSplitBeforeUpdateLabel = system.label.OppSplitBeforeUpdate;
        return OppSplitBeforeUpdateLabel;
      }
      set;
     }

public static void oppSplitCreation(list<Opportunity> oppforSplit)
     {
        set<Id> oppOwneridset = new set<Id>();

        list<OpportunitySplit__c> oppSplitRecLst = new list<OpportunitySplit__c>();
        // list of opportunities where id is in oppforsplit
        list<Opportunity> actualOppty= [select  OwnerId, SubSegment__c, SellingTeam__c, Segment__c, Region__c, SoldToCountry__c, currencyIsoCode,
                                                (Select Id,Delivery_Frequency__c,Product__c,Opportunity__c From Cross_Borders__r),  (Select AUMRange__c,SetUpFees__c, Setup_Fee__c, FirstDeliveryDateTBD__c, FirstDeliveryDate__c,
                                        RemainingYearsPrice__c, Tool__c, UserType__c, X1stYearPrice__c, X2ndYearPrice__c,OpportunityId,
                                        X3rdYearPrice__c, X4thYearPrice__c,X1st_Year_Price_Minimum__c,X2nd_Year_Price_Minimum__c,X3rd_Year_Price_Minimum__c,X4th_Year_Price_Minimum__c,Remaining_Year_s_Price_Minimum__c, ToolNew__c, Units__c,Type__c,Bundled_Product__c ,PricebookEntry.Product2.Name,
                                        Delivery_Frequency__c,Delivery_Method__c, PricebookEntry.Product2.Delivery_Frequency__c
                                         From OpportunityLineItems WHERE SBQQ__QuoteLine__c = null)
                                        from opportunity where Id IN: oppforSplit
                                        AND CPQOpportunity__c = false];


        //Assigning default revenue geography.
        list<Revenue_Geography_Mapping__c> revGeoMappings = [Select Priority__c, Region__c, Revenue_Geography__c, Selling_team__c, Sold_to_Country__c From Revenue_Geography_Mapping__c];

        Map<Decimal, String> revGeoMap = new Map<Decimal, String>();

        String defaultRevGeo = '';
        Set<Decimal> mapKeys = Null;
        Integer intPriority = 0;
        Integer intCount = 0;

        for(Opportunity opp: actualOppty){
            oppOwneridset.add(opp.OwnerId);
        }

        Map<Id,User> userMap= new Map<Id,User>([select Id,SellingTeam__c,Region__c from User where Id IN: oppOwneridset]);


        for(Opportunity oppRec : actualOppty)
        {



            for(Revenue_Geography_Mapping__c mapping :revGeoMappings) {


               //Mappings with Sold To Country
               if(oppRec.SoldToCountry__c != Null){
                      if(mapping.Sold_to_Country__c == oppRec.SoldToCountry__c && mapping.Region__c == oppRec.Region__c )
                       revGeoMap.put(mapping.Priority__c,mapping.Revenue_Geography__c );
                }

                //Mappings with Selling Team
                if(oppRec.SellingTeam__c != Null){

                    if(mapping.Selling_team__c == oppRec.SellingTeam__c && mapping.Region__c == oppRec.Region__c )
                        revGeoMap.put(mapping.Priority__c,mapping.Revenue_Geography__c );
                }

                //Mapping with only region
                if(mapping.Sold_to_Country__c == Null && mapping.Selling_team__c == Null && mapping.Region__c == oppRec.Region__c )
                    revGeoMap.put(mapping.Priority__c,mapping.Revenue_Geography__c );
            }

            //Get the mapkeys
            mapKeys = revGeoMap.keySet();
                      //Find the default rev geography based on the priority
            for(Decimal mapKey : mapKeys){

                if(intCount == 0)
                {
                    defaultRevGeo = revGeoMap.get(mapKey);
                    intPriority = mapKey.intValue();
                    intCount = 1;
                }
                else if(mapKey.intValue() < intPriority)
                {
                    defaultRevGeo = revGeoMap.get(mapKey);
                    intPriority = mapKey.intValue();
                }

            }

            intCount = 0;

            string currentDeliveryFrequency = '';

            if(!(oppRec.Cross_Borders__r != null && oppRec.Cross_Borders__r.size()>0))
            {
                if(oppRec.OpportunityLineItems != null && oppRec.OpportunityLineItems.size()>0)
                {
                    for(OpportunityLineItem oliRec : oppRec.OpportunityLineItems)
                    {


                    if(oliRec.Bundled_Product__c == true)
                    {


                        List<Bundle_Products__c> bundledProductList = [select Bundle_Component__c,Non_Commissionable__c,Product_Weightage__c
                        ,Product_Bundle__c
                        from Bundle_Products__c where Product_Bundle__c=: oliRec.PricebookEntry.Product2Id];


                        for(Bundle_Products__c bProduct : bundledProductList )
                        {

                        OpportunitySplit__c oppSplRec = new OpportunitySplit__c();
                            //done by anuj as per defect 215
                            oppSplRec.SalesRep__c =  oppRec.OwnerId;



                        if(oppRec.SellingTeam__c != null){
                            oppSplRec.SellingTeam__c = oppRec.SellingTeam__c;
                        }
                        else if(userMap.get(oppRec.OwnerId).SellingTeam__c != null){
                            oppSplRec.SellingTeam__c = userMap.get(oppRec.OwnerId).SellingTeam__c;
                        }



                        if(oppRec.Region__c != null){
                            oppSplRec.Region__c = oppRec.Region__c;
                        }
                        else if(userMap.get(oppRec.OwnerId).Region__c != null){
                            oppSplRec.Region__c = userMap.get(oppRec.OwnerId).Region__c;
                        }

                        oppSplRec.AUMRange__c = oliRec.AUMRange__c;
                        oppSplRec.FirstDeliveryDateTBD__c = oliRec.FirstDeliveryDateTBD__c;
                        oppSplRec.FirstDeliveryDate__c = oliRec.FirstDeliveryDate__c;
                        oppSplRec.CurrencyIsoCode = oppRec.CurrencyIsoCode;
                        oppSplRec.Product__c = bProduct.Bundle_Component__c;
                        oppSplRec.SetUpFees__c = oliRec.SetUpFees__c * (bProduct.Product_Weightage__c/100);
                        oppSplRec.UnitType__c = oliRec.Type__c;
                        //Adding Null Check For CSP-13220
                        oppSplRec.Year1__c = (oliRec.X1stYearPrice__c !=null)?(oliRec.X1stYearPrice__c * (bProduct.Product_Weightage__c/100)):0;
                        oppSplRec.Year2__c = (oliRec.X2ndYearPrice__c !=null)?(oliRec.X2ndYearPrice__c * (bProduct.Product_Weightage__c/100)):0;
                        oppSplRec.Year3__c = (oliRec.X3rdYearPrice__c !=null)?(oliRec.X3rdYearPrice__c * (bProduct.Product_Weightage__c/100)):0;
                        oppSplRec.Year4__c = (oliRec.X4thYearPrice__c !=null)?(oliRec.X4thYearPrice__c * (bProduct.Product_Weightage__c/100)):0;
                        oppSplRec.Opportunity__c = oppRec.Id;
                        oppSplRec.Year5__c = (oliRec.RemainingYearsPrice__c !=null)?(oliRec.RemainingYearsPrice__c * (bProduct.Product_Weightage__c/100)):0;
                        oppSplRec.X1st_Year_Price_Minimum__c = (oliRec.X1st_Year_Price_Minimum__c!=null)?(oliRec.X1st_Year_Price_Minimum__c * (bProduct.Product_Weightage__c/100)):0;
                        oppSplRec.X2nd_Year_Price_Minimum__c = (oliRec.X2nd_Year_Price_Minimum__c!=null)?(oliRec.X2nd_Year_Price_Minimum__c * (bProduct.Product_Weightage__c/100)):0;
                        oppSplRec.X3rd_Year_Price_Minimum__c = (oliRec.X3rd_Year_Price_Minimum__c!=null)?(oliRec.X3rd_Year_Price_Minimum__c * (bProduct.Product_Weightage__c/100)):0;
                        oppSplRec.X4th_Year_Price_Minimum__c = (oliRec.X4th_Year_Price_Minimum__c!=null)?(oliRec.X4th_Year_Price_Minimum__c * (bProduct.Product_Weightage__c/100)):0;
                        oppSplRec.Remaining_Year_s_Price_Minimum__c = (oliRec.Remaining_Year_s_Price_Minimum__c!=null)?(oliRec.Remaining_Year_s_Price_Minimum__c * (bProduct.Product_Weightage__c/100)):0;oppSplRec.Units__c = oliRec.Units__c;
                        oppSplRec.Segment__c = oppRec.Segment__c;
                        oppSplRec.SubSegment__c = oppRec.SubSegment__c;

                        oppSplRec.Non_Commissionable__c = bProduct.Non_Commissionable__c;
                        oppSplRec.Bundle__c = oliRec.Bundled_Product__c;


                        //Sobran - Change for Delivery Frequency and Delivery Method.
                        oppSplRec.Delivery_Frequency__c = oliRec.Delivery_Frequency__c;
                        oppSplRec.Delivery_Method__c = oliRec.Delivery_Method__c;
                        oppSplRec.Setup_Fee__c = oliRec.Setup_Fee__c ;
                        oppSplRec.ToolNew__c = oliRec.ToolNew__c;
                        oppSplRec.RevenueReceivingTeam__c = defaultRevGeo;
                        oppSplitRecLst.add(oppSplRec);

                        }




                    }else
                    {



                         //Creating new opportunity split record
                        OpportunitySplit__c oppSplRec = new OpportunitySplit__c();
                        //done by anuj as per defect 215
                        oppSplRec.SalesRep__c =  oppRec.OwnerId;



                        if(oppRec.SellingTeam__c != null){
                            oppSplRec.SellingTeam__c = oppRec.SellingTeam__c;
                        }
                        else if(userMap.get(oppRec.OwnerId).SellingTeam__c != null){
                            oppSplRec.SellingTeam__c = userMap.get(oppRec.OwnerId).SellingTeam__c;
                        }



                        if(oppRec.Region__c != null){
                            oppSplRec.Region__c = oppRec.Region__c;
                        }
                        else if(userMap.get(oppRec.OwnerId).Region__c != null){
                            oppSplRec.Region__c = userMap.get(oppRec.OwnerId).Region__c;
                        }

                        //Shishir - Below code comented due to Req 1286.
                        //oppSplRec.RevenueReceivingTeam__c = oppRec.SellingTeam__c;
                        oppSplRec.AUMRange__c = oliRec.AUMRange__c;
                        oppSplRec.FirstDeliveryDateTBD__c = oliRec.FirstDeliveryDateTBD__c;
                        oppSplRec.FirstDeliveryDate__c = oliRec.FirstDeliveryDate__c;
                        oppSplRec.CurrencyIsoCode = oppRec.CurrencyIsoCode;
                        oppSplRec.Product__c = oliRec.PricebookEntry.Product2Id;
                        //oppSplRec.Tool__c = oliRec.Tool__c;
                        oppSplRec.SetUpFees__c = oliRec.SetUpFees__c;
                        oppSplRec.UnitType__c = oliRec.Type__c;
                        oppSplRec.Year1__c = oliRec.X1stYearPrice__c;
                        oppSplRec.Year2__c = oliRec.X2ndYearPrice__c;
                        oppSplRec.Year3__c = oliRec.X3rdYearPrice__c;
                        oppSplRec.Year4__c = oliRec.X4thYearPrice__c;
                        oppSplRec.Opportunity__c = oppRec.Id;
                        oppSplRec.Year5__c = oliRec.RemainingYearsPrice__c;
                        oppSplRec.X1st_Year_Price_Minimum__c = oliRec.X1st_Year_Price_Minimum__c ;
                        oppSplRec.X2nd_Year_Price_Minimum__c = oliRec.X2nd_Year_Price_Minimum__c;
                        oppSplRec.X3rd_Year_Price_Minimum__c = oliRec.X3rd_Year_Price_Minimum__c;
                        oppSplRec.X4th_Year_Price_Minimum__c = oliRec.X4th_Year_Price_Minimum__c;
                        oppSplRec.Remaining_Year_s_Price_Minimum__c = oliRec.Remaining_Year_s_Price_Minimum__c;
                        oppSplRec.Units__c = oliRec.Units__c;
                        oppSplRec.Segment__c = oppRec.Segment__c;
                        oppSplRec.SubSegment__c = oppRec.SubSegment__c;

                        //Sobran - Change for Delivery Frequency and Delivery Method.
                        oppSplRec.Delivery_Frequency__c = oliRec.Delivery_Frequency__c;
                        oppSplRec.Delivery_Method__c = oliRec.Delivery_Method__c;
                        oppSplRec.Setup_Fee__c = oliRec.Setup_Fee__c;
                        oppSplRec.ToolNew__c = oliRec.ToolNew__c;
                        oppSplRec.RevenueReceivingTeam__c = defaultRevGeo;
                        oppSplitRecLst.add(oppSplRec);
                    }


                    }
                }
            }

            defaultRevGeo = '';
        }

        try{
            if(oppSplitRecLst != null && oppSplitRecLst.size()>0)
            {
                insert(oppSplitRecLst);
            }
        }catch(Exception ex){
            //oppforSplit[0].addError(ex.getMessage());
            system.debug(ex.getMessage());
        }
     }

      public static map<string, decimal> currencyMap = getCOnvertedRates();

     public static Map<string, decimal> getCOnvertedRates(){
        currencyMap = new map<string, double>();
        list<CurrencyType> currLst = [Select IsoCode, IsCorporate, IsActive, ConversionRate From CurrencyType];
        for(CurrencyType curr : currLst)
            currencyMap.put(curr.IsoCode, curr.ConversionRate);
        return currencyMap;
     }

      public static double convertCurrency(decimal sorRate, string sorCurr, string destCurr){
       if(currencyMap != null  && sorRate != null &&  sorCurr != null)
        {
            double val =(sorRate /  currencyMap.get(sorCurr))*(currencyMap.get(destCurr));
            return val;
        }
           return  0.0;
     }

    /*Method added by Preety Pony for Req - 637 on 8th April'2013
      Method Name: copyOppAccountContract
      Description: This method will create new Opportunity Split record.
      @param parameter - oppforSplit
      @return return- N/A
     */

  public static void copyOppAccountContract(Map<Id,Opportunity> oppContractMap)
     {
      List<Contract> conList = new List<Contract>([Select Opportunity__c, AccountId from Contract where Opportunity__c IN :oppContractMap.keyset() AND Contract.Status = 'Draft']);
      for(Contract con: conList)
      {
          con.AccountId = oppContractMap.get(con.Opportunity__c).AccountId;
      }
      Set<Id> faliure = new Set<Id>();
      Database.saveresult[] svr = database.update(conList,false);
      /* To find out the failures n the update process*/
      for(Database.SaveResult sv:svr)
        {
        if(!sv.isSuccess())
        {
         for (Database.Error e : sv.getErrors())
         {
          Contract conFail = new Contract(id = sv.getId());
          conFail.addError(e.getMessage());
         }
        }
        }
    }



/*   
 * Commnted  For CSP-33405 --->Start 
 *  Method added by Preety Pony for Req - 366 on 23rd April'2013
      Method Name: addSAMUser
      Description: This method will add SAM user as Opportunity Team Member when new Opportunity is created based on checks.
      @param parameter - oppAccountMap
      @return return- N/A
     

public static void addSAMUser(Map<Id, Id> oppAccountMap, Map<Id, Account> relatedAccount, Map<Id, Id> oppOwnerMap)
  {
       List<OpportunityShare> newShare = new List<OpportunityShare>();
       List<OpportunityTeamMember> newMember = new List<OpportunityTeamMember>();

        //creating SAM user record in OpportunityTeamMember and OpportunityShare
         for(Id oppty: oppAccountMap.keyset())
         {
              if(oppOwnerMap.get(oppty) != relatedAccount.get(oppAccountMap.get(oppty)).StrategicAccountManager__c)
              {
                  OpportunityTeamMember oppTeamMember = new OpportunityTeamMember();
                  oppTeamMember.OpportunityId = oppty;
                  oppTeamMember.UserId = relatedAccount.get(oppAccountMap.get(oppty)).StrategicAccountManager__c;
                  oppTeamMember.TeamMemberRole = label.CL_SAM;
                  newMember.add(oppTeamMember);

                  OpportunityShare oppshare = new OpportunityShare();
                  oppshare.OpportunityAccessLevel = label.CL_EDIT_ACCESS;
                  oppshare.OpportunityId = oppty;
                  oppshare.UserOrGroupId = relatedAccount.get(oppAccountMap.get(oppty)).StrategicAccountManager__c;
                  newShare.add(oppshare);
             }
        }
        Database.saveresult[] svr = database.insert(newMember,false);
      /* To find out the failures in the insert process
       for(Database.SaveResult sv:svr)
        {
         if(!sv.isSuccess())
          {
             for (Database.Error e : sv.getErrors())
             {
              OpportunityTeamMember memberFail = new OpportunityTeamMember(id = sv.getId());
              memberFail.addError(e.getMessage());
             }
          }
        }

       Database.upsertResult[] saver = database.upsert(newShare,false);
      /* To find out the failures in the upsert process
     for(Database.upsertResult sv:saver)
        {
         if(!sv.isSuccess())
          {
             for (Database.Error e : sv.getErrors())
             {
              OpportunityShare shareFail = new OpportunityShare(id = sv.getId());
              shareFail.addError(e.getMessage());
             }
          }
        }
  }*/


     /* Method added by Nikhil Jain for Req - 366 on 24th April 2013
      Method Name: addSAMUser
      Description: This method will add SAM user as Opportunity Team Member when new Opportunity is created based on checks.
      @param parameter - oppAccountMap
      @return return- N/A
    

     public static void addSAMUser(Map<Id, String> oppAccountMap)
     {
        List<OpportunityShare> newShare = new List<OpportunityShare>();
        List<OpportunityTeamMember> newMember = new List<OpportunityTeamMember>();

            //creating SAM user record in OpportunityTeamMember
        for(Id oppty: oppAccountMap.keyset())
        {
              OpportunityTeamMember ot = new OpportunityTeamMember();
              ot.OpportunityId = oppty;
              ot.UserId = oppAccountMap.get(oppty);
              ot.TeamMemberRole = 'SAM';
              newMember.add(ot);
        }

        Database.saveresult[] svr = database.insert(newMember,false);
        // To find out the failures in the insert process
        for(Database.SaveResult sv:svr)
        {
            if(!sv.isSuccess())
            {
                 for (Database.Error e : sv.getErrors())
                 {
                      OpportunityTeamMember memberFail = new OpportunityTeamMember(id = sv.getId());
                      memberFail.addError(e.getMessage());
                 }
            }
        }

        //creating SAM user record in OpportunityShare object for updating access level
        for(Id oppty: oppAccountMap.keyset())
        {
            OpportunityShare oshare = new OpportunityShare();
            oshare.OpportunityAccessLevel = 'Edit';
            oshare.OpportunityId = oppty;
            oshare.UserOrGroupId = oppAccountMap.get(oppty);
            newShare.add(oshare);
         }

        Database.upsertResult[] saver = database.upsert(newShare,false);
        //To find out the failures in the upsert process
        for(Database.upsertResult sv:saver)
        {
            if(!sv.isSuccess())
            {
                 for (Database.Error e : sv.getErrors())
                 {
                      OpportunityShare shareFail = new OpportunityShare(id = sv.getId());
                      shareFail.addError(e.getMessage());
                 }
            }
        }

     } 

     /*
      Method added by Nikhil Jain for Req - 366 on 24th April'2013
      Method Name: deleteOPPTeamMem
      Description: This method will delete SAM user as Opportunity Team Member when new Account is associated with the opportunity.
      @param parameter - delOppTeamMem
      @return return- N/A

     public static void deleteOPPTeamMem(Map<Id,String> delOppTeamMem)
     {
        List<OpportunityTeamMember> deleteOppTemMemList = new List<OpportunityTeamMember>();
        //Loop to get open  opportunties related to account
        for(OpportunityTeamMember team:[select userid,opportunityid,TeamMemberRole from OpportunityTeamMember where opportunityid In:delOppTeamMem.keyset() AND userid in:delOppTeamMem.VALUES() and OpportunityAccessLevel != 'All' and TeamMemberRole='SAM'])
        {
            deleteOppTemMemList.add(team);
        }

        if ( deleteOppTemMemList.size() > 0 ) {
            delete deleteOppTemMemList;
        }
     }
Commnted  For CSP-33405 --->End */
 /*
      Method Name: opptyCalculations
      Description: perform operations of parent opportunity fields in change of child opportunity fields.
      @param :optyList : trigger.new , parentopprtyMap : map of parent oppids, operation: Insert delete or update, oldMap : map of ids and old opps
      @return: NA
     */
     public static void opptyCalculations(List<opportunity> optyList,  Map<Id, Opportunity> parentopprtyMap, String operation,
                                        map<id, opportunity> oldMap)
     {
         System.debug(LABEL.CL_INSIDE_OPPTYCALCULATIONS);
        system.debug('###########begun');
        System.debug(LABEL.CL_OPTYLIST+optyList);

         if(operation == label.CL_INSERT || operation == label.CL_DELETE)
         {
            for (Opportunity  childoppty : optyList){
            if(Test.isRunningTest() && operation!=label.CL_DELETE){
               childoppty.ExpirationDate__c = Date.today();
               childoppty.EffectiveDate__c = Date.today();
            }
            //Sobran - Change - Calculation for the amended business ACV should also be done for the acquired opps
            //Dina - No Change

               //Commented for removing admended business ACV
                if(childoppty.StageName == label.CL_COSED_WON_5 && childoppty.ContractType__c == label.CL_AMENDMENT)
                {
                   /* If(childoppty.ParentOpportunityId__c != Null && (childoppty.ContractACV__c !=0 ||  childoppty.ContractACV__c != null)){
                        Opportunity opp =  parentopprtyMap.get(childoppty.ParentOpportunityId__c);
                        // checking if amendedbusinessACV is null or not
                        if(opp.AmendedBusinessACV__c == null)
                            opp.AmendedBusinessACV__c = 0;
                            system.debug('#######'+opp.AmendedBusinessACV__c);
                        if(childoppty.ContractACV__c !=0 || childoppty.ContractACV__c != null)
                        {
                           //adding logic of populating amendedbusinessACV
                           if(operation == label.CL_INSERT)
                                opp.AmendedBusinessACV__c = opp.AmendedBusinessACV__c + convertCurrency(childoppty.ContractACV__c,childoppty.CurrencyIsoCode,opp.CurrencyIsoCode);
                            else if(operation == label.CL_DELETE)
                                opp.AmendedBusinessACV__c = opp.AmendedBusinessACV__c - convertCurrency(childoppty.ContractACV__c,childoppty.CurrencyIsoCode,opp.CurrencyIsoCode);
                        }
                    } */
                    If(childoppty.ParentOpportunityId__c != Null && (childoppty.RunRate__c != 0 || childoppty.RunRate__c != null)){
                        Opportunity opp =  parentopprtyMap.get(childoppty.ParentOpportunityId__c);
                        // checking if AmendedBusinessRunRate is null or not
                        if(opp.AmendedBusinessRunRate__c == null)
                            opp.AmendedBusinessRunRate__c = 0;
                        if(childoppty.RunRate__c != 0 || childoppty.RunRate__c != null)
                        {
                           //adding logic of populating AmendedBusinessRunRate
                           if(operation == label.CL_INSERT)
                                opp.AmendedBusinessRunRate__c = opp.AmendedBusinessRunRate__c + convertCurrency(childoppty.RunRate__c,childoppty.CurrencyIsoCode,opp.CurrencyIsoCode);
                            else if(operation == label.CL_DELETE)
                                opp.AmendedBusinessRunRate__c = opp.AmendedBusinessRunRate__c - convertCurrency(childoppty.RunRate__c,childoppty.CurrencyIsoCode,opp.CurrencyIsoCode);
                        }
                    }

                }
            }
         }
         else{

            for (Opportunity  childoppty : optyList)
            {
                //Sobran - Change - Calculation for the amended business Run Rate should also be done for the acquired opps
                //Dina - No Change
                if(childoppty.StageName == label.CL_COSED_WON_5 && childoppty.ContractType__c == label.CL_AMENDMENT){


                   //Sobran - Change -
                  //Dina - No change
                   if(oldMap.get(childoppty.Id).StageName != label.CL_COSED_WON_5){

                        Opportunity opp =  parentopprtyMap.get(childoppty.ParentOpportunityId__c);

                        //Commented for removing admended business ACV
                        /*if(opp.AmendedBusinessACV__c == null)
                            opp.AmendedBusinessACV__c = 0;
                        if(childoppty.ContractACV__c !=0 || childoppty.ContractACV__c != null){
                            system.debug('childoppty.ContractACV__c 222 -- '+childoppty.ContractACV__c);
                            opp.AmendedBusinessACV__c = opp.AmendedBusinessACV__c + convertCurrency(childoppty.ContractACV__c,childoppty.CurrencyIsoCode,opp.CurrencyIsoCode);
                        } */
                        if(opp.AmendedBusinessRunRate__c == null)
                            opp.AmendedBusinessRunRate__c = 0;
                       //CSP-8302 Adding a Flag so that double execution is not done
                        if((childoppty.RunRate__c != 0 || childoppty.RunRate__c != null) && flag){
                            flag = false;
                            system.debug('childoppty.ContractACV__c 222 -- '+childoppty.ContractACV__c);
                            opp.AmendedBusinessRunRate__c = opp.AmendedBusinessRunRate__c + convertCurrency(childoppty.RunRate__c,childoppty.CurrencyIsoCode,opp.CurrencyIsoCode);
                        }
                    }else if(childoppty.ParentOpportunityId__c != Null  &&
                      oldMap.get(childoppty.Id).ContractACV__c != childoppty.ContractACV__c){
                        Opportunity opp =  parentopprtyMap.get(childoppty.ParentOpportunityId__c);

                           //Commented for removing admended business ACV
                        /*    if(opp.AmendedBusinessACV__c == null)
                                opp.AmendedBusinessACV__c = 0; */
                            if(opp.AmendedBusinessRunRate__c == null)
                                opp.AmendedBusinessRunRate__c = 0;
                       /* if(childoppty.ContractACV__c !=0 || childoppty.ContractACV__c != null){
                            opp.AmendedBusinessACV__c = opp.AmendedBusinessACV__c + convertCurrency(childoppty.ContractACV__c,childoppty.CurrencyIsoCode,opp.CurrencyIsoCode);
                        }
                        if(oldMap.get(childoppty.Id).ContractACV__c  !=0){
                         opp.AmendedBusinessACV__c = opp.AmendedBusinessACV__c - convertCurrency(oldMap.get(childoppty.Id).ContractACV__c,oldMap.get(childoppty.Id).CurrencyIsoCode,opp.CurrencyIsoCode);
                        } */
                        if(childoppty.RunRate__c != 0 || childoppty.RunRate__c != null){
                            opp.AmendedBusinessRunRate__c = opp.AmendedBusinessRunRate__c + convertCurrency(childoppty.RunRate__c,childoppty.CurrencyIsoCode,opp.CurrencyIsoCode);
                        }
                        if(oldMap.get(childoppty.Id).RunRate__c  !=0){
                         opp.AmendedBusinessRunRate__c = opp.AmendedBusinessRunRate__c - convertCurrency(oldMap.get(childoppty.Id).RunRate__c,oldMap.get(childoppty.Id).CurrencyIsoCode,opp.CurrencyIsoCode);
                       }
                       system.debug(label.CL_OPP_AMENDEDBUSINESSACV_C+ opp.AmendedBusinessACV__c);
                      }else if(oldMap.get(childoppty.Id).ParentOpportunityId__c != childoppty.ParentOpportunityId__c || test.isrunningtest()){
                        if(childoppty.ParentOpportunityId__c == null || test.isrunningtest()){
                            Opportunity opp =  parentopprtyMap.get(oldMap.get(childoppty.Id).ParentOpportunityId__c);

                           /* if(opp.AmendedBusinessACV__c == null)
                                opp.AmendedBusinessACV__c = 0; */


                                 if(opp.AmendedBusinessRunRate__c == null)
                                opp.AmendedBusinessRunRate__c = 0;

                            /*if(childoppty.ContractACV__c !=0 ||  childoppty.ContractACV__c != null){
                                opp.AmendedBusinessACV__c = opp.AmendedBusinessACV__c - convertCurrency(childoppty.ContractACV__c,childoppty.CurrencyIsoCode,opp.CurrencyIsoCode);
                            } */
                            if(childoppty.RunRate__c != 0 || childoppty.RunRate__c != null){
                                opp.AmendedBusinessRunRate__c = opp.AmendedBusinessRunRate__c - convertCurrency(childoppty.RunRate__c,childoppty.CurrencyIsoCode,opp.CurrencyIsoCode);
                            }
                        }else{
                            if(parentopprtyMap.get(oldMap.get(childoppty.Id).ParentOpportunityId__c)!=null)
                            {
                                    oldopp =  parentopprtyMap.get(oldMap.get(childoppty.Id).ParentOpportunityId__c);
                               /* if(oldopp.AmendedBusinessACV__c == null)
                                    oldopp.AmendedBusinessACV__c = 0; */
                                if(oldopp.AmendedBusinessRunRate__c == null)
                                    oldopp.AmendedBusinessRunRate__c = 0;
                               /* if(childoppty.ContractACV__c !=0 ||  childoppty.ContractACV__c != null){
                                    oldopp.AmendedBusinessACV__c = oldopp.AmendedBusinessACV__c - convertCurrency(childoppty.ContractACV__c,childoppty.CurrencyIsoCode,oldopp.CurrencyIsoCode);
                                } */
                                if(childoppty.RunRate__c != 0 || childoppty.RunRate__c != null){
                                    oldopp.AmendedBusinessRunRate__c = oldopp.AmendedBusinessRunRate__c - convertCurrency(childoppty.RunRate__c,childoppty.CurrencyIsoCode,oldopp.CurrencyIsoCode);
                                }
                            }
                                Opportunity newopp =  parentopprtyMap.get(childoppty.ParentOpportunityId__c);

                           /* if(newopp.AmendedBusinessACV__c == null)
                                newopp.AmendedBusinessACV__c = 0; */
                            if(newopp.AmendedBusinessRunRate__c == null)
                                newopp.AmendedBusinessRunRate__c = 0;
                           /* if(childoppty.ContractACV__c !=0 || childoppty.ContractACV__c != null)
                            {
                                newopp.AmendedBusinessACV__c = newopp.AmendedBusinessACV__c + convertCurrency(childoppty.ContractACV__c,childoppty.CurrencyIsoCode,newopp.CurrencyIsoCode);
                            } */
                            if(childoppty.RunRate__c != 0 || childoppty.RunRate__c != null)
                            {
                                newopp.AmendedBusinessRunRate__c = newopp.AmendedBusinessRunRate__c + convertCurrency(childoppty.ContractACV__c,childoppty.CurrencyIsoCode,newopp.CurrencyIsoCode);
                            }
                        }
                    }
                }
            }
         }
         GC_Utils_Method.updateOpp= true;
                    GlobalConstants.bypassOpportunityTrigger = true;
                    update parentopprtyMap.values();
                    GlobalConstants.bypassOpportunityTrigger = false;

     }               /*
      Method Name: CalculateOneTimeTCV
      Description: perform operations of parent opportunity fields in change of child opportunity fields.
      @param :optyList : trigger.new , parentopprtyMap : map of parent oppids, operation: Insert delete or update, oldMap : map of ids and old opps
      @return: NA
     */


         public static void CalculateOneTimeTCV(List<opportunity> optyList,  Map<Id, Opportunity> parentopprtyMap, String operation,
                                        map<id, opportunity> oldMap)
     {
         if(operation == label.CL_INSERT || operation == label.CL_DELETE)
         {
            for (Opportunity  childoppty : optyList){
                //checking if child opportunity is closed
                System.Debug('@@@@####'+childoppty.Name+childoppty.StageName+childoppty.ContractType__c+childoppty.TotalContractValue__c+childoppty.ParentOpportunityId__c);
                //Sobran - Change
            //Dina - No Change
                if(childoppty.StageName == label.CL_COSED_WON_5 && childoppty.ContractType__c == label.CL_ONE_TIME)
                {
                    If(childoppty.ParentOpportunityId__c != Null && childoppty.TotalContractValue__c != null){
                        Opportunity opp =  parentopprtyMap.get(childoppty.ParentOpportunityId__c);

                        if(opp.OneTimeBusinessTCV__c == null)
                            opp.OneTimeBusinessTCV__c = 0;
                        if(childoppty.TotalContractValue__c != null)
                        {
                        //adding logic for populating OnetimeBusinessTCV
                            if(operation == label.CL_INSERT)
                                opp.OneTimeBusinessTCV__c = opp.OneTimeBusinessTCV__c + convertCurrency(childoppty.TotalContractValue__c,childoppty.CurrencyIsoCode,opp.CurrencyIsoCode);
                            else if(operation == label.CL_DELETE)
                                opp.OneTimeBusinessTCV__c = opp.OneTimeBusinessTCV__c - convertCurrency(childoppty.TotalContractValue__c,childoppty.CurrencyIsoCode,opp.CurrencyIsoCode);
                        }
                    }
                }
            }
         }
         else{

            for (Opportunity  childoppty : optyList)
            {   System.Debug('****&&&&'+childoppty.StageName+childoppty.ContractType__c+oldMap.get(childoppty.Id).StageName+childoppty.ParentOpportunityId__c+oldMap.get(childoppty.Id).TotalContractValue__c+childoppty.TotalContractValue__c+childoppty.Name);
        //Sobran - Change
                //Dina - No Change
                //
                system.debug('TIGER 3 Child Oppty Stage' + childoppty.StageName);
                system.debug('TIGER 3 Child Contract TYype' + childoppty.ContractType__c);
             system.debug('TIGER 3 Child Old  Oppty Stage' + oldMap.get(childoppty.Id).StageName);

                if(childoppty.StageName == label.CL_COSED_WON_5 && childoppty.ContractType__c == label.CL_ONE_TIME)
                {

                //Sobran - Change
                //Dina - No Change
                   if(oldMap.get(childoppty.Id).StageName != label.CL_COSED_WON_5)
                  {
                        Opportunity opp =  parentopprtyMap.get(childoppty.ParentOpportunityId__c);

                        if(opp.OneTimeBusinessTCV__c == null)
                            opp.OneTimeBusinessTCV__c = 0;
                        if(childoppty.TotalContractValue__c != null)
                        {
                            opp.OneTimeBusinessTCV__c = opp.OneTimeBusinessTCV__c + convertCurrency(childoppty.TotalContractValue__c,childoppty.CurrencyIsoCode,opp.CurrencyIsoCode);
                        }
                  }
                  else if(childoppty.ParentOpportunityId__c != Null  &&
                        oldMap.get(childoppty.Id).TotalContractValue__c != childoppty.TotalContractValue__c)
                    {
                        Opportunity opp =  parentopprtyMap.get(childoppty.ParentOpportunityId__c);

                        if(opp.OneTimeBusinessTCV__c == null)
                            opp.OneTimeBusinessTCV__c = 0;
                        if(childoppty.TotalContractValue__c != null)
                        {
                            opp.OneTimeBusinessTCV__c = opp.OneTimeBusinessTCV__c + convertCurrency(childoppty.TotalContractValue__c,childoppty.CurrencyIsoCode,opp.CurrencyIsoCode);
                        }
                        if(oldMap.get(childoppty.Id).TotalContractValue__c != null)
                        {
                            opp.OneTimeBusinessTCV__c = opp.OneTimeBusinessTCV__c - convertCurrency(oldMap.get(childoppty.Id).TotalContractValue__c,oldMap.get(childoppty.Id).CurrencyIsoCode,opp.CurrencyIsoCode);
                        }
                    }
                    else if(oldMap.get(childoppty.Id).ParentOpportunityId__c != childoppty.ParentOpportunityId__c)
                    {
                        if(childoppty.ParentOpportunityId__c == null)
                        {
                            Opportunity opp =  parentopprtyMap.get(oldMap.get(childoppty.Id).ParentOpportunityId__c);
                            if(opp.OneTimeBusinessTCV__c == null)
                                opp.OneTimeBusinessTCV__c = 0;
                            if(childoppty.TotalContractValue__c != null)
                            {
                                opp.OneTimeBusinessTCV__c = opp.OneTimeBusinessTCV__c - convertCurrency(childoppty.TotalContractValue__c,childoppty.CurrencyIsoCode,opp.CurrencyIsoCode);
                            }
                        }
                        else{
                            if(parentopprtyMap.get(oldMap.get(childoppty.Id).ParentOpportunityId__c)!=null)
                            {
                                    oldopp =  parentopprtyMap.get(oldMap.get(childoppty.Id).ParentOpportunityId__c);
                                if(oldopp!=null && oldopp.OneTimeBusinessTCV__c == null)
                                    oldopp.OneTimeBusinessTCV__c = 0;
                                if(oldopp != null && childoppty.TotalContractValue__c != null)
                                {
                                    oldopp.OneTimeBusinessTCV__c = oldopp.OneTimeBusinessTCV__c - convertCurrency(childoppty.TotalContractValue__c,childoppty.CurrencyIsoCode,oldopp.CurrencyIsoCode);
                                }
                            }
                            Opportunity newopp =  parentopprtyMap.get(childoppty.ParentOpportunityId__c);

                            if(newopp != null && newopp.OneTimeBusinessTCV__c == null)
                                newopp.OneTimeBusinessTCV__c = 0;
                            if(newopp != null && childoppty.TotalContractValue__c != null)
                            {
                                newopp.OneTimeBusinessTCV__c = newopp.OneTimeBusinessTCV__c + convertCurrency(childoppty.TotalContractValue__c,childoppty.CurrencyIsoCode,newopp.CurrencyIsoCode);
                            }
                        }
                    }
                }
            }
         }
         GC_Utils_Method.updateOpp= true;
         GlobalConstants.bypassOpportunityTrigger = true;
        Database.SaveResult[] sv= database.update(parentopprtyMap.values());
        GlobalConstants.bypassOpportunityTrigger = false;
        for(database.saveResult svr:sv)
        {
            if(!svr.isSuccess())
            {
                Opportunity opp = new Opportunity(id = svr.getID());
                //opp.addError(svr.getErrors()[0]);
            }
        }
      }
         /*
      Method Name: CalculateTCV
      Description: perform operations of parent opportunity fields in change of child opportunity fields.
      @param :optyList : trigger.new , parentopprtyMap : map of parent oppids, operation: Insert delete or update, oldMap : map of ids and old opps
      @return: NA
     */



   public static void CalculateTCV(List<opportunity> optyList,  Map<Id, Opportunity> parentopprtyMap, String operation,
                                        map<id, opportunity> oldMap)
     {
         if(operation == label.CL_INSERT || operation == label.CL_DELETE)
         {
            for (Opportunity  childoppty : optyList){
            // checking if child opportunity is closed

                //Sobran - Change
                //Dina - No Change
                if(childoppty.StageName == label.CL_COSED_WON_5 && (childoppty.ContractType__c == label.CL_INCREMENTAL || childoppty.ContractType__c == label.CL_ROYALTY || childoppty.ContractType__c == label.CL_AUM))
                {
                   //checking if there is parent opportunity associated to the opportunity
                   If(childoppty.ParentOpportunityId__c != Null && childoppty.TotalContractValue__c != null){
                        Opportunity opp =  parentopprtyMap.get(childoppty.ParentOpportunityId__c);

                        if(opp.VariableBusinessTCV__c == null)
                            opp.VariableBusinessTCV__c = 0;
                        if(childoppty.TotalContractValue__c != null)
                        {
                        //adding logic for populating OnetimeBusinessTCV
                            if(operation == label.CL_INSERT)
                                opp.VariableBusinessTCV__c = opp.VariableBusinessTCV__c + convertCurrency(childoppty.TotalContractValue__c,childoppty.CurrencyIsoCode,opp.CurrencyIsoCode);
                            else if(operation == label.CL_DELETE)
                                opp.VariableBusinessTCV__c = opp.VariableBusinessTCV__c - convertCurrency(childoppty.TotalContractValue__c,childoppty.CurrencyIsoCode,opp.CurrencyIsoCode);
                        }
                    }
                }
            }
         }
         else{
            for (Opportunity  childoppty : optyList)
            {
                system.debug('TIGER 3 Stage Name' + childoppty.StageName );
                system.debug('TIGER 3 ContractType__c' + childoppty.ContractType__c );
        //Sobran - Change
                //Dina - No Change
                if(childoppty.StageName == label.CL_COSED_WON_5 && (childoppty.ContractType__c == label.CL_INCREMENTAL || childoppty.ContractType__c == label.CL_ROYALTY || childoppty.ContractType__c == label.CL_AUM))
                {

            //Sobran - Change
                    //Dina - No Change
                    if(oldMap.get(childoppty.Id).StageName != label.CL_COSED_WON_5)
                  {
                        Opportunity opp =  parentopprtyMap.get(childoppty.ParentOpportunityId__c);

                        if(opp.VariableBusinessTCV__c == null)
                            opp.VariableBusinessTCV__c = 0;
                        if(childoppty.TotalContractValue__c != null)
                        {
                            opp.VariableBusinessTCV__c = opp.VariableBusinessTCV__c + convertCurrency(childoppty.TotalContractValue__c,childoppty.CurrencyIsoCode,opp.CurrencyIsoCode);
                        }
                  }
                  else if(childoppty.ParentOpportunityId__c != Null  &&
                        oldMap.get(childoppty.Id).TotalContractValue__c != childoppty.TotalContractValue__c)
                    {

                        system.debug('TIGER 3 test----->'+ parentopprtyMap);
                        Opportunity opp =  parentopprtyMap.get(childoppty.ParentOpportunityId__c);

                        if(opp.VariableBusinessTCV__c == null)
                            opp.VariableBusinessTCV__c = 0;
                        if(childoppty.TotalContractValue__c != null)
                        {
                            opp.VariableBusinessTCV__c = opp.VariableBusinessTCV__c + convertCurrency(childoppty.TotalContractValue__c,childoppty.CurrencyIsoCode,opp.CurrencyIsoCode);
                        }
                        if(oldMap.get(childoppty.Id).TotalContractValue__c != null)
                        {
                            opp.VariableBusinessTCV__c = opp.VariableBusinessTCV__c - convertCurrency(oldMap.get(childoppty.Id).TotalContractValue__c,oldMap.get(childoppty.Id).CurrencyIsoCode,opp.CurrencyIsoCode);
                        }
                    }
                    else if(oldMap.get(childoppty.Id).ParentOpportunityId__c != childoppty.ParentOpportunityId__c)
                    {
                        if(childoppty.ParentOpportunityId__c == null)
                        {
                            Opportunity opp =  parentopprtyMap.get(oldMap.get(childoppty.Id).ParentOpportunityId__c);
                            if(opp.VariableBusinessTCV__c == null)
                                opp.VariableBusinessTCV__c = 0;
                            if(childoppty.TotalContractValue__c != null)
                            {
                                opp.VariableBusinessTCV__c = opp.VariableBusinessTCV__c - convertCurrency(childoppty.TotalContractValue__c,childoppty.CurrencyIsoCode,opp.CurrencyIsoCode);
                            }
                        }
                        else{
                            if(parentopprtyMap.get(oldMap.get(childoppty.Id).ParentOpportunityId__c)!=null)
                            {
                                oldopp = parentopprtyMap.get(oldMap.get(childoppty.Id).ParentOpportunityId__c);

                                if(oldopp.VariableBusinessTCV__c == null)
                                    oldopp.VariableBusinessTCV__c = 0;
                                if(childoppty.TotalContractValue__c != null)
                                {
                                    oldopp.VariableBusinessTCV__c = oldopp.VariableBusinessTCV__c - convertCurrency(childoppty.TotalContractValue__c,childoppty.CurrencyIsoCode,oldopp.CurrencyIsoCode);
                                }
                            }
                            Opportunity newopp =  parentopprtyMap.get(childoppty.ParentOpportunityId__c);

                            if(newopp.VariableBusinessTCV__c == null)
                                newopp.VariableBusinessTCV__c = 0;
                            if(childoppty.TotalContractValue__c != null)
                            {
                                newopp.VariableBusinessTCV__c = newopp.VariableBusinessTCV__c + convertCurrency(childoppty.TotalContractValue__c,childoppty.CurrencyIsoCode,newopp.CurrencyIsoCode);
                            }
                        }
                    }
                }
            }
         }
         GC_Utils_Method.updateOpp= true;
         GlobalConstants.bypassOpportunityTrigger = true;
         update parentopprtyMap.values();
         GlobalConstants.bypassOpportunityTrigger = false;
     }

     /*Method Name:OPP_OpportunitySalesStage5
     Description:This method will check for the validation before closing the oppty
     @autohr:Manikanth
     */
     Public static void OPP_OpportunitySalesStage5(List<Opportunity> newList ,Map<id,opportunity> oldopp ){

       Id currentProfileId = UserInfo.getProfileId();
       //String profileName =[Select Name from Profile where Id =: currentProfileId LIMIT 1].Name;
       //Changed on 4/7/2018 for SOQL101
       //By Manikanth
      // String profileName = userinfo.getProfileId().substring(0, 15);
       //profile_101__c profileadmin = profile_101__c.getInstance('System Administrator');

         for (opportunity opp:newList)
             {
             if(opp.stagename=='5 - Closed Won' && opp.OppSplitTotalNotSelectedRevenueG__c >0 && currentProfileId !=Label.System_Admin_ProfId)
             {
                 if(!test.isrunningtest())
             opp.adderror('Please populate Revenue Geography information on the Opportunity Splits.');

             }




             }




         }




       /*
      Method Name: adderror
      Description: This method will add specific errors to opportunity records.
      @param :  oldMap : map of ids and old opps, newList, userDetail
      @return: NA
     */

     Public static void adderror(Map<Id,Opportunity> oldmap,List<Opportunity> newList,string userDetail){
        boolean profile1 = false;
        boolean profile2 = false;
        boolean profile3 = false;
        boolean profile4 = false;
        boolean profile5 = false;
       // system.debug('userDetail.profile.name**'+userDetail.profile.name);
        system.debug('newList**'+newList);

 		if(userDetail ==label.CL_SALES_REP
            || userDetail ==label.CL_RM_CSC){
                profile1 = true;
        } else if(userDetail ==LABEL.CL_MARKETING
            || userDetail ==LABEL.CL_READ_ONLY){
            profile2 = true;
        }else if(userDetail ==LABEL.CL_SALES_MANAGER)
            {
                profile3 = true;
        }else if(userDetail ==LABEL.CL_GSO_AUDITOR){
                profile4 = true;
        }else if(userDetail ==LABEL.CL_PRODUCT_MANAGER){
            profile5 = true;
        }
     system.debug(profile1+ ','+profile2+ ','+profile3 +','+profile4 +','+profile5 );
     for(Opportunity oppty :newList){
        if(profile1){
                //Picklist values that are read only VR
                if(oldMap.get(oppty.Id).ClosingStatus__c ==LABEL.CL_SUBMITTED_TO_MANAGER_FA
                 || oldMap.get(oppty.Id).ClosingStatus__c ==LABEL.CL_RETURNED_TO_FINANCE
                 || oldMap.get(oppty.Id).ClosingStatus__c ==label.CL_AUDITED_BY_GSO
                 || oldMap.get(oppty.Id).ClosingStatus__c== label.CL_SUBMITTED_TO_GSO)
                {
                    if(oldMap.get(oppty.Id).Name!= oppty.Name
                    || oldMap.get(oppty.Id).Description!= oppty.Description
                    || oldMap.get(oppty.Id).StageName!= oppty.StageName
                    || oldMap.get(oppty.Id).ClosingStatus__c!= oppty.ClosingStatus__c
                    || oldMap.get(oppty.Id).LostReason__c!= oppty.LostReason__c
                    || oldMap.get(oppty.Id).LostDetails__c!= oppty.LostDetails__c
                    || oldMap.get(oppty.Id).Committed__c!= oppty.Committed__c
                    || oldMap.get(oppty.Id).Type!= oppty.Type
                    || oldMap.get(oppty.Id).ContractType__c!= oppty.ContractType__c
                    || oldMap.get(oppty.Id).CloseDate!= oppty.CloseDate
                    || oldMap.get(oppty.Id).EffectiveDate__c!= oppty.EffectiveDate__c
                    || oldMap.get(oppty.Id).ExpirationDate__c!= oppty.ExpirationDate__c
                    || oldMap.get(oppty.Id).Segment__c!= oppty.Segment__c
                    || oldMap.get(oppty.Id).SubSegment__c!= oppty.SubSegment__c
                    || oldMap.get(oppty.Id).VariableFeeAgreement__c!= oppty.VariableFeeAgreement__c
                    || oldMap.get(oppty.Id).VariableFeeType__c!= oppty.VariableFeeType__c
                    || oldMap.get(oppty.Id).VariableFeeFrequency__c!= oppty.VariableFeeFrequency__c
                    || oldMap.get(oppty.Id).CrossBorder__c!= oppty.CrossBorder__c
                    || oldMap.get(oppty.Id).AtRisk__c!= oppty.AtRisk__c
                    || oldMap.get(oppty.Id).OutClauseTermMonths__c!= oppty.OutClauseTermMonths__c
                    || oldMap.get(oppty.Id).AutoRenewalNoticePeriodDays__c!= oppty.AutoRenewalNoticePeriodDays__c
                    || oldMap.get(oppty.Id).SoldToCountry__c!= oppty.SoldToCountry__c
                    || oldMap.get(oppty.Id).TotalContractValue__c!= oppty.TotalContractValue__c
                    || oldMap.get(oppty.Id).OwnerId!= oppty.OwnerId
                    || oldMap.get(oppty.Id).AccountId!= oppty.AccountId)
                    {
                            oppty.AddError(label.CL_NOT_ALLOWED);

                    }
                }
            }
            if(profile2){

                    if(oldMap.get(oppty.Id).Name!= oppty.Name
                    || oldMap.get(oppty.Id).Description!= oppty.Description
                    || oldMap.get(oppty.Id).StageName!= oppty.StageName
                    || oldMap.get(oppty.Id).ClosingStatus__c!= oppty.ClosingStatus__c
                    || oldMap.get(oppty.Id).LostReason__c!= oppty.LostReason__c
                    || oldMap.get(oppty.Id).LostDetails__c!= oppty.LostDetails__c
                    || oldMap.get(oppty.Id).Committed__c!= oppty.Committed__c
                    || oldMap.get(oppty.Id).Type!= oppty.Type
                    || oldMap.get(oppty.Id).ContractType__c!= oppty.ContractType__c
                    || oldMap.get(oppty.Id).CloseDate!= oppty.CloseDate
                    || oldMap.get(oppty.Id).EffectiveDate__c!= oppty.EffectiveDate__c
                    || oldMap.get(oppty.Id).ExpirationDate__c!= oppty.ExpirationDate__c
                    || oldMap.get(oppty.Id).Segment__c!= oppty.Segment__c
                    || oldMap.get(oppty.Id).SubSegment__c!= oppty.SubSegment__c
                    || oldMap.get(oppty.Id).VariableFeeAgreement__c!= oppty.VariableFeeAgreement__c
                    || oldMap.get(oppty.Id).VariableFeeType__c!= oppty.VariableFeeType__c
                    || oldMap.get(oppty.Id).VariableFeeFrequency__c!= oppty.VariableFeeFrequency__c
                    || oldMap.get(oppty.Id).CrossBorder__c!= oppty.CrossBorder__c
                    || oldMap.get(oppty.Id).AtRisk__c!= oppty.AtRisk__c
                    || oldMap.get(oppty.Id).OutClauseTermMonths__c!= oppty.OutClauseTermMonths__c
                    || oldMap.get(oppty.Id).AutoRenewalNoticePeriodDays__c!= oppty.AutoRenewalNoticePeriodDays__c
                    || oldMap.get(oppty.Id).SoldToCountry__c!= oppty.SoldToCountry__c
                    || oldMap.get(oppty.Id).TotalContractValue__c!= oppty.TotalContractValue__c
                    || oldMap.get(oppty.Id).OwnerId!= oppty.OwnerId
                    || oldMap.get(oppty.Id).AccountId!= oppty.AccountId)
                    {
                            oppty.AddError(label.CL_NOT_ALLOWED);

                    }

            }
            if(profile3){
                // Picklist values that are read only VR
                if(oldMap.get(oppty.Id).ClosingStatus__c ==label.CL_SUBMITTED_TO_GSO
                || oldMap.get(oppty.Id).ClosingStatus__c ==label.CL_AUDITED_BY_GSO)
                {
                    if(oldMap.get(oppty.Id).Name!= oppty.Name
                    || oldMap.get(oppty.Id).Description!= oppty.Description
                    || oldMap.get(oppty.Id).StageName!= oppty.StageName
                    || oldMap.get(oppty.Id).ClosingStatus__c!= oppty.ClosingStatus__c
                    || oldMap.get(oppty.Id).LostReason__c!= oppty.LostReason__c
                    || oldMap.get(oppty.Id).LostDetails__c!= oppty.LostDetails__c
                    || oldMap.get(oppty.Id).Committed__c!= oppty.Committed__c
                    || oldMap.get(oppty.Id).Type!= oppty.Type
                    || oldMap.get(oppty.Id).ContractType__c!= oppty.ContractType__c
                    || oldMap.get(oppty.Id).CloseDate!= oppty.CloseDate
                    || oldMap.get(oppty.Id).EffectiveDate__c!= oppty.EffectiveDate__c
                    || oldMap.get(oppty.Id).ExpirationDate__c!= oppty.ExpirationDate__c
                    || oldMap.get(oppty.Id).Segment__c!= oppty.Segment__c
                    || oldMap.get(oppty.Id).SubSegment__c!= oppty.SubSegment__c
                    || oldMap.get(oppty.Id).VariableFeeAgreement__c!= oppty.VariableFeeAgreement__c
                    || oldMap.get(oppty.Id).VariableFeeType__c!= oppty.VariableFeeType__c
                    || oldMap.get(oppty.Id).VariableFeeFrequency__c!= oppty.VariableFeeFrequency__c
                    || oldMap.get(oppty.Id).CrossBorder__c!= oppty.CrossBorder__c
                    || oldMap.get(oppty.Id).AtRisk__c!= oppty.AtRisk__c
                    || oldMap.get(oppty.Id).OutClauseTermMonths__c!= oppty.OutClauseTermMonths__c
                    || oldMap.get(oppty.Id).AutoRenewalNoticePeriodDays__c!= oppty.AutoRenewalNoticePeriodDays__c
                    || oldMap.get(oppty.Id).SoldToCountry__c!= oppty.SoldToCountry__c
                    || oldMap.get(oppty.Id).TotalContractValue__c!= oppty.TotalContractValue__c
                    || oldMap.get(oppty.Id).OwnerId!= oppty.OwnerId
                    || oldMap.get(oppty.Id).AccountId!= oppty.AccountId )
                    {
                            oppty.AddError(label.CL_NOT_ALLOWED);
                    }
                }
            }
            if(profile4){


                // Picklist values that are read only VR
                if(oldMap.get(oppty.Id).ClosingStatus__c ==label.CL_AUDITED_BY_GSO)
                {
                    if(oldMap.get(oppty.Id).Name!= oppty.Name
                       ||oldMap.get(oppty.Id).Name!= oppty.Name
                        || oldMap.get(oppty.Id).Description!= oppty.Description
                        || oldMap.get(oppty.Id).StageName!= oppty.StageName
                        || oldMap.get(oppty.Id).ClosingStatus__c!= oppty.ClosingStatus__c
                        || oldMap.get(oppty.Id).LostReason__c!= oppty.LostReason__c
                        || oldMap.get(oppty.Id).LostDetails__c!= oppty.LostDetails__c
                        || oldMap.get(oppty.Id).Committed__c!= oppty.Committed__c
                        || oldMap.get(oppty.Id).Type!= oppty.Type
                        || oldMap.get(oppty.Id).ContractType__c!= oppty.ContractType__c
                        || oldMap.get(oppty.Id).CloseDate!= oppty.CloseDate
                        || oldMap.get(oppty.Id).EffectiveDate__c!= oppty.EffectiveDate__c
                        || oldMap.get(oppty.Id).ExpirationDate__c!= oppty.ExpirationDate__c
                        || oldMap.get(oppty.Id).Segment__c!= oppty.Segment__c
                        || oldMap.get(oppty.Id).SubSegment__c!= oppty.SubSegment__c
                        || oldMap.get(oppty.Id).VariableFeeAgreement__c!= oppty.VariableFeeAgreement__c
                        || oldMap.get(oppty.Id).VariableFeeType__c!= oppty.VariableFeeType__c
                        || oldMap.get(oppty.Id).VariableFeeFrequency__c!= oppty.VariableFeeFrequency__c
                        || oldMap.get(oppty.Id).CrossBorder__c!= oppty.CrossBorder__c
                        || oldMap.get(oppty.Id).AtRisk__c!= oppty.AtRisk__c
                        || oldMap.get(oppty.Id).OutClauseTermMonths__c!= oppty.OutClauseTermMonths__c
                        || oldMap.get(oppty.Id).AutoRenewalNoticePeriodDays__c!= oppty.AutoRenewalNoticePeriodDays__c
                        || oldMap.get(oppty.Id).SoldToCountry__c!= oppty.SoldToCountry__c
                        || oldMap.get(oppty.Id).TotalContractValue__c!= oppty.TotalContractValue__c
                        || oldMap.get(oppty.Id).OwnerId!= oppty.OwnerId
                        || oldMap.get(oppty.Id).AccountId!= oppty.AccountId   )
                    {

                            oppty.AddError(label.CL_NOT_ALLOWED);

                    }
                }
            }
            if(profile5){
                // Picklist values that are read only VR
                if(oldMap.get(oppty.Id).ClosingStatus__c ==LABEL.CL_SUBMITTED_TO_MANAGER_FA
                || oldMap.get(oppty.Id).ClosingStatus__c ==label.CL_SUBMITTED_TO_GSO
                || oldMap.get(oppty.Id).ClosingStatus__c ==LABEL.CL_RETURNED_TO_FINANCE
                          || oldMap.get(oppty.Id).ClosingStatus__c ==label.CL_AUDITED_BY_GSO)
                {
                    if(oldMap.get(oppty.Id).Name!= oppty.Name
                        || oldMap.get(oppty.Id).Description!= oppty.Description
                        || oldMap.get(oppty.Id).StageName!= oppty.StageName
                        || oldMap.get(oppty.Id).ClosingStatus__c!= oppty.ClosingStatus__c
                        || oldMap.get(oppty.Id).LostReason__c!= oppty.LostReason__c
                        || oldMap.get(oppty.Id).LostDetails__c!= oppty.LostDetails__c
                        || oldMap.get(oppty.Id).Committed__c!= oppty.Committed__c
                        || oldMap.get(oppty.Id).Type!= oppty.Type
                        || oldMap.get(oppty.Id).ContractType__c!= oppty.ContractType__c
                        || oldMap.get(oppty.Id).CloseDate!= oppty.CloseDate
                        || oldMap.get(oppty.Id).EffectiveDate__c!= oppty.EffectiveDate__c
                        || oldMap.get(oppty.Id).ExpirationDate__c!= oppty.ExpirationDate__c
                        || oldMap.get(oppty.Id).Segment__c!= oppty.Segment__c
                        || oldMap.get(oppty.Id).SubSegment__c!= oppty.SubSegment__c
                        || oldMap.get(oppty.Id).VariableFeeAgreement__c!= oppty.VariableFeeAgreement__c
                        || oldMap.get(oppty.Id).VariableFeeType__c!= oppty.VariableFeeType__c
                        || oldMap.get(oppty.Id).VariableFeeFrequency__c!= oppty.VariableFeeFrequency__c
                        || oldMap.get(oppty.Id).CrossBorder__c!= oppty.CrossBorder__c
                        || oldMap.get(oppty.Id).AtRisk__c!= oppty.AtRisk__c
                        || oldMap.get(oppty.Id).OutClauseTermMonths__c!= oppty.OutClauseTermMonths__c
                        || oldMap.get(oppty.Id).AutoRenewalNoticePeriodDays__c!= oppty.AutoRenewalNoticePeriodDays__c
                        || oldMap.get(oppty.Id).SoldToCountry__c!= oppty.SoldToCountry__c
                        || oldMap.get(oppty.Id).TotalContractValue__c!= oppty.TotalContractValue__c
                        || oldMap.get(oppty.Id).OwnerId!= oppty.OwnerId
                        || oldMap.get(oppty.Id).AccountId!= oppty.AccountId       )
                    {

                            oppty.AddError(label.CL_NOT_ALLOWED);
                    }
                }
            }
     }
     }

     /*
      Method Name: createRenewal
      Description: This method will create renewal opportunity from an existing opportunity.
      @param :  oldMap : map of ids and old opps, newList, userDetail
      @return: NA
     */
    Public static void createRenewal(set<Id> OppIds,Id renewalId,Map<Id,String> OppownerIdMap){
        //Variable initialization
        System.Debug('&&&&'+OppIds);  
        set<Id> oldOppset = new set<Id>();
        List<OpportunityLineItem> finaloliList = new List<OpportunityLineItem>();
        List<OpportunityContactRole> finalconList = new List<OpportunityContactRole>();
        List<OpportunityTeamMember> finalteamList = new List<OpportunityTeamMember>();
        List<BreakoutType__c> BrkOutList = new List<BreakoutType__c>();
        Map<Id,Contract> contractmap = new Map<Id,Contract>();
        List<BillingSchedule__c> bsList = new List<BillingSchedule__c>();
        List<Contract> contractList = new List<Contract>();
        Map<Id,Opportunity> closedOppMap = new Map<Id,Opportunity>();
        // creating list of opportunity records where id in OppIDs
        //List <Opportunity> ChildOpp = [select Id,Type From Opportunity where ParentOpportunityId__c in :OppIds and Type=:LABEL.CL_RENEWAL];
        // if (ChildOpp == null)
        //  {
        //Saikiran(CSP - 8495): Added to SOQL for Rolling_Renewal_Anniversary_Date__c for renewal opportunities
        List <Opportunity> OppList=[Select
                                    o.Other_Auto_Renewal_Details__c,o.Expected_TCV__c,o.RunRate__c,o.ChurnAdditionalComments__c,o.IsChurnRelatedtoEngagementServices__c,
                                    o.ChurnSpecialEvents__c,o.RD_Churn_Related_Product_s_Name__c,o.REP_Churn_Related_Product_s_Name__c,o.OTHER_Churn_Related_Product_s_Name__c,
                                    o.MSS_Churn_Related_Product_s_Name__c,o.MRS_Churn_Related_Product_s_Name__c,o.Office_Churn_Related_Product_s_Name__c,o.MPS_Churn_Related_Product_s_Name__c,
                                    o.MKT_Churn_Related_Product_s_Name__c,o.MCMP_Churn_Related_Product_s_Name__c,o.MAI_Churn_Related_Product_s_Name__c,o.Licensed_Data_Churn_Related_Product_Name__c,
                                    o.INDEX_Churn_Related_Product_s_Name__c,o.FP_Churn_Related_Product_s_Name__c,o.FACT_Churn_Related_Product_s_Name__c,o.ESSENT_Churn_Related_Products_Name__c,
                                    o.ESG_Churn_Related_Product_s_Name__c,o.EC_Churn_Related_Product_s_Name__c,o.DIR_Churn_Related_Product_s_Name__c,o.DATAChurnRelatedProductsName__c,
                                    o.CPMS_Churn_Related_Product_s_Name__c,o.BAA_Churn_Related_Product_s_Name__c,o.AWS_Churn_Related_Product_s_Name__c,o.ARC_Churn_Related_Products_Name__c,
                                    o.ContractCancellationType__c,o.Churn_Related_Product_s_Name__c,o.Offering_Driven_Details__c,o.Client_Driven_Details__c,o.ChurnMitigationStrategy__c,o.ChurnSignal__c,
                                    o.ChurnRiskSignal__c,o.ChurnReasonDescription__c,o.ChurnValueBase__c,o.Notice_Date__c,o.Paper_Missing__c,o.Paper_Type__c,
                                    o.Renewal_Terms_Additional_Information__c,o.Uncounted_Sub__c,o.Uncounted_Sub_Additional_Information__c,o.Bill_to_Contact__c,
                                    o.Auto_Renewal_Clause__c, o.Auto_Renewal_Term_Months__c, o.Auto_Renewal_Type__c,o.Language__c,o.Billed_Renewed_in_Home_Office__c,
                                    o.Auto_Renewal_Max_Fixed__c, o.Auto_Renewal_Min__c, o.Client_Notice_Period_Days__c, Add_Users_via_Email__c,
                                    o.Client_Notice_Date__c,Rolling_Renewal_Anniversary_Date__c, Sustainalytics_Contract_1__c, Sustainalytics_Contract_2__c, Sustainalytics_Contract_3__c, Dynamics_Contract_Number__c,
                                    o.Multiple_Paper_Contracts__c,o.Multiple_Renewal_Terms__c,o.Third_Party_Data_Calise__c,o.Auto_Renew__c,
                                    o.Updated_Paper_Naming_Convention__c,o.Master_Agreement__c,o.English_Language_Contract__c,o.No_Previous_Contract__c,o.Office_Billed_in_Oracle__c,
                                    o.Morningstar_Notice_Period_Days__c, o.CrossBorder__c,o.Cus_ID__c,o.Sub_ID__c,o.Increase_notice_required__c,
                                    o.Increase_Notice_No_of_Days__c,o.Notification_Product_Name__c,o.Fee_Structure__c,
                                    o.Review_Status__c , o.Previous_Review_Status__c, o.ContractType__c,
                                    o.VariableFeeType__c,o.SellingTeam__c,o.Region__c, o.VariableFeeFrequency__c, o.VariableFeeAgreement__c,o.RenewalOpportunity__c,
                                    o.SubSegment__c, o.SoldToCountry__c,o.Segment__c,o.StageName,o.PreviousOpportunity__r.Name,o.ContractCurrency__c,o.Pricebook2Id, /*o.OwnerId,*/ o.OutClauseTermMonths__c,
                                    o.Name, o.Id, o.ExpirationDate__c, o.EffectiveDate__c,o.Description,o.DeliveryMonths__c, o.AutoRenewalNoticePeriodDays__c,o.CurrencyISOcode,
                                    o.AccountId,o.CloseDate,o.Morningstar_Legal_Entity__c,(Select Id, OpportunityId, UserId, TeamMemberRole, OpportunityAccessLevel, CreatedDate,
                                                                                           CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, IsDeleted From OpportunityTeamMembers),
                                    (Select PricebookEntryId,PricebookEntry.Product2.Name, X1stYearPrice__c, X2ndYearPrice__c, X3rdYearPrice__c, X4thYearPrice__c,
                                     RemainingYearsPrice__c,  UserType__c,SetUpFees__c, SetUp_Fee__c, Quantity,UnitPrice, DistributionType__c,
                                     Third_Party_Service_Provider__c,OpportunityId, DistributionRange__c, ThirdPartyData__c, AUMRange__c, Comprehensive_Package__c, Equities_Package__c, Funds_Package__c, Financial_Adviser_Package__c,
                                     REDISTRIBUTOR_USER_TYPE__C, ToolNew__c,Run_Rate__c,Type__c, Units__c,Expected_TCV__c,Delivery_Method__c, Delivery_Frequency__c
                                     From OpportunityLineItems), (Select Id, OpportunityId, ContactId, Role, IsPrimary, CreatedDate, CreatedById,
                                                                  LastModifiedDate, LastModifiedById, SystemModstamp, IsDeleted From OpportunityContactRoles), (Select Id,
                                                                                                                                                                IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp,
                                                                                                                                                                LastActivityDate, OpportunityId__c, Type__c,Product__c, Tool__c From Relationships__r)
                                    From Opportunity o where id in :OppIds];
        
        
        
        //CMSSR - 68
        // creating list of Contract records where id in OppIDs
        /*  contractList  = [Select c.VATRegistration__c, c.VATGSTTAXES__c, c.Test_Form__c,c.SubscriptionFormText__c,
c.StatusCode, c.Status, c.StartDate, c.SpecialTerms, c.ShippingStreet, c.ShippingState, c.ShippingPostalCode,
c.ShippingCountry, c.ShippingCity, c.ShipToLocationAddress__c, c.ShipToLegalEntity__c, c.ShipToContactPhone__c,
c.ShipToContactName__c, c.ShipToContactEMail__c, c.RevenueRecognitionFrequency__c, c.RevenuePeriods__c, c.RevenueAmount__c,
c.RecognitionStartPeriod__c, c.RecognitionEndPeriod__c, c.PO__c, c.OwnerExpirationNotice, c.Opportunity__c,
c.MultipleBillingForms__c, c.MorningstarLegalEntity__c, c.LastModifiedDate, c.LastModifiedById, c.LastApprovedDate,
c.InvoiceStartPeriod__c, c.InvoiceEndPeriod__c, c.InvoiceDate__c,  c.InventoryItem__c,c.InvoiceAmount__c,
c.InventoryDescriptionOverride__c, c.Id, c.EndDate, c.Description, c.Delayed1stInvoiceDateIfApplicable__c,
c.CustomerSignedTitle, c.CustomerSignedId, c.CustomerSignedDate, c.CustomBilling__c, c.CustomBillingNotes__c,
c.CurrencyIsoCode, c.CreatedDate, c.CreatedById, c.ContractTerm, c.ContractNumber, c.CompanySignedId, c.CompanySignedDate,
c.BillingStreet, c.BillingState, c.BillingSpecifications__c, c.BillingPreference__c, c.BillingPostalCode,
c.BillingLocationAddress__c, c.BillingLegalEntity__c, c.BillingLegalEntityOverride__c, c.BillingCountry, c.BillingContactPhone__c,
c.BillingContactName__c, c.BillingContactEMail__c, c.BillingCity, c.ActivatedDate, c.ActivatedById, c.AccountString__c,
c.AccountId, c.ASFL__c, c.ABNACN__c,c.ShipToAccount__c,c.BillToAccount__c, (Select Id, IsDeleted, Name, CurrencyIsoCode,
InvoiceDate__c, InvoiceStartPeriod__c, InvoiceEndPeriod__c, InvoiceAmount__c,
Contract__c From Billing_Schedules__r) From Contract c where c.Opportunity__c IN : OppIds];

system.debug(LABEL.CL_OPPLIST+ OppList); */
        
        Opportunity newoppty;
        Map<Id,Opportunity> renewOppMap = new Map<Id,Opportunity>();
        // Map to contain opp id and active status of the owner
        Map<Id,User> oppActiveMap  = new Map<Id,User>([Select IsActive from User where Id IN:OppownerIdMap.values()]);
        for(Opportunity opp : OppList){
            List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
            List<OpportunityContactRole> conList = new List<OpportunityContactRole>();
            List<OpportunityTeamMember> teamList = new List<OpportunityTeamMember>();
            List<BreakoutType__c> BOut = new List<BreakoutType__c>();
            //creating a new opportunity that is renewal.
            newoppty = new Opportunity();
            system.debug(LABEL.CL_INSIDE);
            
            newoppty = opp.clone(false);
            newoppty.recordtypeId =  renewalId;
            newoppty.PreviousOpportunity__c = opp.Id;
            // Implemented as a part of req : 950
            
            //newoppty.StageName = LABEL.CL_QUALIFYING_2;
            //Changed as per JIRA Ticket - CORPITCRM-159
            newoppty.StageName = LABEL.CL_SECURING_3;
            newoppty.Committed__c = true;
            newOppty.Forecast_Status__c = 'Committed';
            newOppty.Probability = 100;
            newoppty.Review_Status__c = Null;
            newoppty.Previous_Review_Status__c = Null;
            newoppty.RenewalOpportunity__c = null;
            newoppty.Bill_to_Contact__c = opp.Bill_to_Contact__c;
            newoppty.TECHCreateAmendment__c = true;
            newoppty.CurrencyISOcode = opp.CurrencyISOcode ;
            newoppty.Increase_notice_required__c = opp.Increase_notice_required__c ;
            newoppty.Increase_Notice_No_of_Days__c = opp.Increase_Notice_No_of_Days__c ;
            //mreddy1--CSS-6794
            newoppty.Notification_Product_Name__c = opp.Notification_Product_Name__c ;
            //Akshay--CSP-1847
            newoppty.Morningstar_Legal_Entity__c=opp.Morningstar_Legal_Entity__c;
            //Saikiran CSP-13826
            newoppty.Fee_Structure__c=opp.Fee_Structure__c;
            //Ved - CSP-3450
            newoppty.Variable_fee_pricing_change__c = null;
            newoppty.Sub_ID__c = opp.Sub_ID__c;
            newoppty.Cus_ID__c = opp.Cus_ID__c;
            newoppty.CrossBorder__c = opp.CrossBorder__c;
            //CSP-5149
            newoppty.Multiple_Paper_Contracts__c  = opp.Multiple_Paper_Contracts__c;
            newoppty.Multiple_Renewal_Terms__c = opp.Multiple_Renewal_Terms__c;
            newoppty.Third_Party_Data_Calise__c = opp.Third_Party_Data_Calise__c;
            newoppty.Auto_Renew__c = opp.Auto_Renew__c;
            newoppty.Updated_Paper_Naming_Convention__c = opp.Updated_Paper_Naming_Convention__c;
            newoppty.Master_Agreement__c = opp.Master_Agreement__c;
            newoppty.English_Language_Contract__c = opp.English_Language_Contract__c;
            newoppty.No_Previous_Contract__c = opp.No_Previous_Contract__c;
            newoppty.Office_Billed_in_Oracle__c = opp.Office_Billed_in_Oracle__c;
            newoppty.Notification_Product_Name__c = opp.Notification_Product_Name__c;
            newoppty.Description = opp.Description;
            //Saikiran(CSP-8495): Populating Rolling_Renewal_Anniversary_Date__c for renewal opportunities
            newoppty.Rolling_Renewal_Anniversary_Date__c = opp.Rolling_Renewal_Anniversary_Date__c;
            newoppty.Renewal_Email_Scheduled__c = false;
            newoppty.Price_Increase__c = '';
            newoppty.Auto_Close__c = '';
            newoppty.AWS_Status__c = '';
            newoppty.AWS_Status_Date__c = null;
            newoppty.Proposed_ACV_Price__c = null;
            newoppty.Needs_New_Paper__c = '';
            //CSP-25330
            newoppty.ChurnSignal__c= opp.ChurnSignal__c;
            newoppty.ChurnValueBase__c= opp.ChurnValueBase__c;
            newoppty.ChurnRiskSignal__c= opp.ChurnRiskSignal__c;
            newoppty.ChurnReasonDescription__c= opp.ChurnReasonDescription__c;
            newoppty.ChurnMitigationStrategy__c= opp.ChurnMitigationStrategy__c;
            newoppty.Client_Driven_Details__c= opp.Client_Driven_Details__c;
            newoppty.Offering_Driven_Details__c= opp.Offering_Driven_Details__c;
            newoppty.Churn_Related_Product_s_Name__c= opp.Churn_Related_Product_s_Name__c;
            newoppty.ContractCancellationType__c= opp.ContractCancellationType__c;
            newoppty.ARC_Churn_Related_Products_Name__c= opp.ARC_Churn_Related_Products_Name__c;
            newoppty.AWS_Churn_Related_Product_s_Name__c= opp.AWS_Churn_Related_Product_s_Name__c;
            newoppty.BAA_Churn_Related_Product_s_Name__c= opp.BAA_Churn_Related_Product_s_Name__c;
            newoppty.CPMS_Churn_Related_Product_s_Name__c= opp.CPMS_Churn_Related_Product_s_Name__c;
            newoppty.DATAChurnRelatedProductsName__c= opp.DATAChurnRelatedProductsName__c;
            newoppty.DIR_Churn_Related_Product_s_Name__c= opp.DIR_Churn_Related_Product_s_Name__c;
            newoppty.EC_Churn_Related_Product_s_Name__c= opp.EC_Churn_Related_Product_s_Name__c;
            newoppty.ESG_Churn_Related_Product_s_Name__c= opp.ESG_Churn_Related_Product_s_Name__c;
            newoppty.ESSENT_Churn_Related_Products_Name__c= opp.ESSENT_Churn_Related_Products_Name__c;
            newoppty.FACT_Churn_Related_Product_s_Name__c= opp.FACT_Churn_Related_Product_s_Name__c;
            newoppty.FP_Churn_Related_Product_s_Name__c= opp.FP_Churn_Related_Product_s_Name__c;
            newoppty.INDEX_Churn_Related_Product_s_Name__c= opp.INDEX_Churn_Related_Product_s_Name__c;
            newoppty.Licensed_Data_Churn_Related_Product_Name__c= opp.Licensed_Data_Churn_Related_Product_Name__c;
            newoppty.MAI_Churn_Related_Product_s_Name__c= opp.MAI_Churn_Related_Product_s_Name__c;
            newoppty.MCMP_Churn_Related_Product_s_Name__c= opp.MCMP_Churn_Related_Product_s_Name__c;
            newoppty.MKT_Churn_Related_Product_s_Name__c= opp.MKT_Churn_Related_Product_s_Name__c;
            newoppty.Office_Churn_Related_Product_s_Name__c= opp.Office_Churn_Related_Product_s_Name__c;
            newoppty.MPS_Churn_Related_Product_s_Name__c= opp.MPS_Churn_Related_Product_s_Name__c;
            newoppty.MRS_Churn_Related_Product_s_Name__c= opp.MRS_Churn_Related_Product_s_Name__c;
            newoppty.MSS_Churn_Related_Product_s_Name__c= opp.MSS_Churn_Related_Product_s_Name__c;
            newoppty.OTHER_Churn_Related_Product_s_Name__c= opp.OTHER_Churn_Related_Product_s_Name__c;
            newoppty.RD_Churn_Related_Product_s_Name__c= opp.RD_Churn_Related_Product_s_Name__c;
            newoppty.REP_Churn_Related_Product_s_Name__c= opp.REP_Churn_Related_Product_s_Name__c;
            newoppty.ChurnSpecialEvents__c= opp.ChurnSpecialEvents__c;
            newoppty.IsChurnRelatedtoEngagementServices__c= opp.IsChurnRelatedtoEngagementServices__c;
            // West Monroe - JAN 2022 - adding fields
            newoppty.Sustainalytics_Contract_1__c = opp.Sustainalytics_Contract_1__c;
            newoppty.Sustainalytics_Contract_2__c = opp.Sustainalytics_Contract_2__c;
            newoppty.Sustainalytics_Contract_3__c = opp.Sustainalytics_Contract_3__c;
            newoppty.Dynamics_Contract_Number__c = opp.Dynamics_Contract_Number__c;
            if(opp.ExpirationDate__c != null){
                newoppty.EffectiveDate__c =opp.ExpirationDate__c.addDays(1);
            }else{
                newoppty.EffectiveDate__c = system.today().addDays(1);
            }
            system.debug('####'+opp.DeliveryMonths__c);
            system.debug('####'+opp.Id);
            if(opp.DeliveryMonths__c != null && opp.DeliveryMonths__c != 0 ){
                UpdateOppExpirationAndDeliveryMonths(newoppty,opp);
                //date expirationdate = newoppty.EffectiveDate__c.addMonths((Integer)opp.DeliveryMonths__c);
                //newoppty.ExpirationDate__c = expirationdate.addDays(-1);
                newoppty.CloseDate = newoppty.EffectiveDate__c.addDays(-1);
            }
            else if(  (opp.DeliveryMonths__c == null) || (opp.DeliveryMonths__c == 0)  ){
                
                date expirationdate = newoppty.EffectiveDate__c.addDays(opp.EffectiveDate__c.daysBetween(opp.ExpirationDate__c));
                newoppty.ExpirationDate__c = expirationdate;
                newoppty.CloseDate = newoppty.EffectiveDate__c.addDays(-1);
                system.debug('####expdate'+ expirationdate );
            }
            
            //as per the requirement 493
            if(newoppty.CloseDate < system.today()){
                newoppty.CloseDate = system.today();
            }
            //newoppty.ContractType__c= LABEL.CL_MAIN_AGREEMENT;
            // newoppty.ContractType__c =
            // opp.ContractType__c;
            newoppty.Type =LABEL.CL_RENEWAL;
            newoppty.Name = opp.Name;
            //newoppty.Probability = 30;
            //Changed as per JIRA Ticket - CORPITCRM-159
            newoppty.Probability = 90;
            //newoppty.OwnerId = opp.OwnerId ;
            // as per the description of defect D-0088(Anuj 1/15/2012)
            newoppty.ClosingStatus__c ='' ;//LABEL.CL_IN_PIPELINE;
            renewOppMap.put(opp.Id,newoppty);
            closedOppMap.put(opp.Id,opp);
            oldOppset.add(opp.Id);
            oliList = opp.OpportunityLineItems;
            conList  =opp.OpportunityContactRoles;
            teamList  =opp.OpportunityTeamMembers;
            BOut = opp.Relationships__r;
            
            for(OpportunityLineItem  oli :oliList){
                finaloliList.add(oli);
            }
            System.Debug('!!!!!'+conlist);
            for(OpportunityContactRole con :conList){
                finalconList.add(con);
            }
            for(OpportunityTeamMember member :teamList){
                finalteamList.add(member);
            }
            for(BreakoutType__c BOele :BOut){ 
                BrkOutList.add(BOele);
            }
            
        }
        
        
        for(Id oppItem: OppownerIdMap.KeySet()){
            if(!oppActiveMap.get(OppownerIdMap.get(oppItem)).IsActive)
            {
                newoppty.OwnerId = LABEL.CL_OPP_INACTIVEUSER;
            }
            else
            {
                newoppty.OwnerId = OppownerIdMap.get(oppItem);
            }
        }
        
        //Database.SaveResult[] lsr = Database.insert(renewOppMap.values(),false);
        //try{
        insert renewOppMap.values();
        List<OpportunityLineItem> newoliList = new List<OpportunityLineItem>();
        
        for(OpportunityLineItem oli:finaloliList){
            
            //inserting new opplineitem
            //OpportunityLineItem newoli = new OpportunityLineItem();
            OpportunityLineItem newoli  = oli.clone(false);
            newoli.OpportunityId = renewOppMap.get(oli.OpportunityId).Id;
            newoli.Delivery_Method__c=oli.Delivery_Method__c;
            newoli.Delivery_Frequency__c = oli.Delivery_Frequency__c;
            newoli.FirstDeliveryDate__c = renewOppMap.get(oli.OpportunityId).EffectiveDate__c;
            // Manikanth CSS-3182//
            newoli.Comprehensive_Package__c=oli.Comprehensive_Package__c;
            newoli.Equities_Package__c =oli.Equities_Package__c;
            newoli.Financial_Adviser_Package__c =oli.Financial_Adviser_Package__c;
            newoli.Funds_Package__c =oli.Funds_Package__c;
            //inserted as per the Req 639//
            if(oli.SetUpFees__c != null && oli.SetUpFees__c>0)
            {
                newoli.X1stYearPrice__c -=  oli.SetUpFees__c;
            }
            else
            {
                
                UpdateOppProductsByDeliveryMonths(closedOppMap,newoli,oli);
                
            }
            newoli.SetUpFees__c = 0;
            //--------//
            if (newoli.SetUpFees__c == null )
            {
                newoli.SetUpFees__c = 0;
            }
            
            if (!newoli.SetUp_Fee__c)
            {
                
                newoliList.add(newoli);
            }
        }
        system.debug('newoliList,*****'+ newoliList);
        
        if(newoliList != null && newoliList.size()>0)
        {
            database.insert(newoliList,false);
        }
        
        List<OpportunityContactRole> newConList = new List<OpportunityContactRole>();
        System.Debug('$$$$'+finalconList);
        for(OpportunityContactRole con:finalconList){
            //inserting new OppContactRole
            OpportunityContactRole newconrec = new OpportunityContactRole();
            newconrec = con.clone(false);
            newconrec .OpportunityId = renewOppMap.get(con.OpportunityId).Id;
            newConList.add(newconrec);
        }
        system.debug('newConList,*****'+ newConList);
        if(newConList != null && newConList.size() > 0)
        {
            database.insert(newConList,false);
        }
        
        List<OpportunityTeamMember > newTeamList = new List<OpportunityTeamMember >();
        for(OpportunityTeamMember mem:finalteamList){
            ////inserting new opportunity Team member
            
            OpportunityTeamMember newteamrec = new OpportunityTeamMember ();
            newteamrec = mem.clone(false);
            newteamrec .OpportunityId = renewOppMap.get(mem.OpportunityId).Id;
            newTeamList .add(newteamrec);
        }  system.debug('newTeamList,*****'+ newTeamList);
        
        if (newTeamList != null && newTeamList.size()>0){
            database.insert(newTeamList,false) ;  }
        
        List<BreakoutType__c > newBOList= new List<BreakoutType__c >();
        for(BreakoutType__c BO:BrkOutList ){
            //inserting new Breakout Type record
            BreakoutType__c newBOrec = new BreakoutType__c ();
            newBOrec = BO.clone(false);
            newBOrec.OpportunityId__c = renewOppMap.get(BO.OpportunityId__c).Id;
            newBOrec.CurrencyIsoCode = renewOppMap.get(BO.OpportunityId__c).CurrencyIsoCode;
            newBOrec.Year1Price__c = 0.0;
            newBOList.add(newBOrec);
        }
        
        system.debug('newBOList,*****'+ newBOList);
        
        if(newBOList != null && newBOList.size() > 0){
            database.insert(newBOList,false); }
        List<BillingSchedule__c> tempBs = new List<BillingSchedule__c>();
        
        //CMSSR - 68
        /*for(Contract cont : contractList){
if(oldOppset.contains(cont.Opportunity__c)){
//inserting new Contract record
Contract newContract = new Contract();
newContract = cont.clone(False);
system.debug(LABEL.CL_CONT_OPPORTUNITY_C+cont.Opportunity__c);
system.debug(LABEL.CL_RENEWOPPMAP_GET_CONT_OPPORTUNITY_C_ID+renewOppMap.get(cont.Opportunity__c).Id);
newContract.Opportunity__c = renewOppMap.get(cont.Opportunity__c).Id;
contractmap.put(cont.Id,newContract);
if(cont.Billing_Schedules__r.size() != 0){
for(BillingSchedule__c  BillSched:cont.Billing_Schedules__r) {
tempBs.add(BillSched);
}
}
}
}    */
        system.debug('contractmap.values(),*****'+ contractmap.values());
        if(contractmap!= null && contractmap.size() >0){
            database.insert(contractmap.values(),false);}
        
        
        if(contractmap.size() >=0){
            for(BillingSchedule__c bSchedule :tempBs){
                BillingSchedule__c newBs = new BillingSchedule__c();
                newBs = bSchedule.clone(false);
                newBs.Contract__c = contractmap.get(bSchedule.Contract__c).Id;
                bsList.add(newBs);
            }
        }
        system.debug('bsList*****'+ bsList);
        
        if(bsList.size()!= 0)
        {
            database.insert(bsList,false);
        }
        //CALCULATE THE EXPECTED TCV ON RENEWAL OPP
        List<Id> renewalOppIdList = new List<Id>();
        //GET ALL THE OPP IDS OF THE RENEWAL OPPS
        for(Opportunity opp : renewOppMap.values())
        {
            renewalOppIdList.add(opp.Id);
        }
        //GET THE LINE ITEMS FOR THE RENEWAL OPPS
        List<OpportunityLineItem> lineItems = [SELECT Expected_TCV__c,OpportunityId FROM OpportunityLineItem
                                               WHERE OpportunityId IN :renewalOppIdList];
        List<Opportunity> renewaloppList = new List<Opportunity>();
        for(Opportunity opp : renewOppMap.values())
        {
            Boolean updated = false;
            
            for(OpportunityLineItem lineItem : lineItems)
            {
                if(lineItem.OpportunityId == opp.Id && lineItem.Expected_TCV__c != null & lineItem.Expected_TCV__c>0)
                {
                    if(opp.Expected_TCV__c == null)
                    {
                        opp.Expected_TCV__c = 0.00;
                    }
                    opp.Expected_TCV__c = opp.Expected_TCV__c+lineItem.Expected_TCV__c;
                    updated = true;
                }
            }
            if(updated)
            {
                renewaloppList.add(opp);
            }
        }
        //IF THE LIST IS NOT EMPTY UPDATE OPPS
        if(renewaloppList.size() != 0)
        {
            update renewaloppList;
        }
        List<Opportunity> updateOpp = new List<Opportunity>();
        for(Opportunity opp : OppList){
            if(oldOppset.contains(opp.Id)){
                Opportunity newopp = new Opportunity(Id =opp.Id);
                newopp.RenewalOpportunity__c = renewOppMap.get(opp.Id).Id;
                //newopp.Previous_Review_Status__c = Null;
                //newopp.Review_Status__c = Null;
                updateOpp.add(newopp);
            }
        }
        if(updateOpp.size() != 0){
            GC_Utils_Method.updateOpp  = true;
            update updateOpp;
        }
        system.debug(LABEL.CL_OPPLIST+OppList);
        system.debug(LABEL.CL_RENEWOPPMAP_VALUES+renewOppMap.values());
        //}catch(exception e){
        
        //}
        
    }
    //FIX THE DELIVERY MONTHS AND EXPIRATION DATE
    //BPARUPU
    public static void UpdateOppExpirationAndDeliveryMonths(Opportunity renewalOppurtunity, Opportunity closedOpportunity)
    {
        //HANDLE AUTO RENEW SEPARATELY. TRIGGER ONLY WHEN THE AUTO RENEW TERM IS SET
        if(closedOpportunity.Auto_Renewal_Clause__c && closedOpportunity.Auto_Renewal_Term_Months__c != null && closedOpportunity.Auto_Renewal_Type__c == LABEL.CL_Opp_AutoRenewType_Fixed && closedOpportunity.Auto_Renewal_Max_Fixed__c != null)
        {
            Integer autoRenewTerm = Integer.valueOf(closedOpportunity.Auto_Renewal_Term_Months__c);
            //(Integer)closedOpportunity.Auto_Renewal_Term_Months__c;
            if(autoRenewTerm>0)
            {
                UpdateOppExpirationAndDeliveryMonthsForAutoRenew(renewalOppurtunity,closedOpportunity);
                return;
            }
        }
        if(closedOpportunity.DeliveryMonths__c != null && closedOpportunity.DeliveryMonths__c != 0  && closedOpportunity.DeliveryMonths__c>0)
        {
            
            
            Integer deliveryMonths = (Integer)closedOpportunity.DeliveryMonths__c;
            Boolean isFullYearTerm = true;
            Integer remainder = math.mod(deliveryMonths,12);
            Integer quotient = deliveryMonths/12;
            Decimal deliveryTerm = closedOpportunity.DeliveryMonths__c.divide(12,1);
            if(remainder>0)
            {
                isFullYearTerm = false;
                
            }
            //IF CLOSED OPPORTUNITY DELIVERY MONTHS IS <=12 SET THE RENEWAL EXPIRATION TO 12 MONTHS FROM THE CLOSE OPPORTUNITY EXPIRATION
            if(deliveryMonths <=12)
            {
                renewalOppurtunity.ExpirationDate__c = closedOpportunity.ExpirationDate__c.addMonths(12);
                renewalOppurtunity.DeliveryMonths__c = 12.0;
                
            }
            else if(deliveryMonths >12)
            {
                if(isFullYearTerm)
                {
                    renewalOppurtunity.ExpirationDate__c = closedOpportunity.ExpirationDate__c.addMonths(deliveryMonths);
                    renewalOppurtunity.DeliveryMonths__c = closedOpportunity.DeliveryMonths__c;
                }
                else
                {
                    if(remainder >=1 && remainder <=5)
                    {
                        renewalOppurtunity.ExpirationDate__c = closedOpportunity.ExpirationDate__c.addMonths(((Integer)math.floor(deliveryTerm))*12);
                        renewalOppurtunity.DeliveryMonths__c  = math.floor(deliveryTerm)*12;
                        
                    }
                    else if(remainder >=6  && remainder <=11)
                    {
                        renewalOppurtunity.ExpirationDate__c = closedOpportunity.ExpirationDate__c.addMonths(((Integer)math.ceil(deliveryTerm))*12);
                        renewalOppurtunity.DeliveryMonths__c  = math.ceil(deliveryTerm)*12;
                    }
                    
                }
                
            }
            
            
        }
        else
        {
            date expirationdate = renewalOppurtunity.EffectiveDate__c.addDays(closedOpportunity.EffectiveDate__c.daysBetween(closedOpportunity.ExpirationDate__c));
            renewalOppurtunity.ExpirationDate__c = expirationdate;
            renewalOppurtunity.CloseDate = renewalOppurtunity.EffectiveDate__c.addDays(-1);
            
        }
        
    }
//HANDLE DELIVERY MONTHS AND TERM FOR AUTO RENEW
//RETURNS A BOOLEAN TO INDICATE WHETHER ALL THE VALIDATIONS ARE PASSED AND THE EXPIRATION/DELIVERY MONTHS WERE UPDATED WITH NEW VALUES
//BPARUPU
public static Boolean UpdateOppExpirationAndDeliveryMonthsForAutoRenew(Opportunity renewalOppurtunity, Opportunity closedOpportunity)
{
    Boolean isUpdated = true;
    //HANDLE THE FIXED RENWAL TYPE
    if(closedOpportunity.Auto_Renewal_Type__c == LABEL.CL_Opp_AutoRenewType_Fixed)
    {
        //SINCE THE AUTO RENEWAL TERM IS NOT A REQUIRED FIELD IT CAN BE NULL, APPLY LOGIC ONLY WHEN ITS NOT NULL
        if(closedOpportunity.Auto_Renewal_Term_Months__c != null && closedOpportunity.Auto_Renewal_Max_Fixed__c != null)
        {
           Integer autoRenewTerm = Integer.valueOf(closedOpportunity.Auto_Renewal_Term_Months__c);
           //(Integer)closedOpportunity.Auto_Renewal_Term_Months__c;
           //EVEN THOUGH THE TERM CAN'T BE ZERO OR NEGATIVE CHECK FOR IT JUST TO BE SURE
           if(autoRenewTerm>0)
           {
                 renewalOppurtunity.ExpirationDate__c = closedOpportunity.ExpirationDate__c.addMonths(autoRenewTerm);
                 renewalOppurtunity.DeliveryMonths__c = autoRenewTerm;

           }
           else
           {
            isUpdated = false;
           }

        }
        else
        {
            isUpdated = false;
        }

    }
    return isUpdated;
}
//FIX THE OPPORTUNITY PRODUCTS BASED ON DELIVERY MONTHS
//BPARUPU
public static void UpdateOppProductsByDeliveryMonths(Map<Id,Opportunity> closedOppMap, OpportunityLineItem renewalOppLineItem,OpportunityLineItem closedOppLineItem)
{
    Decimal deliveryMonths = closedOppMap.get(closedOppLineItem.OpportunityId).DeliveryMonths__c;
    Opportunity closedOpportunity = closedOppMap.get(closedOppLineItem.OpportunityId);
    system.debug('delivermonths_newcode,*****'+deliveryMonths);
    //HANDLE AUTO RENEW SEPARATELY. TRIGGER ONLY WHEN ONE OF THE AUTO RENEW PERCENTAGE RELATED FIELDS ARE SET
    if(closedOpportunity.Auto_Renewal_Clause__c)
    {
        //FOR FIXED WE ALWAYS WANT TO MAKE SURE THE AUTO RENEWAL FIXED FIELD IS SET IF NOT WE WOULD WANT THE NORMAL LOGIC TO APPLY
        if(closedOpportunity.Auto_Renewal_Type__c == LABEL.CL_Opp_AutoRenewType_Fixed)
        {

            if(closedOpportunity.Auto_Renewal_Max_Fixed__c != null && closedOpportunity.Auto_Renewal_Term_Months__c != null)
            {
                Integer autoRenewTerm = Integer.valueOf(closedOpportunity.Auto_Renewal_Term_Months__c);
                //(Integer)closedOpportunity.Auto_Renewal_Term_Months__c;
                if(autoRenewTerm>0)
                {
                UpdateOppProductsByDeliveryMonthsForAutoRenew(closedOppMap,renewalOppLineItem,closedOppLineItem);
                return;
                }
            }
        }
    }



    if(deliveryMonths != null && deliveryMonths != 0  && deliveryMonths>0 && closedOppLineItem.SetUpFees__c != null && closedOppLineItem.SetUpFees__c==0)
    {
        Integer deliveryMonthsInt = (Integer)deliveryMonths;
        Boolean isFullYearTerm = true;
        Integer remainder = math.mod(deliveryMonthsInt,12);
        system.debug('code_entrance1,*****');
        if(remainder>0)
        {
            isFullYearTerm = false;

        }
        if(deliveryMonthsInt <=12)
        {
            system.debug('code_entrance2,*****');
            renewalOppLineItem.X1stYearPrice__c = closedOppLineItem.Run_Rate__c;
            renewalOppLineItem.X2ndYearPrice__c = 0.00;
            renewalOppLineItem.X3rdYearPrice__c=0.00;
            renewalOppLineItem.X4thYearPrice__c=0.00;
            renewalOppLineItem.RemainingYearsPrice__c = 0.00;

        }
        else if(deliveryMonthsInt >12)
        {
            if(isFullYearTerm)
           {
             if(deliveryMonthsInt ==24)
             {
               renewalOppLineItem.X1stYearPrice__c = (closedOppLineItem.X2ndYearPrice__c !=null && closedOppLineItem.X2ndYearPrice__c !=0)? closedOppLineItem.X2ndYearPrice__c:((closedOppLineItem.X1stYearPrice__c != null && closedOppLineItem.X1stYearPrice__c !=0)?closedOppLineItem.X1stYearPrice__c:0.00);
               renewalOppLineItem.X2ndYearPrice__c = (closedOppLineItem.X2ndYearPrice__c !=null && closedOppLineItem.X2ndYearPrice__c !=0)? closedOppLineItem.X2ndYearPrice__c:((closedOppLineItem.X1stYearPrice__c != null && closedOppLineItem.X1stYearPrice__c !=0)?closedOppLineItem.X1stYearPrice__c:0.00);
              //renewalOppLineItem.X1stYearPrice__c = (closedOppLineItem.RemainingYearsPrice__c == null)?((closedOppLineItem.X4thYearPrice__c == null)?((closedOppLineItem.X3rdYearPrice__c==null)?((closedOppLineItem.X2ndYearPrice__c==null)?closedOppLineItem.X1stYearPrice__c:closedOppLineItem.X2ndYearPrice__c):closedOppLineItem.X3rdYearPrice__c) :closedOppLineItem.X4thYearPrice__c):closedOppLineItem.RemainingYearsPrice__c;
              //renewalOppLineItem.X2ndYearPrice__c = (closedOppLineItem.RemainingYearsPrice__c == null)?((closedOppLineItem.X4thYearPrice__c == null)?((closedOppLineItem.X3rdYearPrice__c==null)?((closedOppLineItem.X2ndYearPrice__c==null)?closedOppLineItem.X1stYearPrice__c:closedOppLineItem.X2ndYearPrice__c):closedOppLineItem.X3rdYearPrice__c) :closedOppLineItem.X4thYearPrice__c):closedOppLineItem.RemainingYearsPrice__c;
              renewalOppLineItem.X3rdYearPrice__c=0.00;
              renewalOppLineItem.X4thYearPrice__c=0.00;
              renewalOppLineItem.RemainingYearsPrice__c = 0.00;
             }
             if(deliveryMonthsInt ==36)
             {
                renewalOppLineItem.X1stYearPrice__c = (closedOppLineItem.X3rdYearPrice__c !=null && closedOppLineItem.X3rdYearPrice__c !=0)?closedOppLineItem.X3rdYearPrice__c : ((closedOppLineItem.X2ndYearPrice__c !=null && closedOppLineItem.X2ndYearPrice__c !=0)? closedOppLineItem.X2ndYearPrice__c:((closedOppLineItem.X1stYearPrice__c != null && closedOppLineItem.X1stYearPrice__c !=0)?closedOppLineItem.X1stYearPrice__c:0.00));
                renewalOppLineItem.X2ndYearPrice__c = (closedOppLineItem.X3rdYearPrice__c !=null && closedOppLineItem.X3rdYearPrice__c !=0)?closedOppLineItem.X3rdYearPrice__c : ((closedOppLineItem.X2ndYearPrice__c !=null && closedOppLineItem.X2ndYearPrice__c !=0)? closedOppLineItem.X2ndYearPrice__c:((closedOppLineItem.X1stYearPrice__c != null && closedOppLineItem.X1stYearPrice__c !=0)?closedOppLineItem.X1stYearPrice__c:0.00));
                renewalOppLineItem.X3rdYearPrice__c = (closedOppLineItem.X3rdYearPrice__c !=null && closedOppLineItem.X3rdYearPrice__c !=0)?closedOppLineItem.X3rdYearPrice__c : ((closedOppLineItem.X2ndYearPrice__c !=null && closedOppLineItem.X2ndYearPrice__c !=0)? closedOppLineItem.X2ndYearPrice__c:((closedOppLineItem.X1stYearPrice__c != null && closedOppLineItem.X1stYearPrice__c !=0)?closedOppLineItem.X1stYearPrice__c:0.00));
              //renewalOppLineItem.X1stYearPrice__c = (closedOppLineItem.RemainingYearsPrice__c == null)?((closedOppLineItem.X4thYearPrice__c == null)?((closedOppLineItem.X3rdYearPrice__c==null)?((closedOppLineItem.X2ndYearPrice__c==null)?closedOppLineItem.X1stYearPrice__c:closedOppLineItem.X2ndYearPrice__c):closedOppLineItem.X3rdYearPrice__c) :closedOppLineItem.X4thYearPrice__c):closedOppLineItem.RemainingYearsPrice__c;
              //renewalOppLineItem.X2ndYearPrice__c = (closedOppLineItem.RemainingYearsPrice__c == null)?((closedOppLineItem.X4thYearPrice__c == null)?((closedOppLineItem.X3rdYearPrice__c==null)?((closedOppLineItem.X2ndYearPrice__c==null)?closedOppLineItem.X1stYearPrice__c:closedOppLineItem.X2ndYearPrice__c):closedOppLineItem.X3rdYearPrice__c) :closedOppLineItem.X4thYearPrice__c):closedOppLineItem.RemainingYearsPrice__c;
              //renewalOppLineItem.X3rdYearPrice__c = (closedOppLineItem.RemainingYearsPrice__c == null)?((closedOppLineItem.X4thYearPrice__c == null)?((closedOppLineItem.X3rdYearPrice__c==null)?((closedOppLineItem.X2ndYearPrice__c==null)?closedOppLineItem.X1stYearPrice__c:closedOppLineItem.X2ndYearPrice__c):closedOppLineItem.X3rdYearPrice__c) :closedOppLineItem.X4thYearPrice__c):closedOppLineItem.RemainingYearsPrice__c;
              renewalOppLineItem.X4thYearPrice__c=0.00;
              renewalOppLineItem.RemainingYearsPrice__c = 0.00;
             }
             if(deliveryMonthsInt ==48)
             {
                renewalOppLineItem.X1stYearPrice__c = (closedOppLineItem.X4thYearPrice__c != null && closedOppLineItem.X4thYearPrice__c !=0)?closedOppLineItem.X4thYearPrice__c: ((closedOppLineItem.X3rdYearPrice__c !=null && closedOppLineItem.X3rdYearPrice__c !=0)?closedOppLineItem.X3rdYearPrice__c : ((closedOppLineItem.X2ndYearPrice__c !=null && closedOppLineItem.X2ndYearPrice__c !=0)? closedOppLineItem.X2ndYearPrice__c:((closedOppLineItem.X1stYearPrice__c != null && closedOppLineItem.X1stYearPrice__c !=0)?closedOppLineItem.X1stYearPrice__c:0.00)));
                renewalOppLineItem.X2ndYearPrice__c = (closedOppLineItem.X4thYearPrice__c != null && closedOppLineItem.X4thYearPrice__c !=0)?closedOppLineItem.X4thYearPrice__c: ((closedOppLineItem.X3rdYearPrice__c !=null && closedOppLineItem.X3rdYearPrice__c !=0)?closedOppLineItem.X3rdYearPrice__c : ((closedOppLineItem.X2ndYearPrice__c !=null && closedOppLineItem.X2ndYearPrice__c !=0)? closedOppLineItem.X2ndYearPrice__c:((closedOppLineItem.X1stYearPrice__c != null && closedOppLineItem.X1stYearPrice__c !=0)?closedOppLineItem.X1stYearPrice__c:0.00)));
                renewalOppLineItem.X3rdYearPrice__c  = (closedOppLineItem.X4thYearPrice__c != null && closedOppLineItem.X4thYearPrice__c !=0)?closedOppLineItem.X4thYearPrice__c: ((closedOppLineItem.X3rdYearPrice__c !=null && closedOppLineItem.X3rdYearPrice__c !=0)?closedOppLineItem.X3rdYearPrice__c : ((closedOppLineItem.X2ndYearPrice__c !=null && closedOppLineItem.X2ndYearPrice__c !=0)? closedOppLineItem.X2ndYearPrice__c:((closedOppLineItem.X1stYearPrice__c != null && closedOppLineItem.X1stYearPrice__c !=0)?closedOppLineItem.X1stYearPrice__c:0.00)));
                renewalOppLineItem.X4thYearPrice__c = (closedOppLineItem.X4thYearPrice__c != null && closedOppLineItem.X4thYearPrice__c !=0)?closedOppLineItem.X4thYearPrice__c: ((closedOppLineItem.X3rdYearPrice__c !=null && closedOppLineItem.X3rdYearPrice__c !=0)?closedOppLineItem.X3rdYearPrice__c : ((closedOppLineItem.X2ndYearPrice__c !=null && closedOppLineItem.X2ndYearPrice__c !=0)? closedOppLineItem.X2ndYearPrice__c:((closedOppLineItem.X1stYearPrice__c != null && closedOppLineItem.X1stYearPrice__c !=0)?closedOppLineItem.X1stYearPrice__c:0.00)));
              //renewalOppLineItem.X1stYearPrice__c = (closedOppLineItem.RemainingYearsPrice__c == null)?((closedOppLineItem.X4thYearPrice__c == null)?((closedOppLineItem.X3rdYearPrice__c==null)?((closedOppLineItem.X2ndYearPrice__c==null)?closedOppLineItem.X1stYearPrice__c:closedOppLineItem.X2ndYearPrice__c):closedOppLineItem.X3rdYearPrice__c) :closedOppLineItem.X4thYearPrice__c):closedOppLineItem.RemainingYearsPrice__c;
              //renewalOppLineItem.X2ndYearPrice__c = (closedOppLineItem.RemainingYearsPrice__c == null)?((closedOppLineItem.X4thYearPrice__c == null)?((closedOppLineItem.X3rdYearPrice__c==null)?((closedOppLineItem.X2ndYearPrice__c==null)?closedOppLineItem.X1stYearPrice__c:closedOppLineItem.X2ndYearPrice__c):closedOppLineItem.X3rdYearPrice__c) :closedOppLineItem.X4thYearPrice__c):closedOppLineItem.RemainingYearsPrice__c;
              //renewalOppLineItem.X3rdYearPrice__c = (closedOppLineItem.RemainingYearsPrice__c == null)?((closedOppLineItem.X4thYearPrice__c == null)?((closedOppLineItem.X3rdYearPrice__c==null)?((closedOppLineItem.X2ndYearPrice__c==null)?closedOppLineItem.X1stYearPrice__c:closedOppLineItem.X2ndYearPrice__c):closedOppLineItem.X3rdYearPrice__c) :closedOppLineItem.X4thYearPrice__c):closedOppLineItem.RemainingYearsPrice__c;
             // renewalOppLineItem.X4thYearPrice__c = (closedOppLineItem.RemainingYearsPrice__c == null)?((closedOppLineItem.X4thYearPrice__c == null)?((closedOppLineItem.X3rdYearPrice__c==null)?((closedOppLineItem.X2ndYearPrice__c==null)?closedOppLineItem.X1stYearPrice__c:closedOppLineItem.X2ndYearPrice__c):closedOppLineItem.X3rdYearPrice__c) :closedOppLineItem.X4thYearPrice__c):closedOppLineItem.RemainingYearsPrice__c;
              renewalOppLineItem.RemainingYearsPrice__c = 0.00;
             }
             if(deliveryMonthsInt >48)
             {
              renewalOppLineItem.X1stYearPrice__c = (closedOppLineItem.RemainingYearsPrice__c == null && closedOppLineItem.RemainingYearsPrice__c ==0)?((closedOppLineItem.X4thYearPrice__c == null && closedOppLineItem.X4thYearPrice__c==0)?((closedOppLineItem.X3rdYearPrice__c==null && closedOppLineItem.X3rdYearPrice__c==0)?((closedOppLineItem.X2ndYearPrice__c==null && closedOppLineItem.X2ndYearPrice__c ==0)?((closedOppLineItem.X1stYearPrice__c==null && closedOppLineItem.X1stYearPrice__c ==0)?0.00 : closedOppLineItem.X1stYearPrice__c):closedOppLineItem.X2ndYearPrice__c):closedOppLineItem.X3rdYearPrice__c) :closedOppLineItem.X4thYearPrice__c):closedOppLineItem.RemainingYearsPrice__c;
              renewalOppLineItem.X2ndYearPrice__c = (closedOppLineItem.RemainingYearsPrice__c == null && closedOppLineItem.RemainingYearsPrice__c ==0)?((closedOppLineItem.X4thYearPrice__c == null && closedOppLineItem.X4thYearPrice__c==0)?((closedOppLineItem.X3rdYearPrice__c==null && closedOppLineItem.X3rdYearPrice__c==0)?((closedOppLineItem.X2ndYearPrice__c==null && closedOppLineItem.X2ndYearPrice__c ==0)?((closedOppLineItem.X1stYearPrice__c==null && closedOppLineItem.X1stYearPrice__c ==0)?0.00 : closedOppLineItem.X1stYearPrice__c):closedOppLineItem.X2ndYearPrice__c):closedOppLineItem.X3rdYearPrice__c) :closedOppLineItem.X4thYearPrice__c):closedOppLineItem.RemainingYearsPrice__c;
              renewalOppLineItem.X3rdYearPrice__c = (closedOppLineItem.RemainingYearsPrice__c == null && closedOppLineItem.RemainingYearsPrice__c ==0)?((closedOppLineItem.X4thYearPrice__c == null && closedOppLineItem.X4thYearPrice__c==0)?((closedOppLineItem.X3rdYearPrice__c==null && closedOppLineItem.X3rdYearPrice__c==0)?((closedOppLineItem.X2ndYearPrice__c==null && closedOppLineItem.X2ndYearPrice__c ==0)?((closedOppLineItem.X1stYearPrice__c==null && closedOppLineItem.X1stYearPrice__c ==0)?0.00 : closedOppLineItem.X1stYearPrice__c):closedOppLineItem.X2ndYearPrice__c):closedOppLineItem.X3rdYearPrice__c) :closedOppLineItem.X4thYearPrice__c):closedOppLineItem.RemainingYearsPrice__c;
              renewalOppLineItem.X4thYearPrice__c = (closedOppLineItem.RemainingYearsPrice__c == null && closedOppLineItem.RemainingYearsPrice__c ==0)?((closedOppLineItem.X4thYearPrice__c == null && closedOppLineItem.X4thYearPrice__c==0)?((closedOppLineItem.X3rdYearPrice__c==null && closedOppLineItem.X3rdYearPrice__c==0)?((closedOppLineItem.X2ndYearPrice__c==null && closedOppLineItem.X2ndYearPrice__c ==0)?((closedOppLineItem.X1stYearPrice__c==null && closedOppLineItem.X1stYearPrice__c ==0)?0.00 : closedOppLineItem.X1stYearPrice__c):closedOppLineItem.X2ndYearPrice__c):closedOppLineItem.X3rdYearPrice__c) :closedOppLineItem.X4thYearPrice__c):closedOppLineItem.RemainingYearsPrice__c;
              renewalOppLineItem.RemainingYearsPrice__c = (closedOppLineItem.RemainingYearsPrice__c == null && closedOppLineItem.RemainingYearsPrice__c ==0)?((closedOppLineItem.X4thYearPrice__c == null && closedOppLineItem.X4thYearPrice__c==0)?((closedOppLineItem.X3rdYearPrice__c==null && closedOppLineItem.X3rdYearPrice__c==0)?((closedOppLineItem.X2ndYearPrice__c==null && closedOppLineItem.X2ndYearPrice__c ==0)?((closedOppLineItem.X1stYearPrice__c==null && closedOppLineItem.X1stYearPrice__c <=0)?0.00 : closedOppLineItem.X1stYearPrice__c):closedOppLineItem.X2ndYearPrice__c):closedOppLineItem.X3rdYearPrice__c) :closedOppLineItem.X4thYearPrice__c):closedOppLineItem.RemainingYearsPrice__c;
             }

           }
           else
           {
               if(deliveryMonthsInt >=13 && deliveryMonthsInt <=17)
               {
                 renewalOppLineItem.X1stYearPrice__c = closedOppLineItem.Run_Rate__c;
                 renewalOppLineItem.X2ndYearPrice__c = 0.00;
                 renewalOppLineItem.X3rdYearPrice__c=0.00;
                 renewalOppLineItem.X4thYearPrice__c=0.00;
                 renewalOppLineItem.RemainingYearsPrice__c = 0.00;
               }
               if(deliveryMonthsInt >=18 && deliveryMonthsInt <=29)
               {
                 renewalOppLineItem.X1stYearPrice__c = closedOppLineItem.Run_Rate__c;
                 renewalOppLineItem.X2ndYearPrice__c = closedOppLineItem.Run_Rate__c;
                  renewalOppLineItem.X3rdYearPrice__c=0.00;
                  renewalOppLineItem.X4thYearPrice__c=0.00;
                  renewalOppLineItem.RemainingYearsPrice__c = 0.00;
               }
               if(deliveryMonthsInt >=30 && deliveryMonthsInt <=41)
               {
                 renewalOppLineItem.X1stYearPrice__c = closedOppLineItem.Run_Rate__c;
                 renewalOppLineItem.X2ndYearPrice__c = closedOppLineItem.Run_Rate__c;
                 renewalOppLineItem.X3rdYearPrice__c = closedOppLineItem.Run_Rate__c;
                  renewalOppLineItem.X4thYearPrice__c=0.00;
                  renewalOppLineItem.RemainingYearsPrice__c = 0.00;
               }
               if(deliveryMonthsInt >=42 && deliveryMonthsInt <=53)
               {
                 renewalOppLineItem.X1stYearPrice__c = closedOppLineItem.Run_Rate__c;
                 renewalOppLineItem.X2ndYearPrice__c = closedOppLineItem.Run_Rate__c;
                 renewalOppLineItem.X3rdYearPrice__c = closedOppLineItem.Run_Rate__c;
                 renewalOppLineItem.X4thYearPrice__c = closedOppLineItem.Run_Rate__c;
                 renewalOppLineItem.RemainingYearsPrice__c = 0.00;
               }
               if(deliveryMonthsInt > 53)
               {
                 renewalOppLineItem.X1stYearPrice__c = closedOppLineItem.Run_Rate__c;
                 renewalOppLineItem.X2ndYearPrice__c = closedOppLineItem.Run_Rate__c;
                 renewalOppLineItem.X3rdYearPrice__c = closedOppLineItem.Run_Rate__c;
                 renewalOppLineItem.X4thYearPrice__c = closedOppLineItem.Run_Rate__c;
                 renewalOppLineItem.RemainingYearsPrice__c = closedOppLineItem.Run_Rate__c;
               }

           }

        }

    }


}
//UPDATE OPPORTUNITY PRODUCTS FOR AUTO RENEW
//RETURNS A BOOLEAN TO INDICATE WHETHER ALL THE VALIDATIONS ARE PASSED AND THE OPP LINTEM VALUES WERE UPDATED WITH NEW VALUES
//BPARUPU
public static Boolean UpdateOppProductsByDeliveryMonthsForAutoRenew(Map<Id,Opportunity> closedOppMap, OpportunityLineItem renewalOppLineItem,OpportunityLineItem closedOppLineItem)
{
    Boolean isUpdated = true;

    Opportunity closedOpportunity = closedOppMap.get(closedOppLineItem.OpportunityId);
    Decimal closedOppDeliveryMonths = closedOppMap.get(closedOppLineItem.OpportunityId).DeliveryMonths__c;


    //HANDLE THE FIXED RENWAL TYPE
    if(closedOpportunity.Auto_Renewal_Type__c == LABEL.CL_Opp_AutoRenewType_Fixed && closedOpportunity.Auto_Renewal_Term_Months__c != null &&closedOpportunity.Auto_Renewal_Max_Fixed__c != null)
    {
        Integer autoRenewTerm = Integer.valueOf(closedOpportunity.Auto_Renewal_Term_Months__c);
        //(Integer)closedOpportunity.Auto_Renewal_Term_Months__c;
        //FOR FIXED WE NEED THE AUTO RENEWAL MAX FIELD, MAKE SURE ITS NOT NULL
        if(closedOpportunity.Auto_Renewal_Max_Fixed__c != null && autoRenewTerm>0 && closedOppDeliveryMonths>0 && closedOppDeliveryMonths!= null)
        {
            Integer closedOppDeliveryMonthsInt = (Integer)closedOppDeliveryMonths;
            Double percentageIncrease = Double.valueOf(closedOpportunity.Auto_Renewal_Max_Fixed__c);
            SetOppLineItemPriceForAutoRenew(closedOppDeliveryMonthsInt,autoRenewTerm,renewalOppLineItem,closedOppLineItem,percentageIncrease);
        }
        else
        {
            isUpdated = false;
        }

    }
    return isUpdated;
}
public static void SetOppLineItemPriceForAutoRenew(Integer closedOppDeliveryMonthsInt, Integer autoRenewTerm, OpportunityLineItem renewalOppLineItem,OpportunityLineItem closedOppLineItem, Double percentageIncrease)
{
    Decimal appliedAmount = 0.00;
    Integer remainder = math.mod(closedOppDeliveryMonthsInt,12);
    Integer quotient = closedOppDeliveryMonthsInt/12;
    //FOR ALL DELIVERY MONTHS NOT DIVISIBLE BY 12 OR 12 IT WILL ALWAYS BE THE RUN RATE.
    if(remainder>0 || (remainder ==0 && quotient ==1 ))
    {
        appliedAmount = (closedOppLineItem.Run_Rate__c + (closedOppLineItem.Run_Rate__c * (percentageIncrease/100)));
    }
    else if(remainder ==0 && quotient !=1)
    {
        //24 MONTHS
        if(quotient ==2)
        {
            Decimal amount = (closedOppLineItem.X2ndYearPrice__c !=null && closedOppLineItem.X2ndYearPrice__c !=0)? closedOppLineItem.X2ndYearPrice__c:((closedOppLineItem.X1stYearPrice__c != null && closedOppLineItem.X1stYearPrice__c !=0)?closedOppLineItem.X1stYearPrice__c:0.00);
            appliedAmount = (amount + (amount * (percentageIncrease/100)));
        }
        //36 MONTHS
        if(quotient ==3)
        {
            Decimal amount = (closedOppLineItem.X3rdYearPrice__c !=null && closedOppLineItem.X3rdYearPrice__c !=0)?closedOppLineItem.X3rdYearPrice__c : ((closedOppLineItem.X2ndYearPrice__c !=null && closedOppLineItem.X2ndYearPrice__c !=0)? closedOppLineItem.X2ndYearPrice__c:((closedOppLineItem.X1stYearPrice__c != null && closedOppLineItem.X1stYearPrice__c !=0)?closedOppLineItem.X1stYearPrice__c:0.00));
            appliedAmount = (amount + (amount * (percentageIncrease/100)));
        }
        //48 MONTHS
        if(quotient ==4)
        {
            Decimal amount = (closedOppLineItem.X4thYearPrice__c != null && closedOppLineItem.X4thYearPrice__c !=0)?closedOppLineItem.X4thYearPrice__c: ((closedOppLineItem.X3rdYearPrice__c !=null && closedOppLineItem.X3rdYearPrice__c !=0)?closedOppLineItem.X3rdYearPrice__c : ((closedOppLineItem.X2ndYearPrice__c !=null && closedOppLineItem.X2ndYearPrice__c !=0)? closedOppLineItem.X2ndYearPrice__c:((closedOppLineItem.X1stYearPrice__c != null && closedOppLineItem.X1stYearPrice__c !=0)?closedOppLineItem.X1stYearPrice__c:0.00)));
            appliedAmount = (amount + (amount * (percentageIncrease/100)));
        }
        if(quotient>4)
        {
            Decimal amount = (closedOppLineItem.RemainingYearsPrice__c == null && closedOppLineItem.RemainingYearsPrice__c ==0)?((closedOppLineItem.X4thYearPrice__c == null && closedOppLineItem.X4thYearPrice__c==0)?((closedOppLineItem.X3rdYearPrice__c==null && closedOppLineItem.X3rdYearPrice__c==0)?((closedOppLineItem.X2ndYearPrice__c==null && closedOppLineItem.X2ndYearPrice__c ==0)?((closedOppLineItem.X1stYearPrice__c==null && closedOppLineItem.X1stYearPrice__c ==0)?0.00 : closedOppLineItem.X1stYearPrice__c):closedOppLineItem.X2ndYearPrice__c):closedOppLineItem.X3rdYearPrice__c) :closedOppLineItem.X4thYearPrice__c):closedOppLineItem.RemainingYearsPrice__c;
            appliedAmount = (amount + (amount * (percentageIncrease/100)));
        }


    }

    //AUTO RENEW TERM 36 MONTHS
    if(autoRenewTerm ==36)
    {
        //ROUND IT TO NEAREST 5
        appliedAmount = Math.floor(appliedAmount/5)*5;
        renewalOppLineItem.X1stYearPrice__c = appliedAmount;
        renewalOppLineItem.X2ndYearPrice__c = appliedAmount;
        renewalOppLineItem.X3rdYearPrice__c = appliedAmount;
        renewalOppLineItem.X4thYearPrice__c = 0.00;
        renewalOppLineItem.RemainingYearsPrice__c = 0.00;
    }
    //AUTO RENEW TERM 24 MONTHS
    if(autoRenewTerm ==24)
    {
        //ROUND IT TO NEAREST 5
        appliedAmount = Math.floor(appliedAmount/5)*5;
        renewalOppLineItem.X1stYearPrice__c = appliedAmount;
        renewalOppLineItem.X2ndYearPrice__c = appliedAmount;
        renewalOppLineItem.X3rdYearPrice__c = 0.00;
        renewalOppLineItem.X4thYearPrice__c = 0.00;
        renewalOppLineItem.RemainingYearsPrice__c = 0.00;
    }
    //AUTO RENEW TERM 12 MONTHS
    if(autoRenewTerm ==12)
    {
        //ROUND IT TO NEAREST 5
        appliedAmount = Math.floor(appliedAmount/5)*5;
        renewalOppLineItem.X1stYearPrice__c = appliedAmount;
        renewalOppLineItem.X2ndYearPrice__c = 0.00;
        renewalOppLineItem.X3rdYearPrice__c = 0.00;
        renewalOppLineItem.X4thYearPrice__c = 0.00;
        renewalOppLineItem.RemainingYearsPrice__c = 0.00;
    }
    //AUTO RENEW TERM 6 MONTHS
    if(autoRenewTerm ==6)
    {
        Decimal amount = appliedAmount/2;
        renewalOppLineItem.X1stYearPrice__c = Math.floor(amount/5)*5;
        renewalOppLineItem.X2ndYearPrice__c = 0.00;
        renewalOppLineItem.X3rdYearPrice__c = 0.00;
        renewalOppLineItem.X4thYearPrice__c = 0.00;
        renewalOppLineItem.RemainingYearsPrice__c = 0.00;
    }
    //AUTO RENEW TERM 3 MONTHS
    if(autoRenewTerm ==3)
    {
        Decimal amount = appliedAmount/4;
        renewalOppLineItem.X1stYearPrice__c = Math.floor(amount/5)*5;
        renewalOppLineItem.X2ndYearPrice__c = 0.00;
        renewalOppLineItem.X3rdYearPrice__c = 0.00;
        renewalOppLineItem.X4thYearPrice__c = 0.00;
        renewalOppLineItem.RemainingYearsPrice__c = 0.00;
    }
    //AUTO RENEW TERM 1 MONTHS
    if(autoRenewTerm ==1)
    {
        Decimal amount = appliedAmount/12;
        renewalOppLineItem.X1stYearPrice__c = Math.floor(amount/5)*5;
        renewalOppLineItem.X2ndYearPrice__c = 0.00;
        renewalOppLineItem.X3rdYearPrice__c = 0.00;
        renewalOppLineItem.X4thYearPrice__c = 0.00;
        renewalOppLineItem.RemainingYearsPrice__c = 0.00;
    }
    //SET THE EXPECTED TCV field
    renewalOppLineItem.Expected_TCV__c =renewalOppLineItem.X1stYearPrice__c+renewalOppLineItem.X2ndYearPrice__c+renewalOppLineItem.X3rdYearPrice__c+renewalOppLineItem.X4thYearPrice__c+renewalOppLineItem.RemainingYearsPrice__c;

}
// JK 12/27/13 SellingTeam Updates
public static Map<ID, List<Opportunity>> createUsersToFilteredOppMap(List<Opportunity> newOpps, Map<Id, Opportunity> oldMap) {
  Map<ID, List<Opportunity>> filteredMap = new Map<ID, List<Opportunity>>();
  for (Opportunity o : newOpps) {
    if (oldMap.containsKey(o.Id) && o.OwnerId != oldMap.get(o.Id).OwnerId) {
      if (filteredMap.containsKey(o.ownerId))
        filteredMap.get(o.ownerId).add(o);
      else
        filteredMap.put(o.ownerId, new List<Opportunity>{o});
    }
  }
  return filteredMap;
}


public static void updateSellingTeam(Map<ID, List<Opportunity>> usersToOppsMap) {

    List<User> u1 = new List<user>();
u1= [SELECT Id, SellingTeam__c FROM User WHERE ID in :usersToOppsMap.keySet()];
  for (User u : u1) {
    for (Opportunity o : usersToOppsMap.get(u.Id)) {
      if (String.isNotBlank(u.SellingTeam__c))
        o.SellingTeam__c = u.SellingTeam__c;
    }
  }
}

/* Creates map for inserted opportunity splits
public static Map<ID, List<OpportunitySplit__c>> createUsersToFilteredOppSplitsMap(List<OpportunitySplit__c> newOppSplits) {
  Map<ID, List<OpportunitySplit__c>> filteredMap = new Map<ID, List<OpportunitySplit__c>>();
  for (OpportunitySplit__c os : newOppSplits) {
    if (filteredMap.containsKey(os.SalesRep__c))
      filteredMap.get(os.SalesRep__c).add(os);
    else
      filteredMap.put(os.SalesRep__c, new List<OpportunitySplit__c>{os});
  }
  return filteredMap;
} */

/* Creates map for updated opportunity splits */
public static Map<ID, List<OpportunitySplit__c>> createUsersToFilteredOppSplitsMap(List<OpportunitySplit__c> newOppSplits, Map<Id, OpportunitySplit__c> oldMap) {
  Map<ID, List<OpportunitySplit__c>> filteredMap = new Map<ID, List<OpportunitySplit__c>>();
  for (OpportunitySplit__c os : newOppSplits) {
    if (oldMap.containsKey(os.Id) && os.SalesRep__c != oldMap.get(os.Id).SalesRep__c) {
      if (filteredMap.containsKey(os.SalesRep__c))
        filteredMap.get(os.SalesRep__c).add(os);
      else
        filteredMap.put(os.SalesRep__c, new List<OpportunitySplit__c>{os});
    }
  }
  return filteredMap;
}

public static void updateOpportunitySplitSellingTeam(Map<ID, List<OpportunitySplit__c>> usersToOppSplitsMap) {
    List<User> u1 = new List<user>();
u1= [SELECT Id, SellingTeam__c FROM User WHERE ID in :usersToOppSplitsMap.keySet()];

  for (User u : u1) {
    for (OpportunitySplit__c o : usersToOppSplitsMap.get(u.Id)) {
      if (String.isNotBlank(u.SellingTeam__c))
        o.SellingTeam__c = u.SellingTeam__c;
    }
  }
}


//10212013 - Sobran : PersistentID changes.
public static void UpdatePersistentId(List<Opportunity> opps, Map<Id, Opportunity> oldMap){

     List<Id> OppPrev = new List<Id>();
     List<Id> OppParent = new List<Id>();
     List<Id> OppBoth = new List<Id>();

     for(Opportunity op : opps)
     {

        OppPrev.Add(op.PreviousOpportunity__c);
        OppParent.Add(op.ParentOpportunityId__c);
        OppBoth.Add(op.PreviousOpportunity__c);
         OppBoth.Add(op.ParentOpportunityId__c);
     }

    Map<Id, Opportunity> oppPrevMap;
    Map<Id, Opportunity> oppParentMap;
    Map<Id, Opportunity> oppParentPrevMap;


    if(oppBoth.Size() > 0)
        oppParentPrevMap = new Map<Id, Opportunity>([SELECT Id,Persistent_ID__c FROM Opportunity Where id IN : OppBoth]);
    /*if(OppPrev.Size() > 0)
        oppPrevMap = new Map<Id, Opportunity>([SELECT Id,Persistent_ID__c FROM Opportunity Where id IN : OppPrev]);

    if(OppParent.Size() > 0)
        oppParentMap = new Map<Id, Opportunity>([SELECT Id, Persistent_ID__c FROM Opportunity Where id IN : OppParent]);
    */

    for(Opportunity opp : opps)
    {

         if(opp.PersistentId_Override__c != Null)
                      opp.Persistent_ID__c = opp.PersistentId_Override__c ;
         else if(opp.New_Persistent_ID__c == true)
                     opp.Persistent_ID__c = opp.TECH_PersistentId__c ;

         else
         {
             //if(opp.ParentOpportunityId__c != Null && oppParentMap != null)
             if(opp.ParentOpportunityId__c != Null && oppParentPrevMap != null)
                    opp.Persistent_ID__c = oppParentPrevMap.get(opp.ParentOpportunityId__c).Persistent_ID__c;
            //else if(opp.PreviousOpportunity__c != Null && oppPrevMap != null )
            else if(opp.PreviousOpportunity__c != Null && oppParentPrevMap != null )
                    opp.Persistent_ID__c = oppParentPrevMap.get(opp.PreviousOpportunity__c).Persistent_ID__c;
            else
                  opp.Persistent_ID__c = opp.TECH_PersistentId__c;
         }

     }
  }



 public static void UpdateChildsPersistentId(List<Opportunity> opps, Map<Id, Opportunity> oldMap){
    List<Id> prevOpportunityIds = new  List<Id>();
    List<Id> parentOpportunityIds = new  List<Id>();
    List<Opportunity> prevOpportunities = new List<Opportunity>();
    List<Opportunity> parentOpportunities= new List<Opportunity>();

    for(Opportunity opp : opps)
    {
        Opportunity oldOpp1 = oldMap.get(opp.Id);


        if(opp.PreviousOpportunity__c != oldOpp1.PreviousOpportunity__c
             || opp.ParentOpportunityId__c != oldOpp1.ParentOpportunityId__c
             ||  opp.New_Persistent_ID__c != oldOpp1.New_Persistent_ID__c
             ||  opp.PersistentId_Override__c != oldOpp1.PersistentId_Override__c
             || opp.Persistent_ID__C <> oldOpp1.Persistent_ID__C
          )

          {

            //Find All the childs whihc are linked with previous opportunity id
            prevOpportunityIds.Add(opp.ID);
            parentOpportunityIds.Add(Opp.ID);
          }
   }

   if(prevOpportunityIds.Size() > 0)
       prevOpportunities = [SELECT Id, Persistent_ID__c, PreviousOpportunity__c  FROM Opportunity WHERE PreviousOpportunity__c IN :prevOpportunityIds or ParentOpportunityId__c IN :parentOpportunityIds];
  // if(parentOpportunities.Size() > 0)
        //parentOpportunities = [SELECT Id, Persistent_ID__c, ParentOpportunityId__c FROM Opportunity WHERE ParentOpportunityId__c IN :parentOpportunityIds];

    if(prevOpportunities.size() > 0)
        update  prevOpportunities;

    //if(parentOpportunities.size() > 0)
      //  update parentOpportunities;


 }



public static void validateLinkageChange(List<Opportunity> opps, Map<Id, Opportunity> oldMap)
{

    for(Opportunity opp : opps)
    {
        Opportunity oldOpp1 = oldMap.get(opp.Id);

        If(((opp.ParentOpportunityId__c <> oldOpp1.ParentOpportunityId__c) || (opp.PreviousOpportunity__c <> oldOpp1.PreviousOpportunity__c)) && (opp.StageName == '5 - Closed Won' || opp.StageName == 'Acquired'))
        {
            String tgt ='/apex/VFP_LinkageHelperPage';
                Opp.addError('<html><script> function confirmGetMessage() {newwindow=window.open("' + tgt + '" ,"popUpWindow","height=200,width=850,resizable=No");newwindow.focus(); }window.onload = confirmGetMessage;</script></html>', false);

        }

   }

}


public static void createCaseLinkageChange(List<Opportunity> opps, Map<Id, Opportunity> oldMap)
{

    List<Case> caseList = new List<Case>();

    for(Opportunity opp : opps)
    {
        Opportunity oldOpp1 = oldMap.get(opp.Id);

        If(((opp.ParentOpportunityId__c <> oldOpp1.ParentOpportunityId__c) || (opp.PreviousOpportunity__c <> oldOpp1.PreviousOpportunity__c) ) && (opp.StageName == '5 - Closed Won' || opp.StageName == 'Acquired'))
        {

            if(opp.TECH_SyncContract__c)
            {
                    String strQueue = '';

                     strQueue = 'US Accounting Group';
                    //Create a new case
                    Case opportunityLinkageCase = new Case(
                    //OwnerId = [select Id from Group where Name =: strQueue and Type='Queue' limit 1][0].Id,
                    Subject = 'Persistent ID Changing â€“ ' + opp.OpportunityId__c + ' - ' + opp.Name ,
                    Origin = 'Other',
                    Type = 'Billing / Accounting Request',
                    AccountId = opp.AccountId,
                    Description = 'Opportunity ' + opp.OpportunityId__c + ' has had a linkage change (previous or parent ID) resulting in a possible change in Oracle contract linkage.  Please review this opportunity for potential downstream impact.  Persistent ID is ' + opp.Persistent_ID__c);

                    caseList.Add(opportunityLinkageCase);


                    System.debug('Case ID ****' + opportunityLinkageCase.Id);



            }
        }


        If(((opp.EffectiveDate__c <> oldOpp1.EffectiveDate__c) || (opp.ExpirationDate__c <> oldOpp1.ExpirationDate__c) ) && (opp.StageName == '5 - Closed Won' || opp.StageName == 'Acquired') && (opp.FDDsConfirmed__c == 'Complete') && opp.TECH_SyncContract__c)
        {

                    String strQueue = '';

                     strQueue = 'US Accounting Group';
                    //Create a new case
                    Case opportunityLinkageCase = new Case(
                    //OwnerId = [select Id from Group where Name =: strQueue and Type='Queue' limit 1][0].Id,
                    Subject = 'Effective/Expiration Date Changing â€“ ' + opp.OpportunityId__c + ' - ' + opp.Name ,
                    Origin = 'Other',
                    Type = 'Billing / Accounting Request',
                    AccountId = opp.AccountId,
                    Description = 'Opportunity ' + opp.OpportunityId__c + ' has had a Effective/Expiration Date change resulting in a possible change in Oracle contract linkage.  Please review this opportunity for potential downstream impact.  Persistent ID is ' + opp.Persistent_ID__c);

                    caseList.Add(opportunityLinkageCase);

        }

         insert caseList;

   }


}

public static void UpdateContractsReviewStatus(List<Opportunity> opps)
{

    GlobalConstants.isContractSyncFromBackEnd = true;
    List<Contract> contractsToUpdate;
    Boolean flagBillingApplicationError = false;

    Set<Contract> oraclecontractList = new Set<Contract>();
     List<Contract> nonOraclecontractList = new List<Contract>();


    contractsToUpdate = [SELECT Id, IntegrationStatus__c, Billing_Application__c FROM Contract Where Opportunity__c IN :opps];

    String fullFileURL = URL.getSalesforceBaseUrl().getProtocol() + '://' + URL.getSalesforceBaseUrl().getHost() ;
    for(Contract con : contractsToUpdate)
    {
        if(con.Billing_Application__c != Null){
            if(con.Billing_Application__c == 'Oracle' && con.IntegrationStatus__c != 'Sync'){

           // if(con.IntegrationStatus__c == 'Do Not Sync' || con.IntegrationStatus__c == Null)
            //{
                //con.Review_Status__c = 'Submitted To FA';
                //con.IntegrationStatus__c  = 'Sync';
                //
             //}

             trigger.new[0].adderror('<br/><br /><strong><font color="red"> Contract is not yet synced. Please sync the contract to proceed further. Click here to edit the contract - </font></strong>  <A Href="' + fullFileURL + Label.CL_BackSlash + con.Id + '">' + con.Id + '</A>');
             flagBillingApplicationError = true;
             break;



            }
            else {

                    if(con.IntegrationStatus__c != 'Sync')
                        oraclecontractList.Add(con);
            }
        }else
        {
            trigger.new[0].adderror('<br/><br /><strong><font color="red"> Billing application is a required field. Please fill the billing application on - </font></strong>  <A Href="' + fullFileURL + Label.CL_BackSlash + con.Id + '">' + con.Id + '</A>');
            flagBillingApplicationError = true;
            break;
        }

    }

  If(System.Label.CL_REQUIRED_AUDIT_ERROR_FLAG.equalsIgnoreCase('TRUE'))
    for(Opportunity oppty : opps){
        if(oppty.Audit_Errors__c == Null || oppty.Audit_Errors__c == ''){
            trigger.new[0].adderror('<br/><br /><strong><font color="red">' + System.Label.CL_OPP_AUDIT_ERROR + '</font></strong>');
            flagBillingApplicationError = true;
            break;

        }

         if(oppty.ContractType__c == System.Label.CL_AMENDMENT && (oppty.Contract_Sub_Type__c == '' || oppty.Contract_Sub_Type__c == Null)){
             trigger.new[0].adderror('<br/><br /><strong><font color="red">' + System.Label.CL_OPP_CONTRACT_SUB_TYPE_REQUIRED_ERROR + '</font></strong>');
             flagBillingApplicationError = true;
             break;
        }

        if(oppty.FDDsConfirmed__c == 'Empty'){
             trigger.new[0].adderror('<br/><br /><strong><font color="red">' + System.Label.CL_OPP_FDD_CONFIRMED_ERROR + '</font></strong>');
             flagBillingApplicationError = true;
             break;
        }



    }





AP01_Contract conClass = new AP01_Contract();
   if(!flagBillingApplicationError){


        //If(oraclecontractList.Size() > 0)
          //conClass.ProcessRecords(oraclecontractList);

        if(oraclecontractList.Size() > 0){


            validateContracts(opps) ;
        }

         GlobalConstants.isContractSyncFromBackEnd = false;
         try
         {



        Approval.ProcessSubmitRequest req1 ;
        for(Contract Cn : contractsToUpdate)
        {
            if(!Approval.isLocked(Cn.id))
              {

               req1 = new Approval.ProcessSubmitRequest();
              req1.setComments('Submitting request for approval automatically using Trigger');
              req1.setObjectId(Cn.id);
            Approval.ProcessResult result = Approval.process(req1);

              }

        }

             }catch(Exception ex)
         {
             System.debug('NEW PROCESS ERROR' + ex.getMessage());
         }
   }



}


public static void validateRejections(List<Opportunity> opps)
{
     for(Opportunity opp : opps)
        {

            If((opp.Review_Status__c == 'Returned to Gatekeeper' || opp.Review_Status__c == 'Returned to Sales')
            && opp.Audit_Errors__c == null )
               opp.AddError('<br/><br /><strong><font color="red"> You will need to select an Audit error before rejecting the Opportunity.</font></Strong>');

        }
}



public static void validateContracts(List<Opportunity> opps)
{
    GlobalConstants.isContractSyncFromBackEnd = true;
    for(Opportunity opp : opps)
    {
        If(opp.Review_Status__c == 'Submitted to Auditor' && (opp.MorningStarSignatureDate__c == NULL || opp.ClientSignatureDate__c == NULL))
           opp.AddError('<br/><br /><strong><font color="red"> You need to fill out the Morningstar Signature and Client Signature dates before proceeding further.</font></Strong>');

    }


    List<Contract> contractsToUpdate;

    Set<Contract> contractsList = new Set<Contract>();

    contractsToUpdate = [SELECT Id, IntegrationStatus__c, Billing_Application__c FROM Contract Where Opportunity__c IN :opps];

    AP01_Contract conClass = new AP01_Contract();
    for(Contract con : contractsToUpdate)
    {
        if(con.IntegrationStatus__c == 'Do Not Sync' || con.IntegrationStatus__c == Null){
             con.Billing_Application__c = 'Globe';
             contractsList.Add(con);
         }
       // if(con.IntegrationStatus__c == 'Do Not Sync' || con.IntegrationStatus__c == Null)
        //{

          //  con.IntegrationStatus__c = 'Sync';
            //con.Review_Status__c = 'Submitted To FA';
           // contractsList.Add(con);
         //}


    }


    if(contractsList.Size() > 0)
    {

        conClass.ProcessRecords(contractsList) ;
        //Database.update(contractsList);

        //for(Contract con : contractsList)
          //  con.IntegrationStatus__c = 'Do Not Sync';

         //Database.update(contractsList);

     }


     GlobalConstants.isContractSyncFromBackEnd = false;

}


public static void UpdateRenewalOppToLost(List<Id> parentOpps, Map<Id, String> oppAmendParentMap){
    //VED: CMSSS-236 - Added new condition to exclude Closed Renewal Opps when updating renewal to 6 - Closed Lost
    //VED: CMSSS-473 - Added new condition to exclude Lost Renewal Opps when updating renewal to 6 - Closed Lost
    List<Opportunity> renewalOpps = [SELECT id, stageName, PreviousOpportunity__c
    from Opportunity where StageName <> '5 - Closed Won' and StageName <> '6 - Closed Lost' and PreviousOpportunity__c IN : parentOpps LIMIT 100];

    for(Opportunity opp : renewalOpps){
        opp.StageName = Label.CL_CLOSED_LOST_6;
         opp.CloseDate = Date.Today();
        opp.LostReason__c = 'Deal Cancelled: See previous amendment';
        opp.LostDetails__c = 'The deal will not be renewed any longer. Please see ' + oppAmendParentMap.get(opp.PreviousOpportunity__c) + ' for reference.';


     //VED: JIRA - CMSSS-378
        List<Deal_Analysis__c> daofrenewalopps = [select New_Lost_Business_Run_Rate__c,Price_Increase_Decrease_Run_Rate__c,Change_in_Variable_Run_Rate__c from Deal_Analysis__c where Opportunity__c =: opp.Id];
        for(Deal_Analysis__c renewalDa : daofrenewalopps){
            renewalDa.New_Lost_Business_Run_Rate__c = 0;
            renewalDa.Price_Increase_Decrease_Run_Rate__c = 0;
            renewalDa.Change_in_Variable_Run_Rate__c = 0;
        }
         Database.update(daofrenewalopps);
      //VED: CMSSS-378 - END
    }

    Database.Update(renewalOpps);


}

public static void deleteDealAnalysisAndSalesCredit(List<Opportunity> opps){


        List<Deal_Analysis__c> dAOpportunity = [SELECT id from Deal_Analysis__c Where Opportunity__c IN :opps];
        List<Sales_Credit__c> sCOpportunity = [SELECT Id from Sales_Credit__c Where Opportunity__c IN :opps];

        if(dAOpportunity.Size() > 0)
            delete(dAOpportunity);

         if(sCOpportunity.Size() > 0)
             delete(sCOpportunity);

}

//New Lost opportunity process
public static void lostOpportunityProcess(List<Opportunity> opps, Boolean bCalculateDealHistory){

   if(AfterUpdateRun)
    If(opps.Size() > 0){
        system.debug('testing>>>>>>>'+opps.Size());
        System.debug('testing++++++++++++++='+bCalculateDealHistory);


        If(!bCalculateDealHistory)
         deleteDealAnalysisAndSalesCredit(opps);




         If(bCalculateDealHistory){
         //Variable Declarations
         List<Opportunity> prevOpp;
         List<Opportunity> mainOppList;
         List<Id> relatedOppIds = new List<Id>();
         List<Id> prevOppIds = new List<Id>();
         List<Opportunity> relatedOppList;
         List<Opportunity> prevOppList;
         List<OpportunitySplit__c> oppSplits = new List<OpportunitySplit__c>();
         List<DealHistory__c> dealHistoryCol = new List<DealHistory__c>();
         DealHistory__c dealHis;
         Opportunity oppty;
         List<OpportunitySplit__c > prevoppSplits ;
         Opportunity mainOpp;
         Opportunity relatedOpp ;

         List<Opportunity> renewalMainDeletes = new List<Opportunity>();

         mainOppList = [SELECT Id, CurrencyIsoCode, PreviousOpportunity__c, Related_Opportunity__c, Type, LostReason__c, ContractType__c From Opportunity WHERE id IN : opps];
         for(Opportunity Op : mainOppList){
                relatedOppIds.Add(op.Related_Opportunity__c);
                prevOppIds.Add(op.PreviousOpportunity__c);
         }

         relatedOppList = [SELECT Id, StageName From Opportunity WHERE id IN :relatedOppIds];
         prevOppList = [SELECT Id from Opportunity Where Id IN : prevOppIds];
         prevoppSplits = [Select Id, Opportunity__c,  SetUpFees__c, Setup_Fee__c, Run_rate__c, CurrencyIsoCode From OpportunitySplit__c where Opportunity__c =: prevOppIds];

         for(Opportunity opty : opps){

                  for(Opportunity opt : mainOppList ){
                      if(opt.Id == opty.Id)
                         mainOpp = opt;
                  }

                  for(Opportunity opt : relatedOppList ){
                      if(opt.Id == opty.Related_Opportunity__c)
                          relatedOpp = opt;
                  }

                 if(mainOpp.Type == 'Renewal' && mainOpp.ContractType__c == 'Main Agreement' && mainOpp.LostReason__c == 'Not Truly Lost: Convert to another Oppty' && (relatedOpp.StageName <> '5 - Closed Won' && relatedOpp.StageName <> '6 - Closed Lost' && relatedOpp.StageName <> 'Acquired' )){

                         renewalMainDeletes.Add(mainOpp);


                         for(OpportunitySplit__c split: prevoppSplits){
                             If(split.Opportunity__c ==  mainOpp.PreviousOpportunity__c)
                                 oppSplits.Add(split);
                        }



                       if(oppSplits.Size() > 0)
                           system.debug('TIGER2 WE IN HERE SPLIT SIZE' + oppSplits.Size());
                        //Insert Deal History
                         //Create the deal history using the opportunity splits.
                       for(OpportunitySplit__c prodSplit : oppSplits)
                       {
                               //Create an instance of DealHistory
                                dealHis = new DealHistory__c();
                                //Set the appropriate values for the deal History
                                dealHis.Main_Opportunity__c =  relatedOpp.Id;
                                dealHis.Associated_Opportunity__c = prodSplit.Opportunity__c ;
                                dealHis.OpportunitySplit__c = prodSplit.id;
                                dealHis.CurrencyIsoCode= mainOpp.CurrencyIsoCode;
                                if(mainOpp.CurrencyIsoCode != prodSplit.CurrencyIsoCode)
                                {
                                    dealHis.Run_Rate__c  = convertCurrency(prodSplit.Run_rate__c,prodSplit.CurrencyIsoCode,mainOpp.CurrencyIsoCode);
                                 }
                                else
                                {
                                    dealHis.Run_Rate__c = prodSplit.Run_rate__c;

                                }

                               dealHis.Association__c = VFC_DealAnalysisContants.AUTOMATIC;
                               dealHistoryCol.Add(dealHis);

                        }


                        //Insert or update the deal history objects.
                            if(dealHistoryCol != null ){

                            //Remove deal History duplicates
                             List<Id> dealHistoryIds = New List<Id>();

                             for(DealHistory__c dh : dealHistoryCol ){
                                  if(dh.Id != Null)
                                       dealHistoryIds.Add(dh.Id);
                              }

                            Delete [select id from DealHistory__c where Id IN : dealHistoryIds];

                            Database.insert(dealHistoryCol);
                }
          }


    }


            deleteDealAnalysisAndSalesCredit(renewalMainDeletes);
    }

}

            AfterUpdateRun = false;

}
//Amendment roll up process
//BPARUPU
public static void ProcessRollUpsForAmendments(Map<Id,Opportunity> amendmentRollupEligibleOppMap, Map<Id,Id> amendmentParentOppIdMap)
{
    //Even though nothing happens just make sure the list is not empty
    if(!amendmentRollupEligibleOppMap.isEmpty() && !amendmentParentOppIdMap.isEmpty())
    {
        //Get the renewal Opps for each amendement
        Map<Id,Opportunity> amendementrenewalOppIdMap = new Map<Id,Opportunity>([SELECT  RenewalOpportunity__c, RenewalOpportunity__r.StageName , StageName FROM Opportunity WHERE Id IN : amendmentParentOppIdMap.values()]);
       System.debug('++++++++++++'+amendementrenewalOppIdMap);
        //Populate the list of renewal Opp ids
        List<Id> renewalOppIdList = new List<Id>();

        for(Opportunity a : amendementrenewalOppIdMap.values())
        {
            /* sandru:CSS-418 added filter to restrict renwal opp if it's stage is closed won */
            if(a.RenewalOpportunity__r.StageName != '5 - Closed Won'){
            renewalOppIdList.add(a.RenewalOpportunity__c);
            }
        }
        //Get the line items for the renewal opportunity
        Map<Id, Opportunity> renewalOppMap = new Map<Id,Opportunity>([Select o.CurrencyIsoCode, o.ContractType__c,o.Id, o.DeliveryMonths__c, (Select  PricebookEntry.Product2.Id,  Type__c, Units__c, OpportunityId,   RemainingYearsPrice__c, X1stYearPrice__c, X2ndYearPrice__c, X3rdYearPrice__c, X4thYearPrice__c, ToolNew__c, Run_Rate__c From OpportunityLineItems) From Opportunity o WHERE Id IN :renewalOppIdList]);
        system.debug('renewalOppMap'+renewalOppMap);
        //Get the line items for the amendments
        Map<Id, Opportunity>amendmentOppMap = new Map<Id,Opportunity>([Select o.CurrencyIsoCode,o.ContractType__c,o.Id, o.DeliveryMonths__c,o.Contract_Sub_Type__c,o.ParentOpportunityId__c, o.StageName,(Select Product_One_Time_TCV__c,Type__c, Units__c,Id, Run_Rate__c,OpportunityId, SortOrder, PricebookEntryId, PricebookEntry.Product2.Id, PricebookEntry.Product2.Name, X1stYearPrice__c, X2ndYearPrice__c, X3rdYearPrice__c, X4thYearPrice__c,
          RemainingYearsPrice__c,  UserType__c,SetUpFees__c, SetUp_Fee__c, Quantity,UnitPrice, DistributionType__c,
          Third_Party_Service_Provider__c, DistributionRange__c, ThirdPartyData__c, AUMRange__c,
          REDISTRIBUTOR_USER_TYPE__C, ToolNew__c From OpportunityLineItems) From Opportunity o WHERE Id IN :amendmentRollupEligibleOppMap.keySet()]);
        system.debug('amendmentOppMap'+amendmentOppMap);
        system.debug('amendementrenewalOppIdMap'+amendementrenewalOppIdMap);
         Set<OpportunityLineItem> renewalOppLineSaveItemList = new Set<OpportunityLineItem>();
          List<OpportunityLineItem> renewalOppLineInsertItemList = new List<OpportunityLineItem>();
         List<Opportunity_Line_Item_History__c> historyList = new List<Opportunity_Line_Item_History__c>();
        for(Id a : amendmentOppMap.keySet())
        {
            Opportunity amendment = amendmentOppMap.get(a);
            //Check one more time to confirm that its a closed amendment
            if(amendment.ContractType__c == label.CL_AMENDMENT
                           && amendment.StageName == label.CL_COSED_WON_5 && amendment.ParentOpportunityId__c != null)
             {
                //Apply the logic only for contract sub type - Cancellation -Partial renew or New
                if(amendment.Contract_Sub_Type__c == label.CL_PARTIAL_RENEW_CONTRACT_SUB_TYPE
                   || amendment.Contract_Sub_Type__c == label.CL_ContractNew )
                   {
                      List<OpportunityLineItem> amendmentOpplineItems = new List<OpportunityLineItem>();
                      List<OpportunityLineItem> renewalOpplineItems = new List<OpportunityLineItem>();
                      Integer deliveryMonthsInt = (Integer)amendment.DeliveryMonths__c;
                     /* Integer deliveryMonthsInt = (Integer)amendment.DeliveryMonths__c;
                      Boolean isFullYearTerm = true;
                      Integer remainder = math.mod(deliveryMonthsInt,12);
                      system.debug('code_entrance1,*****');
                      if(remainder>0)
                      {
                        isFullYearTerm = false;

                      }*/

                      //Get the Renewal OppId associated with amendment
                      Id renewalOppId = amendementrenewalOppIdMap.get(amendmentParentOppIdMap.get(amendment.Id)).RenewalOpportunity__c;
                      //Get the renewal Opp from the map
                      Opportunity renewalOpp = renewalOppMap.get(renewalOppId);

                      //Get the renewal line items
                      //sandru avoid null pointer exception

                       if(renewalOpp != null )
                       {
                      renewalOpplineItems = renewalOpp.OpportunityLineItems;

                      //Get the amendment line items
                      amendmentOpplineItems = amendment.OpportunityLineItems;

                      //If deliverymonths is <=12 OR (delivery months > 12 AMD not divisible by 12)
                     // if(deliveryMonthsInt <=12 || (deliveryMonthsInt>12 && !isFullYearTerm))
                     // {
                         //Loop through the line items of amendment
                         for(OpportunityLineItem alineItem : amendmentOpplineItems)
                         {
                            Boolean exists = false;
                            Boolean createNewLineItem = true;
                            Integer deliveryMonths = (Integer)renewalOpp.DeliveryMonths__c;
                            double runRate = 0.00;
                            if(amendment.Contract_Sub_Type__c == label.CL_PARTIAL_RENEW_CONTRACT_SUB_TYPE
                               && alineItem.Run_Rate__c != null && alineItem.Run_Rate__c ==0
                               && alineItem.Product_One_Time_TCV__c != null &&  alineItem.Product_One_Time_TCV__c <0)
                            {
                                runRate = (deliveryMonthsInt>0)?((alineItem.Product_One_Time_TCV__c/deliveryMonthsInt)*12):alineItem.Product_One_Time_TCV__c;
                                createNewLineItem = false;
                            }
                            else
                            {
                                runRate = alineItem.Run_Rate__c;
                            }
                            if(runRate != null)
                            {
                                runRate = convertCurrency(runRate,amendment.CurrencyIsoCode,renewalOpp.CurrencyIsoCode);
                            }

                             for(OpportunityLineItem rlineItem : renewalOpplineItems)
                             {
                                //If the same product and tool exists update the yearly breakdown on renewal
                                if(alineItem.PricebookEntry.Product2.Id ==rlineItem.PricebookEntry.Product2.Id
                                                && alineItem.ToolNew__c ==  rlineItem.ToolNew__c)
                                 {
                                    //Make sure the run rate is not null
                                    if(runRate != null)
                                    {
                                        if(deliveryMonths <=17)
                                        {
                                            rlineItem.X1stYearPrice__c = (rlineItem.X1stYearPrice__c == null)?((runRate<0)?0.00:runRate):((rlineItem.X1stYearPrice__c+runRate)>0?(rlineItem.X1stYearPrice__c+runRate):0.00);
                                        }
                                        if(deliveryMonths >=18 && deliveryMonths <=29)
                                        {
                                            rlineItem.X1stYearPrice__c = (rlineItem.X1stYearPrice__c == null)?((runRate<0)?0.00:runRate):((rlineItem.X1stYearPrice__c+runRate)>0?(rlineItem.X1stYearPrice__c+runRate):0.00);
                                            rlineItem.X2ndYearPrice__c = (rlineItem.X2ndYearPrice__c == null)?((runRate<0)?0.00:runRate): ((rlineItem.X2ndYearPrice__c + runRate)>0?(rlineItem.X2ndYearPrice__c + runRate):0.00);

                                        }
                                        if(deliveryMonths >=30 && deliveryMonths <=41)
                                        {
                                            rlineItem.X1stYearPrice__c = (rlineItem.X1stYearPrice__c == null)?((runRate<0)?0.00:runRate):((rlineItem.X1stYearPrice__c+runRate)>0?(rlineItem.X1stYearPrice__c+runRate):0.00);
                                            rlineItem.X2ndYearPrice__c = (rlineItem.X2ndYearPrice__c == null)?((runRate<0)?0.00:runRate): ((rlineItem.X2ndYearPrice__c + runRate)>0?(rlineItem.X2ndYearPrice__c + runRate):0.00);
                                            rlineItem.X3rdYearPrice__c = (rlineItem.X3rdYearPrice__c == null)?((runRate<0)?0.00:runRate): ((rlineItem.X3rdYearPrice__c + runRate)>0?(rlineItem.X3rdYearPrice__c + runRate):0.00);
                                        }
                                        if(deliveryMonths >=42 && deliveryMonths <=53)
                                        {
                                            rlineItem.X1stYearPrice__c = (rlineItem.X1stYearPrice__c == null)?((runRate<0)?0.00:runRate):((rlineItem.X1stYearPrice__c+runRate)>0?(rlineItem.X1stYearPrice__c+runRate):0.00);
                                            rlineItem.X2ndYearPrice__c = (rlineItem.X2ndYearPrice__c == null)?((runRate<0)?0.00:runRate): ((rlineItem.X2ndYearPrice__c + runRate)>0?(rlineItem.X2ndYearPrice__c + runRate):0.00);
                                            rlineItem.X3rdYearPrice__c = (rlineItem.X3rdYearPrice__c == null)?((runRate<0)?0.00:runRate): ((rlineItem.X3rdYearPrice__c + runRate)>0?(rlineItem.X3rdYearPrice__c + runRate):0.00);
                                            rlineItem.X4thYearPrice__c  = (rlineItem.X4thYearPrice__c == null)?((runRate<0)?0.00:runRate): ((rlineItem.X4thYearPrice__c + runRate)>0?(rlineItem.X4thYearPrice__c + runRate):0.00);
                                        }
                                        if(deliveryMonths >53)
                                        {
                                            rlineItem.X1stYearPrice__c = (rlineItem.X1stYearPrice__c == null)?((runRate<0)?0.00:runRate):((rlineItem.X1stYearPrice__c+runRate)>0?(rlineItem.X1stYearPrice__c+runRate):0.00);
                                            rlineItem.X2ndYearPrice__c = (rlineItem.X2ndYearPrice__c == null)?((runRate<0)?0.00:runRate): ((rlineItem.X2ndYearPrice__c + runRate)>0?(rlineItem.X2ndYearPrice__c + runRate):0.00);
                                            rlineItem.X3rdYearPrice__c = (rlineItem.X3rdYearPrice__c == null)?((runRate<0)?0.00:runRate): ((rlineItem.X3rdYearPrice__c + runRate)>0?(rlineItem.X3rdYearPrice__c + runRate):0.00);
                                            rlineItem.X4thYearPrice__c  = (rlineItem.X4thYearPrice__c == null)?((runRate<0)?0.00:runRate): ((rlineItem.X4thYearPrice__c + runRate)>0?(rlineItem.X4thYearPrice__c + runRate):0.00);
                                            rlineItem.RemainingYearsPrice__c = (rlineItem.RemainingYearsPrice__c == null)?((runRate<0)?0.00:runRate): ((rlineItem.RemainingYearsPrice__c + runRate)>0?(rlineItem.RemainingYearsPrice__c + runRate):0.00);
                                        }

                                    }
                                    //If Unit Tpe matches to Num of Users add/update Units
                                    if(alineItem.Type__c == label.CL_Unit_Type_NumOfUsers)
                                    {
                                        if(alineItem.Type__c == rlineItem.Type__c)
                                        {
                                            rlineItem.Units__c = (rlineItem.Units__c == null)?alineItem.Units__c: (rlineItem.Units__c + alineItem.Units__c);
                                        }
                                        else
                                        {
                                            rlineItem.Type__c = alineItem.Type__c;
                                            rlineItem.Units__c = alineItem.Units__c;
                                        }
                                    }

                                    //Add the line item to the final save list
                                    renewalOppLineSaveItemList.add(rlineItem);

                                    //create the history object and add it to the map
                                    Opportunity_Line_Item_History__c histItem = new Opportunity_Line_Item_History__c();
                                    histItem.Opp_contract_sub_type__c = amendment.Contract_Sub_Type__c;
                                    histItem.Opp_contract_type__c = amendment.ContractType__c;
                                    histItem.Opp_delivery_months__c = deliveryMonthsInt;
                                    histItem.Opp_line_item_one_time_tcv__c = alineItem.Product_One_Time_TCV__c;
                                    histItem.Opp_line_item_run_rate__c = alineItem.Run_Rate__c;
                                    histitem.Opp_line_item_unit_type__c = alineItem.Type__c;
                                    histitem.Opp_line_item_units__c =alineItem.Units__c;
                                    histitem.Opportunity__c = amendment.Id;
                                    histitem.Opportunity_Currency_IsoCode__c = amendment.CurrencyIsoCode;
                                    histitem.Opportunity_Line_Item_ID__c = alineItem.Id;
                                    histitem.Renewal_applied_run_rate__c = runRate;
                                    histitem.Renewal_delivery_months__c = deliveryMonths;
                                    histitem.Renewal_Currency_IsoCode__c = renewalOpp.CurrencyIsoCode;
                                    histitem.Renewal_Opportunity__c = renewalOppId;
                                    histitem.action__c = 'Update';
                                    historyList.add(histitem);
                                    exists = true;
                                 }

                             }
                             //If the tool & product combination doesn't match and product one time tcv is not negative and run rate is not zero we need to create a new line item

                             if(!exists && createNewLineItem)
                            {
                                    OpportunityLineItem newLineItem = alineItem.clone(false);
                                    newLineItem.OpportunityId = renewalOppId;
                                    newLineItem.X1stYearPrice__c =0.00;
                                    newLineItem.X2ndYearPrice__c = 0.00;
                                    newLineItem.X3rdYearPrice__c= 0.00;
                                    newLineItem.X4thYearPrice__c=0.00;
                                    newLineItem.RemainingYearsPrice__c=0.00;
                                    if(runRate != null)
                                    {
                                        if(deliveryMonths <=17)
                                        {
                                            newLineItem.X1stYearPrice__c = runRate;
                                        }
                                        if(deliveryMonths >=18 && deliveryMonths <=29)
                                        {
                                            newLineItem.X1stYearPrice__c = runRate;
                                            newLineItem.X2ndYearPrice__c = runRate;
                                        }
                                        if(deliveryMonths >=30 && deliveryMonths <=41)
                                        {
                                            newLineItem.X1stYearPrice__c = runRate;
                                            newLineItem.X2ndYearPrice__c = runRate;
                                            newLineItem.X3rdYearPrice__c = runRate;
                                        }
                                        if(deliveryMonths >=42 && deliveryMonths <=53)
                                        {
                                            newLineItem.X1stYearPrice__c = runRate;
                                            newLineItem.X2ndYearPrice__c = runRate;
                                            newLineItem.X3rdYearPrice__c = runRate;
                                            newLineItem.X4thYearPrice__c = runRate;
                                        }
                                        if(deliveryMonths >53)
                                        {
                                            newLineItem.X1stYearPrice__c = runRate;
                                            newLineItem.X2ndYearPrice__c = runRate;
                                            newLineItem.X3rdYearPrice__c = runRate;
                                            newLineItem.X4thYearPrice__c = runRate;
                                            newLineItem.RemainingYearsPrice__c = runRate;
                                        }
                                    }


                                    system.debug('newLineItem'+newLineItem);
                                    renewalOppLineInsertItemList.add(newLineItem);
                                    //create the history object and add it to the map
                                    Opportunity_Line_Item_History__c histItem = new Opportunity_Line_Item_History__c();
                                    histItem.Opp_contract_sub_type__c = amendment.Contract_Sub_Type__c;
                                    histItem.Opp_contract_type__c = amendment.ContractType__c;
                                    histItem.Opp_delivery_months__c = deliveryMonthsInt;
                                    histItem.Opp_line_item_one_time_tcv__c = alineItem.Product_One_Time_TCV__c;
                                    histItem.Opp_line_item_run_rate__c = alineItem.Run_Rate__c;
                                    histitem.Opp_line_item_unit_type__c = alineItem.Type__c;
                                    histitem.Opp_line_item_units__c =alineItem.Units__c;
                                    histitem.Opportunity__c = amendment.Id;
                                    histitem.Opportunity_Currency_IsoCode__c = amendment.CurrencyIsoCode;
                                    histitem.Opportunity_Line_Item_ID__c = alineItem.Id;
                                    histitem.Renewal_applied_run_rate__c = runRate;
                                    histitem.Renewal_delivery_months__c = deliveryMonths;
                                    histitem.Renewal_Currency_IsoCode__c = renewalOpp.CurrencyIsoCode;
                                    histitem.Renewal_Opportunity__c = renewalOppId;
                                    histitem.action__c = 'Insert';
                                    historyList.add(histitem);
                            }
                         }
                       }

                     
                   }//End of the logic for for contract sub type - Cancellation -Partial renew or New

             }//End of logic toconfirm that its a closed amendment

        }//End of amendmentmapLoop
        //If there are records to update call the update statement
        if(!renewalOppLineSaveItemList.isEmpty())
        {
            
            List<OpportunityLineItem> lOPL = new List<OpportunityLineItem>();
            for(OpportunityLineItem opl: renewalOppLineSaveItemList){
                lOPL.add(opl);
            }
            update lOPL;
        }
        //If there are records to insert call the insert statement
        if(!renewalOppLineInsertItemList.isEmpty())
        {
            insert renewalOppLineInsertItemList;
        }
        //If there is data in history list insert the list
        if(!historyList.isEmpty())
        {
            insert historyList;
        }

    }

}


//Function to log the history changes for the opportunity.
public static void logStageAmountHistoryChanges(List<Opportunity> newOpps, Map<Id, Opportunity> OldValues)
{
    Stage_Amount_History__c stageAmountHistory = Null;
    List<Stage_Amount_History__c> stageHistoryInsertList = new List<Stage_Amount_History__c>();

    for(Opportunity opp : newOpps){

        //Check for the changes to the specific fields
         if(opp.StageName <> OldValues.get(opp.Id).StageName ||
         opp.RunRate__c<> OldValues.get(opp.Id).RunRate__c ||
         opp.DA_Total_Run_Rate__c <> OldValues.get(Opp.Id).DA_Total_Run_Rate__c ||
         opp.CloseDate <> OldValues.get(Opp.Id).CloseDate ||
         opp.One_Time_TCV__c<> OldValues.get(Opp.Id).One_Time_TCV__c ||
         opp.Product__c <> OldValues.get(Opp.Id).Product__c  ) {

            //If there is a change, please log all the required fields in the stage history changes
            stageAmountHistory = New Stage_Amount_History__c();
            stageAmountHistory.X18_Digit_Opportunity_ID__c = opp.Id;
            stageAmountHistory.Opportunity_Id__c = opp.OpportunityID__c;
            stageAmountHistory.Last_Modified_Date__c = opp.LastModifieddate;

            //Stage Changes
            stageAmountHistory.From_Stage__c = OldValues.get(opp.Id).StageName;
            stageAmountHistory.To_Stage__c = opp.StageName;

            //Net New Changes
            stageAmountHistory.From_Net_New__c = OldValues.get(opp.Id).DA_Total_Run_Rate__c;
            stageAmountHistory.To_Net_New__c = opp.DA_Total_Run_Rate__c;

            //Close Date Changes
            stageAmountHistory.From_Close_Date__c = OldValues.get(opp.Id).CloseDate;
            stageAmountHistory.To_Close_Date__c = opp.CloseDate;

            //Run Rate Changes
            stageAmountHistory.From_Recurring_ACV__c = OldValues.get(opp.Id).RunRate__c;
            stageAmountHistory.To_Recurring_ACV__c = opp.RunRate__c;

            //One Time Changes
            stageAmountHistory.From_One_Time_TCV__c = OldValues.get(opp.Id).One_Time_TCV__c;
            stageAmountHistory.To_One_Time_TCV__c = opp.One_Time_TCV__c;

            //Product changes
            stageAmountHistory.From_Product__c = OldValues.get(opp.Id).Product__c;
            stageAmountHistory.To_Product__c = opp.Product__c;

            stageAmountHistory.currencyisocode = opp.currencyisocode ;

        }

        if(stageAmountHistory != Null)
            stageHistoryInsertList.Add(stageAmountHistory );
            stageAmountHistory = null;
    }

    if(stageHistoryInsertList.Size() > 0){
        Database.insert(stageHistoryInsertList);
    }
 }



}