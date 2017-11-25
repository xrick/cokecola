//
//  CCCokeDetailViewController.m
//  coke
//
//  Created by John on 2011/2/10.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import "CCCokeBankBottleViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CCNetworkAPI.h"

@implementation CCCokeBankBottleViewController

- (void)dealloc 
{
	[self.view removeGestureRecognizer:panGesture];
	panGesture.delegate = nil;
	[panGesture release];
//	ZSLog(@"CCCokeBankBottleViewController deallocing...");
	[bottleDataArray release];
//	[barCodeVC.view removeFromSuperview];
//	[introVC.view removeFromSuperview];
	[introVC release];
	[barCodeVC release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[currentCokeId release];
	[currentCokeName release];
    [super dealloc];
}

- (id)initWithCokeDict:(NSDictionary *)dict
{
    self = [super initWithNibName:@"CCCokeBankBottleViewController" bundle:nil];
    if (self) {
		NSString *coke_id = [dict objectForKey:@"coke_id"];
		NSString *coke_name = [dict objectForKey:@"coke_name"];
		self.title = coke_name;
		currentCokeName = [[NSString alloc] initWithFormat:@"%@",coke_name];
		currentCokeId = [[NSString alloc]initWithFormat:@"%@", coke_id];		
		barCodeVC = [[CCCokeBankBarCodeViewController alloc] initWithCokeID:currentCokeId];
		introVC = [[CCCokeBankIntroViewController alloc] initWithCokeID:currentCokeId];
		currentBottleImageNumber = 1;
    }
    return self;
}

- (NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)dismiss
{
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationController.navigationBar.tintColor = [UIColor redColor];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)] autorelease];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpToBarCode) name:CCCokeBankShouldGoBarCodeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpToBottle) name:CCCokeBankShouldGoBottleNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpToIntro) name:CCCokeBankShouldGoIntroNotification object:nil];
	[[CCNetworkAPI requestToURL:kNetworkAPIBaseURL delegate:self] getSingleCokeWithCokeID:currentCokeId action:CCSingleCokeActionStyle];
	
	panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPiece:)];
    [panGesture setMaximumNumberOfTouches:2];
    [panGesture setDelegate:self];
    [self.view addGestureRecognizer:panGesture];
}

-(void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	superView = self.view.superview;
}
-(void)moveToLastImage
{
	currentBottleImageNumber -= 1;
	if (currentBottleImageNumber < 1) {
		currentBottleImageNumber = [bottleDataArray count];
	}
//	ZSLog(@"currentBottleImageNumber : %d",currentBottleImageNumber);
	bottleImageView.image = [UIImage imageWithData:[bottleDataArray objectAtIndex:(currentBottleImageNumber - 1)]];
}

-(void)moveToNextImage
{
	currentBottleImageNumber += 1;
//	if (currentBottleImageNumber > maxNumberOfBottleImage) {
	if (currentBottleImageNumber > [bottleDataArray count]) {
		currentBottleImageNumber = 1;
	}
//	ZSLog(@"currentBottleImageNumber : %d",currentBottleImageNumber);
	bottleImageView.image = [UIImage imageWithData:[bottleDataArray objectAtIndex:currentBottleImageNumber - 1]];
}

-(void)downloadBottleImageData:(NSString *)prefixURLString
{
	NSAssert(![[NSThread currentThread] isMainThread], @"run this in background");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *savePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:[prefixURLString lastPathComponent]];
