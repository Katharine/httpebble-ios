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

#define WIDTH 144
#define HEIGHT 168

- (UIImage*)frameBufferImage
{
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef bitmap = CGBitmapContextCreate(frameBuffer,
                                                WIDTH,
                                                HEIGHT,
                                                8,
                                                WIDTH*4,
                                                rgbColorSpace,
                                                kCGImageAlphaNoneSkipLast);
    
    UIGraphicsBeginImageContext(CGSizeMake(WIDTH, 168));
    CGImageRef imageRef = CGBitmapContextCreateImage(bitmap);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, HEIGHT);
    CGContextSaveGState(context);
    CGContextConcatCTM(context, flipVertical);
    CGContextDrawImage(context, CGRectMake(0, 0, WIDTH, HEIGHT), imageRef);
    CGContextRestoreGState(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(imageRef);
    CGContextRelease(bitmap);
    CGColorSpaceRelease(rgbColorSpace);
    
    return image;
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

- (void)pebbleThing:(KBPebbleThing*)thing frameBuffer:(NSData *)buffer fromIndex:(NSInteger)index {
    if (!index) {
        for (int i=0; i<sizeof(frameBuffer); i+=4) {
            frameBuffer[i+0] = 0x00;
            frameBuffer[i+1] = 0x00;
            frameBuffer[i+2] = 0x00;
            frameBuffer[i+3] = 0xff;
        }
    }
    unsigned char *bytes = (unsigned char *)buffer.bytes;
    int length = buffer.length;
    unsigned char *dst = &frameBuffer[index*8*4];
    if (buffer) {
        for (int i=0; i<length; i++) {
            for (int j=0; j<8; j++) {
                if (bytes[i] & 1<<j) {
                    *dst++ = 0xff;
                    *dst++ = 0xff;
                    *dst++ = 0xff;
                    *dst++ = 0xff;
                } else {
                    *dst++ = 0x00;
                    *dst++ = 0x00;
                    *dst++ = 0x00;
                    *dst++ = 0xff;
                }
            }
        }
        screenImageView.image = [self frameBufferImage];
    }
}

- (void)toggleConnected:(id)sender {
    shouldBeConnected = !shouldBeConnected;
    [[NSUserDefaults standardUserDefaults] setBool:shouldBeConnected forKey:@"ShouldBeConnected"];
    [self handleConnection:_pebbleThing];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)image:(UIImage*)image
didFinishSavingWithError:(NSError*)error
  contextInfo:(void*)contextInfo
{
    [[[UIAlertView alloc] initWithTitle:nil message:@"Saved to the Camera roll." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
        UIImageWriteToSavedPhotosAlbum(screenImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    screenImageView.image = nil;
}

- (IBAction)saveScreenshot:(id)sender {
    if (screenImageView.image) {
        [[[UIAlertView alloc] initWithTitle:@"Save" message:@"Save screenshot to camera roll?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
    } else {
        [self.pebbleThing requestScreenshot];
    }
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
}

@end
