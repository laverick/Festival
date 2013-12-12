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
@property (nonatomic, strong) NSArray *filesForPlayer;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self loadTracks];
    [self configurePlayer];
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
    self.audioController = [[AEAudioController alloc]
                           initWithAudioDescription:[AEAudioController interleaved16BitStereoAudioDescription]
                           inputEnabled:NO];
    self.audioController.preferredBufferDuration = 0.093;
    self.audioController.allowMixingWithOtherApps = NO;
    
    NSMutableArray *tempFilesForPlayer = [[NSMutableArray alloc] init];
    
    // LOOP THROUGH TO SET UP EACH AEAUDIOUNITFILEPLAYER
    for(NSDictionary *track in _trackFiles) {
        AEAudioUnitFilePlayer *fileForPlayer = [AEAudioUnitFilePlayer audioUnitFilePlayerWithController:_audioController error:nil];
        fileForPlayer.volume = 0.75;
        fileForPlayer.currentTime = _currentTrackTimePassed; // DEFAULTS TO '0'
        [tempFilesForPlayer addObject:fileForPlayer];
    }
    _filesForPlayer = [[NSArray alloc] initWithArray:tempFilesForPlayer];
    
    _group = [_audioController createChannelGroup];
    [_audioController addChannels:_filesForPlayer toChannelGroup:_group];
    [_audioController setVolume:0.75 forChannelGroup:_group];
    
    // LOOP TO SET EACH AEAUDIOUNITFILEPLAYER URL
    [_trackFiles enumerateObjectsUsingBlock:^(id track, NSUInteger idx, BOOL *stop) {
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:track[@"filename"] ofType:track[@"type"] inDirectory:_directory]];
        [_filesForPlayer[idx] setUrl:url];
    }];
    _totalTrackTime = [_filesForPlayer[0] duration]; // THEY'RE ALL THE SAME LENGTH SO I JUST GET THE FIRST ONE
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