//	NSLog(@"savePath: %@", savePath);
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSMutableArray *tempArray = nil;
	if ([fileManager fileExistsAtPath:savePath]) {
		tempArray = [NSMutableArray arrayWithContentsOfFile:savePath];
	}
	else {
		tempArray = [NSMutableArray arrayWithCapacity:maxNumberOfBottleImage];
		NSString *prefix = [NSString stringWithString:prefixURLString];
		for (int i = 1; i < 16; i++) {
			NSURL *url = [NSURL URLWithString:[prefix stringByAppendingFormat:@"%d_s.png", i]];
			NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:nil];
			if (data != nil) {
				[tempArray addObject:data];
			}
			else {
				ZSLog(@"URL can't download: %@", url);
			}

		}
		[tempArray writeToFile:savePath atomically:YES];
	}
	
	if (bottleDataArray) {
		[bottleDataArray release];
		bottleDataArray = nil;
	}
	if ([tempArray count] != 0) {
		bottleDataArray = [[NSArray alloc] initWithArray:tempArray];
		[bottleImageView performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageWithData:[bottleDataArray objectAtIndex:0]] waitUntilDone:NO];	
		loadingImageIndicatorLabel.hidden = YES;
	}
	else {
		loadingImageIndicatorLabel.text = @"下載失敗";
		[panGesture setDelegate:nil];
	}
	[pool release];
}

- (void)panPiece:(UIPanGestureRecognizer *)gestureRecognizer
{
	static CGPoint lastPanTranslation;
    UIView *piece = [gestureRecognizer view];
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
		float diff = translation.x - lastPanTranslation.x;
		// ZSLog(@"pan diff: %f",diff);
		if (diff > 0) {
			[self moveToNextImage];
		}
		if (diff < 0) {
			[self moveToLastImage];
		}
		lastPanTranslation = translation;
//        [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y + translation.y)];
//        [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];
    }
}

- (IBAction)jumpToIntro
{
	for (UIView *sView in [superView subviews]) {
		[sView removeFromSuperview];
	}
	[superView addSubview:introVC.view];
	
	// set up an animation for the transition between the views
//	CATransition *animation = [CATransition animation];
//	[animation setDuration:0.5];
//	[animation setType:kCATransitionPush];
//	[animation setSubtype:kCATransitionFromRight];
//	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
//	
//	[[superView layer] addAnimation:animation forKey:@"jumpToIntro"];	
}

- (IBAction)jumpToBarCode
{
	for (UIView *sView in [superView subviews]) {
		[sView removeFromSuperview];
	}
	[superView addSubview:barCodeVC.view];
	
	// set up an animation for the transition between the views
//	CATransition *animation = [CATransition animation];
//	[animation setDuration:0.5];
//	[animation setType:kCATransitionPush];
//	[animation setSubtype:kCATransitionFromRight];
//	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
//	
//	[[superView layer] addAnimation:animation forKey:@"jumpToBarCode"];
}

- (IBAction)jumpToBottle
{
	for (UIView *sView in [superView subviews]) {
		[sView removeFromSuperview];
	}
	[superView addSubview:self.view];
	
	// set up an animation for the transition between the views
//	CATransition *animation = [CATransition animation];
//	[animation setDuration:0.5];
//	[animation setType:kCATransitionPush];
//	[animation setSubtype:kCATransitionFromRight];
//	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
//	
//	[[superView layer] addAnimation:animation forKey:@"jumpToBottle"];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark CCNetworkAPIDelegate
- (void)request:(CCNetworkAPI *)request didGetSingleCoke:(NSDictionary *)dict
{
	ZSLog(@"didGetSingleCoke: %@", dict);
	[self performSelectorInBackground:@selector(downloadBottleImageData:) withObject:[dict objectForKey:@"images"]];
//	NSString *cokeURLPrefix = [NSString stringWithFormat:@"%@1_s.png",[dict objectForKey:@"images"]];
//	bottleImageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:cokeURLPrefix] options:NSDataReadingUncached error:nil];
//	bottleImageView.image = [UIImage imageWithData:bottleImageData];
//	loadingImageIndicatorLabel.hidden = YES;
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
- (void)request:(CCNetwork *)request hadStatusCodeError:(NSError *)error
{
	ZSLog(@"hadStatusCodeError: %@", error);
	ZSAlertView *alert = [[ZSAlertView alloc] initWithTitle:nil message:@"發生網路錯誤無法取得資訊，請稍後再試" delegate:nil cancelButtonTitle:@"確定" otherButtonTitles:nil];
	[alert show];
	[alert release];
	[request release];
}


@end
