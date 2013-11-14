#import "PCProfileParser.h"
#import <Security/Security.h>

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
  NSData *data = [self loadMessageDataFromStream:self.inputStream error:error];
  if (data) {
    _profile = data;
  }
  [self.inputStream close];
  return !!data;
}

- (NSData *)loadMessageDataFromStream:(NSInputStream *)stream error:(NSError **)error {
  NSData *data = nil;
  OSStatus result = noErr;
  CMSDecoderRef decoder = NULL;
  CMSDecoderCreate(&decoder);

  if ([self fillDecoder:decoder fromStream:stream error:error]) {
    result = CMSDecoderFinalizeMessage(decoder);
    if (noErr == result) {
      CFDataRef content = NULL;
      result = CMSDecoderCopyContent(decoder, &content);
      if (noErr == result) {
        data = CFBridgingRelease(content);
      }
    } else if (errSecUnknownFormat == result) {
      *error = [NSError errorWithDomain:PCProfileParserErrorDomain
                                   code:PCProfileParserErrorCorruptProfile
                               userInfo:nil];
      result = noErr;
    }
  } else {
    *error = [NSError errorWithDomain:PCProfileParserErrorDomain
                                 code:PCProfileParserErrorUnexpectedEndOfStream
                             userInfo:nil];
    result = noErr;
  }

  if (noErr != result) {
    NSError *underlying = [NSError
                           errorWithDomain:NSOSStatusErrorDomain
                           code:result
                           userInfo:nil];
    *error = [NSError
              errorWithDomain:PCProfileParserErrorDomain
              code:PCProfileParserErrorUnknown
              userInfo:@{NSUnderlyingErrorKey:underlying}];
  }

  CFRelease(decoder);
  return data;
}

- (BOOL)fillDecoder:(CMSDecoderRef)decoder fromStream:(NSInputStream *)stream error:(NSError **)error {
  uint8_t buffer[4096];
  BOOL anyData = NO;
  while ([self.inputStream hasBytesAvailable]) {
    NSInteger result = [self.inputStream read:buffer maxLength:4096];
    if (result > 0) {
      CMSDecoderUpdateMessage(decoder, buffer, result);
    }
    anyData = YES;
  }
  return anyData;
}
@end
