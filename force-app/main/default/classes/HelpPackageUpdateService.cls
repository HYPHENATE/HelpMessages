/**
 * @description       : Calls the external package version registry and returns update details for the installed package.
 * @author            : daniel@hyphen8.com
 * @last modified on  : 13-04-2026
 * @last modified by  : daniel@hyphen8.com
**/
public with sharing class HelpPackageUpdateService {
    
    private static final String VERSION_ENDPOINT_BASE = 'https://packages.hyphen8.com/api/version?package=';
    private static final Integer CALLOUT_TIMEOUT_MS = 10000;
    private static final String INSTALL_PATH = '/packaging/installPackage.apexp';
    private static final String INSTALL_QUERY_PREFIX = 'p0=';

    /**
    * @description Returns the current package version information alongside the latest available registry result.
    * @return Map<String, Object>
    **/
    @AuraEnabled
    public static Map<String, Object> getUpdateInfo() {
        Map<String, String> currentInfo = HelpPackageVersion.getCurrentVersionInfo();
        HttpResponse response = sendVersionRequest(HelpPackageVersion.PACKAGE_NAME);
        Map<String, Object> latestInfo = parseVersionResponse(response);
        String latestVersion = (String)latestInfo.get('latestVersion');

        return new Map<String, Object>{
            'packageName' => currentInfo.get('packageName'),
            'currentVersion' => currentInfo.get('currentVersion'),
            'isSandbox' => currentInfo.get('isSandbox'),
            'latestVersion' => latestVersion,
            'installUrl' => (String)latestInfo.get('installUrl'),
            'message' => (String)latestInfo.get('message'),
            'updateAvailable' => compareVersions(latestVersion, HelpPackageVersion.CURRENT_VERSION) > 0
        };
    }

    private static HttpResponse sendVersionRequest(String packageName) {
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setTimeout(CALLOUT_TIMEOUT_MS);
        request.setEndpoint(VERSION_ENDPOINT_BASE + EncodingUtil.urlEncode(packageName, 'UTF-8'));

        try {
            return new Http().send(request);
        } catch (Exception e) {
            throw new AuraHandledException('Unable to check for updates right now.');
        }
    }

    private static Map<String, Object> parseVersionResponse(HttpResponse response) {
        if (response == null || response.getStatusCode() != 200 || String.isBlank(response.getBody())) {
            throw new AuraHandledException('Unable to check for updates right now.');
        }

        try {
            Map<String, Object> payload = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            String latestVersion = normalizePayloadString(payload.get('latestVersion'));
            String installUrl = normalizeInstallUrl(normalizePayloadString(payload.get('installUrl')));
            String message = normalizePayloadString(payload.get('message'));

            if (String.isBlank(latestVersion) || String.isBlank(installUrl)) {
                throw new AuraHandledException('Unable to check for updates right now.');
            }

            return new Map<String, Object>{
                'latestVersion' => latestVersion,
                'installUrl' => installUrl,
                'message' => message
            };
        } catch (Exception e) {
            throw new AuraHandledException('Unable to check for updates right now.');
        }
    }

    private static String normalizePayloadString(Object value) {
        if (value == null) {
            return null;
        }
        String normalized = String.valueOf(value).trim();
        return String.isBlank(normalized) ? null : normalized;
    }

    private static String normalizeInstallUrl(String rawInstallValue) {
        if (String.isBlank(rawInstallValue)) {
            throw new AuraHandledException('Unable to check for updates right now.');
        }

        String packageVersionId;
        if (rawInstallValue.startsWith('/')) {
            packageVersionId = extractPackageVersionIdFromInstallPath(rawInstallValue);
        } else {
            packageVersionId = rawInstallValue;
        }

        validatePackageVersionId(packageVersionId);
        return INSTALL_PATH + '?' + INSTALL_QUERY_PREFIX + packageVersionId;
    }

    private static String extractPackageVersionIdFromInstallPath(String installPath) {
        if (String.isBlank(installPath) || installPath.contains('://') || installPath.contains('#')) {
            throw new AuraHandledException('Unable to check for updates right now.');
        }

        Integer questionMarkIndex = installPath.indexOf('?');
        if (questionMarkIndex <= 0 || installPath.substring(0, questionMarkIndex) != INSTALL_PATH) {
            throw new AuraHandledException('Unable to check for updates right now.');
        }

        String queryString = installPath.substring(questionMarkIndex + 1);
        List<String> queryParams = queryString.split('&');
        if (queryParams.size() != 1 || !queryParams[0].startsWith(INSTALL_QUERY_PREFIX)) {
            throw new AuraHandledException('Unable to check for updates right now.');
        }

        String packageVersionId = queryParams[0].substring(INSTALL_QUERY_PREFIX.length());
        if (String.isBlank(packageVersionId) || packageVersionId.contains('?') || packageVersionId.contains('=') || packageVersionId.contains('/')) {
            throw new AuraHandledException('Unable to check for updates right now.');
        }
        return packageVersionId;
    }

    private static void validatePackageVersionId(String packageVersionId) {
        if (String.isBlank(packageVersionId)) {
            throw new AuraHandledException('Unable to check for updates right now.');
        }

        String normalizedId = packageVersionId.trim();
        if (!normalizedId.startsWith('04t')) {
            throw new AuraHandledException('Unable to check for updates right now.');
        }
        if (normalizedId.length() != 15 && normalizedId.length() != 18) {
            throw new AuraHandledException('Unable to check for updates right now.');
        }
        if (!Pattern.matches('^[a-zA-Z0-9]+$', normalizedId)) {
            throw new AuraHandledException('Unable to check for updates right now.');
        }
    }

    private static Integer compareVersions(String leftVersion, String rightVersion) {
        VersionParts left = parseVersion(leftVersion);
        VersionParts right = parseVersion(rightVersion);
        Integer maxLength = Math.max(left.numbers.size(), right.numbers.size());

        for (Integer index = 0; index < maxLength; index++) {
            Integer leftNumber = index < left.numbers.size() ? left.numbers[index] : 0;
            Integer rightNumber = index < right.numbers.size() ? right.numbers[index] : 0;
            if (leftNumber != rightNumber) {
                return leftNumber > rightNumber ? 1 : -1;
            }
        }

        if (left.suffix == right.suffix) {
            return 0;
        }
        if (String.isBlank(left.suffix) && !String.isBlank(right.suffix)) {
            return 1;
        }
        if (!String.isBlank(left.suffix) && String.isBlank(right.suffix)) {
            return -1;
        }
        return left.suffix.toLowerCase().compareTo(right.suffix.toLowerCase());
    }

    private static VersionParts parseVersion(String versionValue) {
        String safeValue = String.isBlank(versionValue) ? '0' : versionValue.trim();
        String numericPart = safeValue;
        String suffix = '';
        Integer suffixIndex = safeValue.indexOf('-');
        if (suffixIndex > -1) {
            numericPart = safeValue.substring(0, suffixIndex);
            suffix = safeValue.substring(suffixIndex + 1);
        }
        List<Integer> numbers = new List<Integer>();

        for (String part : numericPart.split('\\.')) {
            try {
                numbers.add(Integer.valueOf(part));
            } catch (Exception e) {
                numbers.add(0);
            }
        }

        if (numbers.isEmpty()) {
            numbers.add(0);
        }

        return new VersionParts(numbers, suffix);
    }

    private class VersionParts {
        /**
        * @description get set for numbers within the version parts
        **/
        public List<Integer> numbers { get; private set; }
        /**
        * @description suffer within the version parts
        **/
        public String suffix { get; private set; }

        private VersionParts(List<Integer> numbers, String suffix) {
            this.numbers = numbers;
            this.suffix = suffix;
        }
    }
}