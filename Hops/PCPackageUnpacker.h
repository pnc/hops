#import <Foundation/Foundation.h>
#import "PCApplicationUnpacker.h"

typedef NS_ENUM(NSInteger, PCPackageUnpackerError) {
  PCPackageUnpackerErrorUnknown = 9000,
  PCPackageUnpackerErrorCorruptPackage
};

static NSString* const PCPackageUnpackerErrorDomain = @"PCPackageUnpackerErrorDomain";

@interface PCPackageUnpacker : NSObject <PCApplicationUnpacker>
- (instancetype)initWithPackageAtURL:(NSURL *)url error:(NSError *__autoreleasing *)error;
@end
