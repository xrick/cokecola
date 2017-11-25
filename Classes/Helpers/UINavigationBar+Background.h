//
//  UINavigationBar+Background.h
//  coke
//
//  Created by Franky on 3/14/11.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UINavigationBarBackgroundManager : NSObject
{
	NSString *backgroundImageName;
	NSString *defaultImageName;
	BOOL useImage;
}
+ (id)sharedManager;
@property (nonatomic, retain) NSString *backgroundImageName;
@property (nonatomic, retain) NSString *defaultImageName;
@property (readwrite) BOOL useImage;
@end

@interface UINavigationBar (Background)
- (void)drawRect:(CGRect)rect;
@end

