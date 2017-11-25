//
//  CCCameraViewController.m
//  coke
//
//  Created by Franky on 1/19/11.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import "CCCameraViewController.h"
#if !TARGET_IPHONE_SIMULATOR
#import "CCNetworkAPI.h"
#import "CCCameraViewController+CokeDiscounts.h"
#import "CCCokeBankBottleViewController.h"


static const int maxRetryCount = 3;

@implementation CCCameraViewController
@synthesize captureManager;
- (void) dealloc
{
	[hintImageView release];
	[currentCokeDictionary release];
	[dismissButton release];
//	[abandonCurrentImageButton release];
	if (bottleVC) {
		[bottleVC.view removeFromSuperview];
		[bottleVC release];
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	captureManager.delegate = nil;
	[captureManager release];
	[grayPreviewImageView removeFromSuperview];
	[grayPreviewImageView release];
	[statusLabel removeFromSuperview];
	[statusLabel release];
	
//	[bottomBarView removeFromSuperview];
//	[bottomBarView release];
	[aimImageView removeFromSuperview];
	[aimImageView release];
	[prevLayer removeFromSuperlayer];
	[prevLayer release];
	[motionManager stopAccelerometerUpdates];
	[motionManager release];
	[motionQueue release];
	[cokeBodyImageData release];
	[super dealloc];
}


- (id) init
{
	self = [super init];
	if (self != nil) {
		isCurrentViewActive = NO;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recievedEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
//		surfProcessor = [[ZSSURFProcessor alloc] init];
//		UIImage *model = [UIImage imageNamed:@"Coke_Model_Portrait.png"];
//		[surfProcessor addModelImage:[model cvGrayscaleImage]];
		motionQueue = [[NSOperationQueue alloc] init];
		motionManager = [[CMMotionManager alloc] init];
		sendCount = 0;
	}
	return self;
}

-(void)recievedEnterBackgroundNotification
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void) viewDidLoad
{
	[super viewDidLoad];
    didPlay = YES;
	self.navigationController.navigationBar.tintColor = [UIColor redColor];
	dismissButton = [[UIBarButtonItem alloc] initWithTitle:@"關閉" style:UIBarButtonItemStyleBordered target:self action:@selector(dismiss)];
//	abandonCurrentImageButton = [[UIBarButtonItem alloc] initWithTitle:@"放棄此瓶" style:UIBarButtonItemStyleBordered target:self action:@selector(resumeSession)];
	self.navigationItem.leftBarButtonItem = dismissButton;
	NSError *error = nil;
	captureManager = [[ZSAVCaptureManager alloc] init];
	if ([captureManager setupSessionWithPreset:AVCaptureSessionPresetMedium error:&error]) {
        [self setCaptureManager:captureManager];
		prevLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[captureManager session]];
		prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
		[self.view.layer addSublayer:prevLayer];
		
        if ([[captureManager session] isRunning]) {
            [captureManager setDelegate:self];
        } 
		else {
            ZSAlertView *alertView = [[ZSAlertView alloc] initWithTitle:@"無法開啟攝影機"
                                                                message:@"設定攝影機時發生錯誤"
                                                               delegate:nil
                                                      cancelButtonTitle:@"確定"
                                                      otherButtonTitles:nil];
            [alertView show];
            [alertView release];
        }
    } 
	else {
        ZSAlertView *alertView = [[ZSAlertView alloc] initWithTitle:@"無法開啟攝影機"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"確定"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];        
    }
	[captureManager release];
	
	
	grayPreviewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, outImageWidth, outImageHeight)];
	grayPreviewImageView.center = CGPointMake(160, 196);
#ifdef DEBUG
	[self.view addSubview:grayPreviewImageView];
#endif
	statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 380, 320, 30)];
	statusLabel.opaque = YES;
	statusLabel.backgroundColor = [UIColor whiteColor];
	statusLabel.textColor = [UIColor blackColor];
	statusLabel.textAlignment = UITextAlignmentRight;
#ifdef DEBUG
	[self.view addSubview:statusLabel];
#endif

	aimImageView = [[UIImageView alloc] initWithFrame:CGRectMake(80, 140, 200, 228)];
	aimImageView.center = CGPointMake(160, 196);
	[aimImageView setImage:[UIImage imageNamed:@"aim.png"]];
	[self.view addSubview:aimImageView];
	
//	bottomBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 370, 320, 50)];
//	bottomBarView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.8];
//	bottomBarView.opaque = YES;
	bottomBarStartButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[bottomBarStartButton setImage:[UIImage imageNamed:@"start-take.png"] forState:UIControlStateNormal];
	[bottomBarStartButton setFrame:CGRectMake(0, 0, 125, 40)];
//	bottomBarStartButton.center = CGPointMake(160, 25);

	bottomBarStartButton.center = CGPointMake(160, 480-20-44-20);
	[bottomBarStartButton addTarget:self action:@selector(startButtonAction) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:bottomBarStartButton];
//	[bottomBarView addSubview:bottomBarStartButton];
//	[self.view addSubview:bottomBarView];
		
//	hintImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"aim-txt.png"]];
//	[self.navigationItem.titleView addSubview:hintImageView];
//	hintImageView.center = CGPointMake(160, 19);
//	[self.view addSubview:hintImageView];
	
	
//	UILabel *hintLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
//	hintLabel.text = @"用方框對準招牌圖示或可口可樂標誌";
//	hintLabel.textAlignment = UITextAlignmentCenter;
//	hintLabel.textColor = [UIColor redColor];
//	[self.view addSubview:hintLabel];
	
}

-(void)startButtonAction
{
	[[UINavigationBarBackgroundManager sharedManager] setBackgroundImageName:[NSString stringWithString:@"aim-txt3.png"]];
	[self.navigationController.navigationBar setNeedsDisplay];
	networkSendLock = NO;
//	[bottomBarView removeFromSuperview];
	NSMutableArray *imageArray = [NSMutableArray array];
	for (int i=1; i<9; i++) {
		UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"Detect0%d.png",i]];
		[imageArray addObject:image];
	}
	[imageArray addObject:[UIImage imageNamed:@"Detect10.png"]];
	[imageArray addObject:[UIImage imageNamed:@"Detect11.png"]];
	[imageArray addObject:[UIImage imageNamed:@"Detect12.png"]];

	[aimImageView setAnimationImages:imageArray];
	[aimImageView startAnimating];
	aimImageView.frame = CGRectMake(0, 0, 180, 220);
	aimImageView.center = CGPointMake(160, 196+26);
	bottomBarStartButton.hidden = YES;
}

-(void)fitPreviewLayer
{
	CGSize originalImageSize = captureManager.originalImageSize;
	prevLayer.frame = CGRectMake(160 - originalImageSize.width / 2, 196 - originalImageSize.height / 2, originalImageSize.width, originalImageSize.height);
}

-(void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[[UINavigationBarBackgroundManager sharedManager] setBackgroundImageName:[NSString stringWithString:@"aim-txt.png"]];
	[[UINavigationBarBackgroundManager sharedManager] setUseImage:YES];
	[self.navigationController.navigationBar setNeedsDisplay];
}

-(void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
//	self.navigationController.navigationBarHidden = YES;
	[captureManager.session startRunning];
	if ([[captureManager session] isRunning]) {
		[captureManager setDelegate:self];
	}
	else {
		ZSAlertView *alertView = [[ZSAlertView alloc] initWithTitle:@"Failure"
															message:@"Failed to start session."
														   delegate:nil
												  cancelButtonTitle:@"Okay"
												  otherButtonTitles:nil];
		[alertView show];
		[alertView release];		
	}
	networkSendLock = YES;
	isCurrentViewActive = YES;
	bottomBarStartButton.hidden = NO;
//	[self.view addSubview:bottomBarView];
	aimImageView.hidden = NO;
}
-(void) viewWillDisappear:(BOOL)animated
{
	[[UINavigationBarBackgroundManager sharedManager] setUseImage:NO];
	[self.navigationController.navigationBar setNeedsDisplay];
//	self.navigationController.navigationBarHidden = NO;
	[captureManager.session stopRunning];
	isCurrentViewActive = NO;
	captureManager.delegate = nil;
	[super viewWillDisappear:animated];
}

