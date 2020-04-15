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

        insert messageFilters;

    }

    static testMethod void testAccountOne() {

        Account acc = new Account(Name='TestAccount1');
        insert acc;

        List<Help_Message__c> messages = HelpMessageController.getHelpMessages(acc.Id);

        //Should return first and second messages
        System.assertEquals(1, messages.size(), 'Expected number of responses');

        //Check first message name = TestRecordMessage1 and second message name = TestRecordMessage2
        System.assertEquals(messages[0].Name, 'TestRecordMessage1', 'Expected value in response');

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
        }

    }

}