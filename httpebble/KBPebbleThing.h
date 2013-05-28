//
//  KBPebbleThing.h
//  httpebble
//
//  Created by Katharine Berry on 10/05/2013.
//  Copyright (c) 2013 Katharine Berry. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PBWatch;


@class KBPebbleThing;
@protocol KBPebbleThingDelegate <NSObject>

- (void)pebbleThing:(KBPebbleThing*)thing connected:(PBWatch *)watch;
- (void)pebbleThing:(KBPebbleThing*)thing disconnected:(PBWatch *)watch;
- (void)pebbleThing:(KBPebbleThing*)thing found:(PBWatch*)watch;
- (void)pebbleThing:(KBPebbleThing*)thing lost:(PBWatch *)watch;

@end

@interface KBPebbleThing : NSObject

@property (nonatomic, assign) id<KBPebbleThingDelegate> delegate;

- (id)initWithDelegate:(id<KBPebbleThingDelegate>)delegate;
- (void)saveKeyValueData;
- (void)disconnect;
- (void)connect;

@end
