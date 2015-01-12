//
//  TelemetryClient.h
//  applicationinsights
//
//  Copyright (c) 2015 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TelemetryClient : NSObject

@property (nonatomic, strong) NSString *instrumentationKey;

- (void)trackTrace:(NSString*)message;

@end
