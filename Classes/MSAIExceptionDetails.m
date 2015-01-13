#import "MSAIExceptionDetails.h"
/// Data contract class for type ExceptionDetails.
@implementation MSAIExceptionDetails

/// Initializes a new instance of the class.
- (instancetype)init {
    if (self = [super init]) {
        self.hasFullStack = true;
    }
    return self;
}

///
/// Adds all members of this class to a dictionary
/// @param dictionary to which the members of this class will be added.
///
- (void)addToDictionary:(NSMutableDictionary *) dict {
    if (self.exceptionDetailsId != nil) {
        [dict setObject:self.exceptionDetailsId forKey:@"id"];
    }
    if (self.outerId != nil) {
        [dict setObject:self.outerId forKey:@"outerId"];
    }
    if (self.typeName != nil) {
        [dict setObject:self.typeName forKey:@"typeName"];
    }
    if (self.message != nil) {
        [dict setObject:self.message forKey:@"message"];
    }
    NSString *strhasFullStack = [NSString stringWithFormat:@"%s", (self.hasFullStack) ? "true" : "false"];
    [dict setObject:strhasFullStack forKey:@"hasFullStack"];
    if (self.stack != nil) {
        [dict setObject:self.stack forKey:@"stack"];
    }
    if (self.parsedStack != nil) {
        [dict setObject:self.parsedStack forKey:@"parsedStack"];
    }
}

///
/// Serializes the object to a string in json format.
/// @param writer The writer to serialize this object to.
///
- (NSString *)serialize {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [self addToDictionary: dict];
    NSMutableString  *jsonString;
    NSError *error = nil;
    NSData *json;
    json = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    jsonString = [[NSMutableString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    return jsonString;
}

@end
