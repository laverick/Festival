//
//  User.m
//  FestivalPrototype
//
//  Created by Nico on 16/12/2013.
//  Copyright (c) 2013 Nicolas Chourrout. All rights reserved.
//

#import "User.h"

static const CGFloat UserSize = 130.0f;

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
        
        _view = [[UIView alloc] initWithFrame:CGRectMake(self.position.x - UserSize / 2, self.position.y - UserSize / 2, UserSize, UserSize)];
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 130, 100)];

        _nameLabel.text = name;
        _nameLabel.font = [UIFont boldSystemFontOfSize:20];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        
        _stageImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stage"]];
        _stageImageView.frame = CGRectMake(0, 0, 130, 65);
        
        [self.view addSubview:self.stageImageView];
        [self.view addSubview:self.nameLabel];
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
