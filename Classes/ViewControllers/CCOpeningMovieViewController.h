//
//  CCOpeningMovieViewController.h
//  coke
//
//  Created by John on 2011/2/17.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface CCOpeningMovieViewController : UIViewController
{
	MPMoviePlayerViewController *mpvc;
	UIView *touchDetectionView;
}
@end
