//
//  CCDiscountManager.m
//  coke
//
//  Created by Franky on 2/25/11.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//


#import "ZSLocationManager.h"
#import "CCDiscountDetailViewController.h"
#import "cokeAppDelegate.h"

#define kDiscountIndex 3

@implementation CCDiscountManager

- (void)startTimer
{
	if (timer) {
		[timer invalidate];
		timer = nil;
	}
	timer = [NSTimer scheduledTimerWithTimeInterval:5 * 60.0f target: self selector:@selector(onTick:) userInfo: nil repeats:YES];
//	[self onTick:nil];
}

- (void)stopTimer
{
	[timer invalidate];
	timer = nil;
}

- (void)gotDiscount:(NSDictionary *)dict forceShowOldMessage:(BOOL)yOrN
{
	ZSLog(@"gotDiscount: %@", dict);
	if (currentDiscountDict) {
		[currentDiscountDict release];
		currentDiscountDict = nil;
	}
	currentDiscountDict = [[NSDictionary alloc] initWithDictionary:dict];
	NSString *errorString = [dict objectForKey:@"error"];
	if (errorString) {
		ZSLog(@"didGetDiscountForLogo -> error:%@",errorString);
//		ZSAlertView *alert = [[ZSAlertView alloc] initWithTitle:@"錯誤" message:errorString delegate:nil cancelButtonTitle:@"確定" otherButtonTitles:nil];
//		[alert show];
//		[alert release];
		return;
	}
	NSString *message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"message"]];
	NSAssert([[message substringToIndex:2] isEqualToString:@"OK"],@"gotDiscount: message not OK");
	BOOL isExist = [[CoreDataManager sharedManager] isExistDiscountForDict:currentDiscountDict];

	NSManagedObject *obj = [[CoreDataManager sharedManager] addDiscount:currentDiscountDict];
	if (currentObject) {
		[currentObject release];
		currentObject = nil;
	}
	currentObject = [obj retain];
	if (isExist) {
		if (!yOrN) {
			return; // already exist but no showing
		}
	}
	NSString *discount_name = [NSString stringWithFormat:@"%@",[dict objectForKey:@"discount_name"]];
	NSString *discountMsg_image = [NSString stringWithFormat:@"%@",[dict objectForKey:@"discountMsg_image"]];
	NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:discountMsg_image] options:NSDataReadingUncached error:nil];
	UIImageView *headerImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AlertHeader.png"]] autorelease];
	UIImageView *discountImageView = [[[UIImageView alloc] initWithImage:[UIImage imageWithData:imageData]] autorelease];
	//remove previous alert
	[currentDiscountAlertview dismissWithClickedButtonIndex:2 animated:NO];
	[currentDiscountAlertview release];
	currentDiscountAlertview = nil;
	//create new alert
	currentDiscountAlertview = [[ZSAlertView alloc] init];
	[currentDiscountAlertview addSubview:headerImageView];
	[currentDiscountAlertview addSubview:discountImageView];
	[currentDiscountAlertview setMessage:[NSString stringWithFormat:@"\n\n\n\n%@",discount_name]];
	[currentDiscountAlertview addButtonWithTitle:@"觀看詳情"];
	[currentDiscountAlertview addButtonWithTitle:@"發佈訊息"];
	[currentDiscountAlertview addButtonWithTitle:@"關閉"];
	[currentDiscountAlertview setDelegate:self];
	[currentDiscountAlertview show];
	headerImageView.center = CGPointMake(143, 20);
	[discountImageView sizeToFit];
	CGRect discountImageViewRect = discountImageView.frame;
	float scale = discountImageViewRect.size.height / 50.0f;
    if (scale != 0) {
        discountImageViewRect.size.width /= scale; 
        discountImageViewRect.size.height /= scale; 
        discountImageView.frame = discountImageViewRect;
    }
    discountImageView.center = CGPointMake(143, discountImageView.frame.size.height / 2 + 40);
}

- (void)onTick:(id)sender
{
	ZSLocationManager *loc = [ZSLocationManager sharedManager];
	[[CCNetworkAPI requestToURL:kNetworkAPIBaseURL delegate:self] getDiscountTimeWithLongtitude:loc.longitude latitude:loc.latitude];
}
-(void)invalidateCoupon:(NSString *)cokesId
{
	ZSLog(@"invalidating Coupon : cokesid %@",cokesId);
	[[CCNetworkAPI requestToURL:kNetworkAPIBaseURL delegate:self] delCouponWithUserCokesID:cokesId];
}
#pragma mark ZSAlertViewDelegate
-(void) alertView:(ZSAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	NSLog(@"didDismissWithButtonIndex");
	switch (buttonIndex) {
		case 0:
			// 觀看詳情
		{
			CCDiscountDetailViewController *vc = [[CCDiscountDetailViewController alloc] initWithManagedObject:currentObject];
			UITabBarController *tabbarController = [(cokeAppDelegate *)[[UIApplication sharedApplication] delegate] tabBarController];	
			UIViewController *discountVC = [[tabbarController viewControllers] objectAtIndex:kDiscountIndex];
			UINavigationController *naVC = [[UINavigationController alloc] initWithRootViewController:vc];
			[discountVC presentModalViewController:naVC animated:YES];
			[tabbarController setSelectedViewController:discountVC];
			[vc release];
			[naVC release];
		}	
			break;
		case 1:
			// 發佈訊息
			if ([[FaceBookManager sharedManager] isLoggedIn]) {
				[[FaceBookManager sharedManager] performSelectorOnMainThread:@selector(postDiscountWithDictionary:) withObject:currentDiscountDict waitUntilDone:NO];
			}
			else {
				[self performSelector:@selector(waitForFacebookLoginAndRetryPublish) withObject:nil afterDelay:1.0f];
			}
			break;
		case 2:
			//dismiss alertView
			break;
		default:
			break;
	}
}
- (void)waitForFacebookLoginAndRetryPublish
{
	[[FaceBookManager sharedManager] login];
	[currentDiscountAlertview show];
}

#pragma mark CCNetworkAPIDelegate
- (void)request:(CCNetworkAPI *)request didGetDiscountTime:(NSDictionary *)dict
{
	ZSLog(@"didGetDiscountTime:%@",dict);
	NSString *errorString = [dict objectForKey:@"error"];
	if (!errorString) {
		[self gotDiscount:dict forceShowOldMessage:NO];
	}
}

- (void)request:(CCNetworkAPI *)request didFailGetDiscountTimeWithError:(NSError *)error
{
	ZSLog(@"didFailGetDiscountTimeWithError:%@",error);
}
- (void)request:(CCNetworkAPI *)request didDelCoupon:(NSDictionary *)dict
{
	ZSLog(@"didDelCoupon:%@",dict);
}
- (void)request:(CCNetworkAPI *)request didFailDelCouponWithError:(NSError *)error
{
	ZSLog(@"didFailDelCouponWithError:%@",error);
}

- (void)request:(CCNetwork *)request hadStatusCodeError:(int)errorCode
{
	ZSLog(@"hadStatusCodeError: %d", errorCode);
}


#pragma mark Singleton Methods
+ (id)sharedManager
{
	static CCDiscountManager *sharedLocationManager = nil;
	if (!sharedLocationManager) {
		sharedLocationManager = [[CCDiscountManager alloc] init];
	}
	return sharedLocationManager;
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
