#import "AppInsights.h"
#import "AppInsightsPrivate.h"

#import "MSAIHelper.h"

#import "MSAIBaseManager.h"
#import "MSAIBaseManagerPrivate.h"
#import "MSAIContextPrivate.h"

#import "MSAIKeychainUtils.h"

#import <mach-o/dyld.h>
#import <mach-o/loader.h>

#ifndef __IPHONE_6_1
#define __IPHONE_6_1     60100
#endif

@implementation MSAIBaseManager {
  NSDateFormatter *_rfc3339Formatter;
}

- (instancetype)init {
  if ((self = [super init])) {
    _serverURL = MSAI_SDK_URL;

    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    _rfc3339Formatter = [[NSDateFormatter alloc] init];
    [_rfc3339Formatter setLocale:enUSPOSIXLocale];
    [_rfc3339Formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [_rfc3339Formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
  }
  return self;
}

- (instancetype)initWithAppContext:(MSAIContext *)appContext;{
  if ((self = [self init])) {
    _appContext = appContext;
  }
  return self;
}

#pragma mark - Private

- (void)reportError:(NSError *)error {
  MSAILog(@"ERROR: %@", [error localizedDescription]);
}

- (NSString *)executableUUID {
  const struct mach_header *executableHeader = NULL;
  for (uint32_t i = 0; i < _dyld_image_count(); i++) {
    const struct mach_header *header = _dyld_get_image_header(i);
    if (header->filetype == MH_EXECUTE) {
      executableHeader = header;
      break;
    }
  }
  
  if (!executableHeader)
    return @"";
  
  BOOL is64bit = executableHeader->magic == MH_MAGIC_64 || executableHeader->magic == MH_CIGAM_64;
  uintptr_t cursor = (uintptr_t)executableHeader + (is64bit ? sizeof(struct mach_header_64) : sizeof(struct mach_header));
  const struct segment_command *segmentCommand = NULL;
  for (uint32_t i = 0; i < executableHeader->ncmds; i++, cursor += segmentCommand->cmdsize) {
    segmentCommand = (struct segment_command *)cursor;
    if (segmentCommand->cmd == LC_UUID) {
      const struct uuid_command *uuidCommand = (const struct uuid_command *)segmentCommand;
      const uint8_t *uuid = uuidCommand->uuid;
      return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
               uuid[0], uuid[1], uuid[2], uuid[3],
               uuid[4], uuid[5], uuid[6], uuid[7],
               uuid[8], uuid[9], uuid[10], uuid[11],
               uuid[12], uuid[13], uuid[14], uuid[15]]
              lowercaseString];
    }
  }
  
  return @"";
}

#pragma mark - Manager Control

- (void)startManager {
}

#pragma mark - Helpers

- (NSDate *)parseRFC3339Date:(NSString *)dateString {
  NSDate *date = nil;
  NSError *error = nil; 
  if (![_rfc3339Formatter getObjectValue:&date forString:dateString range:nil error:&error]) {
    MSAILog(@"INFO: Invalid date '%@' string: %@", dateString, error);
  }
  
  return date;
}

#pragma mark - Keychain

- (BOOL)addStringValueToKeychain:(NSString *)stringValue forKey:(NSString *)key {
  if (!key || !stringValue)
    return NO;
  
  NSError *error = nil;
  return [MSAIKeychainUtils storeUsername:key
                              andPassword:stringValue
                           forServiceName:msai_keychainMSAIServiceName()
                           updateExisting:YES
                                    error:&error];
}

- (BOOL)addStringValueToKeychainForThisDeviceOnly:(NSString *)stringValue forKey:(NSString *)key {
  if (!key || !stringValue)
    return NO;
  
  NSError *error = nil;
  return [MSAIKeychainUtils storeUsername:key
                              andPassword:stringValue
                           forServiceName:msai_keychainMSAIServiceName()
                           updateExisting:YES
                            accessibility:kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
                                    error:&error];
}

- (NSString *)stringValueFromKeychainForKey:(NSString *)key {
  if (!key)
    return nil;
  
  NSError *error = nil;
  return [MSAIKeychainUtils getPasswordForUsername:key
                                    andServiceName:msai_keychainMSAIServiceName()
                                             error:&error];
}

- (BOOL)removeKeyFromKeychain:(NSString *)key {
  NSError *error = nil;
  return [MSAIKeychainUtils deleteItemForUsername:key
                                   andServiceName:msai_keychainMSAIServiceName()
                                            error:&error];
}


@end
