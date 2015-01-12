#import "MSAIBaseManager.h"

@class MSAIMetricsSession;


@interface MSAIMetricsManager : MSAIBaseManager


/**
 Contains details about the current session data
 
 `sessionEndTime` property is 0 since the session didn't end yet
 */
@property (nonatomic, readonly) MSAIMetricsSession *currentSession;

@end
