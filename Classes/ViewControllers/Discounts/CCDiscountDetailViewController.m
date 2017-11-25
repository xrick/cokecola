//
//  CCDiscountDetailViewController.m
//  coke
//
//  Created by John on 2011/2/14.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import "CCDiscountDetailViewController.h"


@implementation CCDiscountDetailViewController

- (void)dealloc 
{
	[discountURL release];
	[imageData release];
	[discountString release];
    [super dealloc];
}

- (id)initWithManagedObject:(NSManagedObject *)obj
{
    self = [super initWithNibName:@"CCDiscountDetailViewController" bundle:nil];
    if (self) {
//		ZSLog(@"initWithManagedObject:%@",obj);
		imageData = [[NSData alloc] initWithData:[obj valueForKey:DiscountImage]];
		discountString = [[NSString alloc] initWithFormat:@"%@",[obj valueForKey:DiscountDescription]];
		self.title = [NSString stringWithFormat:@"%@",[obj valueForKey:DiscountName]];
		discountImageURL = [[NSString alloc] initWithFormat:@"%@",[obj valueForKey:DiscountImageURL]];
		if ([obj valueForKey:DiscountLinkURL]) {
			discountURL = [[NSString alloc] initWithFormat:@"%@",[obj valueForKey:DiscountLinkURL]];
		}
		else {
			discountURL = @"http://www.icoke.com.tw/";
		}

		
    }
    return self;
}

- (void)dismiss
{
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

-(IBAction)publishToFacebook
{
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  discountImageURL, @"discountMsg_image",
						  discountString, @"discountMsg_description",
						  self.title, @"discount_name",
						  nil	  
						  ];
	[[FaceBookManager sharedManager] postDiscountWithDictionary:dict];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	discountTextView.text = discountString;
	logoImageView.image = [UIImage imageWithData:imageData];
	[logoImageView sizeToFit];
	logoImageView.center = CGPointMake(160.0f, 70.0f);
	self.navigationController.navigationBar.tintColor = [UIColor redColor];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)] autorelease];
	if (discountURL) {
		openLinkButton.hidden = NO;
	}
}

-(IBAction)saleLinkAction
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:discountURL]];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
