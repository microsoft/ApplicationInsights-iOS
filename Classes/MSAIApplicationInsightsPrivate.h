#import "ApplicationInsights.h"

@interface MSAIApplicationInsights ()

/**
 *  Checks whether Instrumentation Key is plausible.
 *
 *  @param instrumentationKey the Instrumentation Key which should be tested
 *
 *  @return YES if Instrumentation Key conforms to length and charset
 */
- (BOOL)checkValidityOfInstrumentationKey:(NSString *)instrumentationKey;

@end