-(void)dismiss
{
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark ZSAVCaptureManagerDelegate
//- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleImage:(IplImage *)image
//{
//	// Get the output image here!
//	// ZSLog(@"didOutputSampleImage: %@", image);
//	[grayPreviewImageView performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageWithGralyScaleCVImage:image] waitUntilDone:NO];
//	[currentTimeLabel performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"Current %@",[NSDate date]] waitUntilDone:NO];
////	NSData *dataToSend = UIImageJPEGRepresentation(image, 1.0f);
////	ZSLog(@"the image data is in %d KB size",[dataToSend length] / 1024);
//	int detectPairs = [surfProcessor compareWithImage:image];
//	ZSLog(@"detectPairs: %d", detectPairs);
//}

- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleImage:(UIImage *)image
{
	[self performSelectorOnMainThread:@selector(fitPreviewLayer) withObject:nil waitUntilDone:NO];
	if (!networkSendLock && isCurrentViewActive) {
		NSData *dataToSend = UIImageJPEGRepresentation(image, 1.0f);
//		NSString *base64String = [dataToSend base64EncodedString];
		[grayPreviewImageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
//		ZSLog(@"The image data size is %d KB",[base64String length] / 1024);
//		[[CCNetworkImageService requestToURL:kNetworkImageServiceBaseURL delegate:self] postImageData:[base64String dataUsingEncoding:NSASCIIStringEncoding]];
		[[CCNetworkImageService requestToURL:kNetworkImageServiceBaseURL delegate:self] postImageData:dataToSend];

		networkSendLock = YES;
	}
}

-(void)pauseSessionAndShowBottleCaptureScreenWithBrand:(int)brand
{
	[aimImageView stopAnimating];
	[aimImageView setImage:[UIImage imageNamed:@"aim.png"]];
	aimImageView.frame = CGRectMake(0, 0, 200, 228);
	aimImageView.center = CGPointMake(160, 196);
	
	[hintImageView setHidden:YES];
	[captureManager.session stopRunning];
	self.navigationItem.leftBarButtonItem = nil;
//	self.navigationItem.rightBarButtonItem = abandonCurrentImageButton;
	if (!bottleVC) {
		bottleVC = [[CCCaptureBottleViewController alloc] initWithNibName:@"CCCaptureBottleViewController" bundle:nil];
		[bottleVC.view setFrame:self.view.frame];
	}
	aimImageView.hidden = YES;
	// download coke body
	ZSLocationManager *locManager = [ZSLocationManager sharedManager];
	[[CCNetworkAPI requestToURL:kNetworkAPIBaseURL delegate:self] getCokeWithLongtitude:locManager.longitude latitude:locManager.latitude brand:brand];
}

-(void)resumeSession
{
	[hintImageView setHidden:NO];
	[self turnOffShakeListener];
	self.navigationItem.leftBarButtonItem = dismissButton;
	self.navigationItem.rightBarButtonItem = nil;

	[bottleVC.view removeFromSuperview];
	networkSendLock = NO;
	[captureManager.session startRunning];
	aimImageView.hidden = NO;
}
-(void)turnOnShakeListener
{
	// Shake
	didPlay = NO;
	[bottleVC restoreToUnopenState];
	// Turn on the appropriate type of data
	motionManager.accelerometerUpdateInterval = 1.0f / 15.0f;
	[motionManager startAccelerometerUpdatesToQueue:motionQueue withHandler:^(CMAccelerometerData *accel, NSError *error) {
		CMAcceleration userAcceleration = accel.acceleration;
		if (!histeresisExcited && L0AccelerationIsShaking(lastAcceleration, userAcceleration, 1.0)) {
			histeresisExcited = YES;
			if (!didPlay) {
                didPlay = YES;
				[self.navigationItem performSelectorOnMainThread:@selector(setRightBarButtonItem:) withObject:nil waitUntilDone:YES];
				[self.navigationItem performSelectorOnMainThread:@selector(setLeftBarButtonItem:) withObject:nil waitUntilDone:YES];
				[bottleVC performSelectorOnMainThread:@selector(playCokeStep2Animation) withObject:nil waitUntilDone:NO];
				[self performSelectorOnMainThread:@selector(viewCapturedCoke) withObject:nil waitUntilDone:NO];
			}
		} 
		else if (histeresisExcited && !L0AccelerationIsShaking(lastAcceleration, userAcceleration, 0.2)) {
			histeresisExcited = NO;
		}
		lastAcceleration = userAcceleration;
	}];
	[[UINavigationBarBackgroundManager sharedManager] setBackgroundImageName:[NSString stringWithString:@"aim-txt2.png"]];
	[self.navigationController.navigationBar setNeedsDisplay];

//	if (!self.navigationItem.leftBarButtonItem) {
//		self.navigationItem.rightBarButtonItem = abandonCurrentImageButton; // prevent race condition (press abandon when downloading coke body image)
//	}
}
-(void)turnOffShakeListener
{
	// Stop shake
	[motionManager stopAccelerometerUpdates];
	self.navigationItem.rightBarButtonItem = nil;
}

-(void)viewCapturedCoke
{
//	ZSLog(@"viewCapturedCoke");
//	CCCapturedBottleViewController *vc = [[CCCapturedBottleViewController alloc] initWithCapturedBottleData:currentCokeDictionary];
	CCCokeBankBottleViewController *vc = [[CCCokeBankBottleViewController alloc] initWithCokeDict:currentCokeDictionary];
	ZSLog(@"currentCokeDictionary:%@",currentCokeDictionary);
	vc.title = [currentCokeDictionary objectForKey:@"coke_name"];
	[self.navigationController performSelector:@selector(pushViewController:animated:) withObject:vc afterDelay:2.5f];
	[vc release];
	[[NSNotificationCenter defaultCenter] removeObserver:self]; // should not dismiss for background after this
	[self turnOffShakeListener];
	self.navigationItem.leftBarButtonItem = dismissButton;
	self.navigationItem.rightBarButtonItem = nil;
	[bottleVC.view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:3.0f];
//	aimImageView.hidden = NO;
	bottomBarStartButton.hidden = YES;
	ZSLog(@"request cokeid :%@",[currentCokeDictionary objectForKey:@"coke_id"]);
	[[CCNetworkAPI requestToURL:kNetworkAPIBaseURL delegate:self] saveCokeWithCokeID:[currentCokeDictionary objectForKey:@"coke_id"]];
}

-(void)downloadCokeBodyWithURL:(NSString *)URLString
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	if (cokeBodyImageData) {
		[cokeBodyImageData release];
		cokeBodyImageData = nil;
	}
	[self performSelectorOnMainThread:@selector(showLoadingCokeAlertView) withObject:nil waitUntilDone:NO];
	cokeBodyImageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:URLString] options:NSDataReadingUncached error:nil];
	[self performSelectorOnMainThread:@selector(dismissLoadingCokeAlertView) withObject:nil waitUntilDone:NO];
	
	[bottleVC.bottleImageView performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageWithData:cokeBodyImageData] waitUntilDone:YES];
	[self.view performSelectorOnMainThread:@selector(addSubview:) withObject:bottleVC.view waitUntilDone:YES];
