//
//  KBViewController.h
//  httpebble
//
//  Created by Katharine Berry on 10/05/2013.
//  Copyright (c) 2013 Katharine Berry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBPebbleThing.h"

@interface KBViewController: UIViewController<KBPebbleThingDelegate, UIAlertViewDelegate>  {
    IBOutlet UILabel* connectedLabel;
    IBOutlet UIButton* connectButton;
    BOOL shouldBeConnected;
    BOOL couldConnect;
    BOOL isConnected;
    IBOutlet UIImageView* screenImageView;
    unsigned char frameBuffer[144*168*4];
}

@property (nonatomic, retain) KBPebbleThing *pebbleThing;

- (IBAction)toggleConnected:(id)sender;
- (IBAction)saveScreenshot:(id)sender;

@end
