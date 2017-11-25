//
//  FaceBookManager.h
//  FaceBookZoaksTest
//
//  Created by Hsu John on 2011/3/5.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"


//#define FBDidSuccessLoginNotication @"FBDidSuccessLoginNotication"
//#define FBStartFetchUserDataNotification @"FBStartFetchUserDataNotification"
#define FBDidFetchUserDataNotification @"FBDidFetchUserDataNotification"

@interface FaceBookManager : NSObject <FBRequestDelegate, FBDialogDelegate, FBSessionDelegate>
{
	Facebook *fbInstance;
	NSArray* permissions;
	BOOL isLoggedIn;
}
+ (id)sharedManager;
-(void)postRankInfoWithRankNumber:(int)number;
-(void)postDiscountWithDictionary:(NSDictionary *)dict;

- (void)login;
- (void)logout;
@property(nonatomic,readonly)Facebook *fbInstance;
@property(nonatomic,readonly)BOOL isLoggedIn;
@end
