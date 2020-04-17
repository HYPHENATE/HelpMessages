/**
 * @description     Helper class to improve the readability and maintability of the HelpMessageController class
 * @author          daniel@hyphen8.com
 * @date            17/04/2020
 * @group           Helper
*/
public with sharing class HelpMessageHelper {


    /**
     * @description     getSObjectFieldTypeRelationship Helper to process getting field types on relationships
     * @param           SObjectType objecttype - the object we are checking the field on
     * @param           List<String> sOQLFields - list of field relationship
     * @return          DisplayType a list of record messages to return
    */
    public static DisplayType getSObjectFieldTypeRelationship(SObjectType objectType, List<String> sOQLFields){
        // setup return fieldtype
        DisplayType fieldType = null;

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
        return fieldType;
    }
    
    /**
     * @description     getHelpFilterMessages Helper to process filters on help messages
     * @param           List<Help_Message__c> withFilters a list of help messages with filters
     * @param           string sObjectType - the type of object we are working with
     * @param           recordId ID of the record that we are currently on
     * @return          List<Help_Message__c> a list of record messages to return
    */
    public static List<Help_Message__c> getHelpFilterMessages(List<Help_Message__c> withFilters, string sObjectType, string recordId){
        
        // return list setup
        List<Help_Message__c> results = new List<Help_Message__c>();
    
        //Need to create a query that includes all fields references in all filters so we can then check
        Set<String> recordFields = new Set<String>();

        // loop through the filter list
        for(Help_Message__c rm : withFilters) {
            
            // for each filter list records process them
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
                //try {
                result = getSObjectField(record.getSobject(sOQLRelationship), String.join(sOQLFields, '.'));
                //} catch (Exception ex) {
                //    result = null;
                //}                
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
            fieldtype = getSObjectFieldTypeRelationship(objectType, sOQLFields);
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
        
        //If And or OR - Advanced to be developed
        if(filterLogic==HelpMessageConstants.FILTER_LOGIC_OR) {
            result = false;
        } else if(filterLogic==HelpMessageConstants.FILTER_LOGIC_AND) {
            result = true;
        }
            
        for(Help_Message_Filter__c filter : filters) {
            
            system.debug('###filter.Field_Name__c: ' + filter.Field_Name__c);
            system.debug('###filter.Field_Value__c: ' + filter.Field_Value__c);
            
            DisplayType fieldType = getSObjectFieldType(record.getSObjectType(), filter.Field_Name__c);
            system.debug('###fieldType: ' + fieldType);

            //Need to support cross object reference link RecordType.Name
            boolean filterCheck = handlefilterchecks(filter, record, fieldType);

            if(filterLogic==HelpMessageConstants.FILTER_LOGIC_OR){
                result = result || filterCheck;
            } else if(filterLogic==HelpMessageConstants.FILTER_LOGIC_AND) 
            {
                result = result && filterCheck;
            }
            
        }           
        
        system.debug('###result: ' + result);        
        return result;
    }

    /**
    * @description  handlefilterchecks - will handle the filtering of against the record
    * @param        Help_Message_Filter__c filter - the filter that we need to check if true
    * @param        SObject record - the record that we are checking
    * @param        DisplayType fieldType - the field type that we are processing
    * @return       boolean - confirms if we have match and if we should display the message
    */
    public static boolean handlefilterchecks(Help_Message_Filter__c filter, SObject record, DisplayType fieldType){
        
        //set up our return boolean
        boolean filterCheck;

        // check if equals
        if(filter.Field_Operator__c==HelpMessageConstants.FIELD_OPERATOR_EQUALS) {
            Object fieldResult = HelpMessageHelper.getSObjectField(record, filter.Field_Name__c);
            if (fieldType == Schema.DisplayType.BOOLEAN){
                filterCheck = (fieldResult==Boolean.valueOf(filter.Field_Value__c));        
            } else if (fieldType == Schema.DisplayType.STRING || fieldType == Schema.DisplayType.PICKLIST && !String.isBlank(filter.Field_Value__c)){
                    List<String> splitValues = filter.Field_Value__c.split(HelpMessageConstants.FIELD_VALUE_OR_DELIMITER);
                    system.debug('###splitValues: ' + splitValues);        
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
