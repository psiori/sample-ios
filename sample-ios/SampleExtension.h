//
//  SampleExtension.h
//  sample-ios
//
//  Created by Daniel Band on 10/09/14.
//  Copyright (c) 2014 5dlab GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sample.h"

extern NSString *const kInstallToken;

@class Connector;

@interface Sample ()

@property (nonatomic, copy) NSString *sdk;
@property (nonatomic, copy) NSString *sdkVersion;

@property (nonatomic, strong) id client;
@property (nonatomic, copy) NSString *clientVersion;

@property (nonatomic, copy) NSString *appToken;
@property (nonatomic, strong) id module;
@property (nonatomic, copy) NSString *platform;
@property (nonatomic, strong) id userId;
@property (nonatomic, strong) id facebookId;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *locale;

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
@property (nonatomic, copy) NSString *installToken;

/**
 A session token is genereted every time the tracker gets initialized.
 */
@property (nonatomic, copy) NSString *sessionToken;

/**
 The endpoints url
 */
@property (nonatomic, strong) NSString *endpoint;

/**
 The Connector
 */
@property (nonatomic, strong) Connector *connector;

/**
 Get a shared Sample instance
 */
+ (Sample *)sharedInstance;

/**
 Reset the singleton in order to tear it down  at the end of a unit test
 */
+ (void)setSharedInstance:(Sample *)instance;

/**
 Init a new Sample with a given connector
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
 Set the client id and version
 @param clientId
 @param version
 */
- (void)setClient:(id)client version:(NSString *)version;


#pragma mark - Tracking

/**
 Stop the tracking
 */
- (void)stop;

/**
 Resumes the tracking
 */
- (void)resume;

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
