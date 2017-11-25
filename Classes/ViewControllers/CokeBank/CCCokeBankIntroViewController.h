//
//  CCCokeBankIntroViewController.h
//  coke
//
//  Created by John on 2011/2/18.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CCCokeBankIntroViewController : UIViewController 
{
	NSString *currentCokeId;
	IBOutlet UITextView *introTextView;
	IBOutlet UIImageView *cokeBottleIntroductionImageView;
//	IBOutlet UIWebView *introWebView;
	IBOutlet UIView *subContainer;
	IBOutlet UIScrollView *scrollView;
}
-(IBAction)sendGoBottleNotification;
-(IBAction)sendGoBarCodeNotification;

@end
