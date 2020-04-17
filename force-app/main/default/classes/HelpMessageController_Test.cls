/**
 *  @description        test class for HelpMessageController
 *  @author             hyphen8.com
 *  @date               July 2019
*/
@isTest
public with sharing class HelpMessageController_Test {
 
    @testSetup static void setup() {

        //Valid for all
        Help_Message__c message1 = new Help_Message__c(Name='TestRecordMessage1', Record_SObjectType__c='Account', Records_Valid_For__c='All', Filter_Type__c='N/A', Message_Title__c='TestRecordMessage1', Message__c='TestRecordMessage1');
        insert message1;

        //Valid for filter 'AND'
        Help_Message__c message2 = new Help_Message__c(Name='TestRecordMessage2', Record_SObjectType__c='Account', Records_Valid_For__c='By Filter', Filter_Type__c='AND', Message_Title__c='TestRecordMessage2', Message__c='TestRecordMessage2');
        insert message2;

        List<Help_Message_Filter__c> messageFilters = new List<Help_Message_Filter__c>();

        messageFilters.add(new Help_Message_Filter__c(Help_Message__c=message2.Id, Type__c='Record Field', Field_Name__c='Name', Field_Operator__c='equals', Field_Value__c='TestAccount1'));
        messageFilters.add(new Help_Message_Filter__c(Help_Message__c=message2.Id, Type__c='Record Field', Field_Name__c='Parent.Name', Field_Operator__c='equals', Field_Value__c='DEMO'));

        //Valid for filter 'OR'
        Help_Message__c message3 = new Help_Message__c(Name='TestRecordMessage3', Record_SObjectType__c='Account', Records_Valid_For__c='By Filter', Filter_Type__c='OR', Message_Title__c='TestRecordMessage3', Message__c='TestRecordMessage3');
        insert message3;
        messageFilters.add(new Help_Message_Filter__c(Help_Message__c=message3.Id, Type__c='Record Field', Field_Name__c='Name', Field_Operator__c='equals', Field_Value__c='TestAccount2'));
        
        //Valid for greater than
        Help_Message__c message4 = new Help_Message__c(Name='TestRecordMessage4', Record_SObjectType__c='Opportunity', Records_Valid_For__c='By Filter', Filter_Type__c='AND', Message_Title__c='TestRecordMessage4', Message__c='TestRecordMessage4');
        insert message4;
        messageFilters.add(new Help_Message_Filter__c(Help_Message__c=message4.Id, Type__c='Record Field', Field_Name__c='Amount', Field_Operator__c='greater than', Field_Value__c='10000'));
        
        //Valid for greater than equals
        Help_Message__c message5 = new Help_Message__c(Name='TestRecordMessage5', Record_SObjectType__c='Opportunity', Records_Valid_For__c='By Filter', Filter_Type__c='AND', Message_Title__c='TestRecordMessage5', Message__c='TestRecordMessage5');
        insert message5;
        messageFilters.add(new Help_Message_Filter__c(Help_Message__c=message5.Id, Type__c='Record Field', Field_Name__c='Amount', Field_Operator__c='greater than or equals', Field_Value__c='10000'));
        
        //Valid for less than
        Help_Message__c message6 = new Help_Message__c(Name='TestRecordMessage6', Record_SObjectType__c='Opportunity', Records_Valid_For__c='By Filter', Filter_Type__c='AND', Message_Title__c='TestRecordMessage6', Message__c='TestRecordMessage6');
        insert message6;
        messageFilters.add(new Help_Message_Filter__c(Help_Message__c=message6.Id, Type__c='Record Field', Field_Name__c='Amount', Field_Operator__c='less than', Field_Value__c='10000'));
        
        //Valid for less than equals
        Help_Message__c message7 = new Help_Message__c(Name='TestRecordMessage7', Record_SObjectType__c='Opportunity', Records_Valid_For__c='By Filter', Filter_Type__c='AND', Message_Title__c='TestRecordMessage7', Message__c='TestRecordMessage7');
        insert message7;
        messageFilters.add(new Help_Message_Filter__c(Help_Message__c=message7.Id, Type__c='Record Field', Field_Name__c='Amount', Field_Operator__c='less than or equals', Field_Value__c='10000'));
        
        //Valid for equals string
        Help_Message__c message8 = new Help_Message__c(Name='TestRecordMessage8', Record_SObjectType__c='Opportunity', Records_Valid_For__c='By Filter', Filter_Type__c='AND', Message_Title__c='TestRecordMessage8', Message__c='TestRecordMessage8');
        insert message8;
        messageFilters.add(new Help_Message_Filter__c(Help_Message__c=message8.Id, Type__c='Record Field', Field_Name__c='Name', Field_Operator__c='equals', Field_Value__c='DEMO STRING CHECK'));
        
        //Valid for equals boolean
        Help_Message__c message9 = new Help_Message__c(Name='TestRecordMessage9', Record_SObjectType__c='Contact', Records_Valid_For__c='By Filter', Filter_Type__c='AND', Message_Title__c='TestRecordMessage9', Message__c='TestRecordMessage9');
        insert message9;
        messageFilters.add(new Help_Message_Filter__c(Help_Message__c=message9.Id, Type__c='Record Field', Field_Name__c='DoNotCall', Field_Operator__c='equals', Field_Value__c='false'));
        
        //Valid for equals string
        Help_Message__c message10 = new Help_Message__c(Name='TestRecordMessage10', Record_SObjectType__c='Contact', Records_Valid_For__c='By Filter', Filter_Type__c='AND', Message_Title__c='TestRecordMessage10', Message__c='TestRecordMessage10');
        insert message10;
        messageFilters.add(new Help_Message_Filter__c(Help_Message__c=message10.Id, Type__c='Record Field', Field_Name__c='LastName', Field_Operator__c='not equal to', Field_Value__c='DEMO STRING CHECK'));
        
        //Valid for equals boolean
        Help_Message__c message11 = new Help_Message__c(Name='TestRecordMessage11', Record_SObjectType__c='Contact', Records_Valid_For__c='By Filter', Filter_Type__c='AND', Message_Title__c='TestRecordMessage11', Message__c='TestRecordMessage11');
        insert message11;
        messageFilters.add(new Help_Message_Filter__c(Help_Message__c=message11.Id, Type__c='Record Field', Field_Name__c='DoNotCall', Field_Operator__c='not equal to', Field_Value__c='false'));
        
        //Valid for equals string null
        Help_Message__c message12 = new Help_Message__c(Name='TestRecordMessage12', Record_SObjectType__c='Opportunity', Records_Valid_For__c='By Filter', Filter_Type__c='AND', Message_Title__c='TestRecordMessage12', Message__c='TestRecordMessage12');
        insert message12;
        messageFilters.add(new Help_Message_Filter__c(Help_Message__c=message12.Id, Type__c='Record Field', Field_Name__c='Description', Field_Operator__c='equals', Field_Value__c=''));
        
        //Valid for equals decimal
        Help_Message__c message13 = new Help_Message__c(Name='TestRecordMessage13', Record_SObjectType__c='Opportunity', Records_Valid_For__c='By Filter', Filter_Type__c='AND', Message_Title__c='TestRecordMessage13', Message__c='TestRecordMessage13');
        insert message13;
        messageFilters.add(new Help_Message_Filter__c(Help_Message__c=message13.Id, Type__c='Record Field', Field_Name__c='Amount', Field_Operator__c='equals', Field_Value__c='10000'));
        
        //insert merge filters
        insert messageFilters;

    }


    /**
     * @description testing a greater than filter
    */
    static testMethod void testgreaterthan(){
        Account acc = new Account(Name='TestAccount1');
        insert acc;

        Opportunity opp = new Opportunity(Name='DEMO', StageName='Prospecting',CloseDate=system.today(), Amount=10000.00,AccountId=acc.Id);
        insert opp;

        List<Help_Message__c> messages = HelpMessageController.getHelpMessages(opp.Id);

        //Should return first and second messages
        System.assertEquals(3, messages.size(), 'Expected number of responses');

    }

    /**
     * @description testing a greater than or equals filter
    */
    static testMethod void testgreaterthanequals(){
        Account acc = new Account(Name='TestAccount1');
        insert acc;

        Opportunity opp = new Opportunity(Name='DEMO', StageName='Prospecting',CloseDate=system.today(), Amount=10000.00,AccountId=acc.Id);
        insert opp;

        List<Help_Message__c> messages = HelpMessageController.getHelpMessages(opp.Id);

        //Should return first and second messages
        System.assertEquals(3, messages.size(), 'Expected number of responses');
    }

    /**
     * @description testing a less than filter
    */
    static testMethod void testlessthan(){
        Account acc = new Account(Name='TestAccount1');
        insert acc;

        Opportunity opp = new Opportunity(Name='DEMO', StageName='Prospecting',CloseDate=system.today(), Amount=10000.00,AccountId=acc.Id);
        insert opp;

        List<Help_Message__c> messages = HelpMessageController.getHelpMessages(opp.Id);

        //Should return first and second messages
        System.assertEquals(3, messages.size(), 'Expected number of responses');

    }

    /**
     * @description testing a less than or equals filter
    */
    static testMethod void testlessthanequals(){
        Account acc = new Account(Name='TestAccount1');
        insert acc;

        Opportunity opp = new Opportunity(Name='DEMO', StageName='Prospecting',CloseDate=system.today(), Amount=10000.00,AccountId=acc.Id);
        insert opp;

        List<Help_Message__c> messages = HelpMessageController.getHelpMessages(opp.Id);

        //Should return first and second messages
        System.assertEquals(3, messages.size(), 'Expected number of responses');
    }

    /**
     * @description testing a equals string filter
    */
    static testmethod void testequalsstring(){
        Account acc = new Account(Name='TestAccount1');
        insert acc;

        Opportunity opp = new Opportunity(Name='DEMO STRING CHECK', StageName='Prospecting',CloseDate=system.today(), Amount=20000.00,AccountId=acc.Id);
        insert opp;

        List<Help_Message__c> messages = HelpMessageController.getHelpMessages(opp.Id);

        //Should return first and second messages
        System.assertEquals(4, messages.size(), 'Expected number of responses');
    }

    /**
     * @description testing a equals boolean filter
    */
    static testMethod void testequalsbooolean(){
        Account acc = new Account(Name='TestAccount1');
        insert acc;

        Contact con = new Contact(LastName='DEMO', AccountID=acc.Id);
        insert con;

        List<Help_Message__c> messages = HelpMessageController.getHelpMessages(con.Id);

        //Should return first and second messages
        System.assertEquals(3, messages.size(), 'Expected number of responses');
    }

    /**
     * @description testing a not equals string filter
    */
    static testMethod void testnotequalsstring(){
        Account acc = new Account(Name='TestAccount1');
        insert acc;

        Contact con = new Contact(LastName='DEMO', AccountID=acc.Id, DoNotCall=true);
        insert con;

        List<Help_Message__c> messages = HelpMessageController.getHelpMessages(con.Id);

        //Should return first and second messages
        System.assertEquals(2, messages.size(), 'Expected number of responses');
    }

    /**
     * @description testing a not equals boolean filter
    */
    static testMethod void testnotqualsboolean(){
        Account acc = new Account(Name='TestAccount1');
        insert acc;

        Contact con = new Contact(LastName='DEMO', AccountID=acc.Id, DoNotCall=true);
        insert con;

        List<Help_Message__c> messages = HelpMessageController.getHelpMessages(con.Id);

        //Should return first and second messages
        System.assertEquals(2, messages.size(), 'Expected number of responses');
    }


    static testMethod void testAccountOne() {

        Account acc = new Account(Name='TestAccount1');
        insert acc;

        List<Help_Message__c> messages = HelpMessageController.getHelpMessages(acc.Id);

        //Should return first and second messages
        System.assertEquals(1, messages.size(), 'Expected number of responses');

        //Check first message name = TestRecordMessage1 and second message name = TestRecordMessage2
        System.assertEquals(messages[0].Name, 'TestRecordMessage1', 'Expected value in response');

        ID helpmessage = [SELECT ID FROM Help_Message__c LIMIT 1].Id;
        string publishhelpmessage = HelpMessageController.changeMessageStatus(helpmessage, 'Published');
        system.assertEquals('You have successfully changed the status', publishhelpmessage, 'We got the correct message back');

        string unpublishhelpmessage = HelpMessageController.changeMessageStatus(helpmessage, 'Unpublished');
        system.assertEquals('You have successfully changed the status', unpublishhelpmessage, 'We got the correct message back');

        string helpmessageerror = HelpMessageController.changeMessageStatus(null, null);
        system.assertNotEquals('You have successfully changed the status', helpmessageerror, 'We did not get the correct message back');

        boolean canviewrecordcheck = HelpMessageController.canViewRecordActions();
        system.assertEquals(true, canviewrecordcheck, 'We do have the correct permissions');

    }

    static testMethod void testAccountTwo() {

        Account acc = new Account(Name='TestAccount2');
        insert acc;
    
        List<Help_Message__c> messages = HelpMessageController.getHelpMessages(acc.Id);

        //Should return first and third messages
        System.assertEquals(2, messages.size(), 'Message size matches expected');

        //Check first message name = TestRecordMessage1 and second message name = TestRecordMessage3
        System.assertEquals(messages[0].Name, 'TestRecordMessage1', 'Expected message response from test');
        System.assertEquals(messages[1].Name, 'TestRecordMessage3', 'Expected message response from test');

    }

    static testMethod void testAccountTwoNoPermissionsForDraft() {

        Account acc = new Account(Name='TestAccount2');
        insert acc;

        ID profileid = [SELECT ID FROM Profile WHERE Name=:'Standard User' LIMIT 1].Id;
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+randomId; 
        User user = new User(
            FirstName = 'DEMO',
            LastName = 'DEMO', 
            Email = uniqueName + '@test' + orgId + '.org', 
            Username = uniqueName + '@test' + orgId + '.org', 
            EmailEncodingKey = 'ISO-8859-1', 
            Alias = uniqueName.substring(18, 23), 
            TimeZoneSidKey = 'GMT',  
            LocaleSidKey = 'en_GB', 
            LanguageLocaleKey = 'en_US', 
            ProfileId  = profileid); 
        insert user;

        system.runAs(user){ 
            List<Help_Message__c> messages = HelpMessageController.getHelpMessages(acc.Id);
            //Should return first and third messages
            System.assertEquals(0, messages.size(), 'Message size matches expected');
            boolean canviewrecordcheck = HelpMessageController.canViewRecordActions();
            system.assertEquals(false, canviewrecordcheck, 'We do not have the correct permissions');
        }

    }

}