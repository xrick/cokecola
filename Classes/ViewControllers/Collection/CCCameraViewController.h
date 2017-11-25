//
//  CCCameraViewController.h
//  coke
//
//  Created by Franky on 1/19/11.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

//#import "ZSSURFProcessor.h"
#if !TARGET_IPHONE_SIMULATOR
#import <CoreMotion/CoreMotion.h>
#import "ZSAVCaptureManager.h"
#import "CCNetworkImageService.h"
#import "CCCaptureBottleViewController.h"

#define shouldPushToCapturedCokeViewControllerNotification @"shouldPushToCapturedCokeViewControllerNotification"

static BOOL L0AccelerationIsShaking(CMAcceleration last, CMAcceleration current, double threshold) {
	double
	deltaX = fabs(last.x - current.x),
	deltaY = fabs(last.y - current.y),
	deltaZ = fabs(last.z - current.z);
	
	return
	(deltaX > threshold && deltaY > threshold) ||
	(deltaX > threshold && deltaZ > threshold) ||
	(deltaY > threshold && deltaZ > threshold);
}

@interface CCCameraViewController : UIViewController <ZSAVCaptureManagerDelegate, CCNetworkImageServiceDelegate, UIAlertViewDelegate>
{
	CCCaptureBottleViewController *bottleVC;
	AVCaptureVideoPreviewLayer *prevLayer;
	ZSAVCaptureManager *captureManager;
//	ZSSURFProcessor *surfProcessor;
	
	UIImageView *grayPreviewImageView;
	UILabel *statusLabel;
	UIImageView *aimImageView;
	BOOL networkSendLock;
	BOOL isCurrentViewActive;
	UIBarButtonItem *dismissButton;
//	UIBarButtonItem *abandonCurrentImageButton;
	
	NSOperationQueue* motionQueue;
	CMMotionManager *motionManager;
	
	BOOL histeresisExcited;
	BOOL didPlay;
	CMAcceleration lastAcceleration;
	NSData *cokeBodyImageData;
	
	//used after get_coke api
	NSDictionary *currentCokeDictionary;
	
	ZSAlertView *alert;
	
//	UIView *bottomBarView;
	UIButton *bottomBarStartButton;
	int sendCount;
	UIImageView *hintImageView;
}
-(void)startButtonAction;
-(void)fitPreviewLayer;
-(void)pauseSessionAndShowBottleCaptureScreenWithBrand:(int)brand;
-(void)viewCapturedCoke;
-(void)resumeSession;
-(void)recievedEnterBackgroundNotification;
-(void)dismiss;
-(void)turnOnShakeListener;
-(void)turnOffShakeListener;
-(void)downloadCokeBodyWithURL:(NSString *)URLString;
@property (nonatomic,retain) ZSAVCaptureManager *captureManager;
@end
#endif