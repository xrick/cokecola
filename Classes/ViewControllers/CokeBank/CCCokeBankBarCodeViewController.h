//
//  CCCokeBankBarCodeViewController.h
//  coke
//
//  Created by John on 2011/2/18.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCNetworkAPI.h"

@interface CCCokeBankBarCodeViewController : UIViewController 
{
	IBOutlet UILabel *serialNameLabel;
	IBOutlet UILabel *serialNumberStaticTitleLabel;
	IBOutlet UITextView *serialNumberLabel;
	IBOutlet UILabel *platformLabel;
	IBOutlet UILabel *platformStaticTitleLabel;
	IBOutlet UILabel *discountDateStaticTitleLabel;
	IBOutlet UILabel *discountDateLabel;
	IBOutlet UILabel *discountDescriptionStaticTitleLabel;
	IBOutlet UITextView *discountDescriptionTextView;
	IBOutlet UIImageView *discountHelpImageView;

	IBOutlet UIScrollView *scrollView;
	IBOutlet UIView *subContainer;
	NSString *currentCokeId;
	NSDictionary *currentDataDict;
}
- (id)initWithCokeID:(NSString *)cokeId;
-(void)resetContentSize;
-(IBAction)sendGoBottleNotification;
-(IBAction)sendGoIntroNotification;
@end
