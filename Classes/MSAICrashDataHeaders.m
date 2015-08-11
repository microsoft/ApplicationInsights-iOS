#import "MSAICrashDataHeaders.h"
#import "MSAIOrderedDictionary.h"

/// Data contract class for type CrashDataHeaders.
@implementation MSAICrashDataHeaders

///
/// Adds all members of this class to a dictionary
/// @param dictionary to which the members of this class will be added.
///
- (MSAIOrderedDictionary *)serializeToDictionary {
    MSAIOrderedDictionary *dict = [super serializeToDictionary];
    if (self.crashDataHeadersId != nil) {
        [dict setObject:self.crashDataHeadersId forKey:@"id"];
    }
    if (self.process != nil) {
        [dict setObject:self.process forKey:@"process"];
    }
    if (self.processId != nil) {
        [dict setObject:self.processId forKey:@"processId"];
    }
    if (self.parentProcess != nil) {
        [dict setObject:self.parentProcess forKey:@"parentProcess"];
    }
    if (self.parentProcessId != nil) {
        [dict setObject:self.parentProcessId forKey:@"parentProcessId"];
    }
    if (self.crashThread != nil) {
        [dict setObject:self.crashThread forKey:@"crashThread"];
    }
    if (self.applicationPath != nil) {
        [dict setObject:self.applicationPath forKey:@"applicationPath"];
    }
    if (self.applicationIdentifier != nil) {
        [dict setObject:self.applicationIdentifier forKey:@"applicationIdentifier"];
    }
    if (self.applicationBuild != nil) {
        [dict setObject:self.applicationBuild forKey:@"applicationBuild"];
    }
    if (self.exceptionType != nil) {
        [dict setObject:self.exceptionType forKey:@"exceptionType"];
    }
    if (self.exceptionCode != nil) {
        [dict setObject:self.exceptionCode forKey:@"exceptionCode"];
    }
    if (self.exceptionAddress != nil) {
        [dict setObject:self.exceptionAddress forKey:@"exceptionAddress"];
    }
    if (self.exceptionReason != nil) {
        [dict setObject:self.exceptionReason forKey:@"exceptionReason"];
    }
    return dict;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if(self) {
    _crashDataHeadersId = [coder decodeObjectForKey:@"self.crashDataHeadersId"];
    _process = [coder decodeObjectForKey:@"self.process"];
    _processId = [coder decodeObjectForKey:@"self.processId"];
    _parentProcess = [coder decodeObjectForKey:@"self.parentProcess"];
    _parentProcessId = [coder decodeObjectForKey:@"self.parentProcessId"];
    _crashThread = [coder decodeObjectForKey:@"self.crashThread"];
    _applicationPath = [coder decodeObjectForKey:@"self.applicationPath"];
    _applicationIdentifier = [coder decodeObjectForKey:@"self.applicationIdentifier"];
    _applicationBuild = [coder decodeObjectForKey:@"self.applicationBuild"];
    _exceptionType = [coder decodeObjectForKey:@"self.exceptionType"];
    _exceptionCode = [coder decodeObjectForKey:@"self.exceptionCode"];
    _exceptionAddress = [coder decodeObjectForKey:@"self.exceptionAddress"];
    _exceptionReason = [coder decodeObjectForKey:@"self.exceptionReason"];
  }

  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [super encodeWithCoder:coder];
  [coder encodeObject:self.crashDataHeadersId forKey:@"self.crashDataHeadersId"];
  [coder encodeObject:self.process forKey:@"self.process"];
  [coder encodeObject:self.processId forKey:@"self.processId"];
  [coder encodeObject:self.parentProcess forKey:@"self.parentProcess"];
  [coder encodeObject:self.parentProcessId forKey:@"self.parentProcessId"];
  [coder encodeObject:self.crashThread forKey:@"self.crashThread"];
  [coder encodeObject:self.applicationPath forKey:@"self.applicationPath"];
  [coder encodeObject:self.applicationIdentifier forKey:@"self.applicationIdentifier"];
  [coder encodeObject:self.applicationBuild forKey:@"self.applicationBuild"];
  [coder encodeObject:self.exceptionType forKey:@"self.exceptionType"];
  [coder encodeObject:self.exceptionCode forKey:@"self.exceptionCode"];
  [coder encodeObject:self.exceptionAddress forKey:@"self.exceptionAddress"];
  [coder encodeObject:self.exceptionReason forKey:@"self.exceptionReason"];
}


@end
