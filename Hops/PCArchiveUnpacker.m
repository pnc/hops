#import "PCArchiveUnpacker.h"
#import <zipzap/zipzap.h>

@interface PCArchiveUnpacker ()
@property ZZArchive *archive;
@property (readwrite) NSInputStream *streamForEmbeddedProfile;
@property (readwrite) NSInputStream *streamForInfo;
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
                                   code:PCArchiveUnpackerErrorCorruptArchive
                               userInfo:@{NSLocalizedDescriptionKey:
                                            @"The file is not a valid ZIP archive and cannot be parsed."}];
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
    } else if (path.count > 0 &&
              [@"Payload" isEqual:[path objectAtIndex:0]] &&
              [@"Info.plist" isEqual:path.lastObject]) {
      self.streamForInfo = entry.stream;
    } else {
      NSLog(@"Unrecognized archive file: %@", entry.fileName);
    }
  }
  return YES;
}
@end
