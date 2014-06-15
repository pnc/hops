#import <Foundation/Foundation.h>

@protocol PCApplicationUnpacker <NSObject>
@property (readonly) NSInputStream *streamForEmbeddedProfile;
@property (readonly) NSInputStream *streamForInfo;
@end
