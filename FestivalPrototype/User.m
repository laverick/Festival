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
          mainUser:(BOOL)mainUser
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
        
        int bandmate1Pic = arc4random() % 33;
        int bandmate3Pic = arc4random() % 33;
        NSString *bandmate1FileName = [NSString stringWithFormat:@"Staff-%d", bandmate1Pic];
        NSString *bandmate3FileName = [NSString stringWithFormat:@"Staff-%d", bandmate3Pic];
        
        _bandmate1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:bandmate1FileName]];
        _bandmate2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[name lowercaseString]]];
        _bandmate3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:bandmate3FileName]];
        
        _bandmate1.frame = CGRectMake(20, 80, 40, 40);
        _bandmate2.frame = CGRectMake(80, 80, 60, 60);
        _bandmate3.frame = CGRectMake(160, 80, 40, 40);
        
        if (!mainUser) {
            [self.view addSubview:self.stageImageView];
            [self.view addSubview:self.nameLabel];
            [self.view addSubview:_bandmate1];
            [self.view addSubview:_bandmate2];
            [self.view addSubview:_bandmate3];
            [self clearStage];
        }
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

- (void)playTrackID:(NSString *)trackID
  inAudioController:(AEAudioController *)controller
         withVolume:(CGFloat)volume
                pan:(CGFloat)pan
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Clear the existing player in case we don't catch the null preceding it.
        if (self.player) {
            [controller removeChannels:@[self.player]];
            self.player = nil;
        }
        
        if (!trackID) {
            [self stopAnimatingBandmates];
            return;
        }
        
        [self animateBandmates];
        
        NSLog(@"playing %@ by %@", trackID, self.name);
        
        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:trackID withExtension:@"mp3"];
        
        if (fileURL) {
            self.player = [AEAudioFilePlayer audioFilePlayerWithURL:fileURL
                                                    audioController:controller
                                                              error:NULL];
            self.player.volume = volume;
            self.player.pan = pan;
            self.player.currentTime = 0;
            
            [controller addChannels:@[self.player]];
        } else {
            NSLog(@"TRACK NOT FOUND, YO!");
        }
    });
}

- (void)stopTracksInAudioController:(AEAudioController *)controller
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if (self.player) {
            [controller removeChannels:@[self.player]];
            self.player = nil;
        }
    });
}

- (void)animateBandmates
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *bandmates = @[self.bandmate1, self.bandmate2, self.bandmate3];
        for (UIImageView *bandmate in bandmates) {
            [UIView animateWithDuration:0.25f
                                  delay:0.0f
                                options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse)
                             animations:^{
                                 CGRect frame = bandmate.frame;
                                 frame.origin.y = 70;
                                 bandmate.frame = frame;
                             }
                             completion:nil];
        }
    });
}

- (void)stopAnimatingBandmates
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *bandmates = @[self.bandmate1, self.bandmate2, self.bandmate3];
        for (UIView *bandmate in bandmates) {
            CGRect frame = bandmate.frame;
            frame.origin.y = 80;
            bandmate.frame = frame;
            [bandmate.layer removeAllAnimations];
        }
    });
}

- (void)clearStage
{
    NSArray *bandmates = @[self.bandmate1, self.bandmate2, self.bandmate3];
    for (UIView *bandmate in bandmates) {
        [UIView animateWithDuration:0.75f
                              delay:0.0f
                            options:kNilOptions
                         animations:^{
                             bandmate.alpha = 0.0f;
                         }
                         completion:nil];
    }
}

- (void)fillStage
{
    NSArray *bandmates = @[self.bandmate1, self.bandmate2, self.bandmate3];
    for (UIView *bandmate in bandmates) {
        [UIView animateWithDuration:0.75f
                              delay:0.0f
                            options:kNilOptions
                         animations:^{
                             bandmate.alpha = 1.0f;
                         }
                         completion:nil];
    }
}

- (void)setVolume:(CGFloat)volume
{
    self.player.volume = volume;
}

- (void)setPan:(CGFloat)pan
{
    self.player.pan = pan;
}


#pragma mark - Motion Effect
- (UIView *)viewWithMotionEffect
{
    UIView *view = [UIView new];
    UIInterpolatingMotionEffect *verticalMotionEffect =
    [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    
    verticalMotionEffect.minimumRelativeValue = @(-50);
    verticalMotionEffect.maximumRelativeValue = @(50);
    
    UIInterpolatingMotionEffect *horizontalMotionEffect =
    [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    
    horizontalMotionEffect.minimumRelativeValue = @(-50);
    
    horizontalMotionEffect.maximumRelativeValue = @(50);
    
    
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    
    [view addMotionEffect:group];
    return view;
}

@end
