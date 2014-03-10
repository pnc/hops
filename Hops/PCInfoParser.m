#import "PCInfoParser.h"

@interface PCInfoParser ()
@property (readwrite) NSString *bundleDisplayName;
@property (readwrite) NSString *bundleVersion;
@property NSInputStream *inputStream;
@end

@implementation PCInfoParser
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
  NSDictionary *info = [self.class infoFromStream:self.inputStream error:error];
  [self.inputStream close];
  if (info) {
    self.bundleDisplayName = [info objectForKey:@"CFBundleDisplayName"];
    self.bundleVersion = [info objectForKey:@"CFBundleVersion"];
    if (self.bundleDisplayName && self.bundleVersion) {
      return YES;
    } else {
      *error = [NSError
                errorWithDomain:PCInfoParserErrorDomain
                code:PCInfoParserErrorCorruptInfo
                userInfo:@{NSLocalizedDescriptionKey:
                             @"Missing one or more required Info.plist keys."}];
    }
  }
  return NO;
}

#pragma mark - Interpret plist
+ (NSDictionary *)infoFromStream:(NSInputStream *)stream error:(NSError *__autoreleasing *)error {
  NSPropertyListFormat format;
  id propertyList = [NSPropertyListSerialization
                     propertyListWithStream:stream
                     options:0
                     format:&format
                     error:error];
  if (propertyList && [propertyList isKindOfClass:[NSDictionary class]]) {
    // Sounds good
  } else if (propertyList) {
    *error = [NSError errorWithDomain:PCInfoParserErrorDomain
                                 code:PCInfoParserErrorUnexpectedPropertyListType
                             userInfo:nil];
    propertyList = nil;
  } else {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (*error) {
      [userInfo setObject:*error forKey:NSUnderlyingErrorKey];
    }
    *error = [NSError errorWithDomain:PCInfoParserErrorDomain
                                 code:PCInfoParserErrorUnknown
                             userInfo:userInfo];
  }
  return propertyList;
}
@end
