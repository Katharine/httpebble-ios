//
//  KBPebbleThing.h
//  httpebble
//
//  Created by Katharine Berry on 10/05/2013.
//  Copyright (c) 2013 Katharine Berry. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PBWatch;

@protocol KBPebbleThingDelegate <NSObject>

- (void)pebbleConnected:(PBWatch*) watch;
- (void)pebbleDisconnected;

@end

@interface KBPebbleThing : NSObject

@property (nonatomic, assign) id<KBPebbleThingDelegate> delegate;

- (void)saveKeyValueData;

@end
