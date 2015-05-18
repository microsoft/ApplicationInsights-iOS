#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

@interface MSAITestsDependencyInjection : XCTestCase

- (void)setMockNotificationCenter:(id)mockNotificationCenter;
- (id)mockNotificationCenter;

- (void)setMockUserDefaults:(NSUserDefaults *)userDefaults;
- (NSUserDefaults *)mockUserDefaults;

@end
