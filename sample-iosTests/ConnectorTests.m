//
//  ConnectorTests.m
//  analytics-sample-ios
//
//  Created by Daniel Band on 29/08/14.
//  Copyright (c) 2014 5dlab GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Connector.h"
#import "XCTestCase+AsyncTesting.h"

@interface ConnectorTests : XCTestCase

@property (nonatomic, strong) Connector *connector;

@end

@implementation ConnectorTests

- (void)setUp
{
  [super setUp];
  self.connector = [Connector new];
  self.connector.url = @"http://events.neurometry.com/sample/v01/event";
  [self.connector start];
}

- (void)tearDown
{
  [super tearDown];
  [self.connector stop];
}

- (void)testInit
{
  XCTAssertNotNil(self.connector.eventQueue, @"EventQueue should be initialized");
  XCTAssertTrue(self.connector.isRunning, @"Connector should run");
}

- (void)testGrouping
{
  [self.connector startGroup];
  XCTAssertTrue(self.connector.isGrouping, @"Group should be set to true");
  [self.connector endGroup];
  XCTAssertFalse(self.connector.isGrouping, @"Group should be set to false");
}

- (void)testStartStop
{
  XCTAssertTrue(self.connector.isRunning, @"Connector should run");
  [self.connector stop];
  XCTAssertFalse(self.connector.isRunning, @"Connector should have stoped");
  [self.connector start];
  XCTAssertTrue(self.connector.isRunning, @"Connector should run after resuming");
}

- (void)testAddEvent
{
  [self.connector stop];
  
  [self.connector addEvent:@{}];
  
  NSUInteger events = [self.connector.eventQueue count];
  XCTAssertEqual(events, 1, @"Eventqueue should contain 0 entries but contains %ld", events);
}

- (void)testAddGroup
{
  [self.connector stop];
  
  [self.connector startGroup];
  [self.connector addEvent:@{}];
  [self.connector addEvent:@{}];
  
  NSUInteger groupEvents = [self.connector.eventGroup count];
  XCTAssertEqual(groupEvents, 2, @"Groupqueue should contain 2 entry but contains %ld", groupEvents);
  
  [self.connector endGroup];
  
  groupEvents = [self.connector.eventGroup count];
  XCTAssertEqual(groupEvents, 0, @"Groupqueue should contain 0 entry but contains %ld", groupEvents);
  
  NSUInteger events = [self.connector.eventQueue count];
  XCTAssertEqual(events, 1, @"Groupqueue should contain 1 entry but contains %ld", events);
}

- (void)testSendNext
{
  [self.connector stop];
  [self.connector addEvent:@{@"event_name": @"ping" ,@"event_category":@"session"}];
  [self.connector start];
  
  [self waitForTimeout:5];
  [self.connector stop];
  
  NSUInteger events = [self.connector.eventQueue count];
  XCTAssertEqual(events, 0, @"Eventqueue should contain 0 entries but contains %ld", events);
}

- (void)testSendNextShouldNotSend
{
  [self.connector stop];
  [self.connector addEvent:@{@"event_name": @"ping" ,@"event_category":@"session"}];
  
  [self waitForTimeout:5];
  NSUInteger events = [self.connector.eventQueue count];
  XCTAssertEqual(events, 1, @"Eventqueue should contain 1 entry but contains %ld", events);
  
  [self.connector sendNext];
  [self waitForTimeout:5];
  events = [self.connector.eventQueue count];
  XCTAssertEqual(events, 1, @"Eventqueue should contain 1 entry but contains %ld", events);
}

@end
