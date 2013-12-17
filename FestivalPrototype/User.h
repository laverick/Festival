//
//  User.h
//  FestivalPrototype
//
//  Created by Nico on 16/12/2013.
//  Copyright (c) 2013 Nicolas Chourrout. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) NSArray *playlist;
@property (nonatomic) UIImageView *bandmate1;
@property (nonatomic) UIImageView *bandmate2;
@property (nonatomic) UIImageView *bandmate3;
@property (nonatomic) CGPoint position;

@property (nonatomic, strong) UIImageView *stageImageView;

- (id)initWithName:(NSString *)name
          playlist:(NSArray *)playlist
          position:(CGPoint)position
          mainUser:(BOOL)mainUser;

- (CGFloat)distanceFrom:(User *)user;
- (CGFloat)xPosFrom:(User *)user;

- (NSURL *)currentTrack;
- (void)nextTrack;


@end
