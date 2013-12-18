//
//  MyScene.m
//  SpriteKitTest
//
//  Created by Sven A. Schmidt on 05/11/2013.
//  Copyright (c) 2013 feinstruktur. All rights reserved.
//

#import "MyScene.h"

const uint32_t SolidCategory  =  0x1 << 0;

static inline CGVector VectorMultiply(CGVector vector, CGFloat m);

static inline CGVector VectorMinus(CGPoint p1, CGPoint p2)
{
    return CGVectorMake(p1.x - p2.x, p1.y - p2.y);
}

static inline CGFloat VectorLength(CGVector vector)
{
	return sqrtf(vector.dx * vector.dx + vector.dy * vector.dy);
}

static inline CGVector VectorUnit(CGVector vector)
{
    CGFloat length = VectorLength(vector);
    if (length > 0) {
        CGFloat invLen = 1.0 / VectorLength(vector);
        return VectorMultiply(vector, invLen);
    } else {
        return CGVectorMake(0, 0);
    }
}

static inline CGVector VectorMultiply(CGVector vector, CGFloat m)
{
    return CGVectorMake(vector.dx * m, vector.dy * m);
}

@interface MyScene ()

@property (nonatomic) NSMutableArray *persons;

@end

@implementation MyScene {
    SKNode *_nodeA;
    SKNode *_nodeB;
    SKNode *_movingNode;
    SKNode *_edge;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.view.showsFPS = YES;
        self.view.showsNodeCount = YES;

        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];

        self.physicsWorld.gravity = CGVectorMake(0, 0);
        SKPhysicsBody* borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsBody = borderBody;
        self.physicsBody.friction = 0;
        self.physicsBody.categoryBitMask = SolidCategory;

        { // top
            SKNode* top = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(1024, 50)];
            top.position = CGPointMake(512, 824);
            top.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:top.frame.size];
            top.physicsBody.categoryBitMask = SolidCategory;
            top.physicsBody.dynamic = NO;
            [self addChild:top];
        }
        { // bottom
            SKNode* bottom = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(1024, 50)];
            bottom.position = CGPointMake(512, 200);
            bottom.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bottom.frame.size];
            bottom.physicsBody.categoryBitMask = SolidCategory;
            bottom.physicsBody.dynamic = NO;
            [self addChild:bottom];
        }
        
        [self createCrowd];
    }

    return self;
}

- (void)createCrowd
{
    const int NumberOfPersons = 30;
    self.persons = [NSMutableArray array];
    for (int i = 0; i < NumberOfPersons; i++) {
        SKSpriteNode *person = [[SKSpriteNode alloc] initWithImageNamed:[NSString stringWithFormat:@"Staff-%d.png", i]];
        person.size = CGSizeMake(30, 30);
        person.position = CGPointMake(250 + i * 20, 250 + i * 20);
        person.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:15];
        person.physicsBody.dynamic = YES;
        person.physicsBody.categoryBitMask = SolidCategory;
        person.physicsBody.mass = 2;
        person.physicsBody.friction = 0;
        person.physicsBody.linearDamping = 0;
        person.physicsBody.restitution = 0;
        [self.persons addObject:person];
        [self addChild:person];
        
        CGPoint targetLoc;
        switch (i%4) {
            case 0:
                targetLoc = CGPointMake(200, 200);
                break;
            case 1:
                targetLoc = CGPointMake(200, 500);
                break;
            case 2:
                targetLoc = CGPointMake(800, 200);
                break;
            default:
                targetLoc = CGPointMake(800, 500);
                break;
        }
        CGVector direction = VectorUnit(CGVectorMake(targetLoc.x - person.position.x, targetLoc.y - person.position.y));
        
        CGFloat magnitude = 100;
        person.physicsBody.velocity = VectorMultiply(direction, magnitude);

    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        for (SKNode *n in self.persons) {
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

- (void)update:(NSTimeInterval)currentTime
{
    const int maxSpeed = 1000;

    for (SKNode *p in self.persons) {
        CGFloat v = VectorLength(p.physicsBody.velocity);
        if (v > maxSpeed) {
            p.physicsBody.linearDamping = 0.4f;
        } else {
            p.physicsBody.linearDamping = 0.0f;
            CGFloat magnitude = 0.5;
            CGVector direction = VectorUnit(p.physicsBody.velocity);
            [p.physicsBody applyImpulse:VectorMultiply(direction, magnitude)];
        }
    }
}

@end
