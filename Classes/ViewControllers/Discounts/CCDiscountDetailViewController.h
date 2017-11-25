//
//  CCDiscountDetailViewController.h
//  coke
//
//  Created by John on 2011/2/14.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CCDiscountDetailViewController : UIViewController 
{
	IBOutlet UITextView *discountTextView;
	IBOutlet UIImageView *logoImageView;
	IBOutlet UIButton *openLinkButton;
	NSData *imageData;
	NSString *discountString;
	NSString *discountImageURL;
	NSString *discountURL;
}
- (id)initWithManagedObject:(NSManagedObject *)obj;
- (void)dismiss;
-(IBAction)publishToFacebook;
-(IBAction)saleLinkAction;
@end
