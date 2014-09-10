//
//  Connector.h
//  sample-ios
//
//  Created by Daniel Band on 09/09/14.
//  Copyright (c) 2014 5dlab GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Protocol that allows callbacks from the Connector
 Needed for unit testing
 */
@protocol ConnectionDelegate <NSObject>

/**
 Delegate method called when a track action succeeds
 @param data The success data
 */
- (void)trackingDidSucceedWithData:(NSData *)data response:(NSURLResponse *)response;

/**
 Delegate method called when a track action failed
 @param error An error object
 */
- (void)trackingDidFailWithError:(NSError *)error;

@end


@interface Connector : NSObject

@property (nonatomic, assign, getter = isRunning)  BOOL running;
@property (nonatomic, assign, getter = isGrouping) BOOL grouping;
@property (nonatomic, assign, getter = isSending)  BOOL sending;

@property (nonatomic, strong, readonly) NSTimer *sendNextEventTimer;

/**
 The endpoints url
 */
@property (nonatomic, strong) NSString *endpoint;

/**
 If needed set a delegate to receive callbacks when a event was send successfully or an error occured
 */
@property (nonatomic, strong) id<ConnectionDelegate> delegate;

/**
 Events are send as fifo
 */
@property (nonatomic, strong) NSMutableArray *eventQueue;

/**
 If grouping is activated events are added to the group until the group is closed. Then the array is added to the event queue.
 */
@property (nonatomic, strong) NSMutableArray *eventGroup;

/**
 Stops the connector
 */
- (void)stop;

/**
 Starts the connector
 */
- (void)start;

/**
 Start a tracking group. If a tracking group is started, all events in the group will be sent i a single HTTP event after endGroup is called.
 */
- (void)startGroup;

/**
 Ends a tracking group.
 */
- (void)endGroup;

/**
 Adds an event to the event queue or the event group if grouping is on.
 */
- (void)addEvent:(NSDictionary *)event;

/**
 Sends the next event in the event queue
 */
- (void)sendNext;

/**
 Returns the lenth of the event queue
 @return the length of the event queue
 */
- (NSInteger)length;

@end
