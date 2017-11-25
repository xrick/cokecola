//
//  CCCollectionWriteProfileViewController.h
//  coke
//
//  Created by John on 2011/5/4.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#define UserDefaultKeyOfName @"UserDefaultKeyOfName"
#define UserDefaultKeyOfMail @"UserDefaultKeyOfMail"
#define UserDefaultKeyOfPhone @"UserDefaultKeyOfPhone"

@interface CCCollectionWriteProfileViewController : UIViewController <UITextFieldDelegate>
{
	IBOutlet UILabel *missionNameLabel;
	IBOutlet UITextField *nameField;
	IBOutlet UITextField *mailField;
	IBOutlet UITextField *phoneField;
	IBOutlet UIScrollView *scrollView;
	int missionId;
	ZSAlertView *savingAlertView;
}
- (id) initWithMissionId:(int)mid missionName:(NSString *)mName;
-(void)closeKeyboardAction;
-(IBAction)saveProfileAction;
@property(nonatomic,retain)NSString *missionName;
@end
