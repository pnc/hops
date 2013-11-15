#import <Foundation/Foundation.h>

@class PCProfile;

static NSString* const PCProfileParserErrorDomain = @"PCProfileParserError";

typedef NS_ENUM(NSInteger, PCProfileParserError) {
  PCProfileParserErrorUnknown = 9000,
  PCProfileParserErrorUnexpectedEndOfStream,
  PCProfileParserErrorCorruptProfile,
  PCProfileParserErrorUnexpectedPropertyListType
};

@interface PCProfileParser : NSObject
- (instancetype)initWithStream:(NSInputStream *)stream;
- (instancetype)initWithContentsOfURL:(NSURL *)url;
- (BOOL)parse:(NSError **)error;

@property (readonly) PCProfile *profile;
@end
