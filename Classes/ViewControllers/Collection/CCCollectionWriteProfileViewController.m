//
//  CCCollectionWriteProfileViewController.m
//  coke
//
//  Created by John on 2011/5/4.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import "CCCollectionWriteProfileViewController.h"


@implementation CCCollectionWriteProfileViewController
@synthesize missionName;
- (void)dealloc 
{
	self.missionName = nil;
	[savingAlertView release];
	savingAlertView = nil;
    [super dealloc];
}

- (id) initWithMissionId:(int)mid missionName:(NSString *)mName
{
	self = [super initWithNibName:@"CCCollectionWriteProfileViewController" bundle:nil];
	if (self != nil) {
		missionId = mid;
		self.missionName = mName;
		self.title = @"任務完成回報";
	}
	return self;
}
-(void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[nameField becomeFirstResponder];
	scrollView.contentSize = CGSizeMake(320, 416);
	nameField.text = [[NSUserDefaults standardUserDefaults] valueForKey:UserDefaultKeyOfName];
	mailField.text = [[NSUserDefaults standardUserDefaults] valueForKey:UserDefaultKeyOfMail];
	phoneField.text = [[NSUserDefaults standardUserDefaults] valueForKey:UserDefaultKeyOfPhone];
	missionNameLabel.text = self.missionName;
//	NSLog(@"scroll frame:%f,%f",scrollView.frame.size.width,scrollView.frame.size.height);
	UIBarButtonItem *closeKeyboardButton = [[[UIBarButtonItem alloc] initWithTitle:@"關閉鍵盤" style:UIBarButtonItemStyleBordered target:self action:@selector(closeKeyboardAction)] autorelease];
	self.navigationItem.rightBarButtonItem = closeKeyboardButton;
}
-(void)closeKeyboardAction
{
	[nameField resignFirstResponder];
	[phoneField resignFirstResponder];
	[mailField resignFirstResponder];
}

-(void) textFieldDidBeginEditing:(UITextField *)textField
{
	scrollView.frame = CGRectMake(0, 0, 320, 416-200);

	if (textField == nameField) {
		[scrollView scrollRectToVisible:CGRectMake(0, 100, 320, 436-200) animated:NO];
	}
	else if (textField == mailField) {
		[scrollView scrollRectToVisible:CGRectMake(0, 200, 320, 436-200) animated:NO];
	}
	else if (textField == phoneField) {
		[scrollView scrollRectToVisible:CGRectMake(0, 200, 320, 436-200) animated:NO];
	}

}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
	scrollView.frame = CGRectMake(0, 0, 320, 416);
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
	if (textField == nameField) {
		[mailField becomeFirstResponder];
	}
	else if (textField == mailField) {
		[phoneField becomeFirstResponder];
	}
	else if (textField == phoneField) {
		[phoneField resignFirstResponder];
	}
	return YES;
}

-(IBAction)saveProfileAction
{
	//TODO: use regularExpression to check fields
	if (nameField.text.length == 0 || mailField.text.length == 0 || phoneField.text.length == 0) {
		showSimpleAlert(@"請填完全部項目");
	}
	else {
		savingAlertView = [[ZSAlertView alloc] initWithTitle:@"請稍候" message:@"正在儲存" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
		[savingAlertView show];
		[[CCNetworkAPI requestToURL:kNetworkAPIBaseURL delegate:self] saveProfileWithMissionId:[NSString stringWithFormat:@"%d",missionId] name:nameField.text email:mailField.text phone:phoneField.text];
	}
}

- (void)request:(CCNetworkAPI *)request didSaveProfile:(NSDictionary *)dict
{
	[savingAlertView dismissWithClickedButtonIndex:0 animated:YES];
	[savingAlertView release];
	savingAlertView = nil;
	if ([dict objectForKey:@"detail"]) {
		showSimpleAlert([dict objectForKey:@"detail"]);
		[self.navigationController dismissModalViewControllerAnimated:YES];
	}
	else if ([[dict objectForKey:@"message"] isEqualToString:@"OK"]){
		showSimpleAlert(@"儲存成功");
		[self.navigationController dismissModalViewControllerAnimated:YES];
	}
	else {
		showSimpleAlert(@"儲存失敗");
	}

}

- (void)request:(CCNetworkAPI *)request didFailSaveProfileWithError:(NSError *)error
{
	[savingAlertView dismissWithClickedButtonIndex:0 animated:YES];
	[savingAlertView release];
	savingAlertView = nil;	
	showSimpleAlert(@"儲存失敗");
}

- (void)request:(CCNetwork *)request hadStatusCodeError:(int)errorCode
{
	[savingAlertView dismissWithClickedButtonIndex:0 animated:YES];
	[savingAlertView release];
	savingAlertView = nil;	
	showSimpleAlert(@"儲存失敗");
	
	[request release];
}

@end
