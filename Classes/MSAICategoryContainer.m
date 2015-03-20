#import "MSAICategoryContainer.h"
#import <objc/runtime.h>
#import "MSAIMetricsManager.h"
#import "MSAIMetricsManagerPrivate.h"

@implementation MSAICategoryContainer

+ (void)activateCategory{
}

@end

@implementation UIViewController(PageViewLogging)

+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    Class class = [self class];
    
    SEL originalSelector = @selector(viewWillAppear:);
    SEL swizzledSelector = @selector(msai_viewWillAppear:);
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    method_exchangeImplementations(originalMethod, swizzledMethod);
  });
}

#pragma mark - Method Swizzling

- (void)msai_viewWillAppear:(BOOL)animated {
  [self msai_viewWillAppear:animated];
  
  if(![MSAIMetricsManager sharedManager].autoPageViewTrackingDisabled){
    NSString *pageViewName = [NSString stringWithFormat:@"%@ %@", NSStringFromClass([self class]), self.title];
    [MSAIMetricsManager trackPageView:pageViewName];
  }
}

@end



