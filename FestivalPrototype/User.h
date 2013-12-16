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
@property (nonatomic) CGPoint position;
@property (nonatomic, strong) NSArray *playlist;

- (id)initWithName:(NSString *)name
          playlist:(NSArray *)playlist
          position:(CGPoint)position;

- (CGFloat)distanceFrom:(User *)user;

- (NSURL *)currentTrack;
- (void)nextTrack;

@end
