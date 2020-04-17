/**
 * @description     Controller for the in record help message component
 *                  will return dynamically messages driven by the type of record and filters on the record
 * @author          hyphen8.com
 * @date            15/04/2020
 * @group           Controller
*/
public with sharing class HelpMessageController {
   
    /**
     * @description     method that will support the handling of publishing and unpublishing actions
     * @param           string recordId - this is the message to process
     * @param           string status - this is the status that we will change
     * @return          string return message of success or failure
    */
    @AuraEnabled
    public static string changeMessageStatus(string recordId, string status){
        string returnmessage;
        try {
            Help_Message__c helpmessage = [SELECT ID, Status__c FROM Help_Message__c WHERE ID=:recordId LIMIT 1];
            helpmessage.Status__c = status;
            update helpmessage;
            returnmessage = 'You have successfully changed the status';
        } catch(Exception e){
            returnmessage = 'We encountered an error > ' + e.getMessage();
        }
        return returnmessage;
    }

    /**
     * @description     method to confirm if the current user is a member of the editor permission set
     * @return          boolean true yes they are false no they are not
    */
    @AuraEnabled
    public static boolean canViewRecordActions(){
        ID userID = UserInfo.getUserId();
        boolean returnvalue;
        try {
            ID helpmessageeditorpermissionset = [SELECT PermissionSetId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Help_Message_Editor' AND AssigneeId=:UserId].PermissionSetId;
            returnvalue = true;
        } catch (Exception e){
            system.debug(e.getMessage());
            returnvalue = false;
        }
        return returnvalue;
    }


    /**
     * @description     simple help to confirm what statuses we should be looking for based on the current user access the help messages
     * @param           string userId
     * @return          List<String> listofstatuses
    */
    public static List<String> getStatusList(string userId){
        List<String> returnlist;
        try {
            ID helpmessageeditorpermissionset = [SELECT PermissionSetId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Help_Message_Editor' AND AssigneeId=:UserId].PermissionSetId;
            returnlist = new List<String>{'Draft','Published'};
        } catch (Exception e){
            returnlist = new List<String>{'Published'};
        }
        return returnlist;
    }

    /**
     * @description     getHelpMessages Aura method used for pulling in the messages to display based on the recordID we are on
     * @param           recordId ID of the record that we are currently on
     * @return          List<Help_Message__c> a list of record messages to return
    */
    @AuraEnabled
    public static List<Help_Message__c> getHelpMessages(Id recordId){

        List<String> statuslist = HelpMessageController.getStatusList(UserInfo.getUserId());

        List<Help_Message__c> results = new List<Help_Message__c>();

        List<Help_Message__c> withFilters = new List<Help_Message__c>();

        String sObjectType = recordId.getSobjectType().getDescribe().getName();
        system.debug('###sObjectType: ' + sObjectType);
        
        for(Help_Message__c rm : [SELECT Id, Name, Is_Draft__c, Message_Title__c, Message__c, Records_Valid_For__c, Filter_Type__c, Custom_Filter_Logic__c, Status__c, (SELECT Id, Name, Type__c, Field_Name__c, Field_Operator__c, Field_Value__c FROM Help_Message_Filters__r ORDER BY CreatedDate) FROM Help_Message__c WHERE Record_SObjectType__c=:sObjectType AND Status__c IN:statuslist ORDER BY Order__c ASC]) {
            system.debug('###rm: ' + rm);  
            if(rm.Records_Valid_For__c == 'All') {
                results.add(rm);
            } else {
                //Only add if there are filters
                if(!rm.Help_Message_Filters__r.isEmpty()) {
                    withFilters.add(rm);
                }
            }     
        }

        // if we have filters on the help message lets get the type for the filter
        if(!withFilters.isEmpty()) {
            List<Help_Message__c> filtererlist = HelpMessageHelper.getHelpFilterMessages(withFilters, sObjectType, recordId);
            results.addAll(filtererlist);
        }

        return results;

    }
}