//
//  CCLeaderboardViewController.m
//  coke
//
//  Created by Franky on 2/5/11.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import "CCLeaderboardViewController.h"
#import "CCNetworkAPI.h"
#import "ZSBlockActionAlert.h"

@implementation CCLeaderboardViewController
@synthesize _tableView;
- (void)dealloc 
{
	[updateFBInfoToServerAlertView release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[tableDataArray release];
	[currentScoreKeyName release];
    [super dealloc];
}
-(IBAction)showHelp
{
    CCHelpViewController *vc = [[CCHelpViewController alloc] init];
    [self.tabBarController presentModalViewController:vc animated:YES];
    [vc release];
    
}
-(IBAction)loginFB
{
	[[FaceBookManager sharedManager] login];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	didFinishUpdateFBToServer = NO;
	self.tableView.backgroundColor = [UIColor redColor];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultFBTokenKey]) {
        //login with saved token
        updateFBInfoToServerAlertView = [[UIAlertView alloc] initWithTitle:@"請稍候" message:@"嘗試取得朋友列表..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [updateFBInfoToServerAlertView show];
        [[CCNetworkAPI requestToURL:kNetworkAPIBaseURL delegate:self] loginFBSync];
    }
    else
    {
        //wait for login
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFBLoginAccessTokenToServer) name:FBDidFetchUserDataNotification object:nil];
    }
    [self segmentControlsDidChangeValue:nil]; // send first request for rank all

//	self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background.png"]];
}
-(void)refreshFBLoginAccessTokenToServer
{
    updateFBInfoToServerAlertView = [[UIAlertView alloc] initWithTitle:@"請稍候" message:@"嘗試取得朋友列表..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [updateFBInfoToServerAlertView show];
    [[CCNetworkAPI requestToURL:kNetworkAPIBaseURL delegate:self] loginFBSync];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)segmentControlsDidChangeValue:(UISegmentedControl *)control
{
    if (!didFinishUpdateFBToServer && rankFriendOnlySegmentControl.selectedSegmentIndex == 1) {
        [ZSBlockActionAlert showAlertViewWithTitle:nil message:@"請先登入facebook以取得朋友列表" button1:@"登入" button2:@"取消" block1:^{
            [[FaceBookManager sharedManager] login];
        } block2:nil];
        rankFriendOnlySegmentControl.selectedSegmentIndex = 0; // switch to all rank
        return;
    }
	rankTypeSegmentControl.enabled = NO;
	rankFriendOnlySegmentControl.enabled = NO;
	CCRankingAction actionType = rankFriendOnlySegmentControl.selectedSegmentIndex;
	switch (rankTypeSegmentControl.selectedSegmentIndex) {
		case CCRankType:
			[[CCNetworkAPI requestToURL:kNetworkAPIBaseURL delegate:self] getStyleRankingWithAction:actionType];
			break;
		case CCRankSum:
			[[CCNetworkAPI requestToURL:kNetworkAPIBaseURL delegate:self] getSumRankingWithAction:actionType];
			break;
		case CCRankMission:
			[[CCNetworkAPI requestToURL:kNetworkAPIBaseURL delegate:self] getMissionRankingWithAction:actionType];
			break;
		default:
			break;
	}
}
-(IBAction)shareToFacebookAction
{
	[[FaceBookManager sharedManager] postRankInfoWithRankNumber:currentRankNumber];
}

#pragma mark tableView datasource preprocessing
-(void)updateTableWithArray:(NSArray *)dataArray keyName:(NSString *)scoreKeyName
{
	if (tableDataArray) {
		[tableDataArray release];
		tableDataArray = nil;
	}
	if (currentScoreKeyName) {
		[currentScoreKeyName release];
		currentScoreKeyName = nil;
	}
	currentScoreKeyName = [[NSString alloc] initWithFormat:@"%@",scoreKeyName];
	tableDataArray = [[NSArray alloc] initWithArray:dataArray];
	[self.tableView reloadData];
}
-(void)updateTableWithErrorMessage:(NSString *)errorMessage
{
	if (tableDataArray) {
		[tableDataArray release];
		tableDataArray = nil;
	}
	if (currentScoreKeyName) {
		[currentScoreKeyName release];
		currentScoreKeyName = nil;
	}
	currentScoreKeyName = [[NSString alloc] initWithString:@"error"];
	tableDataArray = [[NSArray alloc] initWithObjects:[NSString stringWithString:errorMessage],nil];
	[self.tableView reloadData];
}
#pragma mark tableView datasource
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.backgroundColor = [UIColor clearColor];
		cell.contentView.backgroundColor = [UIColor clearColor];
		cell.contentView.opaque = NO;
		cell.opaque = NO;
		cell.textLabel.textColor = [UIColor whiteColor];
		cell.detailTextLabel.textColor = [UIColor whiteColor];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	NSDictionary *currentDict = [tableDataArray objectAtIndex:indexPath.row];
//	ZSLog(@"currentScoreKeyName:%@ , currentDict:%@",currentScoreKeyName, currentDict);
	if ([currentScoreKeyName isEqualToString:@"error"]) {
		cell.textLabel.text = @"";
		cell.detailTextLabel.text = @" ";
		if (indexPath.row == 0) {
			NSString *errString = [tableDataArray objectAtIndex:0];
			cell.textLabel.text = [NSString stringWithFormat:@"%@", errString];
		}
	}
	else
	{
		cell.textLabel.text = [NSString stringWithFormat:@"第%@名 %@",[currentDict objectForKey:@"user_rank"],[currentDict objectForKey:@"user_fb_name"]];
		NSString *numberString = [currentDict objectForKey:currentScoreKeyName];
		switch (currentRankType) {
			case CCRankSum:
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%@瓶收集",numberString];
				break;
			case CCRankMission:
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%@件任務破解",numberString];
				break;
			case CCRankType:
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%@款收集",numberString];
				break;
			default:
				break;
		}
	}
	
	return cell;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [tableDataArray count];
}
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}
#pragma mark tableView delegate
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark CCNetworkAPIDelegate
#pragma mark -SucceedPart
- (void)request:(CCNetworkAPI *)request didGetSumRanking:(NSDictionary *)dict
{
	rankTypeSegmentControl.enabled = YES;
	rankFriendOnlySegmentControl.enabled = YES;
	ZSLog(@"didGetSumRanking: %@", dict);

	NSString *string = [dict objectForKey:@"error"];
	if (string) {
		[self updateTableWithErrorMessage:string];
	}
	else {
//		NSString *message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"message"]];
//		NSAssert([message isEqualToString:@"OK"],@"didGetSumRanking: message not OK");
		NSString *rank_me = [dict objectForKey:@"Rank_me"];
		rankNumberLabel.text = [NSString stringWithFormat:@"您目前排行第%@名",rank_me];
		currentRankNumber = [rank_me intValue];
		NSArray *rank_counts = [dict objectForKey:@"Rank_sum"];
		[self updateTableWithArray:rank_counts keyName:@"rank_counts"];
		currentRankType = CCRankSum;
	}
	[request release];
	
}
- (void)request:(CCNetworkAPI *)request didGetStyleRanking:(NSDictionary *)dict
{
	rankTypeSegmentControl.enabled = YES;
	rankFriendOnlySegmentControl.enabled = YES;	
	ZSLog(@"didGetStyleRanking: %@", dict);

	NSString *string = [dict objectForKey:@"error"];
	if (string) {
		[self updateTableWithErrorMessage:string];
	}
	else {
		NSString *message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"message"]];
		NSAssert([message isEqualToString:@"OK"],@"didGetStyleRanking: message not OK");
		
		NSString *rank_me = [dict objectForKey:@"Rank_me"];
		rankNumberLabel.text = [NSString stringWithFormat:@"您目前排行第%@名",rank_me];
		currentRankNumber = [rank_me intValue];

		NSArray *rank_styles = [dict objectForKey:@"Rank_style"];
		[self updateTableWithArray:rank_styles keyName:@"rank_styles"];
		currentRankType = CCRankType;
	}
	[request release];

}
- (void)request:(CCNetworkAPI *)request didGetMissionRanking:(NSDictionary *)dict
{
	rankTypeSegmentControl.enabled = YES;
	rankFriendOnlySegmentControl.enabled = YES;	
	ZSLog(@"didGetMissionRanking: %@", dict);

	NSString *string = [dict objectForKey:@"error"];
	if (string) {
		[self updateTableWithErrorMessage:string];
	}
	else {
		NSString *message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"message"]];
		NSAssert([message isEqualToString:@"OK"],@"didGetMissionRanking: message not OK");
		NSString *rank_me = [dict objectForKey:@"Rank_me"];
		rankNumberLabel.text = [NSString stringWithFormat:@"您目前排行第%@名",rank_me];
		currentRankNumber = [rank_me intValue];

		NSArray *rank_missions = [dict objectForKey:@"Rank_mission"];
		[self updateTableWithArray:rank_missions keyName:@"rank_missions"];
		currentRankType = CCRankMission;
	}
	[request release];

}
#pragma mark -FailPart
- (void)request:(CCNetworkAPI *)request didFailGetSumRankingWithError:(NSError *)error
{
	rankTypeSegmentControl.enabled = YES;
	rankFriendOnlySegmentControl.enabled = YES;
	ZSLog(@"didFailGetSumRankingWithError: %@", error);
	[self updateTableWithErrorMessage:@"發生網路錯誤無法取得列表"];
	[request release];
}

