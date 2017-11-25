//
//  CCCollectionViewController.h
//  coke
//
//  Created by Franky on 2/5/11.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCNetworkAPI.h"
#import "XBase.h"
#import "AFOpenFlowView.h"

@interface CCCollectionViewController : UIViewController <CCNetworkAPIDelegate, AFOpenFlowViewDelegate>
{	
    XIBOUTLET AFOpenFlowView *smallOpenFlowView;
    IBOutlet UILabel *coverTitleLabel;
    IBOutlet UILabel *missionDetailLabel;
    int lastIndex;
}
- (IBAction)openCameraVC;
-(IBAction)descriptionAction;
-(IBAction)showHelp;
- (void)missionDetailAtIndex:(int)index;
@property (nonatomic, retain) IBOutlet AFOpenFlowView *smallOpenFlowView;
@property(nonatomic,retain)NSDictionary *currentMissionDictionary;
@end
