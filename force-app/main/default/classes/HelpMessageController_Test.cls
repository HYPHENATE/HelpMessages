/**
 * @description       : test class for HelpMessageController
 * @author            : daniel@hyphen8.com
 * @last modified on  : 31/05/2023
 * @last modified by  : daniel@hyphen8.com
 * Modifications Log
 * Ver      Date            Author                  Modification
 * 1.0      04/03/2022      daniel@hyphen8.com      Initial Version
**/
@isTest
public with sharing class HelpMessageController_Test {
 
    /**
    * @description      setup of test data for test class
    **/
    @testSetup static void setup() {

        Help_Message__c message1 = new Help_Message__c(Name='TestRecordMessage1', Record_SObjectType__c='Account', Records_Valid_For__c='All', Filter_Type__c='N/A', Message_Title__c='TestRecordMessage1', Message__c='TestRecordMessage1', Status__c='Published');
        insert message1;
        Help_Message__c message2 = new Help_Message__c(Name='TestRecordMessage2', Record_SObjectType__c='Account', Records_Valid_For__c='By Filter', Filter_Type__c='AND', Message_Title__c='TestRecordMessage2', Message__c='TestRecordMessage2', Status__c='Published');
        insert message2;
        List<Help_Message_Filter__c> messageFilters = new List<Help_Message_Filter__c>();
        messageFilters.add(new Help_Message_Filter__c(Help_Message__c=message2.Id, Type__c='Record Field', Field_Name__c='Name', Field_Operator__c='equals', Field_Value__c='TestAccount1'));
        messageFilters.add(new Help_Message_Filter__c(Help_Message__c=message2.Id, Type__c='Record Field', Field_Name__c='Parent.Name', Field_Operator__c='equals', Field_Value__c='DEMO'));
        Help_Message__c message3 = new Help_Message__c(Name='TestRecordMessage3', Record_SObjectType__c='Account', Records_Valid_For__c='By Filter', Filter_Type__c='OR', Message_Title__c='TestRecordMessage3', Message__c='TestRecordMessage3', Status__c='Published');
        insert message3;
        messageFilters.add(new Help_Message_Filter__c(Help_Message__c=message3.Id, Type__c='Record Field', Field_Name__c='Name', Field_Operator__c='equals', Field_Value__c='TestAccount2'));
        Help_Message__c message4 = new Help_Message__c(Name='TestRecordMessage4', Record_SObjectType__c='Opportunity', Records_Valid_For__c='By Filter', Filter_Type__c='AND', Message_Title__c='TestRecordMessage4', Message__c='TestRecordMessage4', Status__c='Published');
        insert message4;
        messageFilters.add(new Help_Message_Filter__c(Help_Message__c=message4.Id, Type__c='Record Field', Field_Name__c='Amount', Field_Operator__c='greater than', Field_Value__c='10000'));
        Help_Message__c message5 = new Help_Message__c(Name='TestRecordMessage5', Record_SObjectType__c='Opportunity', Records_Valid_For__c='By Filter', Filter_Type__c='AND', Message_Title__c='TestRecordMessage5', Message__c='TestRecordMessage5', Status__c='Published');
        insert message5;
        messageFilters.add(new Help_Message_Filter__c(Help_Message__c=message5.Id, Type__c='Record Field', Field_Name__c='Amount', Field_Operator__c='greater than or equals', Field_Value__c='10000'));
        Help_Message__c message6 = new Help_Message__c(Name='TestRecordMessage6', Record_SObjectType__c='Opportunity', Records_Valid_For__c='By Filter', Filter_Type__c='AND', Message_Title__c='TestRecordMessage6', Message__c='TestRecordMessage6', Status__c='Published');
        insert message6;
        messageFilters.add(new Help_Message_Filter__c(Help_Message__c=message6.Id, Type__c='Record Field', Field_Name__c='Amount', Field_Operator__c='less than', Field_Value__c='10000'));
        Help_Message__c message7 = new Help_Message__c(Name='TestRecordMessage7', Record_SObjectType__c='Opportunity', Records_Valid_For__c='By Filter', Filter_Type__c='AND', Message_Title__c='TestRecordMessage7', Message__c='TestRecordMessage7', Status__c='Published');
        insert message7;
        messageFilters.add(new Help_Message_Filter__c(Help_Message__c=message7.Id, Type__c='Record Field', Field_Name__c='Amount', Field_Operator__c='less than or equals', Field_Value__c='10000'));
        Help_Message__c message8 = new Help_Message__c(Name='TestRecordMessage8', Record_SObjectType__c='Opportunity', Records_Valid_For__c='By Filter', Filter_Type__c='AND', Message_Title__c='TestRecordMessage8', Message__c='TestRecordMessage8', Status__c='Published');
        insert message8;
        messageFilters.add(new Help_Message_Filter__c(Help_Message__c=message8.Id, Type__c='Record Field', Field_Name__c='Name', Field_Operator__c='equals', Field_Value__c='DEMO STRING CHECK'));
        Help_Message__c message9 = new Help_Message__c(Name='TestRecordMessage9', Record_SObjectType__c='Contact', Records_Valid_For__c='By Filter', Filter_Type__c='AND', Message_Title__c='TestRecordMessage9', Message__c='TestRecordMessage9', Status__c='Published');
        insert message9;
        messageFilters.add(new Help_Message_Filter__c(Help_Message__c=message9.Id, Type__c='Record Field', Field_Name__c='DoNotCall', Field_Operator__c='equals', Field_Value__c='false'));
        Help_Message__c message10 = new Help_Message__c(Name='TestRecordMessage10', Record_SObjectType__c='Contact', Records_Valid_For__c='By Filter', Filter_Type__c='AND', Message_Title__c='TestRecordMessage10', Message__c='TestRecordMessage10', Status__c='Published');
        insert message10;
        messageFilters.add(new Help_Message_Filter__c(Help_Message__c=message10.Id, Type__c='Record Field', Field_Name__c='LastName', Field_Operator__c='not equal to', Field_Value__c='DEMO STRING CHECK'));
        Help_Message__c message11 = new Help_Message__c(Name='TestRecordMessage11', Record_SObjectType__c='Contact', Records_Valid_For__c='By Filter', Filter_Type__c='AND', Message_Title__c='TestRecordMessage11', Message__c='TestRecordMessage11', Status__c='Published');
        insert message11;
        messageFilters.add(new Help_Message_Filter__c(Help_Message__c=message11.Id, Type__c='Record Field', Field_Name__c='DoNotCall', Field_Operator__c='not equal to', Field_Value__c='false'));
        Help_Message__c message12 = new Help_Message__c(Name='TestRecordMessage12', Record_SObjectType__c='Opportunity', Records_Valid_For__c='By Filter', Filter_Type__c='AND', Message_Title__c='TestRecordMessage12', Message__c='TestRecordMessage12', Status__c='Published');
        insert message12;
        messageFilters.add(new Help_Message_Filter__c(Help_Message__c=message12.Id, Type__c='Record Field', Field_Name__c='Description', Field_Operator__c='equals', Field_Value__c=''));
        Help_Message__c message13 = new Help_Message__c(Name='TestRecordMessage13', Record_SObjectType__c='Opportunity', Records_Valid_For__c='By Filter', Filter_Type__c='AND', Message_Title__c='TestRecordMessage13', Message__c='TestRecordMessage13', Status__c='Published');
        insert message13;
        messageFilters.add(new Help_Message_Filter__c(Help_Message__c=message13.Id, Type__c='Record Field', Field_Name__c='Amount', Field_Operator__c='equals', Field_Value__c='10000'));
        insert messageFilters;
    }


    /**
     * @description testing a greater than filter
    */
    @isTest
    static void testgreaterthan() {
        test.startTest();
            Account acc = new Account(Name='TestAccount1');
            insert acc;
            Opportunity opp = new Opportunity(Name='DEMO', StageName='Prospecting',CloseDate=system.today(), Amount=10000.00,AccountId=acc.Id);
            insert opp;
            String messages = HelpMessageController.getHelpMessages(opp.Id);
            Map<String, Object> messagesMap = (Map<String, Object>)JSON.deserializeUntyped(messages);
            List<Object> messagesList = (List<Object>) messagesMap.get('messages');
            System.assertEquals(3, messagesList.size(), 'Expected number of responses');
        test.stopTest();
    }

    /**
     * @description testing a greater than or equals filter
    */
    @isTest
    static void testgreaterthanequals() {
        test.startTest();
            Account acc = new Account(Name='TestAccount1');
            insert acc;
            Opportunity opp = new Opportunity(Name='DEMO', StageName='Prospecting',CloseDate=system.today(), Amount=10000.00,AccountId=acc.Id);
            insert opp;
            String messages = HelpMessageController.getHelpMessages(opp.Id);
            Map<String, Object> messagesMap = (Map<String, Object>)JSON.deserializeUntyped(messages);
            List<Object> messagesList = (List<Object>) messagesMap.get('messages');
            System.assertEquals(3, messagesList.size(), 'Expected number of responses');
        test.stopTest();
    }

    /**
     * @description testing a less than filter
    */
    @isTest
    static void testlessthan() {
        test.startTest();
            Account acc = new Account(Name='TestAccount1');
            insert acc;
            Opportunity opp = new Opportunity(Name='DEMO', StageName='Prospecting',CloseDate=system.today(), Amount=10000.00,AccountId=acc.Id);
            insert opp;
            String messages = HelpMessageController.getHelpMessages(opp.Id);
            Map<String, Object> messagesMap = (Map<String, Object>)JSON.deserializeUntyped(messages);
            List<Object> messagesList = (List<Object>) messagesMap.get('messages');
            System.assertEquals(3, messagesList.size(), 'Expected number of responses');
        test.stopTest();
    }

    /**
     * @description testing a less than or equals filter
    */
    @isTest
    static void testlessthanequals() {
        test.startTest();
            Account acc = new Account(Name='TestAccount1');
            insert acc;
            Opportunity opp = new Opportunity(Name='DEMO', StageName='Prospecting',CloseDate=system.today(), Amount=10000.00,AccountId=acc.Id);
            insert opp;
            String messages = HelpMessageController.getHelpMessages(opp.Id);
            Map<String, Object> messagesMap = (Map<String, Object>)JSON.deserializeUntyped(messages);
            List<Object> messagesList = (List<Object>) messagesMap.get('messages');
            System.assertEquals(3, messagesList.size(), 'Expected number of responses');
        test.stopTest();
    }

    /**
     * @description testing a equals string filter
    */
    @isTest
    static void testequalsstring() {
        test.startTest();
            Account acc = new Account(Name='TestAccount1');
            insert acc;
            Opportunity opp = new Opportunity(Name='DEMO STRING CHECK', StageName='Prospecting',CloseDate=system.today(), Amount=20000.00,AccountId=acc.Id);
            insert opp;
            String messages = HelpMessageController.getHelpMessages(opp.Id);
            Map<String, Object> messagesMap = (Map<String, Object>)JSON.deserializeUntyped(messages);
            List<Object> messagesList = (List<Object>) messagesMap.get('messages');
            System.assertEquals(4, messagesList.size(), 'Expected number of responses');
        test.stopTest();
    }

    /**
     * @description testing a equals boolean filter
    */
    @isTest
    static void testequalsbooolean() {
        test.startTest();
            Account acc = new Account(Name='TestAccount1');
            insert acc;
            Contact con = new Contact(LastName='DEMO', AccountID=acc.Id);
            insert con;
            String messages = HelpMessageController.getHelpMessages(con.Id);
            Map<String, Object> messagesMap = (Map<String, Object>)JSON.deserializeUntyped(messages);
            List<Object> messagesList = (List<Object>) messagesMap.get('messages');
            System.assertEquals(3, messagesList.size(), 'Expected number of responses');
        test.stopTest();
    }

    /**
     * @description testing a not equals string filter
    */
    @isTest
    static void testnotequalsstring(){
        test.startTest();
            Account acc = new Account(Name='TestAccount1');
            insert acc;
            Contact con = new Contact(LastName='DEMO', AccountID=acc.Id, DoNotCall=true);
            insert con;
            String messages = HelpMessageController.getHelpMessages(con.Id);
            Map<String, Object> messagesMap = (Map<String, Object>)JSON.deserializeUntyped(messages);
            List<Object> messagesList = (List<Object>) messagesMap.get('messages');
            System.assertEquals(2, messagesList.size(), 'Expected number of responses');
        test.stopTest();
    }

    /**
     * @description testing a not equals boolean filter
    */
    @isTest
    static void testnotqualsboolean() {
        test.startTest();
            Account acc = new Account(Name='TestAccount1');
            insert acc;
            Contact con = new Contact(LastName='DEMO', AccountID=acc.Id, DoNotCall=true);
            insert con;
            String messages = HelpMessageController.getHelpMessages(con.Id);
            Map<String, Object> messagesMap = (Map<String, Object>)JSON.deserializeUntyped(messages);
            List<Object> messagesList = (List<Object>) messagesMap.get('messages');
            System.assertEquals(2, messagesList.size(), 'Expected number of responses');
        test.stopTest();
    }


    /**
    * @description     test processing against account one
    **/
    @isTest
    static void testAccountOne() {
        test.startTest();
            Account acc = new Account(Name='TestAccount1');
            insert acc;
            String messages = HelpMessageController.getHelpMessages(acc.Id);
            Map<String, Object> messagesMap = (Map<String, Object>)JSON.deserializeUntyped(messages);
            List<Object> messagesList = (List<Object>) messagesMap.get('messages');
            System.assertEquals(1, messagesList.size(), 'Expected number of responses');
            ID helpmessage = [SELECT Id 
                                    FROM Help_Message__c 
                                    LIMIT 1].Id;
            String publishHelpMessage = HelpMessageController.changeMessageStatus(helpmessage, 'Published');
            Map<String, Object> publishHelpMessageMap = (Map<String, Object>)JSON.deserializeUntyped(publishHelpMessage);
            system.assertEquals('You have successfully changed the status', publishHelpMessageMap.get('message'), 'We got the correct message back');
            String unPublishHelpMessage = HelpMessageController.changeMessageStatus(helpmessage, 'Unpublished');
            Map<String, Object> unPublishHelpMessageMap = (Map<String, Object>)JSON.deserializeUntyped(unPublishHelpMessage);
            system.assertEquals('You have successfully changed the status', unPublishHelpMessageMap.get('message'), 'We got the correct message back');
            String helpMessageError = HelpMessageController.changeMessageStatus(null, null);
            Map<String, Object> helpMessageErrorMap = (Map<String, Object>)JSON.deserializeUntyped(helpMessageError);
            system.assertNotEquals('You have successfully changed the status', helpMessageErrorMap.get('message'), 'We did not get the correct message back');
            String canViewRecordCheck = HelpMessageController.canViewRecordActions();
            Map<String, Object> canViewRecordCheckMap = (Map<String, Object>)JSON.deserializeUntyped(canViewRecordCheck);
            system.assertEquals(true, (Boolean)canViewRecordCheckMap.get('success'), 'We do have the correct permissions');
        test.stopTest();
    }

    /**
    * @description      test processing against account two
    **/
    @isTest
    static void testAccountTwo() {
        test.startTest();
            Account acc = new Account(Name='TestAccount2');
            insert acc;
            String messages = HelpMessageController.getHelpMessages(acc.Id);
            Map<String, Object> messagesMap = (Map<String, Object>)JSON.deserializeUntyped(messages);
            List<Object> messagesList = (List<Object>) messagesMap.get('messages');
            System.assertEquals(2, messagesList.size(), 'Expected number of responses');
        test.stopTest();
    }


    @isTest 
    static void permissionsTest() {

        Profile profile = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        Blob cryptoKeyBlob = Crypto.GenerateAESKey(128);
        String hexString = EncodingUtil.ConvertTohex(cryptoKeyBlob);
        String uniqueString = hexString.SubString(0,8);
        User user = new User(Alias = uniqueString, Email= uniqueString + '@myorg.com', 
          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
          LocaleSidKey='en_US', ProfileId = profile.Id, 
          TimeZoneSidKey='America/New_York', UserName= uniqueString + '@myorg.com');
        insert user;

        system.runAs(user) {
            String canViewRecordCheck = HelpMessageController.canViewRecordActions();
            Map<String, Object> canViewRecordCheckMap = (Map<String, Object>)JSON.deserializeUntyped(canViewRecordCheck);
            system.assertEquals(false, canViewRecordCheckMap.get('success'), 'We do have the correct permissions');
            List<String> statusList = HelpMessageController.getStatusList(user.Id);
            system.assertEquals(1, statusList.size(), 'We do have the correct permissions');
        }
    }
}