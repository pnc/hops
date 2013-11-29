#import "PCArchivePreview.h"
#import "PCArchiveUnpacker.h"
#import "PCProfileParser.h"
#import "PCProfile.h"
#import <GRMustache.h>

@interface PCArchivePreview ()
@property NSURL *url;
@property (readwrite) NSString *plainText;
@property (readwrite) NSString *HTML;
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
      if ([self render:profile withError:error]) {
        return YES;
      }
    }
  }
  return NO;
}

- (BOOL)render:(PCProfile *)profile withError:(NSError *__autoreleasing *)error {
  NSBundle *bundle = [NSBundle bundleForClass:[self class]];
  NSString *plainText = [GRMustacheTemplate renderObject:profile
                                            fromResource:@"text"
                                                  bundle:bundle
                                                   error:error];
  if (plainText) {
    NSString *HTML = [GRMustacheTemplate renderObject:profile
                                         fromResource:@"html"
                                               bundle:bundle
                                                error:error];
    if (HTML) {
      self.plainText = plainText;
      self.HTML = HTML;
      return YES;
    }
  }
  return NO;
}
@end
