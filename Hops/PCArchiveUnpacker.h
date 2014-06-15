#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PCArchiveUnpackerError) {
  PCArchiveUnpackerErrorUnknown = 9000,
  PCArchiveUnpackerErrorCorruptPackage
};

static NSString* const PCArchiveUnpackerErrorDomain = @"PCArchiveUnpackerErrorDomain";

@interface PCArchiveUnpacker : NSObject
@property (readonly) NSInputStream *streamForEmbeddedProfile;
@property (readonly) NSInputStream *streamForInfo;

- (instancetype)initWithArchiveAtURL:(NSURL *)url error:(NSError *__autoreleasing *)error;
@end
