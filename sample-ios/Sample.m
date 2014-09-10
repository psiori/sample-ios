//
//  Tracker.m
//  analytics+ios
//
//  Created by Daniel Band on 01/09/14.
//  Copyright (c) 2014 5dlab GmbH. All rights reserved.
//

#import "Sample.h"
#import "SampleExtension.h"
#import "Connector.h"

#define ARC4RANDOM_MAX      0x100000000

NSString * const kInstallToken = @"InstallToken";


@implementation Sample

static Sample *_sharedinstance = nil;
static dispatch_once_t onceToken;

+ (Sample *)sharedInstance
{
  dispatch_once(&onceToken, ^{
    if (!_sharedinstance)
    {
      _sharedinstance = [[Sample alloc] initWithConnector:[Connector new]];
    }
  });
  return _sharedinstance;
}

+ (void)setSharedInstance:(Sample *)instance
{
  _sharedinstance = instance;
  onceToken = 0;
}

- (instancetype)initWithConnector:(Connector *)connector
{
  self = [super init];
  if (self)
  {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (!(_installToken = [defaults objectForKey:kInstallToken]))
    {
      _installToken = [self randomToken:24];
      [defaults setObject:_installToken forKey:kInstallToken];
      [defaults synchronize];
    }
    
    _sessionToken = [self randomToken:32];
    
    _endpoint = @"http://events.neurometry.com/sample/v01/event";
    _platform = @"ios";
    _sdk = @"sample-ios";
    _sdkVersion = @"0.0.1";
    
    connector.endpoint = _endpoint;
    _connector = connector;
    
    [_connector start];
  }
  
  return self;
}

#pragma mark - Tracking

+ (void)resumeTracking
{
  [[Sample sharedInstance] resume];
}

+ (void)stopTracking
{
  [[Sample sharedInstance] stop];
}

+ (void)track:(NSString *)event category:(NSString *)category userParams:(NSDictionary *)userParams
{
  [[Sample sharedInstance] track:event category:category userParams:userParams];
}

+ (void)track:(NSString *)event category:(NSString *)category
{
  [[Sample sharedInstance] track:event category:category];
}

#pragma mark - Grouping

+ (void)startGroup
{
  [[Sample sharedInstance].connector startGroup];
}

+ (void)endGroup
{
  [[Sample sharedInstance].connector endGroup];
}

#pragma mark - Session events

+ (void)sessionStart:(NSString *)appToken
{
  [Sample sharedInstance].appToken = appToken;
  [[Sample sharedInstance] track:@"session_start" category:@"session"];
}

+ (void)sessionUpdate
{
  [[Sample sharedInstance] track:@"session_update" category:@"session"];
}

+ (void)sessionPause
{
  [[Sample sharedInstance] track:@"session_pause" category:@"session"];
}

+ (void)ping
{
  [[Sample sharedInstance] track:@"ping" category:@"session"];
}

+ (void)autoPing:(double)seconds
{
  Sample *sample = [Sample sharedInstance];
  [sample.autoPingTimer invalidate];
  sample.autoPingTimer = nil;
  
  if (seconds > 0)
  {
    sample.autoPingTimer = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(ping) userInfo:nil repeats:YES];
  }
}

+ (void)autoPing
{
  [Sample autoPing:60];
}


#pragma mark - Account Events

+ (void)registration:(NSString *)userId params:(NSDictionary *)params
{
  [Sample sharedInstance].userId = userId;
  [[Sample sharedInstance] track:@"registration" category:@"account" userParams:params];
}

+ (void)signIn:(NSString *)userId params:(NSDictionary *)params
{
  [Sample sharedInstance].userId = userId;
  [[Sample sharedInstance] track:@"sign_in" category:@"account" userParams:params];
}


#pragma mark - Content Events

+ (void)singleContentUsage:(id)contentId contentType:(NSString *)contentType
{
  if (!contentId)
  {
    return;
  }
  
  contentType = contentType ?: @"content";
  NSDictionary *params = @{@"content_type": contentType, @"content_id": contentId};
  
  [[Sample sharedInstance] track:@"usage" category:@"content" userParams:params];
}

+ (void)multipleContentUsage:(NSArray *)contentIds contentType:(NSString *)contentType
{
  if (!contentIds)
  {
    return;
  }
  
  contentType = contentType ?: @"content";
  NSDictionary *params = @{@"content_type": contentType,  @"content_ids": contentIds};
  
  [[Sample sharedInstance] track:@"usage" category:@"content" userParams:params];
}

#pragma mark - Purchase events

+ (void)purchase:(id)productId params:(NSDictionary *)params
{
  if (!productId)
  {
    return;
  }
  
  NSMutableDictionary *mutableParams = [params mutableCopy];
  [mutableParams addEntriesFromDictionary:@{@"product_sku": productId}];
  [[Sample sharedInstance] track:@"purchase" category:@"revenue" userParams:mutableParams];
}

+ (void)chargeback:(id)productId params:(NSDictionary *)params
{
  if (!productId)
  {
    return;
  }
  
  NSMutableDictionary *mutableParams = [params mutableCopy];
  [mutableParams addEntriesFromDictionary:@{@"product_sku": productId}];
  [[Sample sharedInstance] track:@"chargeback" category:@"revenue" userParams:mutableParams];
}

#pragma mark - 

+ (void)setEndpoint:(NSString *)endpoint
{
  [Sample sharedInstance].endpoint = endpoint;
}

+ (void)setEmail:(NSString *)email
{
  [Sample sharedInstance].email = email;
}

+ (void)setFacebookId:(id)facebookId
{
  [Sample sharedInstance].facebookId = facebookId;
}

+ (void)setLatitude:(double)latitude longitude:(double)longitude
{
  [[Sample sharedInstance] setLatitude:latitude longitude:longitude];
}

+ (void)setLocale:(NSString *)locale
{
  [Sample sharedInstance].locale = locale;
}

+ (void)setModule:(id)module
{
  [Sample sharedInstance].module = module;
}

+ (void)setReferer:(NSString *)referer campaign:(NSString *)campaign placement:(NSString *)placement
{
  [[Sample sharedInstance] setReferer:referer campaign:campaign placement:placement];
}

+ (void)setClient:(id)client version:(NSString *)version
{
  [[Sample sharedInstance] setClient:client version:version];
}

+ (void)setUserId:(id)userId
{
  [Sample sharedInstance].userId = userId;
}

+ (void)setAppToken:(NSString *)appToken
{
  [Sample sharedInstance].appToken = appToken;
}

+ (void)setDebug:(BOOL)debug
{
  [Sample sharedInstance].debug = debug;
}

# pragma mark - SampleExtension

- (void)setLatitude:(double)latitude longitude:(double)longitude
{
  _latitude = latitude;
  _longitude = longitude;
}

- (void)setReferer:(NSString *)referer campaign:(NSString *)campaign placement:(NSString *)placement
{
  _referer = referer;
  _campaign = campaign;
  _placement = placement;
}

- (void)setSDK:(NSString *)sdk version:(NSString *)version
{
  _sdk = sdk;
  _sdkVersion = version;
}

- (void)setClient:(id)client version:(NSString *)version
{
  _client = client;
  _clientVersion = version;
}

- (void)setEndpoint:(NSString *)endpoint
{
  if (endpoint)
  {
    _connector.endpoint = endpoint;
    _endpoint = endpoint;
  }
}

- (void)stop
{
  [self.autoPingTimer invalidate];
  [self.connector stop];
}

- (void)resume
{
  [self.connector start];
}

- (void)track:(NSString *)event category:(NSString *)category
{
  [self track:event category:category userParams:nil];
}

- (void)track:(NSString *)event category:(NSString *)category userParams:(NSDictionary *)userParams
{
  NSDictionary *eventDict = [self mergeParams:userParams eventName:event eventCategory:category];
  [self.connector addEvent:eventDict];
}

