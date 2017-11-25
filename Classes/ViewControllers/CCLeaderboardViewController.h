//
//  CCLeaderboardViewController.h
//  coke
//
//  Created by Franky on 2/5/11.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
	CCRankType,
	CCRankSum,
	CCRankMission,
} CCRankNumber;

@interface CCLeaderboardViewController : UIViewController 
{
	IBOutlet UISegmentedControl *rankTypeSegmentControl;
	IBOutlet UISegmentedControl *rankFriendOnlySegmentControl;

	IBOutlet UILabel *rankNumberLabel;
	NSArray *tableDataArray;
	NSString *currentScoreKeyName;
	int currentRankNumber;
	CCRankNumber currentRankType;
	IBOutlet UIImageView *notLoginBG;
	IBOutlet UIButton *notLoginButton;
	BOOL didFinishUpdateFBToServer;
	ZSAlertView *updateFBInfoToServerAlertView;
}
-(void)refreshFBLoginAccessTokenToServer;
-(IBAction)segmentControlsDidChangeValue:(UISegmentedControl *)control;
-(IBAction)loginFB;
-(IBAction)shareToFacebookAction;
-(IBAction)showHelp;

-(void)updateTableWithArray:(NSArray *)dataArray keyName:(NSString *)scoreKeyName;
-(void)updateTableWithErrorMessage:(NSString *)errorMessage;

@property(nonatomic,readonly,getter=tableView)IBOutlet UITableView *_tableView;
@end
