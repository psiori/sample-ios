//
//  Tracker.m
//  analytics+ios
//
//  Created by Daniel Band on 01/09/14.
//  Copyright (c) 2014 5dlab GmbH. All rights reserved.
//

#import "Sample.h"
#import "TrackingInstance.h"

@implementation Sample

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

+ (void)startTracking
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

+ (void)startGroup
{
  [[Sample sharedInstance] startGroup];
}

+ (void)endGroup
{
  [[Sample sharedInstance] endGroup];
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
  [[Sample sharedInstance].autoPingTimer invalidate];
  if (seconds > 0)
  {
    [Sample sharedInstance].autoPingTimer = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(ping) userInfo:nil repeats:YES];
  }
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

#pragma mark - 

+ (void)setEnpoint:(NSString *)endpoint
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

+ (void)setLocal:(NSString *)local
{
  [Sample sharedInstance].local = local;
}

+ (void)setModule:(id)module
{
  [Sample sharedInstance].module = module;
}

+ (void)setReferer:(NSString *)referer campaign:(NSString *)campaign placement:(NSString *)placement
{
  [[Sample sharedInstance] setReferer:referer campaign:campaign placement:placement];
}

+ (void)setClientId:(id)clientId version:(NSString *)version
{
  [[Sample sharedInstance] setClientId:clientId version:version];
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

@end
