#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

@interface MSAITestsDependencyInjection : XCTestCase

- (void)setMockNotificationCenter:(NSNotificationCenter *)notificationCenter;
- (NSNotificationCenter *)mockNotificationCenter;
- (void)setMockUserDefaults:(NSUserDefaults *)userDefaults;
- (NSUserDefaults *)mockUserDefaults;

@end
