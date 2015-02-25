#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "AppInsights.h"
#import "MSAIKeychainUtils.h"

@interface MSAIKeychainUtilsTests : XCTestCase {

}
@end


@implementation MSAIKeychainUtilsTests
- (void)setUp {
  [super setUp];
  
  // Set-up code here.
}

- (void)tearDown {
  // Tear-down code here.
  [super tearDown];
}

- (void)testThatMSAIKeychainHelperStoresAndRetrievesPassword {
  [MSAIKeychainUtils deleteItemForUsername:@"Peter" andServiceName:@"Test" error:nil];
  BOOL success =   [MSAIKeychainUtils storeUsername:@"Peter"
                                        andPassword:@"Pan"
                                     forServiceName:@"Test"
                                     updateExisting:YES
                                              error:nil];
  assertThatBool(success, equalToBool(YES));
  NSString *pass = [MSAIKeychainUtils getPasswordForUsername:@"Peter"
                                              andServiceName:@"Test"
                                                       error:NULL];
  assertThat(pass, equalTo(@"Pan"));
}

- (void)testThatMSAIKeychainHelperStoresAndRetrievesPasswordThisDeviceOnly {
  [MSAIKeychainUtils deleteItemForUsername:@"Peter" andServiceName:@"Test" error:nil];
  BOOL success =   [MSAIKeychainUtils storeUsername:@"Peter"
                                        andPassword:@"PanThisDeviceOnly"
                                     forServiceName:@"Test"
                                     updateExisting:YES
                                      accessibility:kSecAttrAccessibleWhenUnlockedThisDeviceOnly
                                              error:nil];
  assertThatBool(success, equalToBool(YES));
  NSString *pass = [MSAIKeychainUtils getPasswordForUsername:@"Peter"
                                              andServiceName:@"Test"
                                                       error:NULL];
  assertThat(pass, equalTo(@"PanThisDeviceOnly"));
}

- (void)testThatMSAIKeychainHelperRemovesAStoredPassword {
  [MSAIKeychainUtils deleteItemForUsername:@"Peter" andServiceName:@"Test" error:nil];
  [MSAIKeychainUtils storeUsername:@"Peter"
                       andPassword:@"Pan"
                    forServiceName:@"Test"
                    updateExisting:YES
                             error:nil];
  BOOL success = [MSAIKeychainUtils deleteItemForUsername:@"Peter" andServiceName:@"Test" error:nil];
  assertThatBool(success, equalToBool(YES));
  
  NSString *pass = [MSAIKeychainUtils getPasswordForUsername:@"Peter"
                                              andServiceName:@"Test"
                                                       error:NULL];
  assertThat(pass, equalTo(nil));
}

@end
