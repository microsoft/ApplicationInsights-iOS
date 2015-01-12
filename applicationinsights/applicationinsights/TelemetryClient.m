//
//  TelemetryClient.m
//  applicationinsights
//
//  Copyright (c) 2015 Microsoft. All rights reserved.
//

#import "TelemetryClient.h"

@implementation TelemetryClient

- (id)init
{
    self = [super init];
    if(self)
    {
        self.instrumentationKey = @"2b240a15-4b1c-4c40-a4f0-0e8142116250";
    }
    
    return self;
}

- (void)trackTrace:(NSString*)message
{
    [message compare:@"todo:"];
}

@end
