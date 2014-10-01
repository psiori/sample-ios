//
//  SampleTests.m
//  analytics-sample-ios
//
//  Created by Daniel Band on 28/08/14.
//  Copyright (c) 2014 5dlab GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XCTestCase+AsyncTesting.h"
#import "SampleExtension.h"
#import "Sample.h"
#import "Connector.h"

@interface SampleTests : XCTestCase <ConnectionDelegate>

@property (nonatomic, strong) Sample *sample;

@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSError *error;

@end

@implementation SampleTests

- (void)setUp
{
  [super setUp];
  self.sample = [Sample sharedInstance];
  self.sample.connector.delegate = self;
}

- (void)tearDown
{
  [super tearDown];
  [Sample stop];
  [Sample setSharedInstance:nil];
}

- (void)testInit
{
  XCTAssertTrue([self.sample.endpoint isEqual:@"http://events.neurometry.com/sample/v01/event"]);
  XCTAssertTrue([self.sample.connector.endpoint isEqual:@"http://events.neurometry.com/sample/v01/event"]);
  XCTAssertTrue([self.sample.platform isEqualToString:@"ios"]);
  XCTAssertTrue([self.sample.sdk isEqualToString:@"sample-ios"]);
  XCTAssertTrue([self.sample.sdkVersion isEqualToString:@"0.0.1"]);
  XCTAssertTrue(self.sample.connector.isRunning);
  XCTAssertNotNil(self.sample.connector.sendNextEventTimer);
}

- (void)testEndpointShouldNotBeNil
{
  self.sample.endpoint = nil;
  XCTAssertNotNil(self.sample.endpoint, @"Endpoint should not be nil");
}

- (void)testStopAndResumeTracking
{
  [Sample stop];
  XCTAssertFalse(self.sample.connector.isRunning);
  [Sample resume];
  XCTAssertTrue(self.sample.connector.isRunning);
}

- (void)testSessionStart
{
  [Sample stop];
  
  [Sample sessionStart:@"testtoken" userId:@"my_user_id" userParams:@{@"ad_referer": @"my_referer",
                                                                      @"ad_campaign": @"my_campaign",
                                                                      @"ad_placement": @"my_placement"}];
  NSDictionary *event = [self.sample.connector.eventQueue firstObject];
  XCTAssertNotNil(event);
  XCTAssertTrue([event[@"event_name"] isEqualToString:@"session_start"]);
  XCTAssertTrue([event[@"event_category"] isEqualToString:@"session"]);
  XCTAssertTrue([event[@"user_id"] isEqualToString:@"my_user_id"]);
  XCTAssertTrue([event[@"ad_referer"] isEqualToString:@"my_referer"]);
  XCTAssertTrue([event[@"ad_campaign"] isEqualToString:@"my_campaign"]);
  XCTAssertTrue([event[@"ad_placement"] isEqualToString:@"my_placement"]);
}

- (void)testSessionUpdate
{
  [Sample stop];
  
  [Sample sessionUpdate:@{@"ad_referer": @"my_referer",
                          @"ad_campaign": @"my_campaign",
                          @"ad_placement": @"my_placement"}];
  NSDictionary *event = [self.sample.connector.eventQueue firstObject];
  XCTAssertNotNil(event);
  XCTAssertTrue([event[@"event_name"] isEqualToString:@"session_update"]);
  XCTAssertTrue([event[@"event_category"] isEqualToString:@"session"]);
  XCTAssertTrue([event[@"ad_referer"] isEqualToString:@"my_referer"]);
  XCTAssertTrue([event[@"ad_campaign"] isEqualToString:@"my_campaign"]);
  XCTAssertTrue([event[@"ad_placement"] isEqualToString:@"my_placement"]);
}

- (void)testSessionResume
{
  [Sample stop];
  
  [Sample sessionResume];
  NSDictionary *event = [self.sample.connector.eventQueue firstObject];
  XCTAssertNotNil(event);
  XCTAssertTrue([event[@"event_name"] isEqualToString:@"session_resume"]);
  XCTAssertTrue([event[@"event_category"] isEqualToString:@"session"]);
}

