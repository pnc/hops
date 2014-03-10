#import <Foundation/Foundation.h>

@interface PCPackagePreview : NSObject
@property (readonly) NSString *plainText;
@property (readonly) NSString *HTML;
- (instancetype)initWithURL:(NSURL *)url;
- (BOOL)generate:(NSError *__autoreleasing *)error;
@end
