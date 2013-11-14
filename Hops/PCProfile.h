#import <Foundation/Foundation.h>

@interface PCProfile : NSObject
@property (readonly) NSArray *provisionedDevices;
@property (readonly) NSString *name;
@property (readonly) NSString *applicationIdentifier;
@property (readonly) NSString *applePushServiceEnvironment;
@property (readonly) NSNumber *getTaskAllow;
@property (readonly) NSArray *keychainAccessGroups;
@end
