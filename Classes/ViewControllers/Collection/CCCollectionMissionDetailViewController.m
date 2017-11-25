//
//  CCCollectionMissionDetailViewController.m
//  coke
//
//  Created by John on 2011/5/4.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import "CCCollectionMissionDetailViewController.h"
#import "UIButton+ASIHttpDownloadImage.h"
#import "CCMissionNearestViewController.h"
#import "ZSBlockActionAlert.h"
@implementation CCCollectionMissionDetailViewController
@synthesize selectedMissionDict;
- (void)dealloc 
{
	self.selectedMissionDict = nil;
    [super dealloc];
}

- (id) initWithMissionDictionary:(NSDictionary *)dict needToWriteProfile:(BOOL)needProfile
{
	self = [super initWithNibName:@"CCCollectionMissionDetailViewController" bundle:nil];
	if (self != nil) {
		self.selectedMissionDict = dict;
		NSLog(@"initWithMissionDictionary:%@",dict);
		isProfileNeeded = needProfile;
	}
	return self;
}

-(void) viewDidLoad
{
	self.navigationItem.rightBarButtonItem = closeButton;
	NSString *missionImageURLString = [self.selectedMissionDict objectForKey:@"brand_logo"];
	__block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:missionImageURLString]];
	[request setCompletionBlock:^{
		[missionImageView setImage:[UIImage imageWithData:[request responseData]]];
	}];
	[request setFailedBlock:^{
		//ZSLog(@"fetch brand_logo image failed at :%@", urlString);
	}];
	[request startAsynchronous];
	self.title = @"任務";
	missionNameLabel.text = [self.selectedMissionDict objectForKey:@"mission_name"];
	missionTimeLabel.text = [NSString stringWithFormat:@"%@ ~ %@",[self.selectedMissionDict objectForKey:@"mission_timeBegin"],[self.selectedMissionDict objectForKey:@"mission_timeEnd"]];
	missionBrandLabel.text = [self.selectedMissionDict objectForKey:@"brand_name"];
	missionDescriptionTextView.text = [self.selectedMissionDict objectForKey:@"mission_description"];
	scrollView.contentSize = CGSizeMake(320, missionDescriptionTextView.frame.origin.y + missionDescriptionTextView.frame.size.height);
	NSString *missionHelpImageURLString = [self.selectedMissionDict objectForKey:@"mission_imageDsrp"];
	__block ASIHTTPRequest *request2 = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:missionHelpImageURLString]];
	[request2 setCompletionBlock:^{
		UIImage *dataImage = [UIImage imageWithData:[request2 responseData]];
		[missionHelpImageView setImage:dataImage];
		if (dataImage.size.width > 1) {
			float scale = dataImage.size.width / 271;
			missionHelpImageView.frame = CGRectMake(missionHelpImageView.frame.origin.x, missionDescriptionTextView.frame.origin.y + missionDescriptionTextView.frame.size.height, 271, dataImage.size.height / scale);
		}
		else {
			[missionHelpImageView sizeToFit];
			missionHelpImageView.center = CGPointMake(160, missionHelpImageView.center.y);
		}

		scrollView.contentSize = CGSizeMake(320, missionHelpImageView.frame.origin.y + missionHelpImageView.frame.size.height);
	}];
	[request2 setFailedBlock:^{
		//ZSLog(@"fetch mission_imageDsrp image failed at :%@", urlString);
	}];
	[request2 startAsynchronous];
//	NSLog(@"isGoal=Y:%d , isProfileNeeded:%d",[[self.selectedMissionDict objectForKey:@"isGoal"] isEqualToString:@"Y"],isProfileNeeded);

}

-(IBAction)nearestAction
{
	NSString *missionId = [NSString stringWithFormat:@"%@",[selectedMissionDict objectForKey:@"mission_id"]];
	CCMissionNearestViewController *vc = [[CCMissionNearestViewController alloc] initWithMission:missionId];
	vc.title = [selectedMissionDict objectForKey:@"mission_name"];
	[self.navigationController pushViewController:vc animated:YES];
	[vc release];
}

-(IBAction)reportAction
{
    if (![[self.selectedMissionDict objectForKey:@"isGoal"] isEqualToString:@"Y"]){ // 已完成
        [ZSBlockActionAlert showAlertViewWithTitle:@"錯誤" message:@"尚未完成任務喔!" button1:@"確定" button2:nil block1:nil block2:nil];
        return;
	}

	int missionId = [[self.selectedMissionDict objectForKey:@"mission_id"] intValue];
	NSString *missionName = [NSString stringWithFormat:@"%@",[self.selectedMissionDict objectForKey:@"mission_name"]];
	CCCollectionWriteProfileViewController *vc = [[CCCollectionWriteProfileViewController alloc] initWithMissionId:missionId missionName:missionName];
	[self.navigationController pushViewController:vc animated:YES];
	[vc release];
}
-(IBAction)closeAction
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




@end
