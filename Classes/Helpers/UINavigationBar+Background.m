//
//  UINavigationBar+Background.m
//  coke
//
//  Created by Franky on 3/14/11.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import "UINavigationBar+Background.h"

@implementation UINavigationBarBackgroundManager
@synthesize backgroundImageName;
@synthesize defaultImageName;
@synthesize useImage;

#pragma mark Singleton Methods
- (id) init
{
	self = [super init];
	if (self != nil) {
		useImage = NO;
		defaultImageName = [[NSString alloc] initWithString:@"DefaultNavBar.png"];
	}
	return self;
}


+ (id)sharedManager
{
	static UINavigationBarBackgroundManager *sharedManager = nil;
	if (!sharedManager) {
		sharedManager = [[UINavigationBarBackgroundManager alloc] init];
	}
	return sharedManager;
}

- (id)retain 
{
	return self;
}

- (unsigned)retainCount 
{
	return UINT_MAX; // denotes an object that cannot be released
}

- (void)release 
{
	// never release
}

- (id)autorelease 
{
	return self;
}	


@end

@implementation UINavigationBar (Background)
- (void)drawRect:(CGRect)rect
{  
	UINavigationBarBackgroundManager *manager = [UINavigationBarBackgroundManager sharedManager];
	if ([manager useImage]) {
		UIImage *image = [UIImage imageNamed:manager.backgroundImageName];
		[image drawInRect:rect];
	}
	else {
		UIImage *image = [UIImage imageNamed:manager.defaultImageName];
		[image drawInRect:rect];
	}

}
@end  
