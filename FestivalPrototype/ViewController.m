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
#import "TracksClient.h"

@interface ViewController ()

// Audio Engine
@property (nonatomic, strong) AEAudioController *audioController;

// Users
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) User *mainUser;

// Outlets
@property (strong, nonatomic) IBOutlet UIView *scene;

@property (nonatomic) NSTimer *timer;
@property (nonatomic) CGPoint destination;

// Crowd
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UICollisionBehavior *collision;
@property (strong, nonatomic) NSMutableArray *pushers;
@property (strong, nonatomic) UIDynamicItemBehavior *usersBehavior;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    [self createCrowd];
    
    TracksClient *tracksClient = [TracksClient sharedClient];

    tracksClient.updateBlock = ^(NSString *user, NSString *track){
        // Start new track for user
        // If track is nil, stop current track
        NSLog(@"Update %@ \t%@", user, track);
        
        User *userToUpdate;
        
        if ([user isEqualToString:@"Luke"]) {
            userToUpdate = self.users[1];
        } else if ([user isEqualToString:@"Maciek"]) {
            userToUpdate = self.users[2];
        } else if ([user isEqualToString:@"Sven"]) {
            userToUpdate = self.users[0];
        } else if ([user isEqualToString:@"Michal"]) {
            userToUpdate = self.users[3];
        }
        
        if (userToUpdate) {
            [userToUpdate fillStage];
            [self playTrackFromUser:userToUpdate withTrackID:track];
        }
    };
    
    tracksClient.exitBlock = ^(NSString *user){
        // remove user from stage
        NSLog(@"Exit %@", user);
        
        User *userToUpdate;
        
        if ([user isEqualToString:@"Luke"]) {
            userToUpdate = self.users[1];
        } else if ([user isEqualToString:@"Maciek"]) {
            userToUpdate = self.users[2];
        } else if ([user isEqualToString:@"Sven"]) {
            userToUpdate = self.users[0];
        } else if ([user isEqualToString:@"Michal"]) {
            userToUpdate = self.users[3];
        }
        
        if (userToUpdate){
            [userToUpdate clearStage];
            [userToUpdate stopAnimatingBandmates];
            [self stopTracksFromUser:userToUpdate];
        }
    };
    
    
    
    [self createUsers];
    
    [self updateUI];
    
    [self configurePlayer];
    
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
                                          position:CGPointMake(650.0f, 370.0f)
                                          mainUser:YES];
        
        UIImageView *mainUserImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nico"]];
        mainUserImage.frame = CGRectMake(0, 0, 80, 80);
        [self.mainUser.view addSubview:mainUserImage];
        [self.scene addSubview:self.mainUser.view];
        [self.scene bringSubviewToFront:self.mainUser.view];
    }
    
    { // Create and add Stages
        self.users = [@[] mutableCopy];
        
        User *sven   = [[User alloc] initWithName:@"Sven"
                                         playlist:@[@"1"]
                                         position:CGPointMake(150.0f, 618.0f)
                                         mainUser:NO];
        
        User *luke   = [[User alloc] initWithName:@"Luke"
                                         playlist:@[@"2"]
                                         position:CGPointMake(150.0f, 120.0f)
                                         mainUser:NO];
        
        User *maciej = [[User alloc] initWithName:@"Maciej"
                                         playlist:@[@"3"]
                                         position:CGPointMake(874.0f, 618.0f)
                                         mainUser:NO];
        
        User *michal = [[User alloc] initWithName:@"Michal"
                                         playlist:@[@"4"]
                                         position:CGPointMake(874.0f, 120.0f)
                                         mainUser:NO];
        
        [self.users addObject:sven];
        [self.users addObject:luke];
        [self.users addObject:maciej];
        [self.users addObject:michal];
        
        self.destination = self.mainUser.view.center;
        
        self.usersBehavior = [[UIDynamicItemBehavior alloc] init];
        self.usersBehavior.density = 1000.0;
        self.usersBehavior.resistance = 1000.0;
        for (User *user in self.users) {
            [self.scene addSubview:user.view];
            [self.collision addItem:user.view];
            [self.usersBehavior addItem:user.view];
        }
        [self.animator addBehavior:self.usersBehavior];
        
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

- (void)createCrowd
{
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    self.collision = [[UICollisionBehavior alloc] init];
    self.collision.translatesReferenceBoundsIntoBoundary = YES;
    
    self.pushers = [NSMutableArray array];
    for (int i = 0; i< 20; i++) {
        UIView *person = [[UIView alloc] initWithFrame:CGRectMake(150 + i * 20, 150 + i * 20, 15, 15)];
        person.backgroundColor = [UIColor blueColor];
        
        [self.view addSubview:person];
        [self.collision addItem:person];
        
        UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[person] mode:UIPushBehaviorModeContinuous];
        pushBehavior.angle = 0.0;
        pushBehavior.magnitude = 0.01;
        [self.animator addBehavior:pushBehavior];
        [self.pushers addObject:pushBehavior];
    }
    
    [self.animator addBehavior:self.collision];
    
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(moveCrowd) userInfo:nil repeats:YES];
}


- (void)moveCrowd
{
    NSUInteger i = 0;
    for (UIPushBehavior *pusher in self.pushers) {
        pusher.angle += 0.1 + i++;
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
           // position.y += direction * 3;
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
    
    [self.audioController start:nil];
}

- (void)playTrackFromUser:(User *)user withTrackID:(NSString *)trackID
{
    [user playTrackID:trackID
    inAudioController:self.audioController
           withVolume:[self volumeForUser:user]
                  pan:[self panForUser:user]];
}

- (void)stopTracksFromUser:(User *)user
{
    [user stopTracksInAudioController:self.audioController];
}

- (void)adjustChannels
{
    for (User *user in self.users) {
        [user.player setVolume:[self volumeForUser:user]];
        [user.player setPan:[self panForUser:user]];
    }
}

#pragma - Audio Effects

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
    const CGFloat max = 400;
    
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
