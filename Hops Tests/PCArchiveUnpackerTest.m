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
                    URLForResource:@"ipa-corrupt"
                    withExtension:@"ipa"];
  NSError *error = nil;
  PCArchiveUnpacker *unpacker = [[PCArchiveUnpacker alloc] initWithArchiveAtURL:corrupt error:&error];
  XCTAssertNil(unpacker, @"Expected no unpacker result");
  XCTAssertEqual(error.code, PCArchiveUnpackerErrorCorruptArchive,
                 @"Expected a corrupt archive error");
}

- (void)testArchiveWithoutEmbeddedProfile {
  NSURL *archive = [[NSBundle bundleForClass:[self class]]
                    URLForResource:@"ipa-no-profile"
                    withExtension:@"ipa"];
  NSError *error = nil;
  PCArchiveUnpacker *unpacker = [[PCArchiveUnpacker alloc] initWithArchiveAtURL:archive error:&error];
  XCTAssertNotNil(unpacker, @"Expected a packer; had error: %@", error);
  XCTAssertNil(unpacker.streamForEmbeddedProfile, @"Expected no embedded profile");
}

- (void)testArchiveWithEmbeddedProfile {
  NSURL *archive = [[NSBundle bundleForClass:[self class]]
                    URLForResource:@"ipa-valid-profile"
                    withExtension:@"ipa"];
  NSError *error = nil;
  PCArchiveUnpacker *unpacker = [[PCArchiveUnpacker alloc] initWithArchiveAtURL:archive error:&error];
  XCTAssertNotNil(unpacker, @"Expected an archive, had error: %@", error);
  NSInputStream *stream = [unpacker streamForEmbeddedProfile];
  XCTAssertNotNil(stream, @"Expected an embedded profile stream, had error: %@", error);
  [stream open];
  uint8_t buffer[8];
  NSInteger result = [stream read:buffer maxLength:8];
  XCTAssert(result > 0, @"Expected nonzero-length profile stream");
}

- (void)testArchiveWithInfo {
  NSURL *archive = [[NSBundle bundleForClass:[self class]]
                    URLForResource:@"ipa-valid-info"
                    withExtension:@"ipa"];
  NSError *error = nil;
  PCArchiveUnpacker *unpacker = [[PCArchiveUnpacker alloc] initWithArchiveAtURL:archive error:&error];
  XCTAssertNotNil(unpacker, @"Expected an archive, had error: %@", error);
  NSInputStream *stream = [unpacker streamForInfo];
  XCTAssertNotNil(stream, @"Expected an info stream, had error: %@", error);
  [stream open];
  uint8_t buffer[8];
  NSInteger result = [stream read:buffer maxLength:8];
  XCTAssert(result > 0, @"Expected nonzero-length info stream");
}

@end
