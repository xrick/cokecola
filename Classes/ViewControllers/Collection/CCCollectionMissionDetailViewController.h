//
//  CCCollectionMissionDetailViewController.h
//  coke
//
//  Created by John on 2011/5/4.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCollectionWriteProfileViewController.h"


@interface CCCollectionMissionDetailViewController : UIViewController 
{
	IBOutlet UILabel *missionNameLabel;
	IBOutlet UIImageView *missionImageView;
	IBOutlet UILabel *missionTimeLabel;
	IBOutlet UITextView *missionDescriptionTextView;
	IBOutlet UILabel *missionBrandLabel;
	IBOutlet UIButton *reportButton;
	IBOutlet UIImageView *missionHelpImageView;
	IBOutlet UIScrollView *scrollView;
	BOOL isProfileNeeded;
	IBOutlet UIBarButtonItem *closeButton;
	IBOutlet UIButton *nearestButton;
}
@property(nonatomic,retain)NSDictionary *selectedMissionDict;
- (id) initWithMissionDictionary:(NSDictionary *)dict needToWriteProfile:(BOOL)needProfile;
-(IBAction)reportAction;
-(IBAction)closeAction;
-(IBAction)nearestAction;
@end
