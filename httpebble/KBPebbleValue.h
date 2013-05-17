//
//  PebbleValue.h
//  httpebble
//
//  Created by Katharine Berry on 16/05/2013.
//  Copyright (c) 2013 Katharine Berry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define KB_PEBBLE_VALUE_NUMBER @(1)
#define KB_PEBBLE_VALUE_STRING @(2)
#define KB_PEBBLE_VALUE_DATA @(3)

@interface KBPebbleValue : NSManagedObject

@property (nonatomic, retain) NSNumber * key;
@property (nonatomic, retain) NSData * value;
@property (nonatomic, retain) NSNumber * app_id;
@property (nonatomic, retain) NSNumber * kind;

@end
