//
//  Connector.m
//  analytics-sample-ios
//
//  Created by Daniel Band on 25/08/14.
//  Copyright (c) 2014 5dlab GmbH. All rights reserved.
//

#import "Connector.h"

static const int predifiendMaxEvents = 100;

@interface Connector ()

@property (nonatomic, strong) NSTimer *sendNextEventTimer;

@end

@implementation Connector

- (instancetype)init
{
  self = [super init];
  if (self)
  {
    _eventQueue = [[NSMutableArray alloc] initWithCapacity:predifiendMaxEvents];
  }
  
  return self;
}

- (void)start
{
  if (self.isRunning)
  {
    return;
  }
  
  
  [self setRunning:YES];
  self.sendNextEventTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sendNext) userInfo:nil repeats:YES];
}

- (void)stop
{
  if (!self.isRunning)
  {
    return;
  }
  
  [self setRunning:NO];
  [self.sendNextEventTimer invalidate];
}

- (void)startGroup
{
  [self setGrouping:YES];
  self.eventGroup = [[NSMutableArray alloc] init];
}

- (void)endGroup
{
  [self setGrouping:NO];
  
  if (![self.eventGroup count])
  {
    return;
  }
  
  
  [self.eventQueue addObject:self.eventGroup];
  self.eventGroup = nil;          
}

- (void)addEvent:(NSDictionary *)event
{
  if (self.isGrouping)
  {
    [self.eventGroup addObject:event];
  }
  else
  {
    [self.eventQueue addObject:event];
  }
}

- (void)sendNext
{
  if (!self.running || !self.url || self.sending || ![self.eventQueue count])
  {
    return;
  }

  
  self.sending = YES;
  
  NSDictionary *params = [self.eventQueue firstObject];
  
  NSError *error;
  NSData *jsonData = [NSJSONSerialization  dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
  
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]
                                                         cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
  
  [request setHTTPMethod:@"POST"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
  [request setHTTPBody: jsonData];

  [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
  {
    if (error)
    {
      if ([self.delegate respondsToSelector:@selector(trackingDidFailWithError:)])
      {
        [self.delegate trackingDidFailWithError:error];
      }
      
      self.sending = NO;
    }
    else
    {
      if ([self.delegate respondsToSelector:@selector(trackingDidSucceedWithData:)])
      {
        [self.delegate trackingDidSucceedWithData:data];
      }
      
      if ([self.eventQueue count])
      {
        [self.eventQueue removeObjectAtIndex:0];
        self.sending = NO;
        [self sendNext];
      }
      else
      {
        self.sending = NO;
      }
    }
  }];
}

@end
