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

static const CGFloat BandmateRestingY = 74.0f;
static const CGFloat LeadingBandmateRestingY = 54.f;

@interface User ()

@property (nonatomic) NSUInteger currentTrackIndex;

@property (nonatomic) dispatch_queue_t audioQueue;

@property (nonatomic) NSTimer *fadeOutTimer;
@property (nonatomic) AEAudioController *controllerCopy;
@property (nonatomic) BOOL mainUser;
@property (nonatomic) BOOL isAnimating;

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
        _mainUser = mainUser;
        _isAnimating = NO;
        
        _view = [[UIView alloc] initWithFrame:CGRectMake(self.position.x - UserWidth / 2, self.position.y - UserHeight / 2, UserWidth, UserHeight)];
        
        _trackLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 113, UserWidth, 20)];
        _trackLabel.font = [UIFont boldSystemFontOfSize:18];
        _trackLabel.textColor = [UIColor blackColor];
        _trackLabel.textAlignment = NSTextAlignmentCenter;
//        _trackLabel.backgroundColor = [UIColor blueColor];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -54, UserWidth, UserHeight)];
        _nameLabel.text = name;
        _nameLabel.font = [UIFont boldSystemFontOfSize:15];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        
        _stageImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stage"]];
        _stageImageView.frame = CGRectMake(0, 0, UserWidth, UserHeight);
        
        _coverImageView = [UIImageView new];
        _coverImageView.frame = CGRectMake(68, 47, 48, 48);
        _coverImageView2 = [UIImageView new];
        _coverImageView2.frame = CGRectMake(116, 47, 48, 48);
        
        int bandmate1Pic = arc4random() % 30;
        int bandmate3Pic = arc4random() % 30;
        NSString *bandmate1FileName = [NSString stringWithFormat:@"Staff-%d", bandmate1Pic];
        NSString *bandmate3FileName = [NSString stringWithFormat:@"Staff-%d", bandmate3Pic];
        
        _bandmate1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:bandmate1FileName]];
        _bandmate2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[name lowercaseString]]];
        _bandmate3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:bandmate3FileName]];
        
        _bandmate1.frame = CGRectMake(20, BandmateRestingY, 40, 40);
        _bandmate2.frame = CGRectMake(80, LeadingBandmateRestingY, 60, 60);
        _bandmate3.frame = CGRectMake(160, BandmateRestingY, 40, 40);
        
        if (_mainUser) {
            // customize main user
        } else {
            [self.view addSubview:self.stageImageView];
            [self.view addSubview:self.coverImageView];
            [self.view addSubview:self.coverImageView2];
            [self.view addSubview:self.nameLabel];
            [self.view addSubview:self.trackLabel];
            [self.view addSubview:_bandmate1];
            [self.view addSubview:_bandmate2];
            [self.view addSubview:_bandmate3];
            [self clearStageWithAnimation:NO];
            
            _audioQueue = dispatch_queue_create("audio queue", NULL);
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
    dispatch_async(self.audioQueue, ^{
        // Clear the existing player in case we don't catch the null preceding it.
        if (self.player) {
            [controller removeChannels:@[self.player]];
            self.player = nil;
        }
        
        if (!trackID) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self stopAnimating];
            });
            return;
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self animate];
        });
        
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
    self.fadeOutTimer = [NSTimer scheduledTimerWithTimeInterval:0.05f
                                                         target:self
                                                       selector:@selector(fadeOutTick)
                                                       userInfo:nil
                                                        repeats:YES];
}

- (void)fadeOutTick
{
    if (self.player.volume >= 0) {
        NSLog(@"Volume is %f", self.player.volume);
        self.player.volume -= 0.05f;
    } else {
        self.player.volume = 0.0f;
        [self.fadeOutTimer invalidate];
        dispatch_async(self.audioQueue, ^{
            if (self.player) {
                [self.controllerCopy removeChannels:@[self.player]];
                self.player = nil;
            }
        });
    }
}

- (void)animate
{
    if (self.isAnimating) {
        return;
    }
    [self.view.layer removeAllAnimations];
    self.isAnimating = YES;
    if (self.mainUser) {
        [UIView animateWithDuration:0.25f
                              delay:0.0f
                            options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionCurveEaseOut)
                         animations:^{
                             UIImageView *imageView = (UIImageView *)[self.view viewWithTag:10];
                             CGRect frame = imageView.frame;
                             int jumpHeight = ((arc4random() % 5) + 7) * 2;
                             NSLog(@"%u", jumpHeight);
                             frame.origin.y = jumpHeight;
                             imageView.frame = frame;
                         }
                         completion:nil];
    } else {
        
        NSLog(@"start animating");
        NSArray *bandmates = @[self.bandmate1, self.bandmate3];
        for (UIImageView *bandmate in bandmates) {
            [UIView animateWithDuration:0.25f
                                  delay:0.1f
                                options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse |
                                         UIViewAnimationOptionCurveEaseOut)
                             animations:^{
                                 CGRect frame = bandmate.frame;
                                 int jumpHeight = (arc4random() % 5) + 7;
                                 NSLog(@"%u", jumpHeight);
                                 frame.origin.y = BandmateRestingY + jumpHeight;
                                 bandmate.frame = frame;
                             }
                             completion:nil];
        }
        
        
        [UIView animateWithDuration:0.25f
                              delay:0.0f
                            options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse)
                         animations:^{
                             CGRect frame = self.bandmate2.frame;
                             int jumpHeight = (arc4random() % 5) + 7;
                             NSLog(@"%u", jumpHeight);
                             frame.origin.y = LeadingBandmateRestingY - jumpHeight;
                             self.bandmate2.frame = frame;
                         }
                         completion:nil];
    }

}

- (void)stopAnimating
{
    if (!self.isAnimating) {
        return;
    }

    NSLog(@"Stop animating");
    if (self.mainUser) {
        UIImageView *imageView = (UIImageView *)[self.view viewWithTag:10];
        [imageView.layer removeAllAnimations];
        CGRect frame = imageView.frame;
        frame.origin.y = 0;
        imageView.frame = frame;
    } else {
        NSArray *bandmates = @[self.bandmate1, self.bandmate2, self.bandmate3];
        for (UIView *bandmate in bandmates) {
            CGRect frame = bandmate.frame;
            frame.origin.y = BandmateRestingY;
            bandmate.frame = frame;
            [bandmate.layer removeAllAnimations];
        }
        CGRect frame = self.bandmate2.frame;
        frame.origin.y = LeadingBandmateRestingY;
        self.bandmate2.frame = frame;
    }
    self.isAnimating = NO;
}

- (void)clearStageWithAnimation:(BOOL)animate
{
    NSArray *bandmates = @[self.bandmate1, self.bandmate2, self.bandmate3];
    
    CGFloat duration = animate ? 0.75 : 0;
    
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:kNilOptions
                     animations:^{
                         for (UIView *bandmate in bandmates) {
                             bandmate.alpha = 0.0f;
                             self.nameLabel.alpha = 0.0f;
                         }
                     }
                     completion:nil];
}

- (void)fillStage
{
    NSArray *bandmates = @[self.bandmate1, self.bandmate2, self.bandmate3];
    
    [UIView animateWithDuration:0.75f
                          delay:0.0f
                        options:kNilOptions
                     animations:^{
                         for (UIView *bandmate in bandmates) {
                             bandmate.alpha = 1.0f;
                             self.nameLabel.alpha = 1.0f;
                         }
                     }
                     completion:nil];
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
