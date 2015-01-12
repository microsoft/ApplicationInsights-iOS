#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/* NSString helpers */
NSString *msai_URLEncodedString(NSString *inputString);
NSString *msai_URLDecodedString(NSString *inputString);
NSString *msai_base64String(NSData * data, unsigned long length);

NSString *msai_settingsDir(void);

NSString *msai_keychainMSAIServiceName(void);

NSString *msai_mainBundleIdentifier(void);
NSString *msai_encodeAppIdentifier(NSString *inputString);
NSString *msai_UUIDPreiOS6(void);
NSString *msai_UUID(void);
NSString *msai_appAnonID(void);
BOOL msai_isPreiOS7Environment(void);
BOOL msai_isPreiOS8Environment(void);
BOOL msai_isRunningInAppExtension(void);
