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
    IBOutlet UIButton* connectButton;
    BOOL shouldBeConnected;
    BOOL couldConnect;
    BOOL isConnected;
}

- (void)pebbleThing:(KBPebbleThing*)thing connected:(PBWatch *)watch;
- (void)pebbleThing:(KBPebbleThing*)thing disconnected:(PBWatch *)watch;
- (void)pebbleThing:(KBPebbleThing*)thing found:(PBWatch*)watch;
- (void)pebbleThing:(KBPebbleThing*)thing lost:(PBWatch *)watch;

- (IBAction)toggleConnected:(id)sender;

@property (nonatomic, retain) KBPebbleThing *pebbleThing;

@end
