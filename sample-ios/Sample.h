//
//  Sample.h
//  sample-ios
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
+ (void)resume;

/**
 Stops the tracking
 */
+ (void)stop;

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
 You can add six custom key/value pairs as parameters; parameter1 to parameter6
 */
#pragma mark - Pre-defined Events

/**
 Adds a session start event and changes the appToken if the appToken is not nil.
 @param appToken a new appToken
 */
+ (void)sessionStart:(NSString *)appToken userId:(NSString *)userId userParams:(NSDictionary *)params;

/**
 Adds a session update event
 */
+ (void)sessionUpdate:(NSDictionary *)params;

/**
 Adds a session pause event
 */
+ (void)sessionPause;

/**
 Adds a session resume event
 */
+ (void)sessionResume;

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
 Adds a profile update event
 Should be called when the users account receives an update
 @param additional paramater
 */
+ (void)profileUpdate:(NSDictionary *)params;

/**
 Adds a content event. If the content type is nil, "event" will be set as content type
 @param contentIds the id of the content that was used. can be a single NSNumber or an NSArray
 @param contentType the type of the content that was used
 */
+ (void)contentUsage:(id)contentIds contentType:(NSString *)contentType;

/**
 Adds a purchase action for a product id.
 Add the provider, gross, currency, country, earnings and the product_category as parameters.
 The receipt_identifier is optional.
 @param productId
 @param params
 */
+ (void)purchase:(id)productId params:(NSDictionary *)params;

/**
 Adds a chargeback action for a product id.
 Add the provider, gross, currency, country, earnings and the product_category as parameters.
 The receipt_identifier is optional.
 @param productId
 @param params
 */
+ (void)chargeback:(id)productId params:(NSDictionary *)params;

/**
 Creates and sets a new session token
 */
+ (void)renewSessionToken;

#pragma mark -

+ (void)setEndpoint:(NSString *)endpoint;

+ (void)setAppToken:(NSString *)appToken;

+ (void)setClient:(id)client version:(NSString *)version;

+ (void)setModule:(id)module;

+ (void)setUserId:(id)userId;

+ (void)setFacebookId:(id)facebookId;

+ (void)setEmail:(NSString *)email;

+ (void)setLocale:(NSString *)locale;

+ (void)setLatitude:(NSString *)latitude longitude:(NSString *)longitude;

+ (void)setReferer:(NSString *)referer campaign:(NSString *)campaign placement:(NSString *)placement;

+ (void)setDebug:(BOOL)debug;

@end
