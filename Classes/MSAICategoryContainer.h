#import "MSAINullability.h"
#import "MSAIPageViewLogging_UIViewController.h"

NS_ASSUME_NONNULL_BEGIN
@interface MSAICategoryContainer : NSObject

+ (void)activateCategory;

@end

BOOL msai_shouldTrackPageView(UIViewController *viewController);
NSString* msai_pageViewNameForViewController(UIViewController *viewController);

NS_ASSUME_NONNULL_END
