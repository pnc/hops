#import "PCApplicationUnpacker.h"
#import "PCApplicationPreview.h"
#import "PCPackageUnpacker.h"
#import "PCArchiveUnpacker.h"
#import "PCProfileParser.h"
#import "PCInfoParser.h"
#import "PCInfo.h"
#import "PCProfile.h"
#import <GRMustache.h>

@interface PCApplicationPreview ()
@property NSURL *url;
@property NSString *contentUTI;

@property (readwrite) NSString *plainText;
@property (readwrite) NSString *HTML;
@end

@implementation PCApplicationPreview
- (instancetype)initWithURL:(NSURL *)url contentUTI:(NSString *)UTI {
  if (self = [super init]) {
    NSParameterAssert(url);
    NSParameterAssert(UTI);
    self.url = url;
    self.contentUTI = UTI;
  }
  return self;
}

- (BOOL)generate:(NSError *__autoreleasing *)error {
  id <PCApplicationUnpacker> unpacker = nil;
  if ([@"com.apple.itunes.ipa" isEqual:self.contentUTI]) {
    unpacker = [[PCPackageUnpacker alloc] initWithPackageAtURL:self.url
                                                         error:error];
  } else if ([@"com.apple.xcode.archive" isEqual:self.contentUTI]) {
    unpacker = [[PCArchiveUnpacker alloc] initWithArchiveAtURL:self.url
                                                         error:error];
  } else {
    if (error) {
      NSString *message = [NSString stringWithFormat:@"The content type UTI %@ is not supported.", self.contentUTI];
      *error = [NSError
                errorWithDomain:PCApplicationPreviewErrorDomain
                code:PCApplicationPreviewErrorUnsupportedUTI
                userInfo:@{NSLocalizedDescriptionKey:message}];
    }
  }
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
