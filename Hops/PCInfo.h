#import <Foundation/Foundation.h>

@protocol PCInfo <NSObject>
@property (readonly) NSString *bundleDisplayName;
@property (readonly) NSString *bundleVersion;
@end
