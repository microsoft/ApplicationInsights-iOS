#import "MSAITestsDependencyInjection.h"

static NSNotificationCenter *mockNotificationCenter;
static NSUserDefaults *mockUserDefaults;

@implementation NSNotificationCenter (UnitTests)

+(id)defaultCenter {
  return mockNotificationCenter;
}

@end

@implementation NSUserDefaults (UnitTests)

+(id)standardUserDefaults {
  if (!mockUserDefaults) {
    mockUserDefaults = OCMPartialMock([NSUserDefaults new]);
  }
  return mockUserDefaults;
}

@end

@implementation MSAITestsDependencyInjection

- (void)setUp {
  mockNotificationCenter = mock(NSNotificationCenter.class);
}

- (void)tearDown {
  [super tearDown];
  mockNotificationCenter = nil;
  mockUserDefaults = nil;
}

# pragma mark - Helper

- (void)setMockNotificationCenter:(NSNotificationCenter *)notificationCenter {
  mockNotificationCenter = notificationCenter;
}

- (NSNotificationCenter *)mockNotificationCenter {
  return mockNotificationCenter;
}

- (void)setMockUserDefaults:(NSUserDefaults *)userDefaults {
  mockUserDefaults = userDefaults;
}

- (NSUserDefaults *)mockUserDefaults {
  return mockUserDefaults;
}

@end
