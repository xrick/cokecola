//
//  CCCaptureBottleViewController.h
//  coke
//
//  Created by John on 2011/2/9.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface CCCaptureBottleViewController : UIViewController 
{
	IBOutlet UIImageView *animationImageView;
	IBOutlet UIImageView *bottleImageView;
}
- (void)restoreToUnopenState;
- (IBAction)playCokeStep1Animation;
- (IBAction)playCokeStep2Animation;

 @property(nonatomic,retain)IBOutlet UIImageView *bottleImageView;
@end