- (void)testPing
{
  [Sample stop];
  
  [Sample ping];
  NSDictionary *event = [self.sample.connector.eventQueue firstObject];
  XCTAssertNotNil(event);
  XCTAssertTrue([event[@"event_name"] isEqualToString:@"ping"]);
  XCTAssertTrue([event[@"event_category"] isEqualToString:@"session"]);
}

- (void)testAutoPing
{
  [Sample stop];
  
  [Sample autoPing:60];
  XCTAssertNotNil(self.sample.autoPingTimer);
}

- (void)testAutoPingStopPing
{
  [Sample stop];
  
  [Sample autoPing:60];
  XCTAssertNotNil(self.sample.autoPingTimer);
  [Sample autoPing:0];
  XCTAssertNil(self.sample.autoPingTimer, @"auto ping should stop when the interval is 0");
}

- (void)testDefaultAutoPing
{
  [Sample stop];
  
  [Sample autoPing:0];
  XCTAssertNil(self.sample.autoPingTimer, @"auto ping should stop when the interval is 0");
  [Sample autoPing];
  XCTAssertNotNil(self.sample.autoPingTimer);
}

- (void)testSingleContentUsage
{
  [Sample stop];
  
  [Sample contentUsage:@(99) contentType:nil];
  NSDictionary *event = [self.sample.connector.eventQueue firstObject];
  XCTAssertNotNil(event);
  XCTAssertTrue([event[@"event_name"] isEqualToString:@"usage"]);
  XCTAssertTrue([event[@"event_category"] isEqualToString:@"content"]);
  XCTAssertTrue([event[@"content_type"] isEqualToString:@"content"]);
  XCTAssertTrue([event[@"content_id"] integerValue] == 99);
}

- (void)testSingleContentUsageCorrectContentType
{
  [Sample stop];
  
  [Sample contentUsage:@(88) contentType:@"page"];
  NSDictionary *event = [self.sample.connector.eventQueue firstObject];
  XCTAssertNotNil(event);
  XCTAssertTrue([event[@"event_name"] isEqualToString:@"usage"]);
  XCTAssertTrue([event[@"event_category"] isEqualToString:@"content"]);
  XCTAssertTrue([event[@"content_type"] isEqualToString:@"page"]);
  XCTAssertTrue([event[@"content_id"] integerValue] == 88);
}

- (void)testMultipleContentUsage
{
  [Sample stop];
  
  [Sample contentUsage:@[@(88), @(99)] contentType:@"page"];
  NSDictionary *event = [self.sample.connector.eventQueue firstObject];
  XCTAssertNotNil(event);
  XCTAssertTrue([event[@"event_name"] isEqualToString:@"usage"]);
  XCTAssertTrue([event[@"event_category"] isEqualToString:@"content"]);
  XCTAssertTrue([event[@"content_type"] isEqualToString:@"page"]);
  
  NSArray *array = event[@"content_ids"];
  XCTAssertTrue([array count] == 2);
  XCTAssertTrue([array[0] integerValue] == 88);
  XCTAssertTrue([array[1] integerValue] == 99);
}

- (void)testPurchase
{
  [Sample stop];
  
  [Sample purchase:@(99) params:@{@"provider": @"provider", @"gross": @(1), @"currency": @"usd", @"country": @"ger", @"earnings": @(2), @"product_category": @"category"}];
  NSDictionary *event = [self.sample.connector.eventQueue firstObject];
  XCTAssertNotNil(event);
  XCTAssertTrue([event[@"provider"] isEqualToString:@"provider"]);
  XCTAssertTrue([event[@"gross"] integerValue] == 1);
  XCTAssertTrue([event[@"currency"] isEqualToString:@"usd"]);
  XCTAssertTrue([event[@"country"] isEqualToString:@"ger"]);
  XCTAssertTrue([event[@"earnings"] integerValue] == 2);
  XCTAssertTrue([event[@"product_category"] isEqualToString:@"category"]);
}

