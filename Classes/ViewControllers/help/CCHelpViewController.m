//
//  MWMenuViewController.m
//  mower
//
//  Created by John on 2010/12/29.
//  Copyright 2010 Zoaks Co., Ltd. All rights reserved.
//

#import "CCHelpViewController.h"

@implementation CCHelpViewController

-(void) loadView
{
	if (!controller) {
        controller = [[PhoneContentController alloc] init];
    }
	self.view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)] autorelease];
    [self.view addSubview:[controller view]];
	[self.view setBackgroundColor:[UIColor clearColor]];
    self.view.opaque = NO;
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 235, 21)] autorelease];
    label.text = @"請用手指左右滑動切換頁面";
    [label sizeToFit];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    [self.view addSubview:label];
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dismissButton setTitle:@"關閉" forState:UIControlStateNormal];
    dismissButton.frame = CGRectMake(248, 0, 72, 30);
    [dismissButton addTarget:self action:@selector(dismissModalViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:dismissButton];
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


- (void)dealloc {
    [controller release];
    [super dealloc];
}


@end
