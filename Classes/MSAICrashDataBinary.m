#import "MSAICrashDataBinary.h"
/// Data contract class for type CrashDataBinary.
@implementation MSAICrashDataBinary

/// Initializes a new instance of the class.
- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

///
/// Adds all members of this class to a dictionary
/// @param dictionary to which the members of this class will be added.
///
- (MSAIOrderedDictionary *)serializeToDictionary {
    MSAIOrderedDictionary *dict = [super serializeToDictionary];
    if (self.startAddress != nil) {
        [dict setObject:self.startAddress forKey:@"startAddress"];
    }
    if (self.endAddress != nil) {
        [dict setObject:self.endAddress forKey:@"endAddress"];
    }
    if (self.name != nil) {
        [dict setObject:self.name forKey:@"name"];
    }
    if (self.cpuType != nil) {
        [dict setObject:self.cpuType forKey:@"cpuType"];
    }
    if (self.cpuSubType != nil) {
        [dict setObject:self.cpuSubType forKey:@"cpuSubType"];
    }
    if (self.uuid != nil) {
        [dict setObject:self.uuid forKey:@"uuid"];
    }
    if (self.path != nil) {
        [dict setObject:self.path forKey:@"path"];
    }
    return dict;
}

@end
