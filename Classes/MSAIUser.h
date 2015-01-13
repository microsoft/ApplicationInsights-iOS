#import <Foundation/Foundation.h>
#import "MSAIDataPointType.h"
#import "MSAIDependencyKind.h"
#import "MSAIDependencySourceType.h"
#import "MSAISeverityLevel.h"
#import "MSAITelemetryData.h"

///Data contract class for type User.
@interface MSAIUser : NSObject

@property (nonatomic, strong) NSString *accountAcquisitionDate;
@property (nonatomic, strong) NSString *accountId;
@property (nonatomic, strong) NSString *userAgent;
@property (nonatomic, strong) NSString *userId;

/// Serializes the object to a string in json format.
- (NSString *)serialize;

@end
