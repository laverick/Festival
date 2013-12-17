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
@property (nonatomic) CGPoint position;

- (id)initWithName:(NSString *)name
          playlist:(NSArray *)playlist
          position:(CGPoint)position;

- (CGFloat)distanceFrom:(User *)user;

- (NSURL *)currentTrack;
- (void)nextTrack;

@end
