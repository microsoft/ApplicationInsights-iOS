#import "NotificationTests.h"

static NSNotificationCenter *mockNotificationCenter;

@implementation NSNotificationCenter (UnitTests)

+(id)defaultCenter {
  return mockNotificationCenter;
}

@end

@implementation NotificationTests

- (void)setUp {
  mockNotificationCenter = mock(NSNotificationCenter.class);
}

- (void)tearDown {
  [super tearDown];
  mockNotificationCenter = nil;
}

# pragma mark - Helper

- (void)setMockNotificationCenter:(NSNotificationCenter *)notificationCenter {
  mockNotificationCenter = notificationCenter;
}

- (NSNotificationCenter *)mockNotificationCenter {
  return mockNotificationCenter;
}

@end
