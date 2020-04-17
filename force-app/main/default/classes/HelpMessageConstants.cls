/**
 * @description     constants class for use throughout the application
 * @author          daniel@hyphen8.com
 * @date            17/04/2020
 * @group           Constants
*/
public with sharing class HelpMessageConstants {

    /**
     * @description     static string confirming AND FILTER LOGIC for use with SOQL Queries
    */
    public static final String FILTER_LOGIC_AND = 'AND';
    
    /**
     * @description     static string confirming OR FILTER LOGIC for use with SOQL Queries
    */
    public static final String FILTER_LOGIC_OR = 'OR';
    
    /**
     * @description     static string confirming EQUALS FILTER LOGIC for use with SOQL Queries
    */
    public static final String FIELD_OPERATOR_EQUALS = 'equals';

    /**
     * @description     static string confirming NOT EQUAL TO FILTER LOGIC for use with SOQL Queries
    */
    public static final String FIELD_OPERATOR_NOT_EQUALS = 'not equal to';

    /**
     * @description     static string confirming GREATER THAN TO FILTER LOGIC for use with SOQL Queries
    */
    public static final String FIELD_OPERATOR_GREATER_THAN = 'greater than';

    /**
     * @description     static string confirming GREATER THAN QUALS TO FILTER LOGIC for use with SOQL Queries
    */
    public static final String FIELD_OPERATOR_GREATER_THAN_EQUALS = 'greater than or equals';

    /**
     * @description     static string confirming LESS THAN TO FILTER LOGIC for use with SOQL Queries
    */
    public static final String FIELD_OPERATOR_LESS_THAN = 'less than';

    /**
     * @description     static string confirming LESS THAN OR EQUALS TO FILTER LOGIC for use with SOQL Queries
    */
    public static final String FIELD_OPERATOR_LESS_THAN_EQUALS = 'less than or equals';

    /**
     * @description     static string confirming FIELD DELIMITER
    */
    public static final String FIELD_VALUE_OR_DELIMITER = ',';

}
