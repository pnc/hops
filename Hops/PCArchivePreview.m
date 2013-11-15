#import "PCArchivePreview.h"
#import "PCArchiveUnpacker.h"
#import "PCProfileParser.h"
#import "PCProfile.h"

@interface PCArchivePreview ()
@property NSURL *url;
@property (readwrite) NSString *plainText;
@end

@implementation PCArchivePreview
- (instancetype)initWithURL:(NSURL *)url {
  if (self = [super init]) {
    self.url = url;
  }
  return self;
}

- (BOOL)generate:(NSError *__autoreleasing *)error {
  PCArchiveUnpacker *archive = [[PCArchiveUnpacker alloc] initWithArchiveAtURL:self.url error:error];
  if (archive) {
    PCProfileParser *parser = [[PCProfileParser alloc]
                               initWithStream:archive.streamForEmbeddedProfile];
    if ([parser parse:error]) {
      PCProfile *profile = parser.profile;
      self.plainText = [NSString stringWithFormat:@"Permitted UDIDs:\n  %@",
                        [profile.provisionedDevices
                         componentsJoinedByString:@"\n  "]];
      return YES;
    }
  }
  return NO;
}
@end
