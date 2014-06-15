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

- (void)testArchiveWithEmbeddedProfile {
  NSURL *archive = [[NSBundle bundleForClass:[self class]]
                    URLForResource:@"archive-valid-profile"
                    withExtension:@"xcarchive"];
  NSError *error = nil;
  PCArchiveUnpacker *unpacker = [[PCArchiveUnpacker alloc] initWithArchiveAtURL:archive error:&error];
  XCTAssertNotNil(unpacker, @"Expected an unpacker, had error: %@", error);
  NSInputStream *stream = [unpacker streamForEmbeddedProfile];
  XCTAssertNotNil(stream, @"Expected an embedded profile stream, had error: %@", error);
  [stream open];
  uint8_t buffer[8];
  NSInteger result = [stream read:buffer maxLength:8];
  XCTAssert(result > 0, @"Expected nonzero-length profile stream");
}

@end
