//
//  Sample.m
//  analytics-sample-ios
//
//  Created by Daniel Band on 25/08/14.
//  Copyright (c) 2014 5dlab GmbH. All rights reserved.
//

#import "TrackingInstance.h"

#define ARC4RANDOM_MAX      0x100000000

NSString * const kInstallToken = @"InstallToken";

NSString * const parameter1 = @"parameter1";
NSString * const parameter2 = @"parameter2";
NSString * const parameter3 = @"parameter3";
NSString * const parameter4 = @"parameter4";
NSString * const parameter5 = @"parameter5";
NSString * const parameter6 = @"parameter6";

static const int predifiendMaxEvents = 100;

@interface TrackingInstance ()

@property (nonatomic, copy, readwrite) NSString *installToken;
@property (nonatomic, copy, readwrite) NSString *sessionToken;

@property (nonatomic, strong) NSTimer *sendNextEventTimer;

@end

@implementation TrackingInstance

- (instancetype)init
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
    
     _eventQueue = [[NSMutableArray alloc] initWithCapacity:predifiendMaxEvents];
  }
  
  return self;
}

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

- (void)setClientId:(id)clientId version:(NSString *)version
{
  _clientId = clientId;
  _clientVersion = version;
}

#pragma mark - Resuming/Stoping the connector

- (void)resume
{
  if (self.isRunning)
  {
    return;
  }
  
  
  [self setRunning:YES];
  self.sendNextEventTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sendNext) userInfo:nil repeats:YES];
}

- (void)stop
{
  if (!self.isRunning)
  {
    return;
  }
  
  [self setRunning:NO];
  [self.sendNextEventTimer invalidate];
  [self.autoPingTimer invalidate];
}


#pragma mark - Grouping

- (void)startGroup
{
  [self setGrouping:YES];
  self.eventGroup = [[NSMutableArray alloc] init];
}

- (void)endGroup
{
  [self setGrouping:NO];
  
  if (![self.eventGroup count])
  {
    return;
  }
  
  
  [self.eventQueue addObject:self.eventGroup];
  self.eventGroup = nil;
}


#pragma mark - Generic Tracking Event

- (void)track:(NSString *)event category:(NSString *)category
{
  [self track:event category:category userParams:nil];
}

- (void)track:(NSString *)event category:(NSString *)category userParams:(NSDictionary *)userParams
{
  if (event)
  {
    NSDictionary *eventDict = @{@"p":[self mergeParams:userParams eventName:event eventCategory:category]};
    if (self.isGrouping)
    {
      [self.eventGroup addObject:eventDict];
    }
    else
    {
      [self.eventQueue addObject:eventDict];
    }
  }
}

- (void)sendNext
{
  if (!self.running || !self.url || self.sending || ![self.eventQueue count])
  {
    return;
  }
  
  
  self.sending = YES;
  
  NSDictionary *params = [self.eventQueue firstObject];
  
  NSError *error;
  NSData *jsonData = [NSJSONSerialization  dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
  
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]
                                                         cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
  
  [request setHTTPMethod:@"POST"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
  [request setHTTPBody: jsonData];
  
  [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
   {
     if (error)
     {
       if ([self.delegate respondsToSelector:@selector(trackingDidFailWithError:)])
       {
         [self.delegate trackingDidFailWithError:error];
       }
       
       self.sending = NO;
     }
     else
     {
       if ([self.delegate respondsToSelector:@selector(trackingDidSucceedWithData: response:)])
       {
         [self.delegate trackingDidSucceedWithData:data response:response];
       }
       
       if ([self.eventQueue count])
       {
         [self.eventQueue removeObjectAtIndex:0];
         self.sending = NO;
         [self sendNext];
       }
       else
       {
         self.sending = NO;
       }
     }
   }];
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
 
  if (userParams)
  {
    [self addKey:@"client" value:(userParams[@"client"] ?: self.clientId) to:keyValuePairs];
    [self addKey:@"client_version" value:(userParams[@"client_version"] ?: self.clientVersion) to:keyValuePairs];
    [self addKey:@"platform" value:(userParams[@"platform"] ?: self.platform) to:keyValuePairs];
    
    [self addKey:@"content_id" value:userParams[@"content_id"] to:keyValuePairs];
    [self addKey:@"content_ids" value:userParams[@"content_ids"] to:keyValuePairs];
    [self addKey:@"content_type" value:userParams[@"content_type"] to:keyValuePairs];
    
    [self addKey:@"module" value:(userParams[@"module"] ?: self.module) to:keyValuePairs];
    
    [self addKey:parameter1 value:userParams[parameter1] to:keyValuePairs];
    [self addKey:parameter2 value:userParams[parameter2] to:keyValuePairs];
    [self addKey:parameter3 value:userParams[parameter3] to:keyValuePairs];
    [self addKey:parameter4 value:userParams[parameter4] to:keyValuePairs];
    [self addKey:parameter5 value:userParams[parameter5] to:keyValuePairs];
    [self addKey:parameter6 value:userParams[parameter6] to:keyValuePairs];
    
    if ([eventName isEqualToString:@"session_start"] ||
        [eventName isEqualToString:@"session_update"] ||
        [eventCategory isEqualToString:@"account"])
    {
      [self addKey:@"email" value:(userParams[@"email"] ?: self.email) to:keyValuePairs];
      [self addKey:@"locale" value:(userParams[@"locale"] ?: self.local) to:keyValuePairs];
      
      [self addKey:@"add_referer" value:(userParams[@"add_referer"] ?: self.referer) to:keyValuePairs];
      [self addKey:@"add_campaign" value:(userParams[@"add_campaign"] ?: self.campaign) to:keyValuePairs];
      [self addKey:@"add_placement" value:(userParams[@"add_placement"] ?: self.placement) to:keyValuePairs];
      
      [self addKey:@"longitude" value:(userParams[@"longitude"] ?: @(self.longitude)) to:keyValuePairs];
      [self addKey:@"latitude" value:(userParams[@"latitude"] ?: @(self.latitude)) to:keyValuePairs];
    }
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
