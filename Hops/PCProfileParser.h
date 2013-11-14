#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PCProfileParserError) {
  PCProfileParserErrorUnknown = 9000,
  PCProfileParserErrorUnexpectedEndOfStream,
  PCProfileParserErrorCorruptProfile
};

@interface PCProfileParser : NSObject
- (instancetype)initWithStream:(NSInputStream *)stream;
- (instancetype)initWithContentsOfURL:(NSURL *)url;
- (BOOL)parse:(NSError **)error;

@property (readonly) id profile;
@end
