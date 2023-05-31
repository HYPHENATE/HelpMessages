/**
 * @description       : Controller for the in record help message component
 *                      will return dynamically messages driven by the type of record and filters on the record
 * @author            : daniel@hyphen8.com
 * @last modified on  : 31/05/2023
 * @last modified by  : daniel@hyphen8.com
 * Modifications Log
 * Ver      Date            Author                  Modification
 * 1.0      04/03/2022      daniel@hyphen8.com      Initial Version
**/
public with sharing class HelpMessageController {

    public static Set<String> filterFields = new Set<String>();
   
    /**
     * @description     method that will support the handling of publishing and unpublishing actions
     * @param           recordId
     * @param           status 
     * @return          string 
    */
    @SuppressWarnings('PMD.ApexCRUDViolation')
    @AuraEnabled
    public static String changeMessageStatus(string recordId, string status){
        String returnmessage;
        
        try {
            Help_Message__c helpmessage = [SELECT ID, Status__c 
                                                    FROM Help_Message__c 
                                                    WHERE ID=:recordId
                                                    LIMIT 1];
            helpmessage.Status__c = status;
            update helpmessage;
            returnmessage = 'You have successfully changed the status';
        
        } catch(Exception e) {
        
            returnmessage = 'We encountered an error > ' + e.getMessage();
        
        }

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
            gen.writeStringField('message', returnmessage);
        gen.writeEndObject();
        return gen.getAsString();
    }

    /**
     * @description     method to confirm if the current user is a member of the editor permission set
     * @return          boolean
    */
    @SuppressWarnings('PMD.ApexCRUDViolation')
    @AuraEnabled
    public static String canViewRecordActions(){
        ID userID = UserInfo.getUserId();
        Boolean returnValue;
        String message = '';
        try {
            ID helpMessageEditorPermissionSet = [SELECT PermissionSetId 
                                                            FROM PermissionSetAssignment 
                                                            WHERE PermissionSet.Name = 'Help_Message_Editor' AND AssigneeId=:UserId].PermissionSetId;
            returnvalue = true;
        } catch (Exception e){
            system.debug(e.getMessage());
            message = e.getMessage();
            returnValue = false;
        }

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
            gen.writeBooleanField('success', returnvalue);
            gen.writeStringField('message', message);
        gen.writeEndObject();
        return gen.getAsString();
    }


    /**
     * @description     simple help to confirm what statuses we should be looking for based on the current user access the help messages
     * @param           userId string 
     * @return          List<String>
    */
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public static List<String> getStatusList(string userId){
        List<String> returnlist;
        try {
            ID helpmessageeditorpermissionset = [SELECT PermissionSetId 
                                                        FROM PermissionSetAssignment 
                                                        WHERE PermissionSet.Name = 'Help_Message_Editor' AND AssigneeId=:UserId].PermissionSetId;
            returnlist = new List<String>{'Draft','Published'};
        } catch (Exception e){
            returnlist = new List<String>{'Published'};
        }
        return returnlist;
    }

    /**
     * @description     getHelpMessages Aura method used for pulling in the messages to display based on the recordID we are on
     * @param           recordId
     * @return          List<Help_Message__c>
    */
    @SuppressWarnings('PMD.ApexCRUDViolation')
    @AuraEnabled
    public static String getHelpMessages(Id recordId){
        List<String> statuslist = HelpMessageController.getStatusList(UserInfo.getUserId());
        filterFields.add('Id');
        List<Help_Message__c> results = new List<Help_Message__c>();
        List<Help_Message__c> withFilters = new List<Help_Message__c>();
        String sObjectType = recordId.getSobjectType().getDescribe().getName();
        for(Help_Message__c rm : [SELECT Id, Name, Is_Draft__c, Message_Title__c, Message__c, Records_Valid_For__c, Filter_Type__c, Custom_Filter_Logic__c, Status__c, 
                                        (SELECT Id, Name, Type__c, Field_Name__c, Field_Operator__c, Field_Value__c 
                                                                    FROM Help_Message_Filters__r 
                                                                    ORDER BY CreatedDate) 
                                        FROM Help_Message__c 
                                        WHERE Record_SObjectType__c=:sObjectType AND Status__c IN:statuslist 
                                        ORDER BY Order__c ASC]) {
            if(rm.Records_Valid_For__c == 'All') {
                results.add(rm);
            } else {
                if(!rm.Help_Message_Filters__r.isEmpty()) {
                    withFilters.add(rm);
                }
            }     
        }
        if(!withFilters.isEmpty()) {
            List<Help_Message__c> filtererlist = HelpMessageHelper.getHelpFilterMessages(withFilters, sObjectType, recordId);
            results.addAll(filtererlist);
        }

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
            gen.writeFieldName('fieldArray');
            gen.writeStartArray();
            for(String field:filterFields){

                gen.writeStartObject();
                    gen.writeStringField('fieldAPIName', sObjectType + '.' + field);
                gen.writeEndObject();
            }
            gen.writeEndArray();
            // gen.writeObjectField('fieldArray', filterFields);
            gen.writeFieldName('messages');
            gen.writeStartArray();
                for(Help_Message__c helpMessage:results){
                    gen.writeStartObject();
                        gen.writeIdField('id', helpMessage.Id);
                        gen.writeStringField('title', null != helpMessage.Message_Title__c ? helpMessage.Message_Title__c : '');
                        gen.writeStringField('message', null != helpMessage.Message__c ? helpMessage.Message__c : '');
                        gen.writeBooleanField('isDraft', helpMessage.Is_Draft__c);

                    gen.writeEndObject();
                }
            gen.writeEndArray();
        gen.writeEndObject();
        return gen.getAsString();
    }
}