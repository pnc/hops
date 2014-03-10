#import <Foundation/Foundation.h>
#import "PCInfo.h"

static NSString* const PCInfoParserErrorDomain = @"PCInfoParserError";

typedef NS_ENUM(NSInteger, PCInfoParserError) {
  PCInfoParserErrorUnknown = 9000,
  PCInfoParserErrorCorruptInfo,
  PCInfoParserErrorUnexpectedPropertyListType
};

@interface PCInfoParser : NSObject <PCInfo>
- (instancetype)initWithStream:(NSInputStream *)stream;
- (instancetype)initWithContentsOfURL:(NSURL *)url;
- (BOOL)parse:(NSError **)error;
@end
