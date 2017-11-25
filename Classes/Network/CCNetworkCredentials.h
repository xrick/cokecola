//
//  CCNetworkCredentials.h
//  coke
//
//  Created by Franky on 2/5/11.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CCNetworkCredentials : NSObject 
{
	NSString *_UDID;
	NSString *_facebookID;
	NSString *_facebookAccessToken;
	NSString *facebookUserName;
	NSString *facebookEmail;
}
+ (id)sharedManager;
- (void)setFacebookID:(NSString *)fbid accessToken:(NSString *)token;
@property (readonly) NSString *UDID;
@property (readonly) NSString *facebookID;
@property (readonly) NSString *facebookAccessToken;
@property (nonatomic,copy)NSString *facebookUserName;
@property (nonatomic,copy)NSString *facebookEmail;
@end
