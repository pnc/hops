#import "PCPackagePreview.h"
#import "PCPackageUnpacker.h"
#import "PCProfileParser.h"
#import "PCInfoParser.h"
#import "PCInfo.h"
#import "PCProfile.h"
#import <GRMustache.h>

@interface PCPackagePreview ()
@property NSURL *url;
@property (readwrite) NSString *plainText;
@property (readwrite) NSString *HTML;
@end

@implementation PCPackagePreview
- (instancetype)initWithURL:(NSURL *)url {
  if (self = [super init]) {
    self.url = url;
  }
  return self;
}

- (BOOL)generate:(NSError *__autoreleasing *)error {
  PCPackageUnpacker *unpacker = [[PCPackageUnpacker alloc] initWithPackageAtURL:self.url error:error];
  if (unpacker) {
    PCProfileParser *profileParser = nil;
    if (unpacker.streamForEmbeddedProfile) {
      profileParser = [[PCProfileParser alloc]
                       initWithStream:unpacker.streamForEmbeddedProfile];
    }
    PCInfoParser *infoParser = nil;
    if (unpacker.streamForInfo) {
      infoParser = [[PCInfoParser alloc]
                    initWithStream:unpacker.streamForInfo];
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
