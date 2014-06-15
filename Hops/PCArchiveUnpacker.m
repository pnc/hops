#import "PCArchiveUnpacker.h"

@interface PCArchiveUnpacker ()
@property NSFileWrapper *wrapper;
@property (readwrite) NSInputStream *streamForEmbeddedProfile;
@property (readwrite) NSInputStream *streamForInfo;
@end

@implementation PCArchiveUnpacker
- (instancetype)initWithArchiveAtURL:(NSURL *)url error:(NSError *__autoreleasing *)error {
  if (self = [super init]) {
    self.wrapper = [[NSFileWrapper alloc] initWithURL:url options:0 error:error];
    if (self.wrapper) {
      if ([self accessFiles:error]) {
        return self;
      }
      return nil;
    } else {
      NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
      if (*error) {
        [userInfo setObject:*error forKey:NSUnderlyingErrorKey];
      }
      *error = [NSError errorWithDomain:PCArchiveUnpackerErrorDomain
                                   code:PCArchiveUnpackerErrorCorruptPackage
                               userInfo:@{NSLocalizedDescriptionKey:
                                            @"The file is not an application archive."}];
      return nil;
    }
  }
  return self;
}

- (BOOL)accessFiles:(NSError *__autoreleasing *)error {
  NSLog(@"File wrappers: %@", self.wrapper.fileWrappers);
  NSFileWrapper *productsWrapper = [self.wrapper.fileWrappers
                                    objectForKey:@"Products"];
  NSFileWrapper *applicationsWrapper = [productsWrapper.fileWrappers
                                        objectForKey:@"Applications"];
  NSFileWrapper *applicationWrapper = nil;
  for (NSString *filename in applicationsWrapper.fileWrappers.allKeys) {
    if ([@"app" isEqual:[filename pathExtension]]) {
      applicationWrapper = [applicationsWrapper.fileWrappers
                             objectForKey:filename];
    }
  }
  NSFileWrapper *mobileProvisionWrapper = [applicationWrapper.fileWrappers
                                           objectForKey:@"embedded.mobileprovision"];
  NSFileWrapper *infoWrapper = [applicationWrapper.fileWrappers
                                objectForKey:@"Info.plist"];
  if (productsWrapper && applicationsWrapper && applicationWrapper) {
    if (mobileProvisionWrapper) {
      NSData *mobileProvision = [mobileProvisionWrapper regularFileContents];
      self.streamForEmbeddedProfile = [NSInputStream inputStreamWithData:mobileProvision];
    }
    if (infoWrapper) {
      NSData *info = [infoWrapper regularFileContents];
      self.streamForInfo = [NSInputStream inputStreamWithData:info];
    }
    return YES;
  } else {
    // This will happen if the file moves before we have
    // a chance to read it, which is unlikely.
    *error = [NSError errorWithDomain:PCArchiveUnpackerErrorDomain
                                 code:PCArchiveUnpackerErrorCorruptPackage
                             userInfo:@{NSLocalizedDescriptionKey:
                                          @"The file is a bundle, but not an application archive."}];
    return NO;
  }
}

@end
