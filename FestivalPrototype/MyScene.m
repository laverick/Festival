//
//  MyScene.m
//  SpriteKitTest
//
//  Created by Sven A. Schmidt on 05/11/2013.
//  Copyright (c) 2013 feinstruktur. All rights reserved.
//

#import "MyScene.h"

const uint32_t SolidCategory  =  0x1 << 0;

@implementation MyScene {
    SKNode *_nodeA;
    SKNode *_nodeB;
    SKNode *_movingNode;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];

        _nodeA = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(80, 80)];
        _nodeA.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        _nodeA.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_nodeA.frame.size];
        _nodeA.physicsBody.dynamic = YES;
        _nodeA.physicsBody.categoryBitMask = SolidCategory;
        [self addChild:_nodeA];

        _nodeB = [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:CGSizeMake(80, 80)];
        _nodeB.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        _nodeB.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_nodeB.frame.size];
        _nodeB.physicsBody.dynamic = YES;
        _nodeB.physicsBody.categoryBitMask = SolidCategory;
        [self addChild:_nodeB];

        self.physicsWorld.gravity = CGVectorMake(0, 0);
    }

    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        for (SKNode *n in @[_nodeA, _nodeB]) {
            if (CGRectContainsPoint(n.frame, location)) {
                _movingNode = n;
                break;
            }
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        CGPoint newLoc = CGPointMake(location.x, location.y);
        _movingNode.position = newLoc;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _movingNode = nil;
}

@end
