/**
 * @description       : Controller class to support with the management of help message filters during configuration
 * @author            : daniel@hyphen8.com
 * @last modified on  : 21/02/2024
 * @last modified by  : daniel@hyphen8.com
**/
public with sharing class HelpMessageConfigurationFilters {

    /**
    * @description              method that will delete a filter when requested from the configuration component and then reorder existing items
    * @param                    messageFilterId 
    * @return                   String 
    **/
    @AuraEnabled
    public static String deleteConditionFilter(String messageFilterId){
        try {
            Help_Message_Filter__c messageFilter = [SELECT Id, Help_Message__c, Order__c 
                                                                FROM Help_Message_Filter__c 
                                                                WHERE Id=:messageFilterId 
                                                                WITH SECURITY_ENFORCED 
                                                                LIMIT 1];
            List<Help_Message_Filter__c> existingFiltersToUpdate = new List<Help_Message_Filter__c>();
            Integer orderUpdate = 1;
            for(Help_Message_Filter__c existingFilter:[SELECT Id, Order__c 
                                                                    FROM Help_Message_Filter__c 
                                                                    WHERE Id!=:messageFilterId 
                                                                    AND Help_Message__c=:messageFilter.Help_Message__c 
                                                                    WITH SECURITY_ENFORCED 
                                                                    ORDER BY Order__c DESC]){
                System.debug(existingFilter);
                existingFilter.Order__c = orderUpdate;
                orderUpdate = orderUpdate + 1;
                existingFiltersToUpdate.add(existingFilter);
            }

            Help_Message__c currentHelpMessage = [SELECT Id, Records_Valid_For__c, Filter_Type__c
                                                        FROM Help_Message__c 
                                                        WHERE Id=:messageFilter.Help_Message__c 
                                                        WITH SECURITY_ENFORCED 
                                                        LIMIT 1];
            if(currentHelpMessage.Records_Valid_For__c == 'By Filter' && currentHelpMessage.Filter_Type__c == 'CUSTOM'){
                currentHelpMessage.Custom_Filter_Logic__c = '';
                update currentHelpMessage;
            }
            update existingFiltersToUpdate;
            delete messageFilter;
            
            return '';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    /**
    * @description              method that is used to support with the saving of values on a specific help message filter record
    * @param                    helpMessageFilterId 
    * @param                    fieldAPIName 
    * @param                    filterValue 
    * @return                   String 
    **/
    @AuraEnabled
    public static String handleSaveFilterValues(String helpMessageFilterId, String fieldAPIName, String filterValue){
        try {
            Help_Message_Filter__c helpMessageFilter = [SELECT Id 
                                                            FROM Help_Message_Filter__c 
                                                            WHERE Id=:helpMessageFilterId 
                                                            WITH SECURITY_ENFORCED 
                                                            LIMIT 1];
            helpMessageFilter.put(fieldAPIName, filterValue);
            update helpMessageFilter;
            return '';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}