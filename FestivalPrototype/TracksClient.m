//
//  TracksClient.m
//  FestivalPrototype
//
//  Created by Dustin Laverick on 17/12/2013.
//  Copyright (c) 2013 Nicolas Chourrout. All rights reserved.
//

#import "TracksClient.h"
#import <Parse/Parse.h>

static const NSTimeInterval updateDelay = 0.1f;

@interface TracksClient()


@end


@implementation TracksClient

+ (instancetype)sharedClient
{
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self performSelector:@selector(fetchUpdates) withObject:nil];
    }
    return self;
}

- (void)fetchUpdates
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fetchUpdates) object:nil];
    NSMutableDictionary *newState __block = [NSMutableDictionary dictionary];
    PFQuery *q = [PFQuery queryWithClassName:@"NowPlaying"];
    [q findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *obj in objects) {
                NSString *name = obj[@"name"];
                NSString *track = obj[@"trackId"];
                NSString *title = obj[@"title"];
                NSString *artist = obj[@"artist"];
                NSString *imageUrl = obj[@"imageUrl"];
                
                newState[name] = @{ @"trackId" : track ? : @"",
                                    @"title" : title ? : @"",
                                    @"artist" : artist ? : @"",
                                    @"imageUrl" : imageUrl ? : @"" };
                
                if (self.playbackState[name]) {
                    // user exists
                    if ([self.playbackState[name][@"trackId"] isEqualToString:track]) {
                        // same track, do nothing
                        continue;
                    } else {
                        // user exists, different track, callback with new track
                        if (self.updateBlock) {
                            self.updateBlock(name, [track isEqualToString:@""] ? nil : track,
                                             artist,
                                             title,
                                             imageUrl);
                        }
                    }
                }
            }
            
            for (NSString *name in [self.playbackState allKeys]) {
                BOOL found = NO;
                for (PFObject *obj in objects) {
                    if ([obj[@"name"] isEqualToString:name]) {
                        found = YES;
                        break;
                    }
                }
                if (!found){
                    if (self.exitBlock) {
                        self.exitBlock(name);
                    }
                }
            }
            
            self.playbackState = newState;
            [self performSelector:@selector(fetchUpdates) withObject:nil afterDelay:updateDelay];
        }
    }];
}

- (void)updateName:(NSString *)name withTrack:(NSString *)track
{
    
}

@end
