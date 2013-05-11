//
//  KBPebbleThing.m
//  httpebble
//
//  Created by Katharine Berry on 10/05/2013.
//  Copyright (c) 2013 Katharine Berry. All rights reserved.
//

#import "KBPebbleThing.h"
#import <PebbleKit/PebbleKit.h>
#define HTTP_UUID { 0x91, 0x41, 0xB6, 0x28, 0xBC, 0x89, 0x49, 0x8E, 0xB1, 0x47, 0x04, 0x9F, 0x49, 0xC0, 0x99, 0xAD }
#define URL_KEY @(0xFFFF)
#define HTTP_STATUS_KEY @(0xFFFE)
#define HTTP_SUCCESS_KEY @(0xFFFD)
#define HTTP_COOKIE_KEY @(0xFFFC)

@interface KBPebbleThing () <PBPebbleCentralDelegate> {
    PBWatch *ourWatch; // We actually never really use this.
    id updateHandler;
}

- (BOOL)handleWatch:(PBWatch*)watch message:(NSDictionary*)message;

@end

@implementation KBPebbleThing

- (id)init
{
    self = [super init];
    if (self) {
        [[PBPebbleCentral defaultCentral] setDelegate:self];
        [self setOurWatch:[[PBPebbleCentral defaultCentral] lastConnectedWatch]];
    }
    return self;
}

- (void)setOurWatch:(PBWatch*)watch {
    [watch appMessagesGetIsSupported:^(PBWatch *watch, BOOL isAppMessagesSupported) {
        if(!isAppMessagesSupported) return;
        uint8_t uuid[] = HTTP_UUID;
        [watch appMessagesSetUUID:[NSData dataWithBytes:uuid length:sizeof(uuid)]];
        updateHandler = [watch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch *watch, NSDictionary *update) {
            return [self handleWatch:watch message:update];
        }];
        NSLog(@"Update handler: %@", updateHandler);
        ourWatch = watch;
        NSLog(@"Connected to watch %@", [watch name]);
    }];
}

#pragma mark PBPebbleCentral delegate

- (void)pebbleCentral:(PBPebbleCentral *)central watchDidConnect:(PBWatch *)watch isNew:(BOOL)isNew {
    NSLog(@"A watch connected: %@", [watch friendlyDescription]);
    [self setOurWatch:watch];
}

- (void)pebbleCentral:(PBPebbleCentral *)central watchDidDisconnect:(PBWatch *)watch {
    NSLog(@"A watch disconnected.");
}

#pragma mark Other stuff

void errorResponse(PBWatch* watch, NSInteger status) {
    NSDictionary *error_response = [NSDictionary
                                    dictionaryWithObjects:@[[NSNumber numberWithUint8:NO], [NSNumber numberWithUint16:status]]
                                    forKeys:@[HTTP_SUCCESS_KEY, HTTP_STATUS_KEY]];
    [watch appMessagesPushUpdate:error_response onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
        NSLog(@"Error response failed: %@", error);
    }];
}

- (BOOL)handleWatch:(PBWatch *)watch message:(NSDictionary *)message {
    NSLog(@"Message received.");
    if(![message objectForKey:URL_KEY]) {
        return NO;
    }
    NSURL* url = [NSURL URLWithString:[message objectForKey:URL_KEY]];
    NSNumber* cookie = [message objectForKey:HTTP_COOKIE_KEY];
    NSLog(@"Asked to request the contents of %@", url);
    NSMutableDictionary *request_dict = [[NSMutableDictionary alloc] initWithCapacity:[message count]];
    for (NSNumber* key in message) {
        if([key isEqualToNumber:URL_KEY] || [key isEqualToNumber:HTTP_COOKIE_KEY]) {
            continue;
        }
        [request_dict setValue:[message objectForKey:key] forKey:[key stringValue]];
    }
    [request_dict removeObjectsForKeys:@[URL_KEY, HTTP_COOKIE_KEY]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:request_dict options:0 error:nil]];
    NSLog(@"Made request with data: %@", request_dict);
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               NSLog(@"Got HTTP response.");
                               NSInteger status_code = [(NSHTTPURLResponse*)response statusCode];
                               if(error) {
                                   NSLog(@"Something went wrong: %@", error);
                                   errorResponse(watch, status_code);
                                   return;
                               }
                               NSError *json_error = nil;
                               NSDictionary *json_response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&json_error];
                               if(error) {
                                   NSLog(@"Invalid JSON: %@", json_error);
                                   errorResponse(watch, 500);
                                   return;
                               }
                               NSMutableDictionary *response_dict = [[NSMutableDictionary alloc] initWithCapacity:[json_response count]];
                               NSLog(@"Parsing received dictionary: %@", json_response);
                               for(NSString* key in json_response) {
                                   NSNumber *k = [NSNumber numberWithInteger:[key integerValue]];
                                   id value = [json_response objectForKey:key];
                                   if([value isKindOfClass:[NSArray class]]) {
                                       NSArray* array_value = (NSArray*)value;
                                       if([array_value count] != 2 ||
                                          ![[array_value objectAtIndex:0] isKindOfClass:[NSString class]] ||
                                          ![[array_value objectAtIndex:1] isKindOfClass:[NSNumber class]]) {
                                           NSLog(@"Illegal size specification: %@", array_value);
                                           errorResponse(watch, 500);
                                           return;
                                       }
                                       NSString *size_specification = [array_value objectAtIndex:0];
                                       NSInteger number = [[array_value objectAtIndex:1] integerValue];
                                       NSNumber *pebble_value;
                                       if([size_specification isEqualToString:@"b"]) {
                                           pebble_value = [NSNumber numberWithInt8:number];
                                       } else if([size_specification isEqualToString:@"B"]) {
                                           pebble_value = [NSNumber numberWithUint8:number];
                                       } else if([size_specification isEqualToString:@"s"]) {
                                           pebble_value = [NSNumber numberWithInt16:number];
                                       } else if([size_specification isEqualToString:@"S"]) {
                                           pebble_value = [NSNumber numberWithUint16:number];
                                       } else if([size_specification isEqualToString:@"i"]) {
                                           pebble_value = [NSNumber numberWithInt32:number];
                                       } else if([size_specification isEqualToString:@"I"]) {
                                           pebble_value = [NSNumber numberWithUint32:number];
                                       } else {
                                           NSLog(@"Illegal size string: %@", size_specification);
                                           errorResponse(watch, 500);
                                           return;
                                       }
                                       [response_dict setObject:pebble_value forKey:k];
                                   } else if([value isKindOfClass:[NSString class]]) {
                                       [response_dict setObject:value forKey:k];
                                   } else if([value isKindOfClass:[NSNumber class]]) {
                                       [response_dict setObject:[NSNumber numberWithInt32:[value integerValue]] forKey:k];
                                   }
                               }
                               [response_dict setObject:[NSNumber numberWithUint8:YES] forKey:HTTP_SUCCESS_KEY];
                               [response_dict setObject:[NSNumber numberWithUint16:status_code] forKey:HTTP_STATUS_KEY];
                               [response_dict setObject:cookie forKey:HTTP_COOKIE_KEY];
                               NSLog(@"Pushing dictionary to watch: %@", response_dict);
                               [watch appMessagesPushUpdate:response_dict onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
                                   if(error) {
                                       NSLog(@"Response send failed: %@", error);
                                   }
                               }];
                           }
     ];
    return YES;
}

@end
