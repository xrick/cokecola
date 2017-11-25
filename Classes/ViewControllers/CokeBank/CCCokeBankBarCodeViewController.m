//
//  CCCokeBankBarCodeViewController.m
//  coke
//
//  Created by John on 2011/2/18.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import "CCCokeBankBarCodeViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"

@implementation CCCokeBankBarCodeViewController

- (void)dealloc 
{
	//	ZSLog(@"CCCokeBankBarCodeViewController deallocing...");
//	[self invalidateCoupon];
	[currentDataDict release];
	[currentCokeId release];
    [super dealloc];
}


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithCokeID:(NSString *)cokeId
{
    self = [super initWithNibName:@"CCCokeBankBarCodeViewController" bundle:nil];
    if (self) {
        currentCokeId = [[NSString alloc] initWithFormat:@"%@",cokeId];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	// UserCokeID : saveCoke時拿到
	[[CCNetworkAPI requestToURL:kNetworkAPIBaseURL delegate:self] getSingleCokeWithCokeID:currentCokeId action:CCSingleCokeActionCoupoun];

}

-(IBAction)sendGoBottleNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:CCCokeBankShouldGoBottleNotification object:nil];
}

-(IBAction)sendGoIntroNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:CCCokeBankShouldGoIntroNotification object:nil];
}
-(void)resetContentSize
{
	subContainer.frame = CGRectMake(0, 0, 320, 400 + discountHelpImageView.frame.size.height);
	[scrollView setContentSize:subContainer.frame.size];
	
}


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
	if (currentDataDict) {
		[currentDataDict release];
		currentDataDict = nil;
	}

	currentDataDict = [[NSDictionary alloc] initWithDictionary:dict];
    if ([dict objectForKey:@"new_serial_name"] && ![[NSString stringWithFormat:@"%@",[dict objectForKey:@"new_serial_name"]] isEqualToString:@"null"]) {
        serialNameLabel.text = [dict objectForKey:@"new_serial_name"];
        serialNumberLabel.hidden = NO;
		NSMutableString *serialStrings = [NSMutableString string];
		for (int i=0; i<[[dict objectForKey:@"new_serial_number"] count]; i++) {
			[serialStrings appendFormat:@"%@\n",[[dict objectForKey:@"new_serial_number"] objectAtIndex:i]];
		}
		serialNumberLabel.text = serialStrings;
		platformLabel.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"new_serial_brand"]];
		discountDateLabel.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"new_serial_time"]];
		discountDescriptionTextView.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"new_serial_description"]];
		NSString *imageURL = [NSString stringWithFormat:@"%@",[dict	objectForKey:@"new_serial_helpimage"]];
//		NSData *couponImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL] options:NSDataReadingUncached error:nil];
//		discountHelpImageView.image = [UIImage imageWithData:couponImageData];
		serialNumberStaticTitleLabel.hidden = NO;
		serialNumberLabel.hidden = NO;
		platformLabel.hidden = NO;
		platformStaticTitleLabel.hidden = NO;
		discountDateStaticTitleLabel.hidden = NO;
		discountDateLabel.hidden = NO;
		discountDescriptionStaticTitleLabel.hidden = NO;
		discountDescriptionTextView.hidden = NO;
		__block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imageURL] usingCache:[ASIDownloadCache sharedCache] andCachePolicy:ASIUseDefaultCachePolicy];
		[request setCompletionBlock:^{
			[discountHelpImageView performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageWithData:[request responseData]] waitUntilDone:YES];
			[discountHelpImageView sizeToFit];
			if (discountHelpImageView.frame.size.width > 300) {
				int scale = discountHelpImageView.frame.size.width / 300;
				discountHelpImageView.frame = CGRectMake(discountHelpImageView.frame.origin.x, discountHelpImageView.frame.origin.y, discountHelpImageView.frame.size.width / scale, discountHelpImageView.frame.size.height / scale);
			}
			else {
				discountHelpImageView.center = CGPointMake(160, 400 + discountHelpImageView.frame.size.height / 2);
			}
			[self performSelectorOnMainThread:@selector(resetContentSize) withObject:nil waitUntilDone:NO];

		}];
		[request setFailedBlock:^{
			ZSLog(@"fetch image failed at :%@", imageURL);
		}];
		[request startAsynchronous];
    }
    else
    {
        serialNameLabel.text = @"目前無優惠券可使用";
    }

    /*
//	barcodeNumberLabel.text = [dict objectForKey:@"barcode_number"];
	barCodeDescription.text = [dict objectForKey:@"coupoun_description"];
	barcodeNameLabel.text = [(NSString *)[dict objectForKey:@"coupoun_name"] stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
	barCodeTimeLabel.text = [NSString stringWithFormat:@"%@ - %@",[dict objectForKey:@"coupoun_timeBegin"],[dict objectForKey:@"coupoun_timeEnd"]];
	
	if (![[dict objectForKey:@"coupoun_name"] isEqualToString:@"null"]) {
		[barCodeDescription setHidden:NO];
		[barCodeTimeLabel setHidden:NO];
		[countDownLabel setHidden:NO];
		if (![[dict objectForKey:@"coupoun_timeBegin"] isEqualToString:@"null"]) {
			discountDateLabel.hidden = NO;
		}
		if (![[dict objectForKey:@"coupoun_description"] isEqualToString:@"null"]) {
			discountDescriptionLabel.hidden = NO;
		}
		NSData *couponImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[dict objectForKey:@"coupoun_image"]] options:NSDataReadingUncached error:nil];
		couponHelpImageView.image = [UIImage imageWithData:couponImageData];
	}
	else {
		barcodeNameLabel.text = @"目前無優惠券可使用";
	}
     */
	[request release];
}

- (void)request:(CCNetworkAPI *)request didFailGetSingleCokeWithError:(NSError *)error
{
	ZSLog(@"didFailGetSingleCokeWithError: %@", error);
	ZSAlertView *alert = [[ZSAlertView alloc] initWithTitle:nil message:@"發生網路錯誤無法取得資訊，請稍後再試" delegate:nil cancelButtonTitle:@"確定" otherButtonTitles:nil];
	[alert show];
	[alert release];
	[request release];
	serialNameLabel.text = @"目前無優惠券可使用";
}

#pragma mark CCNetworkDelegate
- (void)request:(CCNetwork *)request hadStatusCodeError:(NSError *)error
{
	ZSLog(@"hadStatusCodeError: %@", error);
	ZSAlertView *alert = [[ZSAlertView alloc] initWithTitle:nil message:@"發生網路錯誤無法取得資訊，請稍後再試" delegate:nil cancelButtonTitle:@"確定" otherButtonTitles:nil];
	[alert show];
	[alert release];
	[request release];
	serialNameLabel.text = @"目前無優惠券可使用";
}


@end
