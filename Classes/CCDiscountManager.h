//
//  CCDiscountManager.h
//  coke
//
//  Created by Franky on 2/25/11.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCNetworkAPI.h"
#import "ZSAlertView.h"

@interface CCDiscountManager : NSObject 
{
	NSTimer *timer;
	NSDictionary *currentDiscountDict;
	NSManagedObject *currentObject;
	ZSAlertView *currentDiscountAlertview;
}
- (void)startTimer;
- (void)stopTimer;
- (void)onTick:(id)sender;
- (void)gotDiscount:(NSDictionary *)dict forceShowOldMessage:(BOOL)yOrN;
- (void)invalidateCoupon:(NSString *)cokesId;
- (void)waitForFacebookLoginAndRetryPublish;
+ (id)sharedManager;
@end
