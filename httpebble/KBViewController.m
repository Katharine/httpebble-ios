//
//  KBViewController.m
//  httpebble
//
//  Created by Katharine Berry on 10/05/2013.
//  Copyright (c) 2013 Katharine Berry. All rights reserved.
//

#import "KBViewController.h"
#import <PebbleKit/PebbleKit.h>

@interface KBViewController ()

@end

@implementation KBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UIImage *buttonImage = [[UIImage imageNamed:@"whiteButton.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"whiteButtonHighlight.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    [connectButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [connectButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    shouldBeConnected = [[NSUserDefaults standardUserDefaults] boolForKey:@"ShouldBeConnected"];
    couldConnect = NO;
    [connectButton setHidden:YES];
    [connectedLabel setText:@"No Pebble available."];
}

- (void)pebbleThing:(KBPebbleThing *)thing found:(PBWatch *)watch {
    [connectedLabel setText:[NSString stringWithFormat:@"%@ is available.", [watch name], nil]];
    [connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    [connectButton setHidden:NO];
    couldConnect = YES;
    [self handleConnection:thing];
}

- (void)pebbleThing:(KBPebbleThing *)thing connected:(PBWatch *)watch {
    [connectedLabel setText:[NSString stringWithFormat:@"Connected to %@", [watch name], nil]];
    [connectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
    [connectButton setHidden:NO];
    isConnected = YES;
}

- (void)pebbleThing:(KBPebbleThing *)thing disconnected:(PBWatch *)watch {
    [connectedLabel setText:@"Disconnected"];
    [connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    [connectButton setHidden:NO];
    isConnected = NO;
}

- (void)pebbleThing:(KBPebbleThing *)thing lost:(PBWatch *)watch {
    [connectButton setHidden:YES];
    [connectedLabel setText:@"No Pebble available."];
}

- (void)toggleConnected:(id)sender {
    shouldBeConnected = !shouldBeConnected;
    [[NSUserDefaults standardUserDefaults] setBool:shouldBeConnected forKey:@"ShouldBeConnected"];
    [self handleConnection:_pebbleThing];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)handleConnection:(KBPebbleThing*)thing {
    if(!isConnected) {
        if(shouldBeConnected && couldConnect) {
            [connectedLabel setText:@"Connecting…"];
            [connectButton setHidden:YES];
            [thing connect];
        }
    } else {
        if(!shouldBeConnected) {
            [connectedLabel setText:@"Disconnecting…"];
            [connectButton setHidden:YES];
            [thing disconnect];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
