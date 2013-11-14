#import "PCProfileParser.h"

@interface PCProfileParser ()
+ (PCProfile *)profileFromData:(NSData *)data error:(NSError **)error;
@end
