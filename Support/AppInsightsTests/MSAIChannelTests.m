#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "MSAIAppClient.h"
#import "MSAIChannel.h"
#import "MSAIChannelPrivate.h"
#import "MSAITelemetryContext.h"
#import "MSAITelemetryContextPrivate.h"
#import "MSAIEnvelope.h"

@interface MSAIChannelTests : XCTestCase

@end


@implementation MSAIChannelTests {
  MSAIChannel *_sut;
  MSAIAppClient *_appClient;
}

- (void)setUp {
  [super setUp];
  
  _appClient = [[MSAIAppClient alloc]initWithBaseURL:[NSURL URLWithString:@"http://test.com/"]];
  _sut = [MSAIChannel sharedChannel];
  MSAISafeJsonEventsString = NULL;
}

#pragma mark - Setup Tests

- (void)testThatItInstantiates {
  assertThat(_sut, notNilValue());
}

#pragma mark - Safe JSON String Tests

- (void)testAppendDictionaryToSafeJsonString {
  msai_appendDictionaryToSafeJsonString(nil, 0);
  XCTAssertTrue(MSAISafeJsonEventsString == NULL);
  
  MSAISafeJsonEventsString = NULL;
  msai_appendDictionaryToSafeJsonString(nil, &MSAISafeJsonEventsString);
  XCTAssertTrue(MSAISafeJsonEventsString == NULL);
  
  msai_appendDictionaryToSafeJsonString(@{}, &MSAISafeJsonEventsString);
  XCTAssertEqual(strcmp(MSAISafeJsonEventsString,"[{},"), 0);
  
  msai_appendDictionaryToSafeJsonString(@{@"Key1":@"Value1"}, &MSAISafeJsonEventsString);
  XCTAssertEqual(strcmp(MSAISafeJsonEventsString,"[{},{\"Key1\":\"Value1\"},"), 0);
}

- (void)testResetSafeJsonString {
  msai_resetSafeJsonString(&MSAISafeJsonEventsString);
  XCTAssertEqual(strcmp(MSAISafeJsonEventsString,"["), 0);
  
  MSAISafeJsonEventsString = NULL;
  msai_resetSafeJsonString(nil);
  XCTAssertEqual(MSAISafeJsonEventsString, NULL);
  
  MSAISafeJsonEventsString = strdup("test string");
  msai_resetSafeJsonString(&MSAISafeJsonEventsString);
  XCTAssertEqual(strcmp(MSAISafeJsonEventsString,"["), 0);
}

#pragma mark - Helper

//TODO more tests

@end
