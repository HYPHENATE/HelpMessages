/**
 * @description     Controller for the in record help message component
 *                  will return dynamically messages driven by the type of record and filters on the record
 * @author          hyphen8.com
 * @date            15/04/2020
*/
public with sharing class HelpMessageController {
   
    public static final String FILTER_LOGIC_AND = 'AND';
    public static final String FILTER_LOGIC_OR = 'OR';
    
    public static final String FIELD_OPERATOR_EQUALS = 'equals';
    public static final String FIELD_OPERATOR_NOT_EQUALS = 'not equal to';

    public static final String FIELD_VALUE_OR_DELIMITER = ',';

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

        if(!withFilters.isEmpty()) {
            system.debug('###withFilters: ' + withFilters);
            system.debug('###withFilters.Size: ' + withFilters.Size());
        
            //Need to create a query that includes all fields references in all filters so we can then check
            Set<String> recordFields = new Set<String>();

            for(Help_Message__c rm : withFilters) {
                //for each filter
                for(Help_Message_Filter__c filter : rm.Help_Message_Filters__r) {
                    system.debug('###filter: ' + filter);            
                    if(filter.Field_Name__c != null) {
                        recordFields.add(filter.Field_Name__c);
                    }
                }                
            }

            system.debug('###recordFields: ' + recordFields);
            recordFields.add('Id');

            String query = 'SELECT ' + String.join(new List<String>(recordFields),',') + ' FROM ' + sObjectType + ' WHERE Id=:recordId LIMIT 1';
            System.debug('####query: ' + query);
            SObject record = Database.query(query);
            System.debug('####record: ' + record);

            //now iterate over each message with a filter and check if it matches
            for(Help_Message__c rm : withFilters) {
                if(fieldFilterMatch(record, rm.Filter_Type__c, rm.Help_Message_Filters__r)) {
                    results.add(rm);
                }
            }
            
        }

        return results;

    }
    
    /**
    * @description  Will take in a field name which can be a referenced field e.g Object.RecordType.DeveloperName 
    *               and parse the object dynamically and return the value of that field from the record supplied
    * @param        Sobject record this is the record that we are reviewing
    * @param        string sOQLField this is the field on the record that we need to review
    * @return       Object this is the object with the value in it
    */
    public static Object getSObjectField(sObject record, string sOQLField) {
        
        Object result = null;
        if (sOQLField != null) {
            List<String> sOQLFields = sOQLField.Split('\\.');
            
            if(sOQLFields.size() == 1) {
                try {
                    result = record.get(sOQLFields[0]);
                } catch (Exception ex) {
                    result = null;
                }                
            } else {
                string sOQLRelationship = sOQLFields.remove(0);
                try {
                    result = getSObjectField(record.getSobject(sOQLRelationship), String.join(sOQLFields, '.'));
                } catch (Exception ex) {
                    result = null;
                }                
            }
        }        
        return result;        
    }

    /**
    * @description  getSObjectFieldType - Will take in a field name which can be a referenced field e.g Object.RecordType.DeveloperName and parse the object dynamically and return the fieldType of the final field
    * @param        string SOQLField - confirms the SOQL API Name of the field
    * @param        SObjectType objectType - confirms what objecttype we are working with
    * @return       DisplayType - confirmed what or how we are going to display the field
    */
    public static DisplayType getSObjectFieldType(SObjectType objectType, string sOQLField) {        
        
        system.debug('###objectType: ' + objectType);
        system.debug('###SOQLField: ' + sOQLField);
        
        DisplayType fieldType = null;

        List<String> sOQLFields = sOQLField.Split('\\.');
        system.debug('###SOQLFields: ' + sOQLFields);
                
        if(sOQLFields.size() == 1) {
            if(objectType.getDescribe().fields.getMap().containsKey(sOQLField)) {
                fieldType = objectType.getDescribe().fields.getMap().get(sOQLField).getDescribe().getType();    
            }
        } else {
            //Need to identify which object this refernce relates to so remove from SOQLFields into SOQLRelationship
            system.debug('###SOQLFields[0]: ' + sOQLFields[0]);
            string sOQLRelationship = sOQLFields.remove(0);
            system.debug('###SOQLRelationship: ' + sOQLRelationship);
            system.debug('###SOQLFields: ' + sOQLFields);
            
            //For each field find out the relationship name and if this matches then get the SObjectType of this and iterate
            Map<String, Schema.SObjectField> fsMap =  objectType.getDescribe().fields.getMap();
            for(Schema.SObjectField fld : fsMap.values()) {
                DescribeFieldResult dfr = fld.getDescribe();
                if(dfr.getRelationshipName()==sOQLRelationship) {
                    //if isNamePointing then this field can hold multiple types of objects and skip as we would need to query actual value to find type - for now!
                    system.debug('###fldisNamePointing(): ' + dfr.isNamePointing());
                    if(!dfr.isNamePointing()) {
                        List<Schema.sObjectType> rels = dfr.getReferenceTo();
                        fieldType = getSObjectFieldType(rels[0], String.join(sOQLFields, '.'));
                    }
                    // break out now as no need to carry on
                    break;
                }
            }  
        }
        return fieldType;
    }

    /**
     * @description     fieldFilterMatch - method support the validaty of the filter logic
     * @param           string filterLogic - suggested logic from the record message record
     * @param           SObject - the record that the filter logic / record message will be displayed on
     * @param           List<Help_Message_Filter__c> list of filters applied to the record message
     * @return          booloean - confirmation the the filter logic matches
    */
    public static boolean fieldFilterMatch(SObject record, String filterLogic, List<Help_Message_Filter__c> filters) {
        
        //Quick filter match code
        boolean result = false;
            
        system.debug('###filterLogic: ' + filterLogic);
        system.debug('###filters: ' + filters);
        
        //for each filter
        if(filters.size()>0) {
            
            
            //If And or OR - Advanced to be developed
            if(filterLogic==FILTER_LOGIC_OR) {
                result = false;
            } else if(filterLogic==FILTER_LOGIC_AND) {
                result = true;
            }
            
            for(Help_Message_Filter__c filter : filters) {
                
                system.debug('###filter.Field_Name__c: ' + filter.Field_Name__c);
                system.debug('###filter.Field_Value__c: ' + filter.Field_Value__c);
                
                DisplayType fieldType = getSObjectFieldType(record.getSObjectType(), filter.Field_Name__c);
                system.debug('###fieldType: ' + fieldType);

                //Need to support cross object reference link RecordType.Name
                boolean filterCheck;
                if(filter.Field_Operator__c==FIELD_OPERATOR_EQUALS) {
                    Object fieldResult = getSObjectField(record, filter.Field_Name__c);
                    if (fieldType == Schema.DisplayType.BOOLEAN){
                        filterCheck = (fieldResult==Boolean.valueOf(filter.Field_Value__c));        
                    } else if (fieldType == Schema.DisplayType.STRING || fieldType == Schema.DisplayType.PICKLIST){
                        // if value is not null then split to allow comma delimted
                        if(!String.isBlank(filter.Field_Value__c)) {
                            //Split value by comma to allow or - if no comma will return string is first item in list
                            List<String> splitValues = filter.Field_Value__c.split(FIELD_VALUE_OR_DELIMITER);
                            system.debug('###splitValues: ' + splitValues);        
                            filterCheck = splitValues.contains(String.valueOf(fieldResult));
                        } else {
                            //just check and compare as normal
                            filterCheck = (fieldResult==filter.Field_Value__c);
                        }
                        
                    } else {
                       filterCheck = (fieldResult==filter.Field_Value__c); 
                    }
                    
                                            
                } else if(filter.Field_Operator__c==FIELD_OPERATOR_NOT_EQUALS) {
                    filterCheck = getSObjectField(record, filter.Field_Name__c)!=filter.Field_Value__c;                         
                } 
                    
                if(filterLogic==FILTER_LOGIC_OR){
                    result = result || filterCheck;
                } else if(filterLogic==FILTER_LOGIC_AND) 
                {
                    result = result && filterCheck;
                }
                
            }           
        } 
        system.debug('###result: ' + result);        
        return result;
    }
}