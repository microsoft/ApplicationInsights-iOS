#import "MSAIInternal.h"
/// Data contract class for type Internal.
@implementation MSAIInternal

/// Initializes a new instance of the class.
- (instancetype)init {
  if(self = [super init]) {
  }
  return self;
}

///
/// Adds all members of this class to a dictionary
/// @param dictionary to which the members of this class will be added.
///
- (MSAIOrderedDictionary *)serializeToDictionary {
  MSAIOrderedDictionary *dict = [super serializeToDictionary];
  if(self.sdkVersion != nil) {
    [dict setObject:self.sdkVersion forKey:@"ai.internal.sdkVersion"];
  }
  if(self.agentVersion != nil) {
    [dict setObject:self.agentVersion forKey:@"ai.internal.agentVersion"];
  }
  if(self.dataCollectorReceivedTime != nil) {
    [dict setObject:self.dataCollectorReceivedTime forKey:@"ai.internal.dataCollectorReceivedTime"];
  }
  if(self.profileId != nil) {
    [dict setObject:self.profileId forKey:@"ai.internal.profileId"];
  }
  if(self.profileClassId != nil) {
    [dict setObject:self.profileClassId forKey:@"ai.internal.profileClassId"];
  }
  if(self.accountId != nil) {
    [dict setObject:self.accountId forKey:@"ai.internal.accountId"];
  }
  if(self.applicationName != nil) {
    [dict setObject:self.applicationName forKey:@"ai.internal.applicationName"];
  }
  if(self.instrumentationKey != nil) {
    [dict setObject:self.instrumentationKey forKey:@"ai.internal.instrumentationKey"];
  }
  if(self.telemetryItemId != nil) {
    [dict setObject:self.telemetryItemId forKey:@"ai.internal.telemetryItemId"];
  }
  if(self.applicationType != nil) {
    [dict setObject:self.applicationType forKey:@"ai.internal.applicationType"];
  }
  if(self.requestSource != nil) {
    [dict setObject:self.requestSource forKey:@"ai.internal.requestSource"];
  }
  if(self.flowType != nil) {
    [dict setObject:self.flowType forKey:@"ai.internal.flowType"];
  }
  if(self.isAudit != nil) {
    [dict setObject:self.isAudit forKey:@"ai.internal.isAudit"];
  }
  if(self.trackingSourceId != nil) {
    [dict setObject:self.trackingSourceId forKey:@"ai.internal.trackingSourceId"];
  }
  if(self.trackingType != nil) {
    [dict setObject:self.trackingType forKey:@"ai.internal.trackingType"];
  }
  return dict;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if(self) {
    self.sdkVersion = [coder decodeObjectForKey:@"self.sdkVersion"];
    self.agentVersion = [coder decodeObjectForKey:@"self.agentVersion"];
    self.dataCollectorReceivedTime = [coder decodeObjectForKey:@"self.dataCollectorReceivedTime"];
    self.profileId = [coder decodeObjectForKey:@"self.profileId"];
    self.profileClassId = [coder decodeObjectForKey:@"self.profileClassId"];
    self.accountId = [coder decodeObjectForKey:@"self.accountId"];
    self.applicationName = [coder decodeObjectForKey:@"self.applicationName"];
    self.instrumentationKey = [coder decodeObjectForKey:@"self.instrumentationKey"];
    self.telemetryItemId = [coder decodeObjectForKey:@"self.telemetryItemId"];
    self.applicationType = [coder decodeObjectForKey:@"self.applicationType"];
    self.requestSource = [coder decodeObjectForKey:@"self.requestSource"];
    self.flowType = [coder decodeObjectForKey:@"self.flowType"];
    self.isAudit = [coder decodeObjectForKey:@"self.isAudit"];
    self.trackingSourceId = [coder decodeObjectForKey:@"self.trackingSourceId"];
    self.trackingType = [coder decodeObjectForKey:@"self.trackingType"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [super encodeWithCoder:coder];
  [coder encodeObject:self.sdkVersion forKey:@"self.sdkVersion"];
  [coder encodeObject:self.agentVersion forKey:@"self.agentVersion"];
  [coder encodeObject:self.dataCollectorReceivedTime forKey:@"self.dataCollectorReceivedTime"];
  [coder encodeObject:self.profileId forKey:@"self.profileId"];
  [coder encodeObject:self.profileClassId forKey:@"self.profileClassId"];
  [coder encodeObject:self.accountId forKey:@"self.accountId"];
  [coder encodeObject:self.applicationName forKey:@"self.applicationName"];
  [coder encodeObject:self.instrumentationKey forKey:@"self.instrumentationKey"];
  [coder encodeObject:self.telemetryItemId forKey:@"self.telemetryItemId"];
  [coder encodeObject:self.applicationType forKey:@"self.applicationType"];
  [coder encodeObject:self.requestSource forKey:@"self.requestSource"];
  [coder encodeObject:self.flowType forKey:@"self.flowType"];
  [coder encodeObject:self.isAudit forKey:@"self.isAudit"];
  [coder encodeObject:self.trackingSourceId forKey:@"self.trackingSourceId"];
  [coder encodeObject:self.trackingType forKey:@"self.trackingType"];
}

@end
