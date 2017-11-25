//
//  CCCaptureBottleViewController.m
//  coke
//
//  Created by John on 2011/2/9.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "CCCaptureBottleViewController.h"


@implementation CCCaptureBottleViewController
@synthesize bottleImageView;
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (void)dealloc 
{	
    [super dealloc];
}

//- (id)initWithBackImage:(UIImage *)image
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"CCCaptureBottleViewController" bundle:nil];
    if (self) {
		self.title = @"收集趣";
        
    }
    return self;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor clearColor];
	self.view.opaque = NO;
}

- (void)restoreToUnopenState
{
	[animationImageView setImage:nil];
}

- (IBAction)playCokeStep1Animation
{
//	NSMutableArray *toolImages = [NSMutableArray array];
//	for (int i = 0; i < 6; i++) {
//		NSString *imgSrcString = [NSString stringWithFormat:@"open_coke_000%d.png",i];
//		[toolImages addObject:[UIImage imageNamed:imgSrcString]];
//	}
//	animationImageView.animationImages = toolImages;
//	animationImageView.animationDuration = 6.0f/15.0f; // seconds
//	animationImageView.animationRepeatCount = 1; // 0 = loops forever
//	[animationImageView setHidden:YES];
//	[animationImageView setImage:[UIImage imageNamed:@"open_coke_0006.png"]];
//	[animationImageView startAnimating];
//	[animationImageView setHidden:NO];
}
- (IBAction)playCokeStep2Animation
{
	[animationImageView setHidden:NO];

	AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
	NSMutableArray *toolImages = [NSMutableArray array];
	for (int i = 0; i < 9; i++) {
		NSString *imgSrcString = [NSString stringWithFormat:@"open_coke_000%d.png",i];
		[toolImages addObject:[UIImage imageNamed:imgSrcString]];
	}
	for (int i = 10; i < 29; i++) {
		NSString *imgSrcString = [NSString stringWithFormat:@"open_coke_00%d.png",i];
		[toolImages addObject:[UIImage imageNamed:imgSrcString]];
	}

	animationImageView.animationImages = toolImages;
	animationImageView.animationDuration = 1.2; // seconds
	animationImageView.animationRepeatCount = 1; // 0 = loops forever	
	[animationImageView setImage:[UIImage imageNamed:@"open_coke_0029.png"]];
	[animationImageView startAnimating];
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning 
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




@end
