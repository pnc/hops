#import "PCArchivePreview.h"
#import "PCArchiveUnpacker.h"
#import "PCProfileParser.h"
#import "PCInfoParser.h"
#import "PCInfo.h"
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
    PCProfileParser *profileParser = nil;
    if (archive.streamForEmbeddedProfile) {
      profileParser = [[PCProfileParser alloc]
                       initWithStream:archive.streamForEmbeddedProfile];
    }
    PCInfoParser *infoParser = nil;
    if (archive.streamForInfo) {
      infoParser = [[PCInfoParser alloc]
                    initWithStream:archive.streamForInfo];
    }
    if ([profileParser parse:error] && [infoParser parse:error]) {
      PCProfile *profile = profileParser.profile;
      id <PCInfo> info = infoParser;
      NSDictionary *application = @{@"profile" : profile,
                                    @"info" : info};
      if ([self render:application withError:error]) {
        return YES;
      }
    }
  }
  return NO;
}

- (BOOL)render:(NSDictionary *)application withError:(NSError *__autoreleasing *)error {
  NSBundle *bundle = [NSBundle bundleForClass:[self class]];
  NSString *plainText = [GRMustacheTemplate renderObject:application
                                            fromResource:@"text"
                                                  bundle:bundle
                                                   error:error];
  if (plainText) {
    NSString *HTML = [GRMustacheTemplate renderObject:application
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
