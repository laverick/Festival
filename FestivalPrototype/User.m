//
//  User.m
//  FestivalPrototype
//
//  Created by Nico on 16/12/2013.
//  Copyright (c) 2013 Nicolas Chourrout. All rights reserved.
//

#import "User.h"

@interface User ()
@property (nonatomic) NSUInteger currentTrackIndex;
@end

@implementation User


- (id)initWithName:(NSString *)name
          playlist:(NSArray *)playlist
          position:(CGPoint)position
{
    self = [super init];
    if (self) {
        _name = name;
        _playlist = playlist;
        _position = position;
        _currentTrackIndex = 0;
    }
    return self;
}

- (CGFloat)distanceFrom:(User *)user
{
    double dx = (user.position.x - self.position.x);
    double dy = (user.position.y - self.position.y);
    return sqrt(dx*dx + dy*dy);
}

- (NSURL *)currentTrack
{
    return [[NSBundle mainBundle] URLForResource:self.playlist[self.currentTrackIndex] withExtension:@"m4a"];
}

- (void)nextTrack
{
    if (self.currentTrackIndex < [self.playlist count]) {
        self.currentTrackIndex++;
    }
}



@end
