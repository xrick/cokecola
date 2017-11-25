//
//  ZSAlertView.h
//  alertViewTest
//
//  Created by Hsu John on 2011/3/31.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#if NS_BLOCKS_AVAILABLE

typedef void (^ZSBlock)(void);

@interface ZSBlockActionAlert : NSObject <UIAlertViewDelegate> 
{
	ZSBlock _block1;
	ZSBlock _block2;
	UIAlertView *_alertView;
}
+(void)showAlertViewWithTitle:(NSString *)inTitle message:(NSString *)inMessage button1:(NSString *)btn1 button2:(NSString *)btn2 block1:(ZSBlock)block1 block2:(ZSBlock)block2;

@property(nonatomic,assign)ZSBlock _block1;
@property(nonatomic,assign)ZSBlock _block2;
@property(nonatomic,retain)UIAlertView *_alertView;

@end
#endif