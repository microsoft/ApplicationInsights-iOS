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
}

#pragma mark - Setup Tests

- (void)testThatItInstantiates {
  assertThat(_sut, notNilValue());
}

#pragma mark - Safe JSON String Tests

- (void)testAppendDictionaryToSafeJsonString {
  MSAISafeJsonEventsString = NULL;
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

- (void)testAddToDictionaryPerformance {
  MSAIOrderedDictionary *dictionary = [[MSAIOrderedDictionary alloc] initWithDictionary:@{
                                        @"ver": @1,
                                        @"name": @"Microsoft.ApplicationInsights.Event",
                                        @"time": @"2015-04-01T13:45:54.995Z",
                                        @"sampleRate": @100,
                                        @"iKey": @"d8ceb749-d380-42f6-b38d-2d906bd5fa4b",
                                        @"deviceId": @"5881373D-8881-4A08-A36C-F3749439E524",
                                        @"os": @"iPhone OS",
                                        @"osVer": @"8.2(12D508)",
                                        @"appId": @"com.microsoft.application-insights.ios.demo",
                                        @"appVer": @"1.0 (1)",
                                        @"tags": @{
                                          @"ai.application.ver": @"1.0 (1)",
                                          @"ai.user.id": @"5881373D-8881-4A08-A36C-F3749439E524",
                                          @"ai.internal.sdkVersion": @"ios:1.0-alpha.3",
                                          @"ai.session.id": @"CA180A66-8F4B-4826-A508-3B4C533C32B0",
                                          @"ai.session.isFirst": @"true",
                                          @"ai.session.isNew": @"true",
                                          @"ai.device.id": @"5881373D-8881-4A08-A36C-F3749439E524",
                                          @"ai.device.language": @"en",
                                          @"ai.device.locale": @"en_DE",
                                          @"ai.device.model": @"iPhone7,2",
                                          @"ai.device.network": @"WIFI",
                                          @"ai.device.oemName": @"Apple",
                                          @"ai.device.os": @"iPhone OS",
                                          @"ai.device.osVersion": @"8.2(12D508)",
                                          @"ai.device.screenResolution": @"667x375",
                                          @"ai.device.type": @"Phone"
                                        },
                                        @"data": @{
                                          @"baseType": @"EventData",
                                          @"baseData": @{
                                            @"ver": @2,
                                            @"name": @"Hello World event!",
                                            @"properties": @{
                                              @"Test property 1": @"Some value",
                                              @"Test property 2": @"Some other value"
                                            },
                                            @"measurements": @{
                                             @"Test measurement 2": @15.16,
                                             @"Test measurement 1": @4.8,
                                             @"Test measurement 3": @23.42
                                            }
                                          }
                                        }
                                        }];
  [self measureBlock:^{
    for (int i = 0; i < 100; ++i) {
      [_sut addDictionaryToQueues:dictionary];
    }
  }];
}

#pragma mark - Helper

//TODO more tests

@end
