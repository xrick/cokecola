//
//  CCCokeBankViewController.m
//  coke
//
//  Created by John on 2011/2/8.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import "CCCokeBankViewController.h"
#import "CCCokeBankBottleViewController.h"

@implementation CCCokeBankViewController
@synthesize _webView;

- (void)dealloc {
	[cokeArray release];
    [super dealloc];
}
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/
-(IBAction)showHelp
{
    CCHelpViewController *vc = [[CCHelpViewController alloc] init];
    [self.tabBarController presentModalViewController:vc animated:YES];
    [vc release];
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self reloadHTML];
	NSString *backgroundPath = [[NSBundle mainBundle] pathForResource:@"Background.png" ofType:nil];
	NSURL *backgroundURL = [NSURL fileURLWithPath:backgroundPath];
	NSString *htmlString = [NSString stringWithFormat:@"<body background='%@'>",[backgroundURL absoluteString]];
	[self.webView loadHTMLString:htmlString baseURL:nil];
	[self.webView setBackgroundColor:[UIColor redColor]];
}
-(void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	collectionCountLabel.text = @"載入中...";
	[self.webView loadHTMLString:@"正在讀取中，請稍候..." baseURL:nil];
	[[CCNetworkAPI requestToURL:kNetworkAPIBaseURL delegate:self] getAllCokes];
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

-(void)reloadHTML
{
	collectedCount = 0;
	NSString *backgroundPath = [[NSBundle mainBundle] pathForResource:@"CokeBankBG.png" ofType:nil];
	NSURL *backgroundURL = [NSURL fileURLWithPath:backgroundPath];
	NSString *backgroundAbsolutePathString = [backgroundURL absoluteString];
	NSMutableString *htmlString = [NSMutableString stringWithFormat:@"<body leftmargin='0px' topmargin='0px' marginheight='0px'><table cellpadding='0' cellspacing='0'>"];
	[htmlString appendFormat:@"<style>body { background-color:#FF0000;} a { color:#FFFFFF;font-family:Arial; text-decoration:none; font-size:13px; font-weight: bold; }</style>"];

	for (int counter=0; counter< [cokeArray count]; counter++) {
		NSDictionary *cokeData = [cokeArray objectAtIndex:counter];
		BOOL isGotten = [[cokeData objectForKey:@"isGotten"] boolValue];
		if (isGotten) {
			collectedCount ++;
		}
		
		if (counter % 3 == 0) {
			[htmlString appendFormat:@"<tr><td style='background-image:url(%@);' height='140' width='320'><table width='320'><tr'>", backgroundAbsolutePathString];
		}
		NSString *coke_icon = [cokeData objectForKey:@"coke_icon"];
		if (!isGotten) {
			NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"grayBottle.png" ofType:nil];
			coke_icon = [[NSURL fileURLWithPath:resourcePath] absoluteString];
		}
		NSString *coke_name = [cokeData objectForKey:@"coke_name"];
		NSString *coke_number = [cokeData objectForKey:@"coke_number"];
		[htmlString appendFormat:@"<td width='60'><center><a href='coke:%d'><img src='%@' width='34' height='117' /><br><b>%@ x%@</b></a></center></td>", counter, coke_icon, coke_name,coke_number];
		if (counter % 3 == 2) {
			[htmlString appendFormat:@"</tr></table></td></tr>"];
		}		
	}
	[htmlString appendFormat:@"</table></body>"];
	[self.webView loadHTMLString:htmlString baseURL:nil];
	collectionCountLabel.text = [NSString stringWithFormat:@"目前已收集%d款，共有%d款紀念造型",collectedCount,[cokeArray count]];
}

#pragma mark CCNetworkAPIDelegate
- (void)request:(CCNetworkAPI *)request didGetAllCokes:(NSDictionary *)dict
{
//	ZSLog(@"didGetAllCokes: %@", dict);
	NSString *message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"message"]];
	NSAssert([message isEqualToString:@"OK"],@"didGetAllCokes: message not OK");
	if (cokeArray) {
		[cokeArray release];
	}
	cokeArray = [[NSArray alloc] initWithArray:[dict objectForKey:@"coke"]];
//	ZSLog(@"%@",cokeArray);
	[self reloadHTML];
	[request release];

}

- (void)request:(CCNetworkAPI *)request didFailGetAllCokesWithError:(NSError *)error
{
	ZSLog(@"didFailGetAllCokesWithError: %@", error);
	collectionCountLabel.text = @"發生網路錯誤無法取得列表，請稍後再試";
	[request release];

}

- (void)request:(CCNetwork *)request hadStatusCodeError:(int)errorCode
{
	ZSLog(@"hadStatusCodeError: %d", errorCode);
	collectionCountLabel.text = @"發生網路錯誤無法取得列表，請稍後再試";
	[request release];

}

#pragma mark UIWebViewDelegate
-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSString *url = [[request URL] absoluteString];
//	ZSLog(@"webView shouldStartLoadWithRequest: \"%@\"",url);
	if ([url isEqualToString:@"about:blank"]) {
		return YES;
	}
	NSString *number = [url substringFromIndex:5];
	NSDictionary *cokeData = [cokeArray objectAtIndex:[number intValue]];
	BOOL isGotten = [[cokeData objectForKey:@"isGotten"] boolValue];
	if (!isGotten) {
		ZSAlertView *av = [[ZSAlertView alloc] initWithTitle:nil message:@"您尚未收集到此款紀念造型" delegate:nil cancelButtonTitle:@"確認" otherButtonTitles:nil];
		[av show];
		[av release];		
		return NO;
	}
	CCCokeBankBottleViewController *vc = [[CCCokeBankBottleViewController alloc] initWithCokeDict:cokeData];
	ZSLog(@"initWithCokeDict:%@",cokeData);
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
	[self presentModalViewController:nav animated:YES];
	[vc release];
	[nav release];
	return NO;
}
@end
