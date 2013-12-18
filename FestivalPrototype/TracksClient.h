//
//  TracksClient.h
//  FestivalPrototype
//
//  Created by Dustin Laverick on 17/12/2013.
//  Copyright (c) 2013 Nicolas Chourrout. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TracksClientUpdateBlock)(NSString *user, NSString *track);
typedef void (^TracksClientExitBlock)(NSString *user);


@interface TracksClient : NSObject

+ (instancetype)sharedClient;

@property (nonatomic, copy) TracksClientUpdateBlock updateBlock;
@property (nonatomic, copy) TracksClientExitBlock exitBlock;
@property (nonatomic) NSMutableDictionary *playbackState;



@end
