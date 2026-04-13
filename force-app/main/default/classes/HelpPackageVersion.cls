/**
 * @description       : Central package version registry that exposes the installed package version details to Apex and LWC.
 * @author            : daniel@hyphen8.com
 * @last modified on  : 13-04-2026
 * @last modified by  : daniel@hyphen8.com
**/
public with sharing class HelpPackageVersion {
    
    public static final String PACKAGE_NAME = 'HelpMessages';
    public static final String CURRENT_VERSION = '1.4.0';

    /**
    * @description Returns the current package version details for display in the UI.
    * @return Map<String, String>
    **/
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getCurrentVersionInfo() {
        Organization orgInfo = [SELECT IsSandbox
                                            FROM Organization
                                            WITH SYSTEM_MODE
                                            LIMIT 1];
        return new Map<String, String>{
            'packageName' => PACKAGE_NAME,
            'currentVersion' => CURRENT_VERSION,
            'isSandbox' => String.valueOf(orgInfo.IsSandbox)
        };
    }
}