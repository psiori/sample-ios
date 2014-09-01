//
//  Sample.h
//  analytics-sample-ios
//
//  Created by Daniel Band on 25/08/14.
//  Copyright (c) 2014 5dlab GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kInstallToken;

@class Connector;

@interface TrackingInstance : NSObject

@property (nonatomic, strong, readonly) Connector *connector;

@property (nonatomic, copy) NSString *sdk;
@property (nonatomic, copy) NSString *sdkVersion;

@property (nonatomic, copy) NSString *clientId;
@property (nonatomic, copy) NSString *clientVersion;

@property (nonatomic, copy) NSString *appToken;
@property (nonatomic, copy) NSString *module;
@property (nonatomic, copy) NSString *platform;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *facebookId;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *local;

@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double latitude;

@property (nonatomic, copy) NSString *referer;
@property (nonatomic, copy) NSString *campaign;
@property (nonatomic, copy) NSString *placement;

@property (nonatomic, assign) BOOL debug;

@property (nonatomic, strong) NSTimer *autoPingTimer;

/**
 At the very first start of the tracker a random install token is created and saved to the user defaults
 */
@property (nonatomic, copy, readonly) NSString *installToken;

/**
 A session token is genereted every time the tracker gets initialized.
 */
@property (nonatomic, copy, readonly) NSString *sessionToken;

/**
 Initialize a new Tracker with a connector
 @param connector the connector used for sending the events
 */
- (instancetype)initWithConnector:(Connector *)connector;


/**
 Builds a random token with a specific length. Every fourth character a '-' is added.
 @param the length of the token.
 */
- (NSString *)randomToken:(int)length;

/**
 Sets the user's location.
 @param latitude user's latitude
 @param longitude user's longitude
 */
- (void)setLatitude:(double)latitude longitude:(double)longitude;

/**
 Sets the referer, the campaign and the placement
 @param referer
 @param campaign
 @param placement
 */
- (void)setReferer:(NSString *)referer campaign:(NSString *)campaign placement:(NSString *)placement;

/**
 Set the sdk and the version
 @param sdk
 @param version
 */
- (void)setSDK:(NSString *)sdk version:(NSString *)version;

/**
 Set
 */
- (void)setClientId:(NSString *)clientId version:(NSString *)version;


#pragma mark - Starting and grouping

/**
 Stop the tracking
 */
- (void)stop;

/**
 Resumes the tracking
 */
- (void)resume;

/**
 Start a tracking group. If a tracking group is started, all events in the group will be sent i a single HTTP event after endGroup is called.
 */
- (void)startGroup;

/**
 Ends a tracking group.
 */
- (void)endGroup;


#pragma mark - Tracking

/**
 Forwards the event to the connector where it is send. This method is called when a event is added event.
 @param event the event to send
 @param category the category of the event
 */
- (void)track:(NSString *)event category:(NSString *)category;

/**
 Forwards the event to the connector where it is send. This method is called when a event is added event.
 @param event the event to send
 @param category the category of the event
 @param userParams a dictionary with user specific parameters
 */
- (void)track:(NSString *)event category:(NSString *)category userParams:(NSDictionary *)userParams;

/**
 Helper methods. They are exposed so that they can be tested.
 */
#pragma mark - Helper methods

- (NSDictionary *)mergeParams:(NSDictionary *)userParams eventName:(NSString *)eventName eventCategory:(NSString *)eventCategory;
- (void)addKey:(NSString *)key value:(id)value to:(NSMutableDictionary *)dict;

@end
