#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "AppInsights.h"
#import "MSAIHelper.h"
#import "MSAIKeychainUtils.h"


@interface MSAIHelperTests : XCTestCase

@end

@implementation MSAIHelperTests


- (void)setUp {
  [super setUp];
  // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown {
  // Tear-down code here.
# pragma clang diagnostic push
# pragma clang diagnostic ignored "-Wimplicit"
  __gcov_flush();
# pragma clang diagnostic pop
  
  [super tearDown];
}

- (void)testDevicePlattform {
  NSString *resultString = msai_devicePlatform();
  assertThat(resultString, notNilValue());
}

- (void)testDeviceModel {
  NSString *resultString = msai_devicePlatform();
  assertThat(resultString, notNilValue());
}

- (void)testOsVersion {
  NSString *resultString = msai_osVersion();
  assertThat(resultString, notNilValue());
  assertThatFloat([resultString floatValue], greaterThan(@(0.0)));
}

- (void)testOsName {
  NSString *resultString = msai_osName();
  assertThat(resultString, notNilValue());
  assertThatInteger([resultString length], greaterThan(@(0)));
}

- (void)testDeviceType {
  NSString *resultString = msai_deviceType();
  assertThat(resultString, notNilValue());
  NSArray *typesArray = @[@"Phone", @"Tablet", @"Unknown"];
  assertThat(typesArray, hasItem(resultString));
}

- (void)testSdkVersion {
  NSString *resultString = msai_sdkVersion();
  assertThat(resultString, notNilValue());
  assertThatInteger([resultString length], greaterThan(@(0)));
}

- (void)testSdkBuild {
  NSString *resultString = msai_sdkBuild();
  assertThat(resultString, notNilValue());
  assertThatInteger([resultString intValue], greaterThan(@(0)));
}

- (void)testUUIDPreiOS6 {
  NSString *resultString = msai_UUIDPreiOS6();
  assertThat(resultString, notNilValue());
  assertThatInteger([resultString length], equalToInteger(36));
}

- (void)testUUID {
  NSString *resultString = msai_UUID();
  assertThat(resultString, notNilValue());
  assertThatInteger([resultString length], equalToInteger(36));
}

- (void)testAppAnonID {
  // clean keychain cache
  NSError *error = NULL;
  [MSAIKeychainUtils deleteItemForUsername:@"appAnonID"
                            andServiceName:msai_keychainMSAIServiceName()
                                     error:&error];
  
  NSString *resultString = msai_appAnonID();
  assertThat(resultString, notNilValue());
  assertThatInteger([resultString length], equalToInteger(36));
}


@end