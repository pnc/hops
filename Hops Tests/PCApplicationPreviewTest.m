#import <XCTest/XCTest.h>
#import "PCApplicationPreview.h"

@interface PCApplicationPreviewTest : XCTestCase

@end

@implementation PCApplicationPreviewTest

- (void)setUp {
  [super setUp];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testUnknownTextPreview {
  NSURL *archive = [[NSBundle bundleForClass:[self class]]
                    URLForResource:@"archive-info-and-profile"
                    withExtension:@"xcarchive"];
  PCApplicationPreview *preview = [[PCApplicationPreview alloc]
                                   initWithURL:archive
                                   contentUTI:@"com.garbage"];
  NSError *error = nil;
  BOOL result = [preview generate:&error];
  XCTAssertFalse(result, @"Expected generation to fail, instead it succeeded");
  XCTAssertEqual(PCApplicationPreviewErrorUnsupportedUTI,
                 error.code, @"Expected unsupported UTI error");
}

- (void)testPackageTextPreview {
  NSURL *package = [[NSBundle bundleForClass:[self class]]
                    URLForResource:@"ipa-info-and-profile"
                    withExtension:@"ipa"];
  PCApplicationPreview *preview = [[PCApplicationPreview alloc]
                                   initWithURL:package
                                   contentUTI:@"com.apple.itunes.ipa"];
  NSError *error = nil;
  BOOL result = [preview generate:&error];
  XCTAssertTrue(result, @"Expected generation to succeed, instead had error: %@", error);
  XCTAssertEqualObjects(preview.plainText,
                        @"Coatcheck 1.0\nPermitted UDIDs:\n  26632afcf0600a7f1ce2d36ca0bc97c97e63727d\n  71cd2d97b88f7e56d8d415e0dd2f07ebf0f3a9e9\n  52ee146a30a0cce62bae37cae5d8198813ab9c63\n  05576f02171d25c162ac2a0dcb9890808ea6ecd8", @"Expected plain text preview");
}

- (void)testArchiveTextPreview {
  NSURL *archive = [[NSBundle bundleForClass:[self class]]
                    URLForResource:@"archive-info-and-profile"
                    withExtension:@"xcarchive"];
  PCApplicationPreview *preview = [[PCApplicationPreview alloc]
                                   initWithURL:archive
                                   contentUTI:@"com.apple.xcode.archive"];
  NSError *error = nil;
  BOOL result = [preview generate:&error];
  XCTAssertTrue(result, @"Expected generation to succeed, instead had error: %@", error);
  XCTAssertEqualObjects(preview.plainText,
                        @"Coatcheck 1.0\nPermitted UDIDs:\n  26632afcf0600a7f1ce2d36ca0bc97c97e63727d\n  71cd2d97b88f7e56d8d415e0dd2f07ebf0f3a9e9\n  52ee146a30a0cce62bae37cae5d8198813ab9c63\n  05576f02171d25c162ac2a0dcb9890808ea6ecd8", @"Expected plain text preview");
}

@end
