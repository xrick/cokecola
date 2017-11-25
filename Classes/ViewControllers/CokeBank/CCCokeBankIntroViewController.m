//
//  CCCokeBankIntroViewController.m
//  coke
//
//  Created by John on 2011/2/18.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import "CCCokeBankIntroViewController.h"
#import "CCNetworkAPI.h"

@implementation CCCokeBankIntroViewController

- (void)dealloc 
{
//	ZSLog(@"CCCokeBankIntroViewController deallocing...");
	[currentCokeId release];
    [super dealloc];
}

- (id)initWithCokeID:(NSString *)cokeId
{
    self = [super initWithNibName:@"CCCokeBankIntroViewController" bundle:nil];
    if (self) {
        currentCokeId = [[NSString alloc] initWithFormat:@"%@",cokeId];
    }
    return self;
}

-(IBAction)sendGoBottleNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:CCCokeBankShouldGoBottleNotification object:nil];
}
-(IBAction)sendGoBarCodeNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:CCCokeBankShouldGoBarCodeNotification object:nil];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[scrollView setContentSize:subContainer.frame.size];
//	[introWebView loadHTMLString:@"資料載入中..." baseURL:nil];
	[[CCNetworkAPI requestToURL:kNetworkAPIBaseURL delegate:self] getSingleCokeWithCokeID:currentCokeId action:CCSingleCokeActionDescription];

}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark CCNetworkAPIDelegate
- (void)request:(CCNetworkAPI *)request didGetSingleCoke:(NSDictionary *)dict
{
	ZSLog(@"didGetSingleCoke: %@", dict);
	if ([[dict objectForKey:@"coke_description"] isKindOfClass:NSClassFromString(@"NSNull")]) {
		introTextView.text = @"伺服器錯誤";
		//[introWebView loadHTMLString:@"伺服器錯誤" baseURL:nil];
	}
	else {
		if ([dict objectForKey:@"coke_description"]) {
			introTextView.text = [dict objectForKey:@"coke_description"];
		}
//		NSString *htmlString = [NSString stringWithFormat:@"%@<br>",[dict objectForKey:@"coke_description"]];
//		if ([dict objectForKey:@"coke_dsrp"]) {
//			htmlString = [htmlString stringByAppendingFormat:@"<br><img src='%@'>",[dict objectForKey:@"coke_dsrp"]];
//		}
//		[introWebView loadHTMLString:htmlString baseURL:nil];
		//introTextView.text = ;
	}
	NSData *dsrpImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[dict objectForKey:@"coke_dsrp"]] options:NSDataReadingUncached error:nil];
	[cokeBottleIntroductionImageView setImage:[UIImage imageWithData:dsrpImageData]];
	[request release];
}

- (void)request:(CCNetworkAPI *)request didFailGetSingleCokeWithError:(NSError *)error
{
	ZSLog(@"didFailGetSingleCokeWithError: %@", error);
	ZSAlertView *alert = [[ZSAlertView alloc] initWithTitle:nil message:@"發生網路錯誤無法取得資訊，請稍後再試" delegate:nil cancelButtonTitle:@"確定" otherButtonTitles:nil];
	[alert show];
	[alert release];
	[request release];
}

#pragma mark CCNetworkDelegate
- (void)request:(CCNetwork *)request hadStatusCodeError:(int)errorCode
{
	ZSLog(@"hadStatusCodeError: %d", errorCode);
	ZSAlertView *alert = [[ZSAlertView alloc] initWithTitle:nil message:@"發生網路錯誤無法取得資訊，請稍後再試" delegate:nil cancelButtonTitle:@"確定" otherButtonTitles:nil];
	[alert show];
	[alert release];
	[request release];
}


@end
