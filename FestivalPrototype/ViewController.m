//
//  ViewController.m
//  FestivalPrototype
//
//  Created by Nicolas Chourrout on 11/12/2013.
//  Copyright (c) 2013 Nicolas Chourrout. All rights reserved.
//

#import "ViewController.h"
#import "AEAudioController.h"
#import "AEAudioFilePlayer.h"
#import "AEAudioUnitFilter.h"
#import "User.h"


@interface ViewController ()

// Audio Engine
@property (nonatomic, strong) AEAudioController *audioController;
@property (nonatomic, strong) NSMutableArray *filePlayers;
@property (nonatomic) AEAudioUnitFilter *reverb;
@property (nonatomic) AEAudioUnitFilter *lpf;

// Users
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) User *mainUser;

// Outlets
@property (strong, nonatomic) IBOutlet UIView *scene;

@property (nonatomic) NSTimer *timer;
@property (nonatomic) CGPoint destination;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createUsers];
    
    [self updateUI];
    
    [self configurePlayer];
    
    [self play];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                  target:self
                                                selector:@selector(updateUser)
                                                userInfo:nil
                                                 repeats:YES];
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Users

- (void)createUsers
{
    { // Create Listener
        self.mainUser = [[User alloc] initWithName:@"Nico"
                                          playlist:nil
                                          position:CGPointMake(250.0f, 250.0f)];
        
        UIImageView *mainUserImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nico"]];
        mainUserImage.frame = CGRectMake(0, 0, self.mainUser.view.frame.size.width / 2, self.mainUser.view.frame.size.height / 2);
        [self.mainUser.view addSubview:mainUserImage];
        [self.mainUser.stageImageView removeFromSuperview];
        [self.mainUser.nameLabel removeFromSuperview];
        [self.scene addSubview:self.mainUser.view];
        [self.scene bringSubviewToFront:self.mainUser.view];
    }
    
    { // Create and add Stages
        self.users = [@[] mutableCopy];
        
        User *sven   = [[User alloc] initWithName:@"Sven Stage"
                                         playlist:@[@"1"]
                                         position:CGPointMake(100.0f, 668.0f)];
        
        User *luke   = [[User alloc] initWithName:@"Luke Stage"
                                         playlist:@[@"2"]
                                         position:CGPointMake(100.0f, 100.0f)];
        
        User *maciej = [[User alloc] initWithName:@"Maciej Stage"
                                         playlist:@[@"3"]
                                         position:CGPointMake(924.0f, 668.0f)];
        
        User *michal = [[User alloc] initWithName:@"Michal Stage"
                                         playlist:@[@"4"]
                                         position:CGPointMake(924.0f, 100.0f)];
        
        [self.users addObject:sven];
        [self.users addObject:luke];
        [self.users addObject:maciej];
        [self.users addObject:michal];
        
        self.destination = self.mainUser.view.center;
        
        for (User *user in self.users) {
            [self.scene addSubview:user.view];
        }
        
        User *user1 = self.users[0]; // Sven, Lower-Left
        user1.view.transform = CGAffineTransformMakeRotation(6);
        User *user2 = self.users[1]; // Luke, Upper-Left
        user2.view.transform = CGAffineTransformMakeRotation(6);
        User *user3 = self.users[2]; // Maciej, Lower-Right
        user3.view.transform = CGAffineTransformMakeRotation(0.25);
        User *user4 = self.users[3]; // Michal, Upper-Right
        user4.view.transform = CGAffineTransformMakeRotation(0.25);
    }
}

#pragma mark - Drawing

- (void)updateUI
{
    CGPoint position = self.mainUser.position;
    
    if (fabsf(self.mainUser.position.x - self.destination.x) < 0.0001 &&
        fabsf(self.mainUser.position.y - self.destination.y) < 0.0001) {
        // stationary
        
        static int direction = 1;
        
        if ([self isCloseToAStage:position]) {
            direction = -direction;
            position.x += direction * 3;
        }
    }
    
    [UIView animateWithDuration:0.1f
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.mainUser.view.center = position;
                     }
                     completion:nil];
}

#pragma mark - Audio Player

- (void)configurePlayer
{
    self.audioController = [[AEAudioController alloc]
                           initWithAudioDescription:[AEAudioController interleaved16BitStereoAudioDescription]
                           inputEnabled:NO];
    
    self.audioController.preferredBufferDuration = 0.093;
    self.audioController.allowMixingWithOtherApps = NO;
    self.filePlayers = [NSMutableArray new];
    
    for (User *user in self.users) {
        
        NSURL *fileURL = user.currentTrack;
        
        // TODO: give each user its AEAudioFilePlayer
        AEAudioFilePlayer *filePlayer = [AEAudioFilePlayer audioFilePlayerWithURL:fileURL
                                                                 audioController:_audioController
                                                                           error:NULL];
        filePlayer.volume = [self volumeForUser:user];
        filePlayer.pan = [self panForUser:user];
        filePlayer.currentTime = 0; // set it to the time already elapsed on the user's track
                                    // for real time listening
        
        [self.filePlayers addObject:filePlayer];
    }
    [self.audioController addChannels:self.filePlayers];
    
    { // Add reverb and a low-pass filter to the audio controller.
        AudioComponentDescription reverbComp = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple,
                                                                               kAudioUnitType_Effect,
                                                                               kAudioUnitSubType_Reverb2);
        
        AudioComponentDescription lpfComp = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple,
                                                                            kAudioUnitType_Effect,
                                                                            kAudioUnitSubType_LowPassFilter);
        
        self.reverb = [[AEAudioUnitFilter alloc] initWithComponentDescription:reverbComp
                                                              audioController:self.audioController
                                                                        error:nil];
        
        self.lpf = [[AEAudioUnitFilter alloc] initWithComponentDescription:lpfComp
                                                           audioController:self.audioController
                                                                     error:nil];
        
        AudioUnitSetParameter(self.reverb.audioUnit, kReverb2Param_DryWetMix, kAudioUnitScope_Global, 0, 5, 0);
        AudioUnitSetParameter(self.lpf.audioUnit, kLowPassParam_CutoffFrequency, kAudioUnitScope_Global, 0, 20000, 0);
        
        [self.audioController addFilter:self.reverb];
        [self.audioController addFilter:self.lpf];
    }
}

- (void)play
{
    [self.audioController start:nil];
}

- (void)adjustChannels
{
    for (NSUInteger index = 0; index < [self.users count]; index++) {
        AEAudioFilePlayer *player = self.filePlayers[index];
        User *user = self.users[index];
        player.volume = [self volumeForUser:user];
        player.pan = [self panForUser:user];
        [self adjustReverbForUser:user];
        [self adjustLPFForUser:user];
    }
}

#pragma - Audio Effects

- (void)adjustReverbForUser:(User *)user
{
    CGFloat reverb = [self reverbForUser:user];
    AudioUnitSetParameter(self.reverb.audioUnit, kReverb2Param_DryWetMix, kAudioUnitScope_Global, 0, reverb, 0);
}

- (void)adjustLPFForUser:(User *)user
{
    CGFloat lpf = [self lowPassFilterForUser:user];
    AudioUnitSetParameter(self.lpf.audioUnit, kLowPassParam_CutoffFrequency, kAudioUnitScope_Global, 0, lpf, 0);
}

- (CGFloat)volumeForUser:(User *)user
{
    CGFloat volume = 100 / [self.mainUser distanceFrom:user];
    volume = volume < 0 ? 0 : volume;
    volume = volume > 1 ? 1 : volume;
    return volume;
}

- (CGFloat)panForUser:(User *)user
{
    CGFloat pan = [self.mainUser xPosFrom:user] / [UIScreen mainScreen].bounds.size.width;
    pan = pan < -1 ? -1 : pan;
    pan = pan > 1 ? 1 : pan;
    return pan;
}

- (CGFloat)reverbForUser:(User *)user
{
    return (100 / [self.mainUser distanceFrom:user]) + 30;
}

- (CGFloat)lowPassFilterForUser:(User *)user
{
    // TO-DO: Implement me!
    return 20000.0f;
}

#pragma mark - Moving Around

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    self.destination = [touch locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    self.destination = [touch locationInView:self.view];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // stop moving when finger lifted
//    self.destination = self.mainUser.position;
}

- (void)updateUser
{
    CGPoint currentPosition = self.mainUser.position;
    
    CGFloat distance = 10.f;
    
    CGFloat bigDeltaX = self.destination.x - currentPosition.x;
    CGFloat bigDeltaY = self.destination.y - currentPosition.y;
    
    CGFloat deltaX = fabsf(bigDeltaX) > 0.0001 ? distance / sqrtf( powf(bigDeltaY / bigDeltaX, 2) + 1 ) : 0;
    CGFloat deltaY = fabsf(bigDeltaY) > 0.0001 ? distance / sqrtf( powf(bigDeltaX / bigDeltaY, 2) + 1 ) : 0;

    // no wiggling
    if (powf(bigDeltaX, 2) + powf(bigDeltaY, 2) < powf(distance, 2)) {
        deltaX = fabsf(bigDeltaX);
        deltaY = fabsf(bigDeltaY);
    }

    deltaX = bigDeltaX > 0 ? deltaX : -deltaX;
    deltaY = bigDeltaY > 0 ? deltaY : -deltaY;

    CGPoint nextPosition = CGPointMake(currentPosition.x + deltaX, currentPosition.y + deltaY);
//    CGPoint nextPosition = CGPointMake(currentPosition.x + (self.destination.x - currentPosition.x) / 10,
//                                       currentPosition.y +  (self.destination.y - currentPosition.y) / 10);
    
    [self.scene bringSubviewToFront:self.mainUser.view];
    [self moveUserToPosition:nextPosition];
}

- (BOOL)isCloseToAStage:(CGPoint)location
{
    const CGFloat max = 300;
    
    return
    [self distanceBetween:CGPointMake(0, 0) and:location] < max
    ||
    [self distanceBetween:CGPointMake(0, self.view.frame.size.width) and:location] < max
    ||
    [self distanceBetween:CGPointMake(self.view.frame.size.height, 0) and:location] < max
    ||
    [self distanceBetween:CGPointMake(self.view.frame.size.height, self.view.frame.size.width) and:location] < max
    ;
}

- (CGFloat)distanceBetween:(CGPoint)p1 and:(CGPoint)p2
{
    return sqrtf(powf(p1.x - p2.x, 2) + powf(p1.y - p2.y, 2));
}

- (void)moveUserToPosition:(CGPoint)position
{
    self.mainUser.position = position;
    
    [self updateUI];
    
    [self adjustChannels];
}


@end
