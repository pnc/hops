#import <XCTest/XCTest.h>
#import "PCArchivePreview.h"

@interface PCArchivePreviewTest : XCTestCase

@end

@implementation PCArchivePreviewTest

- (void)setUp {
  [super setUp];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testRealArchiveTextPreview {
  NSURL *archive = [[NSBundle bundleForClass:[self class]]
                    URLForResource:@"ipa-valid-profile"
                    withExtension:@"ipa"];
  PCArchivePreview *preview = [[PCArchivePreview alloc] initWithURL:archive];
  NSError *error = nil;
  BOOL result = [preview generate:&error];
  XCTAssertTrue(result, @"Expected generation to succeed, instead had error: %@", error);
  XCTAssertEqualObjects(preview.plainText,
                        @"Permitted UDIDs:\n  26632afcf0600a7f1ce2d36ca0bc97c97e63727d\n  71cd2d97b88f7e56d8d415e0dd2f07ebf0f3a9e9\n  52ee146a30a0cce62bae37cae5d8198813ab9c63\n  05576f02171d25c162ac2a0dcb9890808ea6ecd8", @"Expected plain text preview");
}

@end