- (NSDictionary *)mergeParams:(NSDictionary *)userParams eventName:(NSString *)eventName eventCategory:(NSString *)eventCategory
{
  NSMutableDictionary *keyValuePairs = [[NSMutableDictionary alloc] init];
  [self addKey:@"sdk" value:self.sdk to:keyValuePairs];
  [self addKey:@"sdk_event" value:self.sdkVersion to:keyValuePairs];
  [self addKey:@"event_name" value:eventName to:keyValuePairs];
  [self addKey:@"app_token" value:self.appToken to:keyValuePairs];
  [self addKey:@"install_token" value:self.installToken to:keyValuePairs];
  [self addKey:@"session_token" value:self.sessionToken to:keyValuePairs];
  [self addKey:@"debug" value:[NSNumber numberWithBool:self.debug] to:keyValuePairs];
  [self addKey:@"timestamp" value:[NSNumber numberWithDouble:round([[NSDate date] timeIntervalSince1970] / 1000)] to:keyValuePairs];
  [self addKey:@"user_id" value:self.userId to:keyValuePairs];
  [self addKey:@"event_category" value:(eventCategory ?: @"custom") to:keyValuePairs];
  
  [self addKey:@"client" value:(userParams[@"client"] ?: self.client) to:keyValuePairs];
  [self addKey:@"client_version" value:(userParams[@"client_version"] ?: self.clientVersion) to:keyValuePairs];
  [self addKey:@"platform" value:(userParams[@"platform"] ?: self.platform) to:keyValuePairs];
  [self addKey:@"module" value:(userParams[@"module"] ?: self.module) to:keyValuePairs];
  
  if ([eventName isEqualToString:@"session_start"] ||
      [eventName isEqualToString:@"session_update"] ||
      [eventCategory isEqualToString:@"account"])
  {
    [self addKey:@"email" value:(userParams[@"email"] ?: self.email) to:keyValuePairs];
    [self addKey:@"locale" value:(userParams[@"locale"] ?: self.locale) to:keyValuePairs];
    
    [self addKey:@"add_referer" value:(userParams[@"add_referer"] ?: self.referer) to:keyValuePairs];
    [self addKey:@"add_campaign" value:(userParams[@"add_campaign"] ?: self.campaign) to:keyValuePairs];
    [self addKey:@"add_placement" value:(userParams[@"add_placement"] ?: self.placement) to:keyValuePairs];
    
    [self addKey:@"longitude" value:(userParams[@"longitude"] ?: @(self.longitude)) to:keyValuePairs];
    [self addKey:@"latitude" value:(userParams[@"latitude"] ?: @(self.latitude)) to:keyValuePairs];
  }
  
  if (userParams)
  {
    [self addKey:@"content_id" value:userParams[@"content_id"] to:keyValuePairs];
    [self addKey:@"content_ids" value:userParams[@"content_ids"] to:keyValuePairs];
    [self addKey:@"content_type" value:userParams[@"content_type"] to:keyValuePairs];
    
    [self addKey:@"provider" value:userParams[@"provider"] to:keyValuePairs];
    [self addKey:@"gross" value:userParams[@"gross"] to:keyValuePairs];
    [self addKey:@"currency" value:userParams[@"currency"] to:keyValuePairs];
    [self addKey:@"country" value:userParams[@"country"] to:keyValuePairs];
    [self addKey:@"earnings" value:userParams[@"earnings"] to:keyValuePairs];
    [self addKey:@"product_sku" value:userParams[@"product_sku"] to:keyValuePairs];
    [self addKey:@"product_category" value:userParams[@"product_category"] to:keyValuePairs];
    [self addKey:@"receipt_identifier" value:userParams[@"receipt_identifier"] to:keyValuePairs];
    
    [self addKey:@"parameter1" value:userParams[@"parameter1"] to:keyValuePairs];
    [self addKey:@"parameter2" value:userParams[@"parameter2"] to:keyValuePairs];
    [self addKey:@"parameter3" value:userParams[@"parameter3"] to:keyValuePairs];
    [self addKey:@"parameter4" value:userParams[@"parameter4"] to:keyValuePairs];
    [self addKey:@"parameter5" value:userParams[@"parameter5"] to:keyValuePairs];
    [self addKey:@"parameter6" value:userParams[@"parameter6"] to:keyValuePairs];
  }
  
  return[[NSMutableDictionary alloc] initWithDictionary:keyValuePairs];
}

- (void)addKey:(NSString *)key value:(id)value to:(NSMutableDictionary *)dict
{
  if (key && value)
  {
    [dict addEntriesFromDictionary:@{key: value}];
  }
}


#pragma mark - Random Token

- (NSString *)randomToken:(int)length
{
  NSMutableString *str = [[NSMutableString alloc] initWithString:@""];
  
  for (int i = 0; i < length; i++)
  {
    if (i > 0 && i % 4 == 0)
    {
      [str appendString:@"-"];
    }
    
    int randomHex = floor(16*((double)arc4random() / ARC4RANDOM_MAX));
    
    NSString *subToken = [[NSString stringWithFormat:@"%x",randomHex] uppercaseString];
    [str appendString:subToken];
  }
  
  return str;
}

@end
