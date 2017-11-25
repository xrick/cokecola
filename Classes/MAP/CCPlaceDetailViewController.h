//
//  FGPlaceDetailViewController.h
//  FashionGuide
//
//  Created by Franky on 12/17/10.
//  Copyright 2010 Zoaks Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "POI.h"

@interface CCPlaceDetailViewController : UIViewController 
{
	IBOutlet UIImageView *imgMapSimple;	
	IBOutlet UILabel *openTimeLabel;
	IBOutlet UILabel *telLabel;
	IBOutlet UILabel *addrLabel;
	IBOutlet UITextView *addrTextView;
	
	POI *target;
	int storeId;
	NSArray *dmListForCurrentStore;
}
- (id)initWithPOI:(POI *)poi;
- (void)didRecievekMapListNotificationNotification:(NSNotification *)notif;
- (IBAction)callPhoneNumber:(id)sender;
@end
