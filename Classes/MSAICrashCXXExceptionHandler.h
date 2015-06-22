#import <Foundation/Foundation.h>
#import "MSAINullability.h"

typedef struct {
    const void * __nullable exception;
    const char * __nullable exception_type_name;
    const char * __nullable exception_message;
    uint32_t exception_frames_count;
    const uintptr_t * __nonnull exception_frames;
} MSAICrashUncaughtCXXExceptionInfo;

typedef void (*MSAICrashUncaughtCXXExceptionHandler)(
    const MSAICrashUncaughtCXXExceptionInfo * __nonnull info
);

@interface MSAICrashUncaughtCXXExceptionHandlerManager : NSObject

+ (void)addCXXExceptionHandler:(nonnull MSAICrashUncaughtCXXExceptionHandler)handler;
+ (void)removeCXXExceptionHandler:(nonnull MSAICrashUncaughtCXXExceptionHandler)handler;

@end
