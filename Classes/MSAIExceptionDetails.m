#import "MSAIExceptionDetails.h"
#import "MSAIStackFrame.h"
/// Data contract class for type ExceptionDetails.
@implementation MSAIExceptionDetails

/// Initializes a new instance of the class.
- (instancetype)init {
    if (self = [super init]) {
        self.hasFullStack = true;
        self.parsedStack = [NSMutableArray new];
    }
    return self;
}

///
/// Adds all members of this class to a dictionary
/// @param dictionary to which the members of this class will be added.
///
- (MSAIOrderedDictionary *)serializeToDictionary {
    MSAIOrderedDictionary *dict = [super serializeToDictionary];
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
        NSMutableArray *parsedStackArray = [NSMutableArray array];
        for (MSAIStackFrame *parsedStackElement in self.parsedStack) {
            [parsedStackArray addObject:[parsedStackElement serializeToDictionary]];
        }
        [dict setObject:parsedStackArray forKey:@"parsedStack"];
    }
    return dict;
}

@end
