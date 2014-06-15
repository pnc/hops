#import <Foundation/Foundation.h>
#import "PCApplicationUnpacker.h"

typedef NS_ENUM(NSInteger, PCArchiveUnpackerError) {
  PCArchiveUnpackerErrorUnknown = 9000,
  PCArchiveUnpackerErrorCorruptPackage
};

static NSString* const PCArchiveUnpackerErrorDomain = @"PCArchiveUnpackerErrorDomain";

@interface PCArchiveUnpacker : NSObject <PCApplicationUnpacker>
- (instancetype)initWithArchiveAtURL:(NSURL *)url error:(NSError *__autoreleasing *)error;
@end
