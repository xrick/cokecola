//
//  FGPlaceDetailViewController.m
//  FashionGuide
//
//  Created by Franky on 12/17/10.
//  Copyright 2010 Zoaks Co., Ltd. All rights reserved.
//

#import "CCPlaceDetailViewController.h"

#define SECTION_PLACEINFO 0
#define SECTION_MOREINFO 1
#define ROW_PLACEINFO_ADDRESS 0
#define ROW_MOREINFO_SHOWINMAP 0
#define ROW_MOREINFO_SEARCHINGOOGLE 1

#define BG_COLOR [UIColor colorWithRed:0.92f green:0.90f blue:0.91f alpha:1.0f]

@implementation CCPlaceDetailViewController
- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[dmListForCurrentStore release];
	[target release];
    [super dealloc];
}

- (id)initWithPOI:(POI *)poi
{
    if (self = [super initWithNibName:@"CCPlaceDetailViewController" bundle:nil]) {
		target = [poi retain];
		storeId = [[target.sourceData objectForKey:@"store_id"] intValue];
//		ZSLog(@"storeId: %d", storeId);
    }
    return self;
}

-(void)didRecievekMapListNotificationNotification:(NSNotification *)notif
{
	int notificationNumber = [[[notif object] objectAtIndex:0] intValue];
//	ZSLog(@"notificationNumber:%d",notificationNumber);
	if (notificationNumber != storeId) {
		return;
	}
	NSArray *notificationArray = [[notif object] objectAtIndex:1];
	if (dmListForCurrentStore) {
		[dmListForCurrentStore release];
		dmListForCurrentStore = nil;
	}
	dmListForCurrentStore = [[NSArray alloc]initWithArray:notificationArray];
//	ZSLog(@"%@",dmListForCurrentStore);

}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	self.view.backgroundColor = BG_COLOR;
	self.navigationItem.title = [NSString stringWithString:target.title];
	NSString *openTime = [target.sourceData objectForKey:@"store_brand"];
	if (openTime != nil) {
		openTimeLabel.text = [NSString stringWithString:openTime];
	}
	NSString *addr = [target.sourceData objectForKey:@"store_address"];
	if (addr != nil) {
//		ZSLog(@"addr: %@", addr);
		addrTextView.text = [NSString stringWithString:addr];
	}
	NSString *tel = [target.sourceData objectForKey:@"store_name"];
	if (tel != nil) {
		telLabel.text = [NSString stringWithString:tel];
	}

	
	[imgMapSimple setImage:target.mapImage];
	

}

-(void) viewWillDisappear:(BOOL)animated
{
	self.navigationItem.rightBarButtonItem = nil;
	[super viewWillDisappear:animated];
}

- (IBAction)callPhoneNumber:(id)sender
{
	NSString* url = [NSString stringWithFormat:@"tel:%@", telLabel.text];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

@end
