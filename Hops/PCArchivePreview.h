#import <Foundation/Foundation.h>

@interface PCArchivePreview : NSObject
@property (readonly) NSString *plainText;
- (instancetype)initWithURL:(NSURL *)url;
- (BOOL)generate:(NSError *__autoreleasing *)error;
@end
