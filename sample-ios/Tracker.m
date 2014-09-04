//
//  Tracker.m
//  analytics+ios
//
//  Created by Daniel Band on 01/09/14.
//  Copyright (c) 2014 5dlab GmbH. All rights reserved.
//

#import "Tracker.h"
#import "TrackingInstance.h"

@implementation Tracker

+ (TrackingInstance *)sharedInstance
{
  static TrackingInstance *sharedinstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedinstance = [[TrackingInstance alloc] init];
  });
  return sharedinstance;
}


#pragma mark - Tracking

+ (void)startTracking:(NSString *)endPoint
{
  [Tracker sharedInstance].url = endPoint;
  [[Tracker sharedInstance] resume];
}

+ (void)stopTracking
{
  [[Tracker sharedInstance] stop];
}

+ (void)track:(NSString *)event category:(NSString *)category userParams:(NSDictionary *)userParams
{
  [[Tracker sharedInstance] track:event category:category userParams:userParams];
}

+ (void)startGroup
{
  [[Tracker sharedInstance] startGroup];
}

+ (void)endGroup
{
  [[Tracker sharedInstance] endGroup];
}

#pragma mark - Session events

+ (void)sessionStart
{
  [[Tracker sharedInstance] track:@"session_start" category:@"session"];
}

+ (void)sessionStart:(NSString *)appToken
{
  [Tracker sharedInstance].appToken = appToken;
  [[Tracker sharedInstance] track:@"session_start" category:@"session"];
}

+ (void)sessionUpdate
{
  [[Tracker sharedInstance] track:@"session_update" category:@"session"];
}

+ (void)sessionPause
{
  [[Tracker sharedInstance] track:@"session_pause" category:@"session"];
}

+ (void)ping
{
  [[Tracker sharedInstance] track:@"ping" category:@"session"];
}

+ (void)autoPing:(double)seconds
{
  [[Tracker sharedInstance].autoPingTimer invalidate];
  if (seconds > 0)
  {
    [Tracker sharedInstance].autoPingTimer = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(ping) userInfo:nil repeats:YES];
  }
}


#pragma mark - Account Events

+ (void)registration:(NSString *)userId params:(NSDictionary *)params
{
  [Tracker sharedInstance].userId = userId;
  [[Tracker sharedInstance] track:@"registration" category:@"account" userParams:params];
}

+ (void)signIn:(NSString *)userId params:(NSDictionary *)params
{
  [Tracker sharedInstance].userId = userId;
  [[Tracker sharedInstance] track:@"sign_in" category:@"account" userParams:params];
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
  
  [[Tracker sharedInstance] track:@"usage" category:@"content" userParams:params];
}

+ (void)multipleContentUsage:(NSArray *)contentIds contentType:(NSString *)contentType
{
  if (!contentIds)
  {
    return;
  }
  
  contentType = contentType ?: @"content";
  NSDictionary *params = @{@"content_type": contentType,  @"content_ids": contentIds};
  
  [[Tracker sharedInstance] track:@"usage" category:@"content" userParams:params];
}

#pragma mark - 

+ (void)setEmail:(NSString *)email
{
  [Tracker sharedInstance].email = email;
}

+ (void)setFacebookId:(id)facebookId
{
  [Tracker sharedInstance].facebookId = facebookId;
}

+ (void)setLatitude:(double)latitude longitude:(double)longitude
{
  [[Tracker sharedInstance] setLatitude:latitude longitude:longitude];
}

+ (void)setLocal:(NSString *)local
{
  [Tracker sharedInstance].local = local;
}

+ (void)setModule:(NSString *)module
{
  [Tracker sharedInstance].module = module;
}

+ (void)setPlattform:(NSString *)platform
{
  [Tracker sharedInstance].platform = platform;
}

+ (void)setReferer:(NSString *)referer campaign:(NSString *)campaign placement:(NSString *)placement
{
  [[Tracker sharedInstance] setReferer:referer campaign:campaign placement:placement];
}

+ (void)setSDK:(NSString *)sdk version:(NSString *)version
{
  [[Tracker sharedInstance] setSDK:sdk version:version];
}

+ (void)setClientId:(id)clientId version:(NSString *)version
{
  [[Tracker sharedInstance] setClientId:clientId version:version];
}

+ (void)setUserId:(id)userId
{
  [Tracker sharedInstance].userId = userId;
}

+ (void)setAppToken:(NSString *)appToken
{
  [Tracker sharedInstance].appToken = appToken;
}

+ (void)setDebug:(BOOL)debug
{
  [Tracker sharedInstance].debug = debug;
}

@end
