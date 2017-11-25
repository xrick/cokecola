//
//  CCCameraViewController+CokeDiscounts.h
//  coke
//
//  Created by John on 2011/2/13.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#if !TARGET_IPHONE_SIMULATOR

#import "CCCameraViewController.h"

@interface CCCameraViewController (CokeDiscounts)
-(void)pauseSessionAndShowCokeDiscount;
-(void)showLoadingDiscountAlert;
-(void)hideLoadingDiscountAlert;
@end
#endif