#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PCArchiveUnpackerError) {
  PCProfileParserErrorUnknown = 9000,
  PCProfileParserErrorCorruptArchive,
  PCProfileParserErrorNoEmbeddedProfile
};

static NSString* const PCArchiveUnpackerErrorDomain = @"PCArchiveUnpackerErrorDomain";

@interface PCArchiveUnpacker : NSObject
@property (readonly) NSInputStream *streamForEmbeddedProfile;

- (instancetype)initWithArchiveAtURL:(NSURL *)url error:(NSError *__autoreleasing *)error;
@end
