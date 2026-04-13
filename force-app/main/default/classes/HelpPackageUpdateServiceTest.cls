/**
 * @description       : test class for HelpPackageUpdateService
 * @author            : daniel@hyphen8.com
 * @last modified on  : 13-04-2026
 * @last modified by  : daniel@hyphen8.com
**/
@isTest(testFor='ApexClass:HelpPackageUpdateService')
public class HelpPackageUpdateServiceTest {
    
    private class JsonParseFailureMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('not valid json');
            return response;
        }
    }

    private class ThrowingCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            throw new CalloutException('Simulated callout failure');
        }
    }

    private class SuccessMock implements HttpCalloutMock {
        private final Integer statusCode;
        private final String body;

        SuccessMock(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        /**
        * @description httpresponse mock method
        * @param request
        * @return HttpResponse
        **/
        public HttpResponse respond(HttpRequest request) {
            Assert.isTrue(request.getEndpoint().contains('package=HelpMessages'), 'Callout should include the package name.');
            HttpResponse response = new HttpResponse();
            response.setStatusCode(statusCode);
            response.setBody(body);
            return response;
        }
    }

    @IsTest
    static void getUpdateInfoReturnsLatestVersionDetails() {
        User runAsUser = HelpMessageController_Test.getCurrentUserForRunAs();
        System.runAs(runAsUser) {
            Test.setMock(
                HttpCalloutMock.class,
                new SuccessMock(
                    200,
                    '{"package":"HelpMessages","latestVersion":"11.4.0","installUrl":"/packaging/installPackage.apexp?p0=04t000000000001","message":"A newer version of HelpMessages is available."}'
                )
            );

            Test.startTest();
                Map<String, Object> result = HelpPackageUpdateService.getUpdateInfo();
            Test.stopTest();

            Assert.areEqual('HelpMessages', (String)result.get('packageName'), 'Expected the service to return the HelpMessages package name.');
            Assert.areEqual('11.4.0', (String)result.get('latestVersion'), 'Expected the service to return the latest package version from the registry response.');
            Assert.areEqual('/packaging/installPackage.apexp?p0=04t000000000001', (String)result.get('installUrl'), 'Expected the service to return the validated package installation URL from the registry response.');
            Assert.areEqual(true, (Boolean)result.get('updateAvailable'), 'Expected the service to flag an update when the registry version is newer than the installed version.');
        }
    }

    @IsTest
    static void getUpdateInfoReturnsNoUpdateWhenVersionIsOlderOrSame() {
        User runAsUser = HelpMessageController_Test.getCurrentUserForRunAs();
        System.runAs(runAsUser) {
            Test.setMock(
                HttpCalloutMock.class,
                new SuccessMock(
                    200,
                    '{"package":"HelpMessages","latestVersion":"0.0.1","installUrl":"04t000000000001","message":"Already current."}'
                )
            );

            Test.startTest();
                Map<String, Object> result = HelpPackageUpdateService.getUpdateInfo();
            Test.stopTest();

            Assert.areEqual(false, (Boolean)result.get('updateAvailable'), 'Expected no update when the registry version is not newer than the installed version.');
        }
    }

    @IsTest
    static void getUpdateInfoRejectsAbsoluteInstallUrls() {
        User runAsUser = HelpMessageController_Test.getCurrentUserForRunAs();
        System.runAs(runAsUser) {
            Test.setMock(
                HttpCalloutMock.class,
                new SuccessMock(
                    200,
                    '{"package":"HelpMessages","latestVersion":"1.5.0","installUrl":"https://login.salesforce.com/packaging/installPackage.apexp?p0=04t000000000001","message":"Bad absolute URL."}'
                )
            );

            Test.startTest();
            try {
                HelpPackageUpdateService.getUpdateInfo();
                Assert.fail('Expected AuraHandledException for absolute install URLs.');
            } catch (AuraHandledException e) {
                Assert.isTrue(e.getMessage().contains('Script-thrown exception'), 'Expected handled validation failure.');
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void getUpdateInfoRejectsInvalidPackageVersionIds() {
        User runAsUser = HelpMessageController_Test.getCurrentUserForRunAs();
        System.runAs(runAsUser) {
            Test.setMock(
                HttpCalloutMock.class,
                new SuccessMock(
                    200,
                    '{"package":"HelpMessages","latestVersion":"1.5.0","installUrl":"/packaging/installPackage.apexp?p0=04tBAD-ID","message":"Bad package id."}'
                )
            );

            Test.startTest();
            try {
                HelpPackageUpdateService.getUpdateInfo();
                Assert.fail('Expected AuraHandledException for invalid package version ids.');
            } catch (AuraHandledException e) {
                Assert.isTrue(e.getMessage().contains('Script-thrown exception'), 'Expected handled validation failure.');
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void getUpdateInfoRejectsMalformedPayloadsMissingRequiredFields() {
        User runAsUser = HelpMessageController_Test.getCurrentUserForRunAs();
        System.runAs(runAsUser) {
            Test.setMock(
                HttpCalloutMock.class,
                new SuccessMock(
                    200,
                    '{"package":"HelpMessages","message":"Missing fields."}'
                )
            );

            Test.startTest();
            try {
                HelpPackageUpdateService.getUpdateInfo();
                Assert.fail('Expected AuraHandledException for malformed payloads.');
            } catch (AuraHandledException e) {
                Assert.isTrue(e.getMessage().contains('Script-thrown exception'), 'Expected handled payload validation failure.');
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void getUpdateInfoThrowsHandledExceptionWhenRegistryFails() {
        User runAsUser = HelpMessageController_Test.getCurrentUserForRunAs();
        System.runAs(runAsUser) {
            Test.setMock(HttpCalloutMock.class, new SuccessMock(500, '{"error":"nope"}'));

            Test.startTest();
            try {
                HelpPackageUpdateService.getUpdateInfo();
                Assert.fail('Expected AuraHandledException for non-200 response.');
            } catch (AuraHandledException e) {
                Assert.isTrue(e.getMessage().contains('Script-thrown exception'), 'Expected handled callout failure.');
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void getUpdateInfoHandlesMalformedJsonPayload() {
        User runAsUser = HelpMessageController_Test.getCurrentUserForRunAs();
        System.runAs(runAsUser) {
            Assert.isTrue(
                verifyHandledException(new JsonParseFailureMock(), 'Malformed registry payloads should raise an AuraHandledException.'),
                'Malformed registry payloads should be handled and asserted.'
            );
        }
    }

    @IsTest
    static void getUpdateInfoHandlesCalloutFailures() {
        User runAsUser = HelpMessageController_Test.getCurrentUserForRunAs();
        System.runAs(runAsUser) {
            Assert.isTrue(
                verifyHandledException(new ThrowingCalloutMock(), 'Callout failures should raise an AuraHandledException.'),
                'Callout failures should be handled and asserted.'
            );
        }
    }

    @IsTest
    static void getUpdateInfoTreatsPrereleaseAsNotNewerThanStableVersion() {
        User runAsUser = HelpMessageController_Test.getCurrentUserForRunAs();
        System.runAs(runAsUser) {
            Test.setMock(
                HttpCalloutMock.class,
                new SuccessMock(
                    200,
                    '{"package":"DocBeaver","latestVersion":"0.0.1-beta","installUrl":"/packaging/installPackage.apexp?p0=04t000000000001","message":"Preview build available."}'
                )
            );

            Test.startTest();
            Map<String, Object> result = HelpPackageUpdateService.getUpdateInfo();
            Test.stopTest();

            Assert.areEqual(
                false,
                (Boolean)result.get('updateAvailable'),
                'A prerelease build should not outrank the installed stable version.'
            );
        }
    }

    private static Boolean verifyHandledException(HttpCalloutMock mockImpl, String failMessage) {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockImpl);
        try {
            HelpPackageUpdateService.getUpdateInfo();
            Assert.fail(failMessage);
        } catch (AuraHandledException exceptionRecord) {
            Assert.isTrue(
                exceptionRecord.getMessage().contains('Script-thrown exception'),
                'Package update failures should surface as handled exceptions in test context.'
            );
            Test.stopTest();
            return true;
        }
        Test.stopTest();
        return false;
    }
}