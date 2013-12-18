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
#import "CrowdMember.h"
#import "MyScene.h"

#import <SpriteKit/SpriteKit.h>

//#define USE_SK

@interface ViewController () <UIAlertViewDelegate>

// Audio Engine
@property (nonatomic, strong) AEAudioController *audioController;

// Users
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) User *mainUser;
@property (nonatomic, strong) UIImageView *mainUserImage;

@property (nonatomic) CGFloat currentFatness;

// Outlets
@property (strong, nonatomic) IBOutlet UIView *scene;

@property (nonatomic) NSTimer *timer;
@property (nonatomic) CGPoint destination;

// Crowd
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UICollisionBehavior *collision;
@property (strong, nonatomic) NSMutableArray *pushers;
@property (strong, nonatomic) UIDynamicItemBehavior *usersBehavior;
@property (strong, nonatomic) UIDynamicItemBehavior *crowdBehavior;

@property (nonatomic) UIView *water;
@property (nonatomic) UIImageView *concession;
@property (nonatomic) CGRect waterHiddenFrame;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentFatness = 1.0f;

//    // Guide
//    UIView *dot = [[UIView alloc] initWithFrame:CGRectMake(200, 200, 5, 5)];
//    dot.backgroundColor = [UIColor orangeColor];
//    [self.view addSubview:dot];
    
#ifdef USE_SK
    self.view = [[SKView alloc] initWithFrame:self.view.frame];
    SKScene *scene = [MyScene sceneWithSize:self.view.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    [(SKView *)self.view presentScene:scene];
#else
    [self createCrowd];
#endif
    

    TracksClient *tracksClient = [TracksClient sharedClient];

    tracksClient.updateBlock = ^(NSString *user, NSString *track, NSString *artist, NSString *title, NSString *imageUrl){
        // Start new track for user
        // If track is nil, stop current track
        NSLog(@"Update %@ \t%@", user, track);
        
        User *userToUpdate;
        
        if ([user isEqualToString:@"Luke"]) {
            userToUpdate = self.users[1];
        } else if ([user isEqualToString:@"Maciek"]) {
            userToUpdate = self.users[2];
        } else if ([user isEqualToString:@"Dustin"]) {
            userToUpdate = self.users[0];
        } else if ([user isEqualToString:@"Michal"]) {
            userToUpdate = self.users[3];
        }
        
        if (userToUpdate) {
            [userToUpdate fillStage];
            [self playTrackFromUser:userToUpdate
                        withTrackID:track
                             artist:artist
                              title:title
                           imageURL:imageUrl];
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
        } else if ([user isEqualToString:@"Dustin"]) {
            userToUpdate = self.users[0];
        } else if ([user isEqualToString:@"Michal"]) {
            userToUpdate = self.users[3];
        }
        
        if (userToUpdate){
            [userToUpdate stopAnimating];
            [userToUpdate clearStageWithAnimation:YES];
            [self stopTracksFromUser:userToUpdate];
        }
    };

#ifndef USE_SK
    [self createUsers];
    
    [self createConcessionStand];

    [self updateUI];
    
    [self configurePlayer];


#endif
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CGRect frame = self.mainUser.view.frame;
    CGRect newFrame = frame;
    newFrame.origin.y -= 80.;
    
    [UIView animateWithDuration:0.2
                          delay:1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.mainUser.view.frame = newFrame;
                         
                     } completion:
     ^(BOOL finished) {
         
         [UIView animateWithDuration:0.2
                               delay:0
                             options:UIViewAnimationOptionCurveEaseIn
                          animations:^{
                              self.mainUser.view.frame = frame;
                              
                          } completion:
          ^(BOOL finished) {
              self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                            target:self
                                                          selector:@selector(updateUser)
                                                          userInfo:nil
                                                           repeats:YES];
          }];
     }];
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Users

- (void)createConcessionStand
{
    UIImageView *concession = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"concession"]];
    concession.userInteractionEnabled = YES;
    concession.frame = CGRectMake(412, 20, 200, 154);
    self.concession = concession;
    [self.scene addSubview:concession];
    UITapGestureRecognizer *concessionTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buyWater)];
    concession.gestureRecognizers = @[concessionTap];
}

- (void)buyWater
{
    if ([self distanceBetween:self.destination and:self.mainUser.view.center] < 100) {
        [[[UIAlertView alloc] initWithTitle:@"Confirm Your In-App Purchase"
                                    message:@"Do you want to buy one Overpriced Hamburger for £12.69?"
                                   delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Buy", nil] show];
    }
}

- (void)getFatter
{
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"chomp" withExtension:@"wav"];
    if (fileURL) {
        AEAudioFilePlayer *chomp = [AEAudioFilePlayer audioFilePlayerWithURL:fileURL
                                                             audioController:self.audioController
                                                                       error:NULL];
        chomp.loop = NO;
        chomp.volume = 0.8f;
        chomp.currentTime = 0;
        
        [self.audioController addChannels:@[chomp]];
    }
    
    self.currentFatness += 0.2f;
    NSLog(@"Making Nico fatter: %f", self.currentFatness);
    [UIView animateWithDuration:0.15f
                          delay:1.4f
                        options:kNilOptions
                     animations:^{
                         self.mainUserImage.transform = CGAffineTransformMakeScale(self.currentFatness*1.4, self.currentFatness*1.2);
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.15f
                                          animations:^{
                                              self.mainUserImage.transform = CGAffineTransformMakeScale(self.currentFatness, self.currentFatness);
                                          }];
                     }];
}

- (void)createUsers
{
    { // Create Listener
        self.mainUser = [[User alloc] initWithName:@"Nico"
                                          playlist:nil
                                          position:CGPointMake(512, 384)
                                          mainUser:YES];
        
        self.mainUserImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nico"]];
        self.mainUserImage.tag = 10;
        self.mainUserImage.frame = CGRectMake(0, 0, 80, 80);
        self.mainUser.view.frame = self.mainUserImage.frame;
        [self.mainUser.view addSubview:self.mainUserImage];
        [self.scene addSubview:self.mainUser.view];
        [self.scene bringSubviewToFront:self.mainUser.view];
    }
    
    { // Create and add Stages
        self.users = [@[] mutableCopy];
        
        User *dustin   = [[User alloc] initWithName:@"Dustin"
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
        
        [self.users addObject:dustin];
        [self.users addObject:luke];
        [self.users addObject:maciej];
        [self.users addObject:michal];
        
        self.destination = CGPointMake(512, 384);
        
        self.usersBehavior = [[UIDynamicItemBehavior alloc] init];
        self.usersBehavior.density = 1000.0;
        self.usersBehavior.resistance = 1000.0;
        for (User *user in self.users) {
            [self.scene addSubview:user.view];
            [self.collision addItem:user.view];
            [self.usersBehavior addItem:user.view];
        }
        [self.animator addBehavior:self.usersBehavior];
        
        User *user1 = self.users[0]; // Dustin, Lower-Left
        user1.view.transform = CGAffineTransformMakeRotation(6.2);
        User *user2 = self.users[1]; // Luke, Upper-Left
        user2.view.transform = CGAffineTransformMakeRotation(6.2);
        User *user3 = self.users[2]; // Maciej, Lower-Right
        user3.view.transform = CGAffineTransformMakeRotation(0.05);
        User *user4 = self.users[3]; // Michal, Upper-Right
        user4.view.transform = CGAffineTransformMakeRotation(0.05);
    }
}

- (void)createCrowd
{
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    self.collision = [[UICollisionBehavior alloc] init];
    self.collision.translatesReferenceBoundsIntoBoundary = YES;
    
    self.pushers = [NSMutableArray array];
    for (int i = 0; i< 8; i++) {
        CrowdMember *person = [[CrowdMember alloc] initWithFrame:CGRectMake(300 + 15 * (i % 30), 210 + 15 * (i / 30), 15, 15)];
        person.backgroundColor = [UIColor blueColor];
        
        switch (i%4) {
            case 0:
                person.targetLoc = CGPointMake(200, 200);
                break;
            case 1:
                person.targetLoc = CGPointMake(200, 550);
                break;
            case 2:
                person.targetLoc = CGPointMake(800, 200);
                break;
            default:
                person.targetLoc = CGPointMake(800, 550);
                break;
        }
        
        [self.view addSubview:person];
        [self.collision addItem:person];
        
        UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[person] mode:UIPushBehaviorModeContinuous];
//        pushBehavior.angle = 0.0;
        pushBehavior.magnitude = 0.01;
        [self.animator addBehavior:pushBehavior];
        [self.pushers addObject:pushBehavior];
    }
    
    [self.animator addBehavior:self.collision];
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(moveCrowd) userInfo:nil repeats:YES];
}


- (void)moveCrowd
{
    for (UIPushBehavior *pusher in self.pushers) {
        CrowdMember *person = (CrowdMember *)[pusher.items firstObject];
        CGVector diff = CGVectorMake(person.targetLoc.x - person.center.x, person.targetLoc.y - person.center.y);
        pusher.magnitude = 0;
        pusher.pushDirection = diff;
        CGFloat multiplier = sqrtf(diff.dx * diff.dx)+(diff.dy * diff.dy);
        pusher.magnitude /= 10000 + multiplier;   // distance away &
    }
}

#pragma mark - Drawing

