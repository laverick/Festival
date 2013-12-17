//
//  TracksClient.m
//  FestivalPrototype
//
//  Created by Dustin Laverick on 17/12/2013.
//  Copyright (c) 2013 Nicolas Chourrout. All rights reserved.
//

#import "TracksClient.h"
#import <Parse/Parse.h>

static const NSTimeInterval updateDelay = 0.5f;

@interface TracksClient()
@property (nonatomic) NSMutableDictionary *previousState;

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
                newState[name] = track;
                
                if (self.previousState[name]) {
                    // user exists
                    if ([self.previousState[name] isEqualToString:track]) {
                        // same track, do nothing
                        continue;
                    } else {
                        // user exists, different track, callback with new track
                        if (self.updateBlock) {
                            self.updateBlock(name, [track isEqualToString:@""] ? nil : track);
                        }
                    }
                }
            }
            
            for (NSString *name in [self.previousState allKeys]) {
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
            
            self.previousState = newState;
            [self performSelector:@selector(fetchUpdates) withObject:nil afterDelay:updateDelay];
        }
    }];
}

- (void)updateName:(NSString *)name withTrack:(NSString *)track
{
    
}

@end
