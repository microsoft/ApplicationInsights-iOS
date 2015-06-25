#import "MSAIObject.h"

@interface MSAIDevice : MSAIObject <NSCoding>

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

- (instancetype)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;


@end
