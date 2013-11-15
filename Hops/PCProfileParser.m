#import "PCProfileParser.h"
#import <Security/Security.h>
#import "PCMutableProfile.h"

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
    _profile = [self.class profileFromData:data error:error];
  }
  [self.inputStream close];
  return !!_profile;
}

#pragma mark - Read cryptographic message

- (NSData *)loadMessageDataFromStream:(NSInputStream *)stream error:(NSError *__autoreleasing *)error {
  NSData *data = nil;
  OSStatus result = noErr;
  CMSDecoderRef decoder = NULL;
  CMSDecoderCreate(&decoder);

  if ([self.class fillDecoder:decoder fromStream:stream error:error]) {
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

+ (BOOL)fillDecoder:(CMSDecoderRef)decoder fromStream:(NSInputStream *)stream error:(NSError *__autoreleasing *)error {
  uint8_t buffer[4096];
  BOOL anyData = NO;
  while ([stream hasBytesAvailable]) {
    NSInteger result = [stream read:buffer maxLength:4096];
    if (result > 0) {
      anyData = YES;
      CMSDecoderUpdateMessage(decoder, buffer, result);
    } else {
      break;
    }
  }
  return anyData;
}

#pragma mark - Interpret plist
+ (PCProfile *)profileFromData:(NSData *)data error:(NSError *__autoreleasing *)error {
  PCProfile *profile = nil;
  NSPropertyListFormat format;
  id propertyList = [NSPropertyListSerialization
                     propertyListWithData:data
                     options:0
                     format:&format
                     error:error];
  if (propertyList && [propertyList isKindOfClass:[NSDictionary class]]) {
    profile = [self.class profileFromDictionary:propertyList error:error];
  } else if (propertyList) {
    *error = [NSError errorWithDomain:PCProfileParserErrorDomain
                                 code:PCProfileParserErrorUnexpectedPropertyListType
                             userInfo:nil];
  } else {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (*error) {
      [userInfo setObject:*error forKey:NSUnderlyingErrorKey];
    }
    *error = [NSError errorWithDomain:PCProfileParserErrorDomain
                                 code:PCProfileParserErrorUnknown
                             userInfo:userInfo];
  }
  return profile;
}

+ (PCProfile *)profileFromDictionary:(NSDictionary *)dictionary error:(NSError *__autoreleasing *)error {
  PCMutableProfile *profile = [PCMutableProfile new];
  profile.name = [dictionary objectForKey:@"Name"];
  profile.provisionedDevices = [dictionary objectForKey:@"ProvisionedDevices"];
  NSDictionary *entitlements = [dictionary objectForKey:@"Entitlements"];
  if (entitlements && [entitlements isKindOfClass:[NSDictionary class]]) {
    profile.applicationIdentifier = [entitlements objectForKey:@"application-identifier"];
    profile.applePushServiceEnvironment = [entitlements objectForKey:@"aps-environment"];
    profile.getTaskAllow = [entitlements objectForKey:@"get-task-allow"];
    profile.keychainAccessGroups = [entitlements objectForKey:@"keychain-access-groups"];
  }
  return profile;
}
@end
