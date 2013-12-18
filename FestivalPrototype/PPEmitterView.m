//
// PPEmitterView.h
// Created by Particle Playground on 18/12/2013
//

#import "PPEmitterView.h"

@implementation PPEmitterView

-(id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		self.backgroundColor = [UIColor clearColor];
        CAEmitterLayer *emitterLayer = (CAEmitterLayer*)self.layer;
        
        emitterLayer.name = @"emitterLayer";
        emitterLayer.emitterPosition = CGPointMake(74, 0);
        emitterLayer.emitterZPosition = 0;
        
        emitterLayer.emitterSize = CGSizeMake(1.00, 1.00);
        emitterLayer.emitterDepth = 0.00;
        
        emitterLayer.renderMode = kCAEmitterLayerAdditive;
        
        emitterLayer.seed = 1556044496;

        // Create the emitter Cell
        CAEmitterCell *emitterCell = [CAEmitterCell emitterCell];
        
        emitterCell.name = @"untitled";
        emitterCell.enabled = YES;
        
        emitterCell.contents = (id)[[UIImage imageNamed:@"notes.png"] CGImage];
        emitterCell.contentsRect = CGRectMake(0.00, 0.00, 1.00, 1.00);
        
        emitterCell.magnificationFilter = kCAFilterLinear;
        emitterCell.minificationFilter = kCAFilterLinear;
        emitterCell.minificationFilterBias = 0.00;
        
        emitterCell.scale = 0.3;
        emitterCell.scaleRange = 0.08;
        emitterCell.scaleSpeed = 0.10;
        
        emitterCell.color = [[UIColor colorWithRed:0.50 green:0.50 blue:0.50 alpha:1.00] CGColor];
        emitterCell.redRange = 1.00;
        emitterCell.greenRange = 0.25;
        emitterCell.blueRange = 1.00;
        emitterCell.alphaRange = 0.00;
        
        emitterCell.redSpeed = 0.00;
        emitterCell.greenSpeed = 0.00;
        emitterCell.blueSpeed = 0.00;
        emitterCell.alphaSpeed = 0.00;
        
        emitterCell.lifetime = 3.00;
        emitterCell.lifetimeRange = 0.50;
        emitterCell.birthRate = 1;
        emitterCell.velocity = 20.00;
        emitterCell.velocityRange = 10.00;
        emitterCell.xAcceleration = 0.00;
        emitterCell.yAcceleration = 0.00;
        emitterCell.zAcceleration = 0.00;
        
        // these values are in radians, in the UI they are in degrees
        emitterCell.spin = 0.000;
        emitterCell.spinRange = 0.052;
        emitterCell.emissionLatitude = 3.142;
        emitterCell.emissionLongitude = 1.571;
        emitterCell.emissionRange = 1.571;
        
        emitterLayer.emitterCells = @[emitterCell];
	}
	
	return self;
}

+ (Class) layerClass {
    return [CAEmitterLayer class];
}

@end
