//
//  ZSAlertView.m
//  alertViewTest
//
//  Created by Hsu John on 2011/3/31.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ZSBlockActionAlert.h"
#if NS_BLOCKS_AVAILABLE


@implementation ZSBlockActionAlert
@synthesize _block1,_block2,_alertView;

-(void) dealloc
{
	[_block1 release];
	_block1 = nil;
	[_block2 release];
	_block2 = nil;

	_alertView.delegate = nil;
	self._alertView = nil; // release by retain property
	[super dealloc];
}

+(void)showAlertViewWithTitle:(NSString *)inTitle message:(NSString *)inMessage button1:(NSString *)btn1 button2:(NSString *)btn2 block1:(ZSBlock)block1 block2:(ZSBlock)block2
{
	ZSBlockActionAlert *zsBlockActionAlert = [[ZSBlockActionAlert alloc] init];
	zsBlockActionAlert._alertView = [[UIAlertView alloc] initWithTitle:inTitle message:inMessage delegate:zsBlockActionAlert cancelButtonTitle:btn1 otherButtonTitles:btn2,nil];
	zsBlockActionAlert._block1 = [block1 copy];
	zsBlockActionAlert._block2 = [block2 copy];
	[zsBlockActionAlert._alertView show];
}
-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0 && _block1 != nil) {
		_block1();
	}
	if (buttonIndex == 1 && _block2 != nil) {
		_block2();
	}
	[self autorelease];
}
@end
#endif
