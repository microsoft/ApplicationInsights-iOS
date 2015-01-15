#import "MSAIObject.h"
#import "MSAITelemetryData.h"

///Data contract class for type Device.
@interface MSAIDevice : MSAIObject

@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic, strong) NSString *ip;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString *locale;
@property (nonatomic, strong) NSString *model;
@property (nonatomic, strong) NSString *network;
@property (nonatomic, strong) NSString *oemName;
@property (nonatomic, strong) NSString *os;
@property (nonatomic, strong) NSString *osVersion;
@property (nonatomic, strong) NSString *roleInstance;
@property (nonatomic, strong) NSString *roleName;
@property (nonatomic, strong) NSString *screenResolution;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *vmName;


@end
