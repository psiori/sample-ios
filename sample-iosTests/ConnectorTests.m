//
//  ConnectorTests.m
//  sample-ios
//
//  Created by Daniel Band on 10/09/14.
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
  self.connector = [[Connector alloc] init];
  self.connector.endpoint = @"http://events.neurometry.com/sample/v01/event";
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [self.connector stop];
}

- (void)testInit
{
  XCTAssertNotNil(self.connector.eventQueue, @"EventQueue should be initialized");
  XCTAssertNil(self.connector.eventGroup, @"EventGroup should be nil");
  XCTAssertNil(self.connector.sendNextEventTimer, @"EventGroup should be nil");
}

- (void)testGrouping
{
  XCTAssertFalse(self.connector.isGrouping, @"Group should be set to false as default");
  [self.connector startGroup];
  XCTAssertTrue(self.connector.isGrouping, @"Group should be set to true");
  [self.connector endGroup];
  XCTAssertFalse(self.connector.isGrouping, @"Group should be set to false");
}

- (void)testStartStop
{
  XCTAssertFalse(self.connector.isRunning, @"connector should not run as default");
  [self.connector start];
  XCTAssertTrue(self.connector.isRunning, @"connector should run");
  [self.connector stop];
  XCTAssertFalse(self.connector.isRunning, @"connector should have stoped");
}

- (void)testAddEvent
{
  [self.connector stop];
  
  [self.connector addEvent:@{}];
  NSUInteger nrOfEvents = [self.connector length];
  XCTAssertEqual(nrOfEvents, 1, @"Eventqueue should contain 1 entry but contains %ld", nrOfEvents);
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
  
  NSUInteger nrOfEvents = [self.connector length];
  XCTAssertEqual(nrOfEvents, 1, @"Eventqueue should contain 1 entry but contains %ld", nrOfEvents);
}

- (void)testSendNext
{
  [self.connector start];
  [self.connector addEvent:@{}];
  
  [self waitForTimeout:5];
  
  NSUInteger nrOfEvents = [self.connector length];
  XCTAssertEqual(nrOfEvents, 0, @"Eventqueue should contain 0 entry but contains %ld", nrOfEvents);
}

- (void)testSendNextShouldNotSend
{
  [self.connector addEvent:@{}];
  
  [self waitForTimeout:5];
  NSUInteger events = [self.connector.eventQueue count];
  XCTAssertEqual(events, 1, @"Eventqueue should contain 1 entry but contains %ld", events);
  
  [self.connector sendNext];
  [self waitForTimeout:5];
  events = [self.connector.eventQueue count];
  XCTAssertEqual(events, 1, @"Eventqueue should contain 1 entry but contains %ld", events);
}

@end