- (void)updateUI
{
    CGPoint position = self.mainUser.position;
    
    [UIView animateWithDuration:0.1f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.mainUser.view.center = position;
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                                 if ([self isCloseToAFilledStage:position]) {
                                     [self.mainUser animate];
                                 } else {
                                     [self.mainUser stopAnimating];
                                 }
                             }
                     }];
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
    
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"crowd" withExtension:@"wav"];
    if (fileURL) {
        AEAudioFilePlayer *crowd = [AEAudioFilePlayer audioFilePlayerWithURL:fileURL
                                                             audioController:self.audioController
                                                                       error:NULL];
        crowd.loop = YES;
        crowd.volume = 0.025f;
        crowd.pan = 0.0f;
        crowd.currentTime = 0;
        
        [self.audioController addChannels:@[crowd]];
    }
}

- (void)playTrackFromUser:(User *)user withTrackID:(NSString *)trackID
                   artist:(NSString *)artist
                   title:(NSString *)title
                   imageURL:(NSString *)imageURL
{
    [user playTrackID:trackID
    inAudioController:self.audioController
           withVolume:[self volumeForUser:user]
                  pan:[self panForUser:user]];
    if (title && artist && ![title isEqualToString:@""] && ![artist isEqualToString:@""]) {
//        user.trackLabel.text = [NSString stringWithFormat:@"%@ by %@", title, artist];
        user.trackLabel.text = artist;
    } else {
        user.trackLabel.text = nil;
    }

    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:imageURL]];
        if ( data == nil ) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            user.coverImageView.image = [UIImage imageWithData: data];
            user.coverImageView2.image = [UIImage imageWithData: data];
        });
    });
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
    CGFloat volume = (100 / [self.mainUser distanceFrom:user]) - 0.15;
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
    CGPoint location = [touch locationInView:self.view];
    
    if (location.y < self.concession.frame.origin.y + self.concession.frame.size.height &&
        location.x > self.concession.frame.origin.x &&
        location.x < self.concession.frame.origin.x + self.concession.frame.size.width) {
        
        location.y = self.concession.frame.origin.y + self.concession.frame.size.height;
    }
    
    self.destination = location;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.view];
    
    if (location.y < self.concession.frame.origin.y + self.concession.frame.size.height &&
        location.x > self.concession.frame.origin.x &&
        location.x < self.concession.frame.origin.x + self.concession.frame.size.width) {
        
        location.y = self.concession.frame.origin.y + self.concession.frame.size.height;
    }
    
    self.destination = location;
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

- (BOOL)isCloseToAFilledStage:(CGPoint)location
{
    const CGFloat max = 450;
    
    User *topLeft = self.users[1];
    User *topRight = self.users[3];
    User *bottomLeft = self.users[0];
    User *bottomRight = self.users[2];
    
    return
    ([self distanceBetween:CGPointMake(0, 0) and:location] < max && topLeft.bandmate1.alpha != 0.0f)
    ||
    ([self distanceBetween:CGPointMake(0, self.view.frame.size.width) and:location] < max && topRight.bandmate1.alpha != 0.0f)
    ||
    ([self distanceBetween:CGPointMake(self.view.frame.size.height, 0) and:location] < max && bottomLeft.bandmate1.alpha != 0.0f)
    ||
    ([self distanceBetween:CGPointMake(self.view.frame.size.height, self.view.frame.size.width) and:location] < max && bottomRight.bandmate1.alpha != 0.0f)
    ;
}

- (CGFloat)distanceBetween:(CGPoint)p1 and:(CGPoint)p2
{
    return sqrtf(powf(p1.x - p2.x, 2) + powf(p1.y - p2.y, 2));
}

- (void)moveUserToPosition:(CGPoint)position
{
    self.mainUser.position = position;
    
//    [self.mainUser stopAnimating];
    [self updateUI];
    
    if (!(fabsf(self.mainUser.position.x - self.destination.x) < 0.0001 &&
        fabsf(self.mainUser.position.y - self.destination.y) < 0.0001)) {
        // stationary
    [self adjustChannels];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self getFatter];
    }
}



- (void)drown
{
    CGRect frame = self.view.bounds;
    frame.origin.y = self.view.bounds.size.height;
    self.waterHiddenFrame = frame;
    self.water = [[UIView alloc] initWithFrame:self.waterHiddenFrame];
    self.water.backgroundColor = [UIColor blueColor];
    self.water.alpha = 0.3f;
    [self.view addSubview:self.water];
    [UIView animateWithDuration:3.0f
                     animations:^{
                         self.water.frame = self.view.bounds;
                     } completion:^(BOOL finished) {
                         [self resurface];
                     }];
}

- (void)resurface
{
    [UIView animateWithDuration:3.0f
                     animations:^{
                         self.water.frame = self.waterHiddenFrame;
                     } completion:^(BOOL finished) {
                         //
                     }];
}

@end
