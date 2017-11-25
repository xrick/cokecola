//
//  CCCokeBankViewController.h
//  coke
//
//  Created by John on 2011/2/8.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCNetworkAPI.h"


@interface CCCokeBankViewController : UIViewController <UIWebViewDelegate>
{
	NSArray *cokeArray;
	IBOutlet UILabel *collectionCountLabel;
	int collectedCount;
}
-(void)reloadHTML;
-(IBAction)showHelp;

@property(nonatomic,readonly,getter=webView)IBOutlet UIWebView *_webView;
@end
