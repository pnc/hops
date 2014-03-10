#import <XCTest/XCTest.h>
#import "PCPackageUnpacker.h"

@interface PCPackageUnpackerTest : XCTestCase

@end

@implementation PCPackageUnpackerTest

- (void)setUp {
  [super setUp];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testCorruptPackage {
  NSURL *corrupt = [[NSBundle bundleForClass:[self class]]
                    URLForResource:@"ipa-corrupt"
                    withExtension:@"ipa"];
  NSError *error = nil;
  PCPackageUnpacker *unpacker = [[PCPackageUnpacker alloc] initWithPackageAtURL:corrupt error:&error];
  XCTAssertNil(unpacker, @"Expected no unpacker result");
  XCTAssertEqual(error.code, PCPackageUnpackerErrorCorruptPackage,
                 @"Expected a corrupt package error");
}

- (void)testPackageWithoutEmbeddedProfile {
  NSURL *archive = [[NSBundle bundleForClass:[self class]]
                    URLForResource:@"ipa-no-profile"
                    withExtension:@"ipa"];
  NSError *error = nil;
  PCPackageUnpacker *unpacker = [[PCPackageUnpacker alloc] initWithPackageAtURL:archive error:&error];
  XCTAssertNotNil(unpacker, @"Expected a packer; had error: %@", error);
  XCTAssertNil(unpacker.streamForEmbeddedProfile, @"Expected no embedded profile");
}

- (void)testPackageWithEmbeddedProfile {
  NSURL *archive = [[NSBundle bundleForClass:[self class]]
                    URLForResource:@"ipa-valid-profile"
                    withExtension:@"ipa"];
  NSError *error = nil;
  PCPackageUnpacker *unpacker = [[PCPackageUnpacker alloc] initWithPackageAtURL:archive error:&error];
  XCTAssertNotNil(unpacker, @"Expected a package, had error: %@", error);
  NSInputStream *stream = [unpacker streamForEmbeddedProfile];
  XCTAssertNotNil(stream, @"Expected an embedded profile stream, had error: %@", error);
  [stream open];
  uint8_t buffer[8];
  NSInteger result = [stream read:buffer maxLength:8];
  XCTAssert(result > 0, @"Expected nonzero-length profile stream");
}

- (void)testPackageWithInfo {
  NSURL *archive = [[NSBundle bundleForClass:[self class]]
                    URLForResource:@"ipa-valid-info"
                    withExtension:@"ipa"];
  NSError *error = nil;
  PCPackageUnpacker *unpacker = [[PCPackageUnpacker alloc] initWithPackageAtURL:archive error:&error];
  XCTAssertNotNil(unpacker, @"Expected a package, had error: %@", error);
  NSInputStream *stream = [unpacker streamForInfo];
  XCTAssertNotNil(stream, @"Expected an info stream, had error: %@", error);
  [stream open];
  uint8_t buffer[8];
  NSInteger result = [stream read:buffer maxLength:8];
  XCTAssert(result > 0, @"Expected nonzero-length info stream");
}

@end
