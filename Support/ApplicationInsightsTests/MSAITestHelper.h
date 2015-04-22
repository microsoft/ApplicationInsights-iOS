NS_ASSUME_NONNULL_BEGIN

extern NSString *const kMSAIDummyInstrumentationKey;

@interface MSAITestHelper : NSObject

+ (NSString *)jsonFixture:(NSString *)fixture;
+ (BOOL)createTempDirectory:(NSString *)directory;
+ (BOOL)copyFixtureCrashReportWithFileName:(NSString *)filename;

@end
NS_ASSUME_NONNULL_END
