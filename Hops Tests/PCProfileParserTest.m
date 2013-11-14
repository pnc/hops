#import <XCTest/XCTest.h>
#import "PCProfileParser.h"
#import "PCProfileParser_Private.h"
#import "PCProfile.h"

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

  XCTAssertTrue(result, @"Expected parsing valid fixture to succeed, instead: %@", error);
  XCTAssertNotNil(parser.profile, @"Expected a parsed profile result");
  PCProfile *profile = parser.profile;
  NSArray *devices = @[@"26632afcf0600a7f1ce2d36ca0bc97c97e63727d",
                       @"71cd2d97b88f7e56d8d415e0dd2f07ebf0f3a9e9",
                       @"52ee146a30a0cce62bae37cae5d8198813ab9c63",
                       @"05576f02171d25c162ac2a0dcb9890808ea6ecd8"];
  XCTAssertEqualObjects(devices, profile.provisionedDevices, @"Expected provisioned devices to be listed");
  /*
   @property (readonly) NSString *name;
   @property (readonly) NSString *applicationIdentifier;
   @property (readonly) NSString *applePushServiceEnvironment;
   @property (readonly) NSNumber *getTaskAllow;
   @property (readonly) NSArray *keychainAccessGroups;
   */
  XCTAssertEqualObjects(@"Coatcheck", profile.name,
                        @"Profile name was wrong");
  XCTAssertEqualObjects(@"VC9P2XC96U.com.phillipcalvin.Coatcheck",
                        profile.applicationIdentifier,
                        @"App identifier was wrong");
  XCTAssertEqualObjects(@"development",
                        profile.applePushServiceEnvironment,
                        @"APS environment was wrong");
  XCTAssertEqualObjects(@YES,
                        profile.getTaskAllow,
                        @"Debuggable flag was wrong");
  XCTAssertEqualObjects(@[@"VC9P2XC96U.*"],
                        profile.keychainAccessGroups,
                        @"Keychain access groups was wrong");

}

- (void)testPropertyListWithArrayRoot {
  NSURL *plist = [[NSBundle bundleForClass:[self class]]
                  URLForResource:@"plist-root-array"
                  withExtension:@"plist"];
  NSData *data = [NSData dataWithContentsOfURL:plist];
  NSError *error = nil;
  PCProfile *profile = [PCProfileParser profileFromData:data
                                                  error:&error];
  XCTAssertNil(profile, @"Expected nil profile from a plist with an array root");
  XCTAssertEqual(error.code, PCProfileParserErrorUnexpectedPropertyListType,
                 @"Expected parsing nil profile to cause an error");

}

@end
