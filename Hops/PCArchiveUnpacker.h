#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PCArchiveUnpackerError) {
  PCArchiveUnpackerErrorUnknown = 9000,
  PCArchiveUnpackerErrorCorruptArchive,
  PCArchiveUnpackerErrorNoEmbeddedProfile
};

static NSString* const PCArchiveUnpackerErrorDomain = @"PCArchiveUnpackerErrorDomain";

@interface PCArchiveUnpacker : NSObject
@property (readonly) NSInputStream *streamForEmbeddedProfile;

- (instancetype)initWithArchiveAtURL:(NSURL *)url error:(NSError *__autoreleasing *)error;
@end
