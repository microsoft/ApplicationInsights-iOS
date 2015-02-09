#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "AppInsights.h"
#import "AppInsightsPrivate.h"
#import "MSAIAppClient.h"
#import "MSAIMetricsManager.h"
#import "MSAIMetricsManagerPrivate.h"
#import "MSAIBaseManager.h"
#import "MSAIBaseManagerPrivate.h"

@interface MSAIMetricsManagerTests : XCTestCase

@end


@implementation MSAIMetricsManagerTests

- (void)setUp {
  [super setUp];
  
  [MSAIMetricsManager startManager];
}

@end
