//
//  cokeAppDelegate.h
//  coke
//
//  Created by Franky on 1/19/11.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "CCOpeningMovieViewController.h"
#import "CCServerLoginViewController.h"

#define UserDefaultUserNameKey @"UserDefaultUserNameKey"

@interface cokeAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UIAlertViewDelegate> 
{
	IBOutlet UIWindow *window;
	IBOutlet UITabBarController *tabBarController;
	CCOpeningMovieViewController *moviePlayerController;
	IBOutlet CCServerLoginViewController *serverLoginViewController;
	ZSAlertView *loginAlertView;
}
-(void)openingMovieDidFinishPlayBack;
-(void)tryLogin;
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end