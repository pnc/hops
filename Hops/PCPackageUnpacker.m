#import "PCPackageUnpacker.h"
#import <zipzap/zipzap.h>

@interface PCPackageUnpacker ()
@property ZZArchive *archive;
@property (readwrite) NSInputStream *streamForEmbeddedProfile;
@property (readwrite) NSInputStream *streamForInfo;
@end

@implementation PCPackageUnpacker
- (instancetype)initWithPackageAtURL:(NSURL *)url error:(NSError *__autoreleasing *)error {
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
      [userInfo
       setObject:@"The file is not a valid ZIP archive and cannot be parsed."
       forKey:NSLocalizedDescriptionKey];
      if (zipError) {
        [userInfo setObject:zipError forKey:NSUnderlyingErrorKey];
      }
      if (error) {
        *error = [NSError errorWithDomain:PCPackageUnpackerErrorDomain
                                     code:PCPackageUnpackerErrorCorruptPackage
                                 userInfo:userInfo];
      }
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
      self.streamForEmbeddedProfile = [entry newStreamWithError:nil];
    } else if (path.count > 0 &&
              [@"Payload" isEqual:[path objectAtIndex:0]] &&
              [@"Info.plist" isEqual:path.lastObject]) {
      self.streamForInfo = [entry newStreamWithError:nil];
    }
  }
  return YES;
}
@end
