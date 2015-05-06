#import <XCTest/XCTest.h>
#import "MSAIReachability.h"
#import "MSAIReachabilityPrivate.h"

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

@interface MSAIReachabilityTests : XCTestCase
@end

NSString *const testHostName = @"www.google.com";

@implementation MSAIReachabilityTests{
  MSAIReachability *_sut;
}

- (void)setUp {
  [super setUp];
  
  _sut = [MSAIReachability sharedInstance];
}

- (void)tearDown {
  _sut = nil;
  
  [super tearDown];
}

- (void)testThatItInstantiates {
  assertThat(_sut, notNilValue());
  assertThat(_sut.networkQueue, notNilValue());
  assertThat(_sut.singletonQueue, notNilValue());
  
  if ([CTTelephonyNetworkInfo class]) {
    assertThat(_sut.radioInfo, notNilValue());
  }
}

- (void)testWwanTypeForRadioAccessTechnology{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
  assertThatInteger([_sut wwanTypeForRadioAccessTechnology:nil], equalToInteger(MSAIReachabilityTypeNone));
#pragma clang diagnostic pop
  assertThatInteger([_sut wwanTypeForRadioAccessTechnology:@"Foo"], equalToInteger(MSAIReachabilityTypeNone));
  
  assertThatInteger([_sut wwanTypeForRadioAccessTechnology:CTRadioAccessTechnologyGPRS], equalToInteger(MSAIReachabilityTypeGPRS));
  assertThatInteger([_sut wwanTypeForRadioAccessTechnology:CTRadioAccessTechnologyCDMA1x], equalToInteger(MSAIReachabilityTypeGPRS));
  
  assertThatInteger([_sut wwanTypeForRadioAccessTechnology:CTRadioAccessTechnologyEdge], equalToInteger(MSAIReachabilityTypeEDGE));
  
  assertThatInteger([_sut wwanTypeForRadioAccessTechnology:CTRadioAccessTechnologyWCDMA], equalToInteger(MSAIReachabilityType3G));
  assertThatInteger([_sut wwanTypeForRadioAccessTechnology:CTRadioAccessTechnologyHSDPA], equalToInteger(MSAIReachabilityType3G));
  assertThatInteger([_sut wwanTypeForRadioAccessTechnology:CTRadioAccessTechnologyHSUPA], equalToInteger(MSAIReachabilityType3G));
  
  assertThatInteger([_sut wwanTypeForRadioAccessTechnology:CTRadioAccessTechnologyCDMAEVDORev0], equalToInteger(MSAIReachabilityType3G));
  assertThatInteger([_sut wwanTypeForRadioAccessTechnology:CTRadioAccessTechnologyCDMAEVDORevA], equalToInteger(MSAIReachabilityType3G));
  assertThatInteger([_sut wwanTypeForRadioAccessTechnology:CTRadioAccessTechnologyCDMAEVDORevB], equalToInteger(MSAIReachabilityType3G));
  assertThatInteger([_sut wwanTypeForRadioAccessTechnology:CTRadioAccessTechnologyeHRPD], equalToInteger(MSAIReachabilityType3G));
  
  assertThatInteger([_sut wwanTypeForRadioAccessTechnology:CTRadioAccessTechnologyLTE], equalToInteger(MSAIReachabilityTypeLTE));
}

- (void)testDescriptionForReachabilityType{
  MSAIReachabilityType type = MSAIReachabilityTypeNone;
  assertThat([_sut descriptionForReachabilityType:type], equalToIgnoringCase(@"none"));
  
  type = MSAIReachabilityTypeWIFI;
  assertThat([_sut descriptionForReachabilityType:type], equalToIgnoringCase(@"wifi"));
  
  type = MSAIReachabilityTypeWWAN;
  assertThat([_sut descriptionForReachabilityType:type], equalToIgnoringCase(@"wwan"));
  
  if ([CTTelephonyNetworkInfo class]) {
    type = MSAIReachabilityTypeGPRS;
    assertThat([_sut descriptionForReachabilityType:type], equalToIgnoringCase(@"gprs"));
    
    type = MSAIReachabilityTypeEDGE;
    assertThat([_sut descriptionForReachabilityType:type], equalToIgnoringCase(@"edge"));
    
    type = MSAIReachabilityType3G;
    assertThat([_sut descriptionForReachabilityType:type], equalToIgnoringCase(@"3g"));
    
    type = MSAIReachabilityTypeLTE;
    assertThat([_sut descriptionForReachabilityType:type], equalToIgnoringCase(@"lte"));
  }
}

@end
