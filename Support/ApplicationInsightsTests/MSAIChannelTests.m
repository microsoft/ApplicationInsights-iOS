#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import <OCMock/OCMock.h>

#import "MSAIAppClient.h"
#import "MSAIChannel.h"
#import "MSAIChannelPrivate.h"
#import "MSAITelemetryContext.h"
#import "MSAITelemetryContextPrivate.h"
#import "MSAIPersistence.h"
#import "MSAIEnvelope.h"

@interface MSAIChannelTests : XCTestCase

@property(nonatomic, strong) MSAIChannel *sut;
@property(nonatomic, strong) MSAIAppClient *appClient;

@end


@implementation MSAIChannelTests

- (void)setUp {
  [super setUp];
  
  self.appClient = [[MSAIAppClient alloc]initWithBaseURL:[NSURL URLWithString:@"http://test.com/"]];
  self.sut = [MSAIChannel sharedChannel];
  MSAISafeJsonEventsString = NULL;
}

- (void)tearDown {
  [MSAIChannel setSharedChannel:nil];
}

#pragma mark - Setup Tests

- (void)testsharedChannelCreated {
  XCTAssertNotNil([MSAIChannel sharedChannel]);
}

- (void)testUniqueInstanceCreated {
  XCTAssertNotNil([MSAIChannel new]);
}

- (void)testInstanceInitialised {
  XCTAssertTrue([self.sut.dataItemQueue isEqualToArray:[NSMutableArray array]]);
  XCTAssertEqual(self.sut.senderBatchSize, defaultMaxBatchCount);
  XCTAssertEqual(self.sut.senderInterval, defaultBatchInterval);
}

- (void)testSingletonReturnsSameInstanceTwice {
  MSAIChannel *m1 = [MSAIChannel sharedChannel];
  XCTAssertEqualObjects(m1, [MSAIChannel sharedChannel]);
}

- (void)testSingletonSeperateFromUniqueInstance {
  XCTAssertNotEqualObjects([MSAIChannel sharedChannel], [MSAIChannel new]);
}

- (void)testMetricsManagerReturnsSeperateUniqueInstances {
  XCTAssertNotEqualObjects([MSAIChannel new], [MSAIChannel new]);
}

- (void)testDataItemsOperationsQueueWasInitialised {
  XCTAssertNotNil(self.sut.dataItemsOperations);
}

- (void)testDataItemsOperationsQueueStaysSame {
  XCTAssertEqualObjects([MSAIChannel sharedChannel].dataItemsOperations, [MSAIChannel sharedChannel].dataItemsOperations);
}

#pragma mark - Queue management

- (void)testEnqueueEnvelopeWithOneEnvelope {
  self.sut = OCMPartialMock(self.sut);
  MSAIOrderedDictionary *dictionary = [MSAIOrderedDictionary new];
  OCMStub([self.sut startTimer]);
  
  [self.sut enqueueDictionary:dictionary];
  
  [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
  
  assertThat(self.sut.dataItemQueue, hasCountOf(1));
  XCTAssertEqual(self.sut.dataItemQueue.firstObject, dictionary);
  OCMVerify([self.sut startTimer]);
}

- (void)testEnqueueEnvelopeWithMultipleEnvelopes {
  self.sut = OCMPartialMock(self.sut);
  OCMStub([self.sut invalidateTimer]);
  
  self.sut.senderBatchSize = 3;
  
  MSAIOrderedDictionary *dictionary = [MSAIOrderedDictionary new];
  
  assertThat(self.sut.dataItemQueue, hasCountOf(0));
  
  [self.sut enqueueDictionary:dictionary];
  assertThat(self.sut.dataItemQueue, hasCountOf(1));
  
  [self.sut enqueueDictionary:dictionary];
  assertThat(self.sut.dataItemQueue, hasCountOf(2));
  
  [self.sut enqueueDictionary:dictionary];
  assertThat(self.sut.dataItemQueue, hasCountOf(0));
  
  OCMVerify([self.sut invalidateTimer]);
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

@end
