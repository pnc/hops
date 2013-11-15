#import "PCArchiveUnpacker.h"
#import <zipzap/zipzap.h>

@interface PCArchiveUnpacker ()
@property ZZArchive *archive;
@property (readwrite) NSInputStream *streamForEmbeddedProfile;
@end

@implementation PCArchiveUnpacker
- (instancetype)initWithArchiveAtURL:(NSURL *)url error:(NSError *__autoreleasing *)error {
  if (self = [super init]) {
    ZZArchive *archive = [ZZArchive archiveWithContentsOfURL:url];
    NSError *zipError = nil;
    if ([archive load:&zipError]) {
      self.archive = archive;
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
                                   code:PCProfileParserErrorCorruptArchive
                               userInfo:nil];
      return nil;
    }
  }
  return self;
}

- (BOOL)accessFiles:(NSError *__autoreleasing *)error {
  for (ZZArchiveEntry *entry in self.archive.entries) {
    NSArray *path = entry.fileName.pathComponents;
    if (path.count > 0 &&
        [@"Payload" isEqual:[path objectAtIndex:0]] &&
        [@"embedded.mobileprovision" isEqual:path.lastObject]) {
      self.streamForEmbeddedProfile = entry.stream;
    } else {
      NSLog(@"Filename: %@", entry.fileName);
    }
  }
  if (self.streamForEmbeddedProfile) {
    return YES;
  } else {
    *error = [NSError errorWithDomain:PCArchiveUnpackerErrorDomain
                                 code:PCProfileParserErrorNoEmbeddedProfile
                             userInfo:nil];
    return NO;
  }
}
@end