- (void)request:(CCNetworkAPI *)request didFailGetStyleRankingWithError:(NSError *)error
{
	rankTypeSegmentControl.enabled = YES;
	rankFriendOnlySegmentControl.enabled = YES;
//	ZSLog(@"didFailGetStyleRankingWithError: %@", error);
	[self updateTableWithErrorMessage:@"發生網路錯誤無法取得列表"];
	[request release];
}

- (void)request:(CCNetworkAPI *)request didFailGetMissionRankingWithError:(NSError *)error
{
	rankTypeSegmentControl.enabled = YES;
	rankFriendOnlySegmentControl.enabled = YES;
//	ZSLog(@"didFailGetMissionRankingWithError: %@", error);
	[self updateTableWithErrorMessage:@"發生網路錯誤無法取得列表"];
	[request release];

}
- (void)request:(CCNetworkAPI *)request didLoginFB:(NSDictionary *)dict
{
    [updateFBInfoToServerAlertView dismissWithClickedButtonIndex:0 animated:NO];
	[updateFBInfoToServerAlertView release];
	updateFBInfoToServerAlertView = nil;

//    NSLog(@"didLoginFB:%@",dict);
    int fbTokenExpired = [[dict objectForKey:@"fbTokenExpired"] intValue];
    if (fbTokenExpired == 0) {
        didFinishUpdateFBToServer = YES;
        [self segmentControlsDidChangeValue:nil]; // finally send request for ranking
    }
    else
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFBLoginAccessTokenToServer) name:FBDidFetchUserDataNotification object:nil];

        showSimpleAlert(@"認證過期需重新登入facebook才能取得facebook朋友排名資訊");
    }
}
- (void)request:(CCNetworkAPI *)request didFailLoginFBWithError:(NSError *)error
{
	[updateFBInfoToServerAlertView dismissWithClickedButtonIndex:0 animated:NO];
	[updateFBInfoToServerAlertView release];
	updateFBInfoToServerAlertView = nil;
	showSimpleAlert(@"伺服器錯誤無法取得facebook排名資訊");
}

#pragma mark CCNetworkDelegate
- (void)request:(CCNetwork *)request hadStatusCodeError:(int)errorCode
{
	[updateFBInfoToServerAlertView dismissWithClickedButtonIndex:0 animated:NO];
	[updateFBInfoToServerAlertView release];
	updateFBInfoToServerAlertView = nil;
	ZSLog(@"hadStatusCodeError: %d", errorCode);
	rankTypeSegmentControl.enabled = YES;
	rankFriendOnlySegmentControl.enabled = YES;
//	ZSLog(@"hadStatusCodeError: %@", error);
	[self updateTableWithErrorMessage:@"發生網路錯誤無法取得列表"];
	[request release];

}

@end
