#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PCApplicationPreviewError) {
  PCApplicationPreviewErrorUnknown = 9000,
  PCApplicationPreviewErrorUnsupportedUTI
};

static NSString* const PCApplicationPreviewErrorDomain = @"PCApplicationPreviewErrorDomain";

@interface PCApplicationPreview : NSObject
@property (readonly) NSString *plainText;
@property (readonly) NSString *HTML;
- (instancetype)initWithURL:(NSURL *)url contentUTI:(NSString *)UTI;
- (BOOL)generate:(NSError *__autoreleasing *)error;
@end
