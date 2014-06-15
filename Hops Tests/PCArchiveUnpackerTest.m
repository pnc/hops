#import <XCTest/XCTest.h>
#import "PCArchiveUnpacker.h"

@interface PCArchiveUnpackerTest : XCTestCase

@end

@implementation PCArchiveUnpackerTest

- (void)setUp {
  [super setUp];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testCorruptArchive {
  NSURL *corrupt = [[NSBundle bundleForClass:[self class]]
                    URLForResource:@"archive-corrupt"
                    withExtension:@"xcarchive"];
  NSError *error = nil;
  PCArchiveUnpacker *unpacker = [[PCArchiveUnpacker alloc] initWithArchiveAtURL:corrupt error:&error];
  XCTAssertNil(unpacker, @"Expected no unpacker result");
  XCTAssertEqual(error.code, PCArchiveUnpackerErrorCorruptPackage,
                 @"Expected a corrupt package error");
}

- (void)testArchiveWithoutEmbeddedProfile {
  NSURL *archive = [[NSBundle bundleForClass:[self class]]
                    URLForResource:@"archive-no-profile"
                    withExtension:@"xcarchive"];
  NSError *error = nil;
  PCArchiveUnpacker *unpacker = [[PCArchiveUnpacker alloc] initWithArchiveAtURL:archive error:&error];
  XCTAssertNil(unpacker, @"Expected no unpacker result");
  XCTAssertEqual(error.code, PCArchiveUnpackerErrorMissingProfile,
                 @"Expected a missing profile error");
}

@end
