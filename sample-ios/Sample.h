//
//  Tracker.h
//  analytics-ios
//
//  Created by Daniel Band on 01/09/14.
//  Copyright (c) 2014 5dlab GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Single access point for all tracking calls
 */
@interface Sample : NSObject


#pragma mark - Tracking

/**
 Resumes the tracking to an endPoint
 @param endPoint the adress where the events will be send to
 */
+ (void)resumeTracking;

/**
 Stops the tracking
 */
+ (void)stopTracking;

/**
 generic tracking event that could be used to send pre-defined tracking
 events as well as user-defined, custom events. Just pass the eventName,
 the eventCategory (used for grouping in reports of the backend) and
 an optional hash of parameters.
 
 Please note that only known parameters will be passed to the server.
 If you want to come up with your own parameters in you custom events,
 use the six pre-defined fields "parameter1" to "parameter6" for this
 purpose.
 
 Examples:
 Sample.track('session_start', 'session'); // send the session start event
 Sample.track('found_item', 'custom', {    // send custom item event
 parameter1: 'Black Stab',                 // custom item name
 parameter2: '21',                         // level of item
 });
 */
+ (void)track:(NSString *)event category:(NSString *)category userParams:(NSDictionary *)userParams;

+ (void)track:(NSString *)event category:(NSString *)category;

/**
 If a tracking group is started, all events in the group will be sent i a single HTTP event after endGroup is called.
 */
#pragma mark - Grouping

/**
 Start a tracking group.
 */
+ (void)startGroup;

/**
 Ends a tracking group.
 */
+ (void)endGroup;


/**
 Pre-defined tracking events. Some events take an optional user parameters.
 You can add six custom key/value pairs as parameters. The keys for these pairs are declared as constants on top of this file.
 parameter1 to parameter6
 */
#pragma mark - Pre-defined Events

/**
 Adds a session start event and changes the appToken if the appToken is not nil.
 @param appToken a new appToken
 */
+ (void)sessionStart:(NSString *)appToken;

/**
 Adds a session update event
 */
+ (void)sessionUpdate;

/**
 Adds a session pause event
 */
+ (void)sessionPause;

/**
 Adds a ping event
 */
+ (void)ping;

/**
 Adds a ping event every x seconds.
 @param seconds the time in seconds between the ping events
 */
+ (void)autoPing:(double)seconds;

/**
 Send ping events every 60 seconds
 */
+ (void)autoPing;

/**
 Adds a registration event.
 @param userId the user who did register
 @param params additional paramater
 */
+ (void)registration:(NSString *)userId params:(NSDictionary *)params;

/**
 Adds a sign in event
 @param userId the user who did sign in
 @param params additional paramater
 */
+ (void)signIn:(NSString *)userId params:(NSDictionary *)params;

/**
 Adds a content event.If the content type is nil, "event" will be set as content type
 @param contentId the id of the content that was used
 @param contentType the type of the content that was used
 */
+ (void)singleContentUsage:(id)contentId contentType:(NSString *)contentType;

/**
 Adds a content event with multiple contentIds of the same content type
 @param contentIds an array of content ids
 @param contentType the content type of all ids in the array
 */
+ (void)multipleContentUsage:(NSArray *)contentIds contentType:(NSString *)contentType;


#pragma mark -

+ (void)setEndpoint:(NSString *)endpoint;

+ (void)setAppToken:(NSString *)appToken;

+ (void)setClient:(id)client version:(NSString *)version;

+ (void)setModule:(id)module;

+ (void)setUserId:(id)userId;

+ (void)setFacebookId:(id)facebookId;

+ (void)setEmail:(NSString *)email;

+ (void)setLocale:(NSString *)locale;

+ (void)setLatitude:(double)latitude longitude:(double)longitude;

+ (void)setReferer:(NSString *)referer campaign:(NSString *)campaign placement:(NSString *)placement;

+ (void)setDebug:(BOOL)debug;

@end
