/**
 * @description       : Helper class to improve the readability and maintability of the HelpMessageController class
 * @author            : daniel@hyphen8.com
 * @last modified on  : 31/05/2023
 * @last modified by  : daniel@hyphen8.com
 * Modifications Log
 * Ver      Date            Author                  Modification
 * 1.0      04/03/2022      daniel@hyphen8.com      Initial Version
**/
@SuppressWarnings('PMD.CognitiveComplexity')
public with sharing class HelpMessageHelper {


    /**
     * @description     getSObjectFieldTypeRelationship Helper to process getting field types on relationships
     * @param           objecttype 
     * @param           sOQLFields 
     * @return          DisplayType
    */
    public static DisplayType getSObjectFieldTypeRelationship(SObjectType objectType, List<String> sOQLFields) {
        DisplayType fieldType = null;
        string sOQLRelationship = sOQLFields.remove(0);
        Map<String, Schema.SObjectField> fsMap =  objectType.getDescribe().fields.getMap();
        for(Schema.SObjectField fld : fsMap.values()) {
            DescribeFieldResult dfr = fld.getDescribe();
            if(dfr.getRelationshipName()==sOQLRelationship) 
            {
                if(!dfr.isNamePointing()) 
                {
                    List<Schema.sObjectType> rels = dfr.getReferenceTo();
                    fieldType = getSObjectFieldType(rels[0], String.join(sOQLFields, '.'));
                }
                break;
            }
        }
        return fieldType;
    }
    
    /**
     * @description     getHelpFilterMessages Helper to process filters on help messages
     * @param           withFilters 
     * @param           sObjectType 
     * @param           recordId 
     * @return          List<Help_Message__c>
    */
    public static List<Help_Message__c> getHelpFilterMessages(List<Help_Message__c> withFilters, string sObjectType, string recordId){
        List<Help_Message__c> results = new List<Help_Message__c>();
        Set<String> recordFields = new Set<String>();
        for(Help_Message__c rm : withFilters) {
            for(Help_Message_Filter__c filter : rm.Help_Message_Filters__r) {
                if(filter.Field_Name__c != null) {
                    recordFields.add(filter.Field_Name__c);
                    HelpMessageController.filterFields.add(filter.Field_Name__c);
                }
            }                
        }
        recordFields.add('Id');
        String query = 'SELECT ' + String.join(new List<String>(recordFields),',') + ' FROM ' + sObjectType + ' WHERE Id=:recordId LIMIT 1';
        SObject record = Database.query(String.escapeSingleQuotes(query));
        for(Help_Message__c rm : withFilters) {
            if(rm.Help_Message_Filters__r.size() > 0){
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
    * @param        record
    * @param        sOQLField
    * @return       Object 
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
                result = getSObjectField(record.getSobject(sOQLRelationship), String.join(sOQLFields, '.'));              
            }
        }        
        return result;        
    }


    /**
    * @description  getSObjectFieldType - Will take in a field name which can be a referenced field e.g Object.RecordType.DeveloperName and parse the object dynamically and return the fieldType of the final field
    * @param        objectType
    * @param        sOQLField
    * @return       DisplayType
    */
    public static DisplayType getSObjectFieldType(SObjectType objectType, string sOQLField) 
    {        
        DisplayType fieldType = null;
        List<String> sOQLFields = sOQLField.Split('\\.');
        if(sOQLFields.size() == 1) {
            if(objectType.getDescribe().fields.getMap().containsKey(sOQLField)) {
                fieldType = objectType.getDescribe().fields.getMap().get(sOQLField).getDescribe().getType();    
            }
        } else {
            fieldtype = getSObjectFieldTypeRelationship(objectType, sOQLFields);
        }
        return fieldType;
    }

    /**
     * @description     fieldFilterMatch - method support the validaty of the filter logic
     * @param           record
     * @param           filterLogic 
     * @param           filters
     * @return          booloean
    */
    public static boolean fieldFilterMatch(SObject record, String filterLogic, List<Help_Message_Filter__c> filters) 
    {
        boolean result = false;
        if(filterLogic==HelpMessageConstants.FILTER_LOGIC_OR) {
            result = false;
        } else if(filterLogic==HelpMessageConstants.FILTER_LOGIC_AND) {
            result = true;
        }      
        for(Help_Message_Filter__c filter : filters) {  
            DisplayType fieldType = getSObjectFieldType(record.getSObjectType(), filter.Field_Name__c);
            boolean filterCheck = handlefilterchecks(filter, record, fieldType);
            if(filterLogic==HelpMessageConstants.FILTER_LOGIC_OR){
                result = result || filterCheck;
            } else if(filterLogic==HelpMessageConstants.FILTER_LOGIC_AND) {
                result = result && filterCheck;
            }
        }           
        return result;
    }

    /**
    * @description  handlefilterchecks - will handle the filtering of against the record
    * @param        filter
    * @param        record
    * @param        fieldType
    * @return       boolean
    */
    public static boolean handlefilterchecks(Help_Message_Filter__c filter, SObject record, DisplayType fieldType) {
        boolean filterCheck;
        if(filter.Field_Operator__c==HelpMessageConstants.FIELD_OPERATOR_EQUALS) {
            Object fieldResult = HelpMessageHelper.getSObjectField(record, filter.Field_Name__c);
            if (fieldType == Schema.DisplayType.BOOLEAN) {
                filterCheck = (fieldResult==Boolean.valueOf(filter.Field_Value__c));        
            } else if (fieldType == Schema.DisplayType.STRING || fieldType == Schema.DisplayType.PICKLIST && !String.isBlank(filter.Field_Value__c)) {
                    List<String> splitValues = filter.Field_Value__c.split(HelpMessageConstants.FIELD_VALUE_OR_DELIMITER);
                    filterCheck = splitValues.contains(String.valueOf(fieldResult));
            } else {
                filterCheck = (fieldResult==filter.Field_Value__c); 
            }                         
        } else if(filter.Field_Operator__c==HelpMessageConstants.FIELD_OPERATOR_NOT_EQUALS) {
            filterCheck = HelpMessageHelper.getSObjectField(record, filter.Field_Name__c)!=filter.Field_Value__c;                         
        } else if(filter.Field_Operator__c==HelpMessageConstants.FIELD_OPERATOR_GREATER_THAN) {
            decimal valuecheck = decimal.valueof(filter.Field_Value__c);
            decimal objectvalue = (decimal)HelpMessageHelper.getSObjectField(record, filter.Field_Name__c);
            filterCheck = objectvalue>valuecheck; 
        } else if(filter.Field_Operator__c==HelpMessageConstants.FIELD_OPERATOR_GREATER_THAN_EQUALS) {
            decimal valuecheck = decimal.valueof(filter.Field_Value__c);
            decimal objectvalue = (decimal)HelpMessageHelper.getSObjectField(record, filter.Field_Name__c);
            filterCheck = objectvalue>=valuecheck; 
        } else if(filter.Field_Operator__c==HelpMessageConstants.FIELD_OPERATOR_LESS_THAN) {
            decimal valuecheck = decimal.valueof(filter.Field_Value__c);
            decimal objectvalue = (decimal)HelpMessageHelper.getSObjectField(record, filter.Field_Name__c);
            filterCheck = objectvalue<valuecheck; 
        } else if(filter.Field_Operator__c==HelpMessageConstants.FIELD_OPERATOR_LESS_THAN_EQUALS) {
            decimal valuecheck = decimal.valueof(filter.Field_Value__c);
            decimal objectvalue = (decimal)HelpMessageHelper.getSObjectField(record, filter.Field_Name__c);
            filterCheck = objectvalue<=valuecheck; 
        }
        return filterCheck;
    }
}
