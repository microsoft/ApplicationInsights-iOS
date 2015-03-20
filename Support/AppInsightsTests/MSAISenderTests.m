#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "MSAIAppClient.h"
#import "MSAISender.h"
#import "MSAISenderPrivate.h"
#import "MSAIEnvelope.h"

@interface MSAISenderTests : XCTestCase

@end


@implementation MSAISenderTests {
  MSAISender *_sut;
  MSAIAppClient *_appClient;
}

- (void)setUp {
  [super setUp];
  
  _appClient = [[MSAIAppClient alloc]initWithBaseURL:[NSURL URLWithString:@"http://test.com/"]];
  _sut = [MSAISender sharedSender];
  [_sut configureWithAppClient:nil endpointPath:nil];
}

- (void)tearDown {
  _sut = nil;
  
  [super tearDown];
}

- (void)testThatItInstantiates {
  assertThat(_sut, notNilValue());
  assertThat([_sut endpointPath], nilValue());
  assertThat([_sut appClient], nilValue());
}

- (void)testConfiguredPropertiesNotNil {
  NSString *testEndpoint = @"test/endpoint";
  [_sut configureWithAppClient:_appClient endpointPath:testEndpoint];
  
  assertThat([_sut endpointPath], notNilValue());
  assertThat([_sut endpointPath], equalTo(testEndpoint));
  assertThat([_sut appClient], notNilValue());
  assertThat([_sut appClient], equalTo(_appClient));
}

- (void)testSingletonReturnsInstanceTwice {
  MSAISender *testSender = [MSAISender sharedSender];
  assertThat(_sut, equalTo(testSender));
}

- (void)testRequestContainsDataItem {
  [_sut configureWithAppClient:_appClient endpointPath:nil];
  MSAIEnvelope *testItem = [MSAIEnvelope new];
  NSData *expectedBodyData = [[testItem serializeToString] dataUsingEncoding:NSUTF8StringEncoding];
  NSURLRequest *testRequest = [_sut requestForData:expectedBodyData urlString:@"http://testurl.com"];

  assertThat(testRequest, notNilValue());
  assertThat([testRequest HTTPBody], equalTo(expectedBodyData));
}

- (void)testEnqueueRequest {
  MSAIAppClient *mockClient = mock(MSAIAppClient.class);
  _sut.appClient = mockClient;
  [_sut sendRequest:[NSURLRequest new] path:@""];
  [verify(mockClient) enqeueHTTPOperation:anything()];
}

- (void)testDeleteDataWithStatusCodeWorks{
  
  for(NSInteger statusCode = 100; statusCode <= 510; statusCode++){
    if((statusCode >= 200 && statusCode <= 202) || statusCode == 400){
      assertThatBool([_sut shouldDeleteDataWithStatusCode:statusCode], equalToBool(YES));
    }else{
      assertThatBool([_sut shouldDeleteDataWithStatusCode:statusCode], equalToBool(NO));
    }
  }
}


@end
