/**
 * @description       : Controller for the in record help message component
 *                      will return dynamically messages driven by the type of record and filters on the record
 * @author            : daniel@hyphen8.com
 * @last modified on  : 14-02-2024
 * @last modified by  : daniel@hyphen8.com
**/

public with sharing class HelpMessageController {

    public static Set<String> filterFields = new Set<String>();
    private static Help_Message_Configuration__c helpConfiguration;
    private static Help_Message_Like__c userLike;

    /**
    * @description          method to support with the submission of likes against a help message
    * @param                helpMessageId 
    **/
    @AuraEnabled
    public static void submitLike(String helpMessageId){
        try {
            getHelpConfiguration();
            getUserLikeRecord(helpMessageId);
            String helpMessageStatus = helpMessageStatus(helpMessageId);
            if(null == userLike && helpMessageStatus == 'Published' && null != helpConfiguration && helpConfiguration.Enabled_Found_Useful__c){
                Help_Message_Like__c newLike = new Help_Message_Like__c();
                newLike.Help_Message__c = helpMessageId;
                insert newLike;
            } else if(null != userLike){
                delete userLike;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description          method to generate the view entry record to support analytics
    * @param                helpMessageId 
    **/
    @AuraEnabled
    public static void generateViewEntry(String helpMessageId){
        try {
            getHelpConfiguration();
            Boolean hasViewLoggedToday = hasViewHelpToday(helpMessageId);
            String helpMessageStatus = helpMessageStatus(helpMessageId);
            if(!hasViewLoggedToday && null != helpConfiguration && helpConfiguration.Enable_Analytics__c && helpMessageStatus == 'Published'){
                Help_Message_View__c helpMessageView = new Help_Message_View__c();
                helpMessageView.Help_Message__c = helpMessageId;
                insert helpMessageView;
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    /**
    * @description          method to pull out the help configuration analytics custom settings
    **/
    private static void getHelpConfiguration(){
        helpConfiguration = Help_Message_Configuration__c.getOrgDefaults();
    }

    /**
    * @description          method to get the help message status
    * @param                helpMessageId 
    * @return               String 
    **/
    private static String helpMessageStatus(String helpMessageId){
        return [SELECT Status__c 
                        FROM Help_Message__c 
                        WHERE Id=:helpMessageId
                        LIMIT 1].Status__c;
    }

    /**
    * @description          method to check and confirm if the user has viewed the help message today
    * @param                helpMessageId 
    * @return               Boolean 
    **/
    private static Boolean hasViewHelpToday(String helpMessageId){
        try {
            Help_Message_View__c helpMessageView = [SELECT Id FROM Help_Message_View__c
                                                            WHERE CreatedById=:UserInfo.getUserId()
                                                            AND Help_Message__c=:helpMessageId
                                                            AND CreatedDate= TODAY
                                                            LIMIT 1];
            return true;
        } catch (Exception e){
            return false;
        }
    }
    
    /**
    * @description          method to get the current users like record if it exists
    * @param                helpMessageId 
    **/
    private static void getUserLikeRecord(String helpMessageId){
        try {
            userLike = [SELECT Id 
                            FROM Help_Message_Like__c 
                            WHERE CreatedById=:UserInfo.getUserId() 
                            AND Help_Message__c=:helpMessageId
                            LIMIT 1];
        } catch (Exception e){
            // no like is found so no action required
        }
    }
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
        for(Help_Message__c rm : [SELECT Id, Name, Is_Draft__c, Message_Title__c, Message__c, Records_Valid_For__c, Filter_Type__c, Custom_Filter_Logic__c, Status__c, Views__c, Likes__c,   
                                        (SELECT Id, Name, Type__c, Field_Name__c, Field_Operator__c, Field_Value__c 
                                                                    FROM Help_Message_Filters__r 
                                                                    ORDER BY CreatedDate),
                                        (SELECT Id
                                                FROM Help_Message_Likes__r
                                                WHERE CreatedById=:UserInfo.getUserId())
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
            gen.writeFieldName('messages');
            gen.writeStartArray();
                for(Help_Message__c helpMessage:results){
                    gen.writeStartObject();
                        gen.writeIdField('id', helpMessage.Id);
                        gen.writeStringField('title', null != helpMessage.Message_Title__c ? helpMessage.Message_Title__c : '');
                        gen.writeStringField('message', null != helpMessage.Message__c ? helpMessage.Message__c : '');
                        gen.writeNumberField('viewCount', helpMessage.Views__c);
                        gen.writeNumberField('likeCount', helpMessage.Likes__c);
                        List<Help_Message_Like__c> helpMessageLikes = helpMessage.Help_Message_Likes__r;
                        if(null != helpMessageLikes && helpMessageLikes.size() > 0){
                            gen.writeStringField('likeLabel', 'Liked');
                            gen.writeBooleanField('likeIsPressed', true);
                            gen.writeStringField('likeButtonAssistiveText', 'Press if you no longer find this help message useful');
                        } else {
                            gen.writeStringField('likeLabel', 'Like');
                            gen.writeBooleanField('likeIsPressed', false);
                            gen.writeStringField('likeButtonAssistiveText', 'Press if you found this help message useful');
                        }
                        gen.writeBooleanField('isDraft', helpMessage.Is_Draft__c);

                    gen.writeEndObject();
                }
            gen.writeEndArray();
        gen.writeEndObject();
        return gen.getAsString();
    }
}