//
//  cokeAppDelegate.m
//  coke
//
//  Created by Franky on 1/19/11.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import "cokeAppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>


@implementation cokeAppDelegate
@synthesize window;
@synthesize tabBarController;

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [tabBarController release];
	[window release];
	[super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{	
	[application setIdleTimerDisabled:YES];
	[window makeKeyAndVisible];
#ifndef DEBUG
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openingMovieDidFinishPlayBack) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
	moviePlayerController = [[CCOpeningMovieViewController alloc] init];
	[window setRootViewController:moviePlayerController];
#else
	[self openingMovieDidFinishPlayBack];
#endif
	return YES;
}

-(void)tryLogin
{
	loginAlertView = [[ZSAlertView alloc] initWithTitle:@"請稍候" message:@"正在連接伺服器" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
	[loginAlertView show];
	if ([[NSUserDefaults standardUserDefaults] valueForKey:UserDefaultUserNameKey]) {
		[[CCNetworkAPI requestToURL:kNetworkAPIBaseURL delegate:self] restart];
	}
	else {
		[[CCNetworkAPI requestToURL:kNetworkAPIBaseURL delegate:self] registerToServer];
	}
}

-(void)openingMovieDidFinishPlayBack
{
	[window setRootViewController:serverLoginViewController];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[moviePlayerController release];
	moviePlayerController = nil;
	[ZSAlertView setBackgroundColor:[UIColor redColor] withStrokeColor:[UIColor whiteColor]];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
	[self tryLogin];

}

-(BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
	return [[FaceBookManager sharedManager] handleOpenURL:url];
}

- (void)applicationWillResignActive:(UIApplication *)application 
{
}


- (void)applicationDidEnterBackground:(UIApplication *)application 
{
}


- (void)applicationWillEnterForeground:(UIApplication *)application 
{
}


- (void)applicationDidBecomeActive:(UIApplication *)application 
{
}


- (void)applicationWillTerminate:(UIApplication *)application 
{
	[[CCNetworkAPI requestToURL:kNetworkAPIBaseURL delegate:nil] close];
}



#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application 
{
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

#pragma mark CCNetworkAPIDelegate
- (void)request:(CCNetworkAPI *)request didRegister:(NSDictionary *)dict
{
//	NSLog(@"didRegister: %@", [dict objectForKey:@"detail"]);
	[[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:UserDefaultUserNameKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[loginAlertView dismissWithClickedButtonIndex:0 animated:YES];
	[loginAlertView release];
	loginAlertView = nil;
	[window setRootViewController:tabBarController];
	[ZSLocationManager sharedManager]; // prepare to locate machine
	[[CCDiscountManager sharedManager] startTimer];

}

- (void)request:(CCNetworkAPI *)request didFailRegisterWithError:(NSError *)error
{
	ZSAlertView *av = [[ZSAlertView alloc] initWithTitle:@"錯誤" message:@"登入失敗" delegate:self cancelButtonTitle:@"重試" otherButtonTitles:nil];
	[av show];
	[av release];
	//	ZSLog(@"didFailRegisterWithError: %@", error);
}

- (void)request:(CCNetworkAPI *)request didClose:(NSDictionary *)dict
{
	//	ZSLog(@"didClose: %@", dict);
}

- (void)request:(CCNetworkAPI *)request didFailCloseWithError:(NSError *)error
{
	//	ZSLog(@"didFailCloseWithError: %@", error);
}

- (void)request:(CCNetworkAPI *)request didRestart:(NSDictionary *)dict
{
//	NSLog(@"didRestart:%@", [dict objectForKey:@"detail"]);
	[loginAlertView dismissWithClickedButtonIndex:0 animated:YES];
	[loginAlertView release];
	loginAlertView = nil;
	[window setRootViewController:tabBarController];
	[ZSLocationManager sharedManager]; // prepare to locate machine
	[[CCDiscountManager sharedManager] startTimer];

}

- (void)request:(CCNetworkAPI *)request didFailRestartWithError:(NSError *)error
{
	ZSAlertView *av = [[ZSAlertView alloc] initWithTitle:@"錯誤" message:@"登入失敗" delegate:self cancelButtonTitle:@"重試" otherButtonTitles:nil];
	[av show];
	[av release];
	
	//	NSLog(@"didFailRestartWithError:%@", error);
}

- (void)request:(CCNetwork *)request hadStatusCodeError:(int)errorCode
{
	ZSLog(@"hadStatusCodeError: %d", errorCode);
}

#pragma mark UIAlertView delegates
-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[self tryLogin];
}

@end