//
//  CCDiscountsViewController.h
//  coke
//
//  Created by John on 2011/2/9.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CCDiscountsViewController : UIViewController
{
	NSArray *dataArray;
	IBOutlet UITableView *_tableView;
}

-(void)refreshDataArray;
-(IBAction)showHelp;
@property(nonatomic,readonly,getter=tableView)IBOutlet UITableView *_tableView;
@end
