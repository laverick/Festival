//
//  User.m
//  FestivalPrototype
//
//  Created by Nico on 16/12/2013.
//  Copyright (c) 2013 Nicolas Chourrout. All rights reserved.
//

#import "User.h"

static const CGFloat UserWidth = 233.0f;
static const CGFloat UserHeight = 135.0f;

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
        
        _view = [[UIView alloc] initWithFrame:CGRectMake(self.position.x - UserWidth / 2, self.position.y - UserHeight / 2, UserWidth, UserHeight)];
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -10, UserWidth, UserHeight)];

        _nameLabel.text = [NSString stringWithFormat:@"%@ Stage", name];
        _nameLabel.font = [UIFont boldSystemFontOfSize:18];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        
        _stageImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stage"]];
        _stageImageView.frame = CGRectMake(0, 0, UserWidth, UserHeight);
        
        _bandmate1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bandmate"]];
        _bandmate2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[name lowercaseString]]];
        _bandmate3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bandmate"]];
        
        _bandmate1.frame = CGRectMake(20, 80, 40, 40);
        _bandmate2.frame = CGRectMake(88, 68, 60, 60);
        _bandmate3.frame = CGRectMake(160, 80, 40, 40);
           
        [self.view addSubview:self.stageImageView];
        [self.view addSubview:self.nameLabel];
        [self.view addSubview:_bandmate1];
        [self.view addSubview:_bandmate2];
        [self.view addSubview:_bandmate3];
    }
    return self;
}

- (CGFloat)distanceFrom:(User *)user
{
    double dx = (user.position.x - self.position.x);
    double dy = (user.position.y - self.position.y);
    return sqrt(dx*dx + dy*dy);
}

- (CGFloat)xPosFrom:(User *)user
{
    double dx = (user.position.x - self.position.x);
    return dx;
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
