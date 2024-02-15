/**
 * @description       : apex helper class for setup and configuration of the help message record
 * @author            : daniel@hyphen8.com
 * @last modified on  : 15-02-2024
 * @last modified by  : daniel@hyphen8.com
**/
public with sharing class HelpMessageConfigurationHelper {

    private static Map<String, String> mapOfSalesforceObjects = new Map<String, String>();
    private static Map<String, Schema.SObjectField> mapOfFields;
    private static Map<String, String> excludedFieldTypes = new Map<String, String>{'TEXTAREA'=>'TEXTAREA','ADDRESS'=>'ADDRESS','REFERENCE'=>'REFERENCE'};
    private static List<Help_Message_Filter__c> helpFilters;

    @AuraEnabled 
    public static void addNewFilterCondition(String helpMessageId, Integer filterCount){
        Help_Message_Filter__c newFilter = new Help_Message_Filter__c();
        newFilter.Help_Message__c = helpMessageId;
        newFilter.Order__c = filterCount + 1;
        insert newFilter;
    }

    @AuraEnabled
    public static String getHelpFilters(String helpMessageId){
        try {
            getHelpMessageFilterRecords(helpMessageId);
            return generateHelpFilterResponse();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static void getHelpMessageFilterRecords(String helpMessageId){
        helpFilters = [SELECT Id, Order__c, Field_Name__c, Field_Operator__c, Field_Value__c
                                            FROM Help_Message_Filter__c
                                            WHERE Help_Message__c=:helpMessageId
                                            WITH SECURITY_ENFORCED
                                            ORDER BY Order__c ASC];
    }

    private static String generateHelpFilterResponse(){
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
            gen.writeFieldName('filters');
            gen.writeStartArray();
            for(Help_Message_Filter__c filter:helpFilters){
                gen.writeStartObject();
                    gen.writeIdField('id', filter.Id);
                    gen.writeStringField('fieldAPIName', null != filter.Field_Name__c ? filter.Field_Name__c : '');
                    gen.writeStringField('operator', null != filter.Field_Operator__c ? filter.Field_Operator__c : '');
                    gen.writeStringField('fieldValue', null != filter.Field_Value__c ? filter.Field_Value__c : '');
                    gen.writeNumberField('order', filter.Order__c);
                gen.writeEndObject();
            }
            gen.writeEndArray();
        gen.writeEndObject();
        return gen.getAsString();
    }

    /**
    * @description              method to perform updates based on configuration changes made within the help message
    * @param                    helpMessageId 
    * @param                    fieldAPIName 
    * @param                    inputValue 
    * @return                   String         
    **/
    @AuraEnabled 
    public static String saveConfigurationFields(String helpMessageId, String fieldAPIName, String inputValue){
        Help_Message__c helpMessage = [SELECT Id 
                                            FROM Help_Message__c 
                                            WHERE Id=:helpMessageId 
                                            LIMIT 1];
        helpMessage.put(fieldAPIName, inputValue);
        
        if(fieldAPIName == 'Records_Valid_For__c' && inputValue == 'By Filter'){
            Help_Message_Filter__c helpMessageFilter = new Help_Message_Filter__c();
            helpMessageFilter.Help_Message__c = helpMessageId;
            helpMessageFilter.Order__c = 1;
            insert helpMessageFilter;
        } else if(fieldAPIName == 'Records_Valid_For__c'){
            List<Help_Message_Filter__c> helpMessageFilters = [SELECT Id 
                                                                        FROM Help_Message_Filter__c 
                                                                        WHERE Help_Message__c=:helpMessageId];
            delete helpMessageFilters;
            helpMessage.Filter_Type__c = null;
        }
        update helpMessage;

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeBooleanField('success', true);
        gen.writeEndObject();
        return gen.getAsString();
    }
    /**
    * @description              aura method to return a complete list of salesforce objects
    * @return                   String 
    **/
    @AuraEnabled
    public static String getListOfSalesforceObjects(){
        getMapOfSalesforceObjects();
        return generateObjectResponse();
    }

    /**
    * @description              method to get and return a list of salesforce objects
    **/
    private static void getMapOfSalesforceObjects(){
        for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){
            String name = objTyp.getDescribe().getName();
            String label = objTyp.getDescribe().getLabel();
            if(!name.containsignorecase('history') && !name.containsignorecase('tag') && !name.containsignorecase('share') && !name.containsignorecase('feed') && 
                !name.containsignorecase('group') && !name.containsignorecase('public') && !objTyp.getDescribe().isCustomSetting() && objTyp.getDescribe().isCreateable() &&
                objTyp.getDescribe().getRecordTypeInfos().size() > 0){      
                mapOfSalesforceObjects.put(name,label);
            }
        }
    }

    /**
    * @description          method to generate the json string response
    * @return               String 
    **/
    private static String generateObjectResponse(){
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
            gen.writeFieldName('objects');
            gen.writeStartArray();
            for(String objectAPIName:mapOfSalesforceObjects.keySet()){
                String objectName = mapOfSalesforceObjects.get(objectAPIName);
                gen.writeStartObject();
                    gen.writeStringField('label', objectName);
                    gen.writeStringField('value', objectAPIName);
                gen.writeEndObject();
            }
            gen.writeEndArray();
        gen.writeEndObject();
        return gen.getAsString();
    }

    /**
    * @description              method to get fields as a json string for a select object api name
    * @param                    objectAPIName 
    * @return                   String 
    **/
    @AuraEnabled 
    public static String getSelectedObjectFields(String objectAPIName){
        getMapOfFields(objectAPIName);
        return generateFieldsListResponse();
    }

    /**
    * @description              method to get a map of fields for the given object
    * @param objectAPIName 
    **/
    private static void getMapOfFields(String objectAPIName){
        SObjectType objectType = Schema.getGlobalDescribe().get(objectAPIName);
        mapOfFields = objectType.getDescribe().fields.getMap();
    }

    /**
    * @description          method to generate the field list as a json string for return
    * @return               String 
    **/
    private static String generateFieldsListResponse(){
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
            gen.writeFieldName('fields');
            gen.writeStartArray();
            for(String fieldName:mapOfFields.keySet()){
                Schema.SObjectField objectField = mapOfFields.get(fieldName);
                DisplayType fieldType = objectField.getDescribe().getType();
                if(!excludedFieldTypes.containsKey(String.valueOf(fieldType))){
                    gen.writeStartObject();
                        gen.writeStringField('label', (String)objectField.getDescribe().getLabel());
                        gen.writeStringField('value', fieldName);
                        gen.writeStringField('fieldType', String.valueOf(fieldType));
                    gen.writeEndObject();
                }
            }
            gen.writeEndArray();
        gen.writeEndObject();
        return gen.getAsString();
    }


}