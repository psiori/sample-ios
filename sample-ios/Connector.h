//
//  Connector.h
//  analytics-sample-ios
//
//  Created by Daniel Band on 25/08/14.
//  Copyright (c) 2014 5dlab GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Protocol that allows callbacks from the Connector
 */
@protocol TrackingDelegate <NSObject>

/**
  Delegate method called when a track action succeeds
  @param data The success data
 */
- (void)trackingDidSucceedWithData:(NSData *)data;

/**
 Delegate method called when a track action failed
 @param error An error object
 */
- (void)trackingDidFailWithError:(NSError *)error;

@end


/**
 The connector implements a queue to send events as fifo.
 It runs a timer which sends an event every second, if there is an event or group available.
 */
@interface Connector : NSObject

@property (nonatomic, assign, getter = isRunning)  BOOL running;
@property (nonatomic, assign, getter = isGrouping) BOOL grouping;
@property (nonatomic, assign, getter = isSending)  BOOL sending;

/**
 If needed set a delegate to receive callbacks when a event was send successfully or an error occured
 */
@property (nonatomic, strong) id< TrackingDelegate> delegate;

/**
 The endpoints url
 */
@property (nonatomic, strong) NSString *url;

/**
 Events are send as fifo
 */
@property (nonatomic, strong) NSMutableArray *eventQueue;

/**
 If grouping is activated events are added to the group until the group is closed. Then the array is added to the event queue.
 */
@property (nonatomic, strong) NSMutableArray *eventGroup;

/**
 Creates a new timer and runs it immediately.
 */
- (void)start;

/**
 Invalidates the timer
 */
- (void)stop;

/**
 Starts a new event group
 */
- (void)startGroup;

/**
 Ends the current event group. All events in this group are send together.
 */
- (void)endGroup;

/**
 Queues an event to the list.
 @param event the event to enqueue
 */
- (void)addEvent:(NSDictionary *)event;

/**
 Is called by the timer when the next event should be send
 */
- (void)sendNext;

@end
