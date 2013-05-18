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
}

- (void)pebbleConnected:(PBWatch *)watch {
    [connectedLabel setText:[NSString stringWithFormat:@"Connected to %@", [watch name], nil]];
}

- (void)pebbleDisconnected {
    [connectedLabel setText:@"Disconnected"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