//	ZSLog(@"結束下載瓶身");
//	[bottleVC performSelectorOnMainThread:@selector(playCokeStep1Animation) withObject:nil waitUntilDone:NO];
	[self performSelectorOnMainThread:@selector(turnOnShakeListener) withObject:nil waitUntilDone:YES];
	[pool drain];
}

- (void)showLoadingCokeAlertView
{
	alert = [[[ZSAlertView alloc] initWithTitle:@"下載可樂瓶中\n請稍候..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] autorelease];
	[alert show];
	UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	// Adjust the indicator so it is up a few pixels from the bottom of the alert
	indicator.center = CGPointMake(alert.bounds.size.width / 2, alert.bounds.size.height - 50);
	[indicator startAnimating];
	[alert addSubview:indicator];
	[indicator release];
}

- (void)dismissLoadingCokeAlertView
{
	[alert dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark CCNetworkDelegate

- (void)request:(CCNetworkImageService *)request didReceiveImageService:(NSDictionary *)dict
{
	int version = [[dict objectForKey:@"version"] intValue];
	if (version > kZIRSVersion) {
		ZSAlertView *av = [[ZSAlertView alloc] initWithTitle:@"錯誤" message:@"請更新至最新版以使用本服務" delegate:nil cancelButtonTitle:@"確認" otherButtonTitles:nil];
		av.delegate = self;
		[av show];
		[av autorelease];
		return;
	}
#ifndef DEBUG
	NSString *result = [NSString stringWithString:[dict objectForKey:@"result"]];
	// 1 (7-11), 2(全家), 3(萊爾富), 4(OK便利商店)
	if ([result isEqualToString:@"seven"]) {
		[self pauseSessionAndShowBottleCaptureScreenWithBrand:1];
	}
	else if ([result isEqualToString:@"coca"]) {
		[self pauseSessionAndShowCokeDiscount];
	}
	else if ([result isEqualToString:@"familymart"]) {
		[self pauseSessionAndShowBottleCaptureScreenWithBrand:2];
	}
	else if ([result isEqualToString:@"ok"]) {
		[self pauseSessionAndShowBottleCaptureScreenWithBrand:4];
	}
	else if ([result isEqualToString:@"hilife"]) {
		[self pauseSessionAndShowBottleCaptureScreenWithBrand:3];
	}
	else {
#endif
		sendCount ++;
//		NSLog(@"IR retry count: %d",sendCount);
		if (sendCount == maxRetryCount) {
			[[UINavigationBarBackgroundManager sharedManager] setBackgroundImageName:[NSString stringWithString:@"aim-txt4.png"]];
			[self.navigationController.navigationBar setNeedsDisplay];
			sendCount = 0;
			networkSendLock = YES;
//			[self.view addSubview:bottomBarView];
			bottomBarStartButton.hidden = NO;
			[aimImageView stopAnimating];
			[aimImageView setImage:[UIImage imageNamed:@"aim.png"]];
			aimImageView.frame = CGRectMake(0, 0, 200, 228);
			aimImageView.center = CGPointMake(160, 196);
		}
		else {
			networkSendLock = NO;
		}

		
#ifndef DEBUG		
	}
#endif

#ifdef DEBUG
	[statusLabel performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"%@", dict] waitUntilDone:NO];
#endif
	[request release];
	
}

- (void)request:(CCNetwork *)request didFailWithError:(NSError *)error
{
	ZSLog(@"didFailWithError: %@", error);
	ZSAlertView *av = [[ZSAlertView alloc] initWithTitle:@"錯誤" message:@"請檢查網路連線" delegate:nil cancelButtonTitle:@"確認" otherButtonTitles:nil];
	[av show];
	[av autorelease];
	[request release];
	[self dismiss];
}

- (void)request:(CCNetwork *)request hadStatusCodeError:(int)errorCode
{
	ZSLog(@"hadStatusCodeError: %d", errorCode);
	ZSAlertView *av = [[ZSAlertView alloc] initWithTitle:@"錯誤" message:@"請檢查網路連線" delegate:nil cancelButtonTitle:@"確認" otherButtonTitles:nil];
	[av show];
	[av autorelease];
	[request release];
	[self dismiss];
}
#pragma mark CCNetworkAPIDelegate

- (void)request:(CCNetworkAPI *)request didGetCoke:(NSDictionary *)dict
{
	ZSLog(@"didGetCoke:%@",dict);
	NSString *errorString = [dict objectForKey:@"error"];
	if (errorString) {
		ZSLog(@"errorString:%@",errorString);
		ZSAlertView *av = [[ZSAlertView alloc] initWithTitle:@"錯誤" message:errorString delegate:nil cancelButtonTitle:@"確認" otherButtonTitles:nil];
		[av show];
		[av autorelease];
		[self dismiss];
		return;
	}
	
//	ZSLog(@"didGetCoke: %@", dict);
//	NSString *message = [dict objectForKey:@"message"];
//	ZSLog(@"message = %@",message);
	if (currentCokeDictionary) {
		[currentCokeDictionary release];
		currentCokeDictionary = nil;
	}
	currentCokeDictionary = [[NSDictionary alloc] initWithDictionary:dict];
	//TODO: replace imgUrl with new cokeBody image
	NSString *imgUrl = [NSString stringWithFormat:@"%@",[dict objectForKey:@"coke_icon"]];
//	ZSLog(@"開始下載瓶身...");
	[self performSelectorInBackground:@selector(downloadCokeBodyWithURL:) withObject:imgUrl];
	[request release];
}

- (void)request:(CCNetworkAPI *)request didSaveCoke:(NSDictionary *)dict
{
	ZSLog(@"didSaveCoke:%@",dict);
	//	NSString *message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"message"]];
	//	NSAssert([message isEqualToString:@"OK"],@"didSaveCoke: message not OK");
}
- (void)request:(CCNetworkAPI *)request didFailSaveCokeWithError:(NSError *)error
{
	ZSLog(@"didFailSaveCokeWithError:%@",error);
}




- (void)request:(CCNetworkAPI *)request didFailGetCokeWithError:(NSError *)error
{
	ZSLog(@"didFailGetCokeWithError: %@", error);
	ZSAlertView *av = [[ZSAlertView alloc] initWithTitle:@"錯誤" message:@"請檢查網路連線" delegate:nil cancelButtonTitle:@"確認" otherButtonTitles:nil];
	[av show];
	[av autorelease];
	[request release];
	[self dismiss];
}

@end
#endif