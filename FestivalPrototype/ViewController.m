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
#import "User.h"


@interface ViewController ()

//Audio Engine
@property (nonatomic, strong) AEAudioController *audioController;
@property (nonatomic, strong) NSMutableArray *filePlayers;

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
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                  target:self
                                                selector:@selector(updateUser)
                                                userInfo:nil
                                                 repeats:YES];
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
        
        for (User *user in self.users) {
            [self.scene addSubview:user.view];
        }
    }
}

#pragma mark - Drawing

- (void)updateUI
{
    [UIView animateWithDuration:0.1f
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.mainUser.view.center = self.mainUser.position;
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
    }
}

- (CGFloat)volumeForUser:(User *)user
{
    // TODO: compute the volume properly (http://sengpielaudio.com/calculator-distance.htm)
    CGFloat volume = 100 / [self.mainUser distanceFrom:user];
    volume = volume < 0 ? 0 : volume;
    volume = volume > 1 ? 1 : volume;
    NSLog (@"Volume for %@ is %f", user.name, volume);
    return volume;
}

- (CGFloat)panForUser:(User *)user
{
    // TODO: to implement
    return 0.0; // Range: -1.0 (left) to 1.0 (right)
}

#pragma mark - Moving around

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    self.destination = [touch locationInView:self.view];
    //[self moveUserToPosition:location];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    self.destination = [touch locationInView:self.view];
    //[self moveUserToPosition:location];
}

- (void)updateUser
{
    CGPoint currentPosition = self.mainUser.position;
    
    CGPoint nextPosition = CGPointMake((((currentPosition.x + self.destination.x) / 2 + currentPosition.x) / 2 + currentPosition.x) / 2,
                                       (((currentPosition.y + self.destination.y) / 2 + currentPosition.y) / 2 + currentPosition.y) / 2);

//    CGPoint nextPosition = CGPointMake(,
//    );
    
    [self moveUserToPosition:nextPosition];
}

- (void)moveUserToPosition:(CGPoint)position
{
    self.mainUser.position = position;
    
    [self updateUI];
    
    [self adjustChannels];
}


@end
