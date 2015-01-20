#import "MSAIContext.h"

@interface MSAIBaseManager()

@property(nonatomic, strong) MSAIContext *appContext;

- (instancetype)initWithAppContext:(MSAIContext *)appContext;

- (void)startManager;

- (NSString *)executableUUID;

- (NSString *)encodedInstrumentationKey;

/**
 * by default, just logs the message
 *
 * can be overriden by subclasses to do their own error handling,
 * e.g. to show UI
 *
 * @param error NSError
 */
- (void)reportError:(NSError *)error;

// Date helpers
- (NSDate *)parseRFC3339Date:(NSString *)dateString;

// keychain helpers
- (BOOL)addStringValueToKeychain:(NSString *)stringValue forKey:(NSString *)key;
- (BOOL)addStringValueToKeychainForThisDeviceOnly:(NSString *)stringValue forKey:(NSString *)key;
- (NSString *)stringValueFromKeychainForKey:(NSString *)key;
- (BOOL)removeKeyFromKeychain:(NSString *)key;

@end
