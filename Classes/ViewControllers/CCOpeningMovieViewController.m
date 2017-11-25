//
//  CCOpeningMovieViewController.m
//  coke
//
//  Created by John on 2011/2/17.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import "CCOpeningMovieViewController.h"


@implementation CCOpeningMovieViewController
- (void)dealloc 
{
	[mpvc.moviePlayer stop];
	[mpvc.view removeFromSuperview];
	[mpvc release];
    [super dealloc];
}

-(void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	NSString *moviePath = [[NSBundle mainBundle] pathForResource:@"Opening.mov" ofType:nil];
	mpvc = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:moviePath]];
	mpvc.moviePlayer.controlStyle = MPMovieControlStyleNone;
	[self.view addSubview:mpvc.view];
	mpvc.view.frame = CGRectMake(0, 0, 720, 480);
	mpvc.view.center = CGPointMake(160, 240);
	touchDetectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	[self.view addSubview:touchDetectionView];
	[mpvc.moviePlayer performSelector:@selector(play) withObject:nil afterDelay:1.0];
	
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
