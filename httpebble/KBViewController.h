//
//  KBViewController.h
//  httpebble
//
//  Created by Katharine Berry on 10/05/2013.
//  Copyright (c) 2013 Katharine Berry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBPebbleThing.h"

@interface KBViewController: UIViewController<KBPebbleThingDelegate>  {
    IBOutlet UILabel* connectedLabel;
}

- (void)pebbleConnected:(PBWatch *)watch;
- (void)pebbleDisconnected;

@end
