#import "MSAIDomain.h"
@class MSAICrashDataHeaders;

@interface MSAICrashData : MSAIDomain <NSCoding>

@property (nonatomic, copy, readonly) NSString *envelopeTypeName;
@property (nonatomic, copy, readonly) NSString *dataTypeName;
@property (nonatomic, strong) MSAICrashDataHeaders *headers;
@property (nonatomic, strong) NSMutableArray *threads;
@property (nonatomic, strong) NSMutableArray *binaries;

- (instancetype)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;


@end
