#import "PCProfileParser.h"

static NSString* const PCProfileParserErrorDomain = @"PCProfileParserError";

@interface PCProfileParser ()
@property NSInputStream *inputStream;
@end

@implementation PCProfileParser
- (instancetype)initWithStream:(NSInputStream *)stream {
  if (self = [super init]) {
    self.inputStream = stream;
  }
  return self;
}

- (instancetype)initWithContentsOfURL:(NSURL *)url {
  NSInputStream *stream = [[NSInputStream alloc] initWithURL:url];
  if (self = [self initWithStream:stream]) {

  }
  return self;
}

- (BOOL)parse:(NSError *__autoreleasing *)error {
  [self.inputStream open];
  if ([self.inputStream hasBytesAvailable]) {
    *error = [NSError errorWithDomain:PCProfileParserErrorDomain
                                 code:PCProfileParserErrorCorruptProfile
                             userInfo:nil];
  } else {
    *error = [NSError errorWithDomain:PCProfileParserErrorDomain
                                 code:PCProfileParserErrorUnexpectedEndOfStream
                             userInfo:nil];
  }
  return NO;
}
@end
