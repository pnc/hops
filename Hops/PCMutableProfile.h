#import "PCProfile.h"

@interface PCMutableProfile : PCProfile
@property (readwrite) NSArray *provisionedDevices;
@property (readwrite) NSString *name;
@property (readwrite) NSString *applicationIdentifier;
@property (readwrite) NSString *applePushServiceEnvironment;
@property (readwrite) NSNumber *getTaskAllow;
@property (readwrite) NSArray *keychainAccessGroups;
@end
