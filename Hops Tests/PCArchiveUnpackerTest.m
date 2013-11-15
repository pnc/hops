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
  XCTAssertEqual(error.code, PCProfileParserErrorCorruptArchive,
                 @"Expected a corrupt archive error");
}

- (void)testArchiveWithoutEmbeddedProfile {
  NSURL *archive = [[NSBundle bundleForClass:[self class]]
                    URLForResource:@"ipa-no-profile"
                    withExtension:@"ipa"];
  NSError *error = nil;
  PCArchiveUnpacker *unpacker = [[PCArchiveUnpacker alloc] initWithArchiveAtURL:archive error:&error];
  XCTAssertNil(unpacker, @"Expected no unpacker result");
  XCTAssertEqual(error.code, PCProfileParserErrorNoEmbeddedProfile,
                 @"Expected a no profile error");

}

- (void)testArchiveWithEmbeddedProfile {
  NSURL *archive = [[NSBundle bundleForClass:[self class]]
                    URLForResource:@"ipa-valid-profile"
                    withExtension:@"ipa"];
  NSError *error = nil;
  PCArchiveUnpacker *unpacker = [[PCArchiveUnpacker alloc] initWithArchiveAtURL:archive error:&error];
  XCTAssertNotNil(unpacker, @"Expected an unpacker result");
  NSInputStream *stream = [unpacker streamForEmbeddedProfile];
  [stream open];
  uint8_t buffer[8];
  NSInteger result = [stream read:buffer maxLength:8];
  XCTAssert(result > 0, @"Expected nonzero-length profile stream");
}

@end
