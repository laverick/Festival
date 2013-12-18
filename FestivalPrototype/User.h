//
//  User.h
//  FestivalPrototype
//
//  Created by Nico on 16/12/2013.
//  Copyright (c) 2013 Nicolas Chourrout. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AEAudioController.h"
#import "AEAudioFilePlayer.h"
#import "AEAudioUnitFilter.h"

@interface User : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *trackLabel;
@property (nonatomic, strong) NSArray *playlist;
@property (nonatomic) UIImageView *bandmate1;
@property (nonatomic) UIImageView *bandmate2;
@property (nonatomic) UIImageView *bandmate3;
@property (nonatomic, strong) AEAudioFilePlayer *player;
@property (nonatomic) CGPoint position;

@property (nonatomic, strong) UIImageView *stageImageView;
@property (nonatomic, strong) UIImageView *coverImageView;

- (id)initWithName:(NSString *)name
          playlist:(NSArray *)playlist
          position:(CGPoint)position
          mainUser:(BOOL)mainUser;

- (CGFloat)distanceFrom:(User *)user;
- (CGFloat)xPosFrom:(User *)user;

- (void)playTrackID:(NSString *)trackID
  inAudioController:(AEAudioController *)controller
         withVolume:(CGFloat)volume
                pan:(CGFloat)pan;

- (void)stopTracksInAudioController:(AEAudioController *)controller;

- (void)setVolume:(CGFloat)volume;
- (void)setPan:(CGFloat)pan;

- (void)animateBandmates;
- (void)stopAnimatingBandmates;
- (void)clearStageWithAnimation:(BOOL)animate;
- (void)fillStage;

@end
