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
  MSAITelemetryContext *telemetryContext = [[MSAITelemetryContext alloc]initWithInstrumentationKey:nil
                                                                                      endpointPath:@"test/path/"
                                                                                applicationContext:nil
                                                                                     deviceContext:nil
                                                                                   locationContext:nil
                                                                                    sessionContext:nil
                                                                                       userContext:nil
                                                                                   internalContext:nil
                                                                                  operationContext:nil];
  _sut = [[MSAIChannel alloc]initWithAppClient:_appClient telemetryContext:telemetryContext];
}

#pragma mark - Setup Tests

- (void)testThatItInstantiates {
  assertThat(_sut, notNilValue());
  assertThat([_sut telemetryContext], notNilValue());
}

#pragma mark - Helper

- (void)testDateString {
  NSDate *testDate = [NSDate dateWithTimeIntervalSince1970:0];
  NSString *expected = @"1970-01-01T01:00:00.000Z";
  
  NSString *resultString = [_sut dateStringForDate:testDate];
  assertThat(resultString, equalTo(expected));
}

@end
