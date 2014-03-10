#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PCPackageUnpackerError) {
  PCPackageUnpackerErrorUnknown = 9000,
  PCPackageUnpackerErrorCorruptPackage
};

static NSString* const PCPackageUnpackerErrorDomain = @"PCPackageUnpackerErrorDomain";

@interface PCPackageUnpacker : NSObject
@property (readonly) NSInputStream *streamForEmbeddedProfile;
@property (readonly) NSInputStream *streamForInfo;

- (instancetype)initWithPackageAtURL:(NSURL *)url error:(NSError *__autoreleasing *)error;
@end
