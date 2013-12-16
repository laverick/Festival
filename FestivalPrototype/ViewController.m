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

@interface ViewController ()
@property (nonatomic, strong) AEAudioController *audioController;
@property (nonatomic, strong) NSArray *trackFiles;
@property (nonatomic, strong) NSMutableArray *filesForPlayer;
@property (nonatomic) AEChannelGroupRef group;
@property (nonatomic) BOOL isPlaying;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self loadTracks];
    [self configurePlayer];
    [self play];
}


- (void)loadTracks
{
    _trackFiles = @[
                    @{@"filename" : @"1.mp3", @"type" : @"mp3"},
                    @{@"filename" : @"2.mp3", @"type" : @"mp3"}
                    ];
}

- (void)configurePlayer
{
    _audioController = [[AEAudioController alloc]
                           initWithAudioDescription:[AEAudioController interleaved16BitStereoAudioDescription]
                           inputEnabled:NO];
    
    _audioController.preferredBufferDuration = 0.093;
    _audioController.allowMixingWithOtherApps = NO;
    _filesForPlayer = [NSMutableArray new];
    
    // LOOP THROUGH TO SET UP EACH AEAUDIOUNITFILEPLAYER
    for(NSDictionary *track in _trackFiles) {
        
        NSURL *fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:track[@"filename"] ofType:track[@"type"] inDirectory:@"Resources/Music"]];
        
        AEAudioFilePlayer *fileForPlayer = [AEAudioFilePlayer audioFilePlayerWithURL:fileURL
                                                                 audioController:_audioController
                                                                           error:NULL];
        fileForPlayer.volume = 0.75;
        fileForPlayer.currentTime = 0; // set it to the time already elapsed on the user's track
        [_filesForPlayer addObject:fileForPlayer];
    }
    
    
  //  _group = [_audioController createChannelGroup];
//    [_audioController addChannels:_filesForPlayer toChannelGroup:_group];
    [_audioController addChannels:_filesForPlayer];
//    [_audioController setVolume:0.75 forChannelGroup:_group];
    
    // LOOP TO SET EACH AEAUDIOUNITFILEPLAYER URL
//    [_trackFiles enumerateObjectsUsingBlock:^(id track, NSUInteger idx, BOOL *stop) {
//        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:track[@"filename"] ofType:track[@"type"] inDirectory:_directory]];
//        [_filesForPlayer[idx] setUrl:url];
//    }];
    //_totalTrackTime = [_filesForPlayer[0] duration]; // THEY'RE ALL THE SAME LENGTH SO I JUST GET THE FIRST ON
}

- (void)play
{
    
    // Start the audio engine.
    [_audioController start:NULL];
    
    _isPlaying = YES;
}


- (void)adjustVolumeTo:(CGFloat)volume forChannel:(NSUInteger)channelNumber
{
    
}

- (void)adjustPanTo:(CGFloat)pan forChannel:(NSUInteger)channelNumber
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
