//
//  CCCokeDetailViewController.h
//  coke
//
//  Created by John on 2011/2/10.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCokeBankBarCodeViewController.h"
#import "CCCokeBankIntroViewController.h"

#define maxNumberOfBottleImage 15
@interface CCCokeBankBottleViewController : UIViewController <UIGestureRecognizerDelegate>
{
	NSString *currentCokeId;
//	NSData *bottleImageData;
	NSString *currentCokeName;
	IBOutlet UIImageView *bottleImageView;
	CCCokeBankBarCodeViewController *barCodeVC;
	CCCokeBankIntroViewController *introVC;
	UIView *superView;
	IBOutlet UILabel *loadingImageIndicatorLabel;
	NSArray *bottleDataArray;
	int currentBottleImageNumber;
	UIPanGestureRecognizer *panGesture;
}
- (id)initWithCokeDict:(NSDictionary *)dict;
- (NSString *)applicationDocumentsDirectory;
-(void)moveToLastImage;
-(void)moveToNextImage;
-(void)downloadBottleImageData:(NSString *)prefixURLString;
- (void)dismiss;
- (IBAction)jumpToIntro;
- (IBAction)jumpToBarCode;
- (IBAction)jumpToBottle;
@end
