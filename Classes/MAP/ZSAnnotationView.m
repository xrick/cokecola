//
//  ZSAnnotationView.m
//  coke
//
//  Created by Franky on 2/24/11.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import "ZSAnnotationView.h"


@implementation ZSAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)identifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:identifier];
    if (self != nil) {
//		UIButton *annButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//		[annButton setFrame:CGRectMake(0, 0, 23, 23)];
//		[annButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
//		[annButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
//		[self setRightCalloutAccessoryView:annButton];
		self.canShowCallout = YES;
        self.multipleTouchEnabled = NO;
		
        self.frame = CGRectMake(0, 0, 65, 100);
        self.backgroundColor = [UIColor clearColor];        
		
        return self;
    }
    return nil;
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
	
    CGPoint drawPoint = CGPointMake(0.0f, 0.0f);
	
//    UIImage *shadowImage = [UIImage imageNamed:@"shadow_image.png"];
//    [shadowImage drawAtPoint:drawPoint];
	
    UIImage *frontImage = [UIImage imageNamed:@"cokeAnnotation.png"];
	[frontImage drawAtPoint:drawPoint];
	
    CGContextRestoreGState(context);
}
@end