- (void)testChargeback
{
  [Sample stop];
  
  [Sample chargeback:@(99) params:@{@"provider": @"provider", @"gross": @(1), @"currency": @"usd", @"country": @"ger", @"earnings": @(2), @"product_category": @"category"}];
  NSDictionary *event = [self.sample.connector.eventQueue firstObject];
  XCTAssertNotNil(event);
  XCTAssertTrue([event[@"provider"] isEqualToString:@"provider"]);
  XCTAssertTrue([event[@"gross"] integerValue] == 1);
  XCTAssertTrue([event[@"currency"] isEqualToString:@"usd"]);
  XCTAssertTrue([event[@"country"] isEqualToString:@"ger"]);
  XCTAssertTrue([event[@"earnings"] integerValue] == 2);
  XCTAssertTrue([event[@"product_category"] isEqualToString:@"category"]);
}

- (void)testSetEndpoint
{
  [Sample setEndpoint:@"myendpoint"];
  XCTAssertTrue([self.sample.endpoint isEqualToString:@"myendpoint"]);
}

- (void)testSetAppToken
{
  [Sample setAppToken:@"token"];
  XCTAssertTrue([self.sample.appToken isEqualToString:@"token"]);
}

- (void)testSetModule
{
  [Sample setModule:@"module"];
  XCTAssertTrue([self.sample.module isEqualToString:@"module"]);
}

- (void)testSetEmail
{
  [Sample setEmail:@"email"];
  XCTAssertTrue([self.sample.email isEqualToString:@"email"]);
}

- (void)testSetDebug
{
  [Sample setDebug:YES];
  XCTAssertTrue(self.sample.debug);
  [Sample setDebug:NO];
  XCTAssertFalse(self.sample.debug);
}

- (void)testTrackSuccess
{
  self.sample.appToken = @"test app";
  [Sample track:@"ping" category:@"session" userParams:nil];
  
  [self waitForTimeout:5];
  
  XCTAssertEqual([self.response statusCode], 201);
}

- (void)testTrackFail
{
  [Sample track:@"ping" category:@"session" userParams:nil];
  
  [self waitForTimeout:5];
  
  XCTAssertEqual([self.response statusCode], 400,  @"Test should fail without app Token");
}

- (void)testTokenAvailability
{
  XCTAssertNotNil(self.sample.installToken, @"Installtoken should be set");
  XCTAssertNotNil(self.sample.sessionToken, @"SessionToken should be set");
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  XCTAssertNotNil([defaults objectForKey:kInstallToken], @"Installtoken should be set in the userdefaults");
}

