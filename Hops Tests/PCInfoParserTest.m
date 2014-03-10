#import <XCTest/XCTest.h>
#import "PCInfoParser.h"

@interface PCInfoParserTest : XCTestCase

@end

@implementation PCInfoParserTest

- (void)testEmptyStream {
  NSInputStream *stream = [NSInputStream inputStreamWithData:[NSData data]];
  PCInfoParser *parser = [[PCInfoParser alloc] initWithStream:stream];
  NSError *error = nil;
  BOOL result = [parser parse:&error];

  XCTAssertFalse(result, @"Expected parsing empty stream to fail");
  XCTAssertEqual(error.code, PCInfoParserErrorUnknown,
                 @"Expected parsing empty stream to return unknown error");
}

- (void)testCorruptInfo {
  NSURL *corrupt = [[NSBundle bundleForClass:[self class]]
                    URLForResource:@"info-plist-missing-bundle-name"
                    withExtension:@"plist"];
  PCInfoParser *parser = [[PCInfoParser alloc]
                          initWithContentsOfURL:corrupt];
  NSError *error = nil;
  BOOL result = [parser parse:&error];

  XCTAssertFalse(result, @"Expected parsing corrupt fixture to fail");
  XCTAssertEqual(error.code, PCInfoParserErrorCorruptInfo,
                 @"Expected parsing corrupt info to cause an error");
}

- (void)testValidInfo {
  NSURL *valid = [[NSBundle bundleForClass:[self class]]
                  URLForResource:@"info-plist-valid"
                  withExtension:@"plist"];
  PCInfoParser *parser = [[PCInfoParser alloc]
                          initWithContentsOfURL:valid];
  NSError *error = nil;
  BOOL result = [parser parse:&error];

  XCTAssertTrue(result, @"Expected parsing valid fixture to succeed, instead: %@", error);
  XCTAssertEqualObjects(@"Coatcheck", parser.bundleDisplayName, @"Bundle name incorrect");
  XCTAssertEqualObjects(@"1.0", parser.bundleVersion, @"Bundle version incorrect");
}

@end
