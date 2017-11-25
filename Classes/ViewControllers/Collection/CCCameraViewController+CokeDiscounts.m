//
//  CCCameraViewController+CokeDiscounts.m
//  coke
//
//  Created by John on 2011/2/13.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#if !TARGET_IPHONE_SIMULATOR
#import "CCCameraViewController+CokeDiscounts.h"
#import "CCNetworkAPI.h"


@implementation CCCameraViewController (CokeDiscounts)
-(void)pauseSessionAndShowCokeDiscount
{
	[captureManager.session stopRunning];
	[self showLoadingDiscountAlert];
	aimImageView.hidden = YES;
	[[CCNetworkAPI requestToURL:kNetworkAPIBaseURL delegate:self] getDiscountForLogoWithLongtitude:[[ZSLocationManager sharedManager] longitude] latitude:[[ZSLocationManager sharedManager] latitude] flag:@"coke"];
}

-(void)showLoadingDiscountAlert
{
	alert = [[[ZSAlertView alloc] initWithTitle:@"下載優惠資訊中\n請稍候..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] autorelease];
	[alert show];
	UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	// Adjust the indicator so it is up a few pixels from the bottom of the alert
	indicator.center = CGPointMake(alert.bounds.size.width / 2, alert.bounds.size.height - 50);
	[indicator startAnimating];
	[alert addSubview:indicator];
	[indicator release];
}

-(void)hideLoadingDiscountAlert
{
	[alert dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark ZSAlertViewDelegate
-(void) alertView:(ZSAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	NSString *string = [alertView buttonTitleAtIndex:buttonIndex];
	if ([string isEqualToString:@"確定"]) { // normal message
		[self resumeSession];
		return;
	}
}
#pragma mark CCNetworkAPIDelegate

- (void)request:(CCNetworkAPI *)request didGetDiscountForLogo:(NSDictionary *)dict
{
	[self hideLoadingDiscountAlert];
	NSString *errorString = [dict objectForKey:@"error"];
	if (errorString) {
		ZSLog(@"errorString:%@",errorString);
		ZSAlertView *av = [[ZSAlertView alloc] initWithTitle:@"錯誤" message:errorString delegate:nil cancelButtonTitle:@"確認" otherButtonTitles:nil];
		[av show];
		[av autorelease];
		[self dismiss];
		return;
	}
	NSDictionary *dictionaryData = [NSDictionary dictionaryWithDictionary:dict];
	[self.navigationController dismissModalViewControllerAnimated:NO];
	[[CCDiscountManager sharedManager] gotDiscount:dictionaryData forceShowOldMessage:YES];
	[request release];
}

- (void)request:(CCNetworkAPI *)request didFailGetDiscountForLogoWithError:(NSError *)error
{
	ZSLog(@"didFailGetDiscountForLogoWithError: %@", error);
	ZSAlertView *av = [[ZSAlertView alloc] initWithTitle:@"錯誤" message:@"請檢查網路連線" delegate:nil cancelButtonTitle:@"確認" otherButtonTitles:nil];
	[av show];
	[av autorelease];
	[request release];
	[self dismiss];
}

@end
#endif