- (void)testMergeParams
{
  NSString *client = @"testId";
  NSNumber *clientVersion = @6;
  NSNumber *contentId = @99;
  NSString *contentType = @"session";
  NSString *module = @"testModule";
  NSString *parameter1 = @"parameter1";
  NSString *parameter2 = @"parameter2";
  NSString *parameter3 = @"parameter3";
  NSString *parameter4 = @"parameter4";
  NSString *parameter5 = @"parameter5";
  NSString *parameter6 = @"parameter6";
  NSString *email = @"email";
  NSString *locale = @"de";
  NSString *adReferer = @"test_referer";
  NSString *adCampaign = @"test_referer";
  NSString *adPlacement = @"test_add";
  NSNumber *longitude = @100;
  NSNumber *latitude = @100;
  
  
  NSDictionary *params = @{@"client": client, @"client_version": clientVersion,
                           @"content_id": contentId, @"content_type": contentType, @"module": module,
                           @"parameter1": parameter1, @"parameter2": parameter2, @"parameter3": parameter3,
                           @"parameter4": parameter4,  @"parameter5": parameter5, @"parameter6": parameter6,
                           @"email": email, @"locale": locale, @"ad_referer": adReferer,
                           @"ad_placement": adPlacement, @"ad_campaign": adCampaign, @"longitude": longitude, @"latitude": latitude};
  
  NSDictionary *userParams = [self.sample mergeParams:params eventName:@"ping" eventCategory:@"session"];
  
  XCTAssertTrue([userParams[@"client"] isEqualToString:client],
                @"Strings are not equal but should be %@ %@", client, userParams[@"client"]);
  XCTAssertTrue([userParams[@"client_version"] isEqualToNumber:clientVersion],
                @"Numbers are not equal but should be %@ %@", clientVersion, userParams[@"client_version"]);
  XCTAssertTrue([userParams[@"platform"] isEqualToString:@"ios"],
                @"Strings are not equal but should be %@ %@", @"ios", userParams[@"platform"]);
  XCTAssertTrue([userParams[@"content_id"] isEqualToNumber:contentId],
                @"Numbers are not equal but should be %@ %@", contentId, userParams[@"content_id"]);
  XCTAssertTrue([userParams[@"module"] isEqualToString:module],
                @"Strings are not equal but should be %@ %@", module, userParams[@"module"]);
  XCTAssertTrue([userParams[@"parameter1"] isEqualToString:parameter1],
                @"Strings are not equal but should be %@ %@", parameter1, userParams[@"parameter1"]);
  XCTAssertTrue([userParams[@"parameter2"] isEqualToString:parameter2],
                @"Strings are not equal but should be %@ %@", parameter2, userParams[@"parameter2"]);
  XCTAssertTrue([userParams[@"parameter3"] isEqualToString:parameter3],
                @"Strings are not equal but should be %@ %@", parameter3, userParams[@"parameter3"]);
  XCTAssertTrue([userParams[@"parameter4"] isEqualToString:parameter4],
                @"Strings are not equal but should be %@ %@", parameter4, userParams[@"parameter4"]);
  XCTAssertTrue([userParams[@"parameter5"] isEqualToString:parameter5],
                @"Strings are not equal but should be %@ %@", parameter5, userParams[@"parameter5"]);
  XCTAssertTrue([userParams[@"parameter6"] isEqualToString:parameter6],
                @"Strings are not equal but should be %@ %@", parameter6, userParams[@"parameter6"]);
  XCTAssertNil(userParams[@"email"], @"email should not be set");
  XCTAssertNil(userParams[@"locale"], @"locale should not be set");
  XCTAssertNil(userParams[@"ad_referer"], @"ad_referer should not be set");
  XCTAssertNil(userParams[@"ad_campaign"], @"ad_campaign should not be set");
  XCTAssertNil(userParams[@"ad_placement"], @"ad_placement should not be set");
  XCTAssertNil(userParams[@"latitude"], @"latitude should not be set");
  XCTAssertNil(userParams[@"longitude"], @"longitude should not be set");
  
  
  userParams = [self.sample mergeParams:params eventName:@"session_start" eventCategory:@"session"];
  
  XCTAssertTrue([userParams[@"email"] isEqualToString:email],
                @"Strings are not equal but should be %@ %@", email, userParams[@"email"]);
  XCTAssertTrue([userParams[@"locale"] isEqualToString:locale],
                @"Strings are not equal but should be %@ %@", locale, userParams[@"locale"]);
  XCTAssertTrue([userParams[@"ad_referer"] isEqualToString:adReferer],
                @"Strings are not equal but should be %@ %@", adReferer, userParams[@"ad_referer"]);
  XCTAssertTrue([userParams[@"ad_placement"] isEqualToString:adPlacement],
                @"Strings are not equal but should be %@ %@", adPlacement, userParams[@"ad_placement"]);
  XCTAssertTrue([userParams[@"ad_campaign"] isEqualToString:adCampaign],
                @"Strings are not equal but should be %@ %@", adCampaign, userParams[@"ad_campaign"]);
  XCTAssertTrue([userParams[@"latitude"] isEqualToNumber:latitude],
                @"Strings are not equal but should be %@ %@", latitude, userParams[@"latitude"]);
  XCTAssertTrue([userParams[@"longitude"] isEqualToNumber:longitude],
                @"Strings are not equal but should be %@ %@", longitude, userParams[@"longitude"]);
}

- (void)testMergeParamsDontMergeNilValues
{
  NSDictionary *userParams = [self.sample mergeParams:nil eventName:nil eventCategory:nil];
  XCTAssertNil(userParams[@"event_name"]);
  XCTAssertNil(userParams[@"client"]);
  XCTAssertNil(userParams[@"content_id"]);
  XCTAssertNil(userParams[@"module"]);
  XCTAssertNil(userParams[@"parameter1"]);
  XCTAssertNil(userParams[@"parameter2"]);
  XCTAssertNil(userParams[@"parameter3"]);
  XCTAssertNil(userParams[@"parameter4"]);
  XCTAssertNil(userParams[@"parameter5"]);
  XCTAssertNil(userParams[@"parameter6"]);
  XCTAssertNil(userParams[@"email"]);
  XCTAssertNil(userParams[@"locale"]);
  XCTAssertNil(userParams[@"add_referer"]);
  XCTAssertNil(userParams[@"add_placement"]);
  XCTAssertNil(userParams[@"latitude"]);
  XCTAssertNil(userParams[@"longitude"]);
  XCTAssertNil(userParams[@"add_referer"]);
  XCTAssertNil(userParams[@"add_campaign"]);
  XCTAssertNil(userParams[@"add_placement"]);
  
  XCTAssertNotNil(userParams[@"sdk"]);
  XCTAssertNotNil(userParams[@"sdk_event"]);
  XCTAssertNotNil(userParams[@"install_token"]);
  XCTAssertNotNil(userParams[@"session_token"]);
  XCTAssertNotNil(userParams[@"debug"]);
  XCTAssertTrue([userParams[@"event_category"] isEqualToString:@"custom"]);
}

- (void)testAddKeyValueTo
{
  NSMutableDictionary *keyValue = [NSMutableDictionary new];
  [self.sample addKey:nil value:nil to:keyValue];
  XCTAssertEqual([keyValue count], 0, @"Dict should be empty");
  
  keyValue = [NSMutableDictionary new];
  [self.sample addKey:@"testkey" value:nil to:keyValue];
  XCTAssertEqual([keyValue count], 0, @"Dict should be empty");
  
  keyValue = [NSMutableDictionary new];
  [self.sample addKey:nil value:@"testValue" to:keyValue];
  XCTAssertEqual([keyValue count], 0, @"Dict should be empty");
  
  keyValue = [NSMutableDictionary new];
  [self.sample addKey:@"testkey" value:@"testValue" to:keyValue];
  XCTAssertTrue([keyValue[@"testkey"] isEqualToString:@"testValue"],
                @"Key %@ does not return value %@", @"testKey", @"testValue");
}

- (void)testRandomToken
{
  XCTAssertEqual([[self.sample randomToken:4] length], 4, @"Token should have a length of 4");
  XCTAssertEqual([[self.sample randomToken:5] length], 6, @"Token should have a length of 6");
  XCTAssertEqual([[self.sample randomToken:6] length], 7, @"Token should have a length of 7");
  XCTAssertEqual([[self.sample randomToken:7] length], 8, @"Token should have a length of 8");
  XCTAssertEqual([[self.sample randomToken:8] length], 9, @"Token should have a length of 9");
  XCTAssertEqual([[self.sample randomToken:9] length], 11, @"Token should have a length of 11");
  
  XCTAssertEqual([[self.sample randomToken:12] characterAtIndex:4], '-', @"The fourth character should be a -");
}

// Delegation methods to get the POST response - no tests!
- (void)trackingDidFailWithError:(NSError *)error
{
  self.error = error;
}

- (void)trackingDidSucceedWithData:(NSData *)data response:(NSURLResponse *)response
{
  self.data = data;
  self.response = (NSHTTPURLResponse *)response;
}

@end
