#import <XCTest/XCTest.h>
#import "PCProfileParser.h"

@interface PCProfileParserTest : XCTestCase

@end

@implementation PCProfileParserTest

- (void)setUp {
  [super setUp];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testEmptyStream {
  NSInputStream *stream = [NSInputStream inputStreamWithData:[NSData data]];
  PCProfileParser *parser = [[PCProfileParser alloc] initWithStream:stream];
  NSError *error = nil;
  BOOL result = [parser parse:&error];

  XCTAssertFalse(result, @"Expected parsing empty stream to fail");
  XCTAssertEqual(error.code, PCProfileParserErrorUnexpectedEndOfStream,
                 @"Expected parsing empty stream to return EOF error");
}

- (void)testCorruptProfile {
  NSURL *corrupt = [[NSBundle bundleForClass:[self class]]
                    URLForResource:@"profile-corrupt"
                    withExtension:@"mobileprovision"];
  PCProfileParser *parser = [[PCProfileParser alloc]
                             initWithContentsOfURL:corrupt];
  NSError *error = nil;
  BOOL result = [parser parse:&error];

  XCTAssertFalse(result, @"Expected parsing corrupt fixture to fail");
  XCTAssertEqual(error.code, PCProfileParserErrorCorruptProfile,
                 @"Expected parsing corrupt profile to cause an error");
}

- (void)testValidProfile {
  NSURL *valid = [[NSBundle bundleForClass:[self class]]
                    URLForResource:@"profile-valid"
                    withExtension:@"mobileprovision"];
  PCProfileParser *parser = [[PCProfileParser alloc]
                             initWithContentsOfURL:valid];
  NSError *error = nil;
  BOOL result = [parser parse:&error];

  XCTAssertTrue(result, @"Expected parsing valid fixture to succeed");
  XCTAssertNotNil(parser.profile, @"Expected a parsed profile result");
}

@end
