//
//  CCCollectionViewController.m
//  coke
//
//  Created by Franky on 2/5/11.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import "CCCollectionViewController.h"
#import "CCCameraViewController.h"
#import "CCCollectionMissionDetailViewController.h"

@implementation CCCollectionViewController
@synthesize currentMissionDictionary;
@synthesize smallOpenFlowView;

- (void)dealloc 
{
	self.currentMissionDictionary = nil;
    [super dealloc];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
	[smallOpenFlowView setViewDelegate:self];
    smallOpenFlowView.backgroundColor = [UIColor clearColor];
    lastIndex = 0;
    [[CCNetworkAPI requestToURL:kNetworkAPIBaseURL delegate:self] getMissionPages:1];
}

-(IBAction)showHelp
{
    CCHelpViewController *vc = [[CCHelpViewController alloc] init];
    [self.tabBarController presentModalViewController:vc animated:YES];
    [vc release];    
}

-(void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)missionDetailAtIndex:(int)index
{
	if (!self.currentMissionDictionary) {
		showSimpleAlert(@"目前尚未接收到任務資訊，請稍候再試");
	}
	else {
		BOOL needToWriteProfile = [[NSString stringWithFormat:@"%@",[self.currentMissionDictionary objectForKey:@"name"]] isEqualToString:@"<null>"];
		if (!needToWriteProfile) {
			[[NSUserDefaults standardUserDefaults] setValue:[self.currentMissionDictionary objectForKey:@"name"] forKey:UserDefaultKeyOfName];
			[[NSUserDefaults standardUserDefaults] setValue:[self.currentMissionDictionary objectForKey:@"phone"] forKey:UserDefaultKeyOfPhone];
			[[NSUserDefaults standardUserDefaults] setValue:[self.currentMissionDictionary objectForKey:@"email"] forKey:UserDefaultKeyOfMail];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
//		NSLog(@"%d",needToWriteProfile);
		NSDictionary *selectedDict = [[self.currentMissionDictionary objectForKey:@"mission"] objectAtIndex:index];
		CCCollectionMissionDetailViewController *vc = [[CCCollectionMissionDetailViewController alloc] initWithMissionDictionary:selectedDict needToWriteProfile:needToWriteProfile];
		UINavigationController *con = [[UINavigationController alloc] initWithRootViewController:vc];
		con.navigationBar.tintColor = [UIColor redColor];
		[self presentModalViewController:con animated:YES];
		[vc release];
		[con release];
	}
}

-(IBAction)descriptionAction
{
	ZSAlertView *alert = [[ZSAlertView alloc] initWithTitle:@"免責聲明" message:@"1. 影像辨識服務不保證辨識正確性\n2. 影像辨識速度會隨著網路傳輸速度而不同" delegate:nil cancelButtonTitle:@"確定" otherButtonTitles:nil];
	[alert show];
	[alert release];	
}

//-(void)viewCapturedBottleByNotification:(NSNotification *)notif
//{
//	[self dismissModalViewControllerAnimated:NO];
//	[self.tabBarController setSelectedIndex:2];
//
//	
//}

- (IBAction)openCameraVC
{
#if !TARGET_IPHONE_SIMULATOR
	CCCameraViewController *cameraVC = [[CCCameraViewController alloc] init];
	UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:cameraVC];
	[self presentModalViewController:navCon animated:YES];
	[cameraVC release];
	[navCon release];
#endif
}
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark CCNetworkAPIDelegate

- (void)request:(CCNetworkAPI *)request didGetMissionPages:(NSDictionary *)dict
{
//	NSLog(@"didGetMissionPages:%@",dict);
	if (![[dict objectForKey:@"message"] isEqualToString:@"OK"]) {
		showSimpleAlert(@"伺服器發生錯誤，無法取得任務列表");
		return;
	}
	self.currentMissionDictionary = dict;
    NSArray *missionArray = [dict objectForKey:@"mission"];
    int flowNumber = [missionArray count];
    for (int i = 0; i < flowNumber; i++) {
        NSDictionary *missionDict = [missionArray objectAtIndex:i];
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[missionDict objectForKey:@"mission_image"]]];
        [smallOpenFlowView setImage:[UIImage imageWithData:imageData] forIndex:i];
    }
    [smallOpenFlowView setNumberOfImages:flowNumber];
	smallOpenFlowView.coverHeightOffset = 12.0;
    [self openFlowView:smallOpenFlowView selectionDidChange:lastIndex];
	[request release];
}

- (void)request:(CCNetworkAPI *)request didFailGetMissionPagesWithError:(NSError *)error;
{
	ZSLog(@"didFailGetMissionPagesWithError: %@", error);
	[request release];
}

- (void)request:(CCNetwork *)request hadStatusCodeError:(int)errorCode
{
	ZSLog(@"hadStatusCodeError: %d", errorCode);
	[request release];
}

#pragma mark OpenFlowViewDelegate
- (void)openFlowView:(AFOpenFlowView *)openFlowView selectionDidChange:(int)index 
{
    NSDictionary *selectedDict = [[self.currentMissionDictionary objectForKey:@"mission"] objectAtIndex:index];
    coverTitleLabel.text = [selectedDict objectForKey:@"mission_name"];
    missionDetailLabel.text = [selectedDict objectForKey:@"mission_description"];
}

- (void)openFlowViewAnimationDidBegin:(AFOpenFlowView *)openFlowView 
{
    
}

- (void)openFlowViewAnimationDidEnd:(AFOpenFlowView *)openFlowView 
{
    
}

- (void)openFlowView:(AFOpenFlowView *)openFlowView didTap:(int)index 
{
    //NSLog(@"Tapped on %d", index);
    lastIndex = index;
    [self missionDetailAtIndex:index];
}

- (void)openFlowView:(AFOpenFlowView *)openFlowView didDoubleTap:(int)index 
{
    //    NSLog(@"Tapped twice on %d", index);
}
@end
