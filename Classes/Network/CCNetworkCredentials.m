//
//  CCNetworkCredentials.m
//  coke
//
//  Created by Franky on 2/5/11.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import "CCNetworkCredentials.h"


@implementation CCNetworkCredentials
@synthesize UDID = _UDID;
@synthesize facebookID = _facebookID;
@synthesize facebookAccessToken = _facebookAccessToken;
@synthesize facebookUserName;
@synthesize facebookEmail;
- (void) dealloc
{
	[_UDID release];
	[_facebookID release];
	[super dealloc];
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		_UDID = [[NSString alloc] initWithString:[[UIDevice currentDevice] uniqueIdentifier]];
	}
	return self;
}


- (void)setFacebookID:(NSString *)fbid accessToken:(NSString *)token
{
	_facebookID = [[NSString alloc] initWithString:fbid];
	_facebookAccessToken  = [[NSString alloc] initWithString:token];
}

#pragma mark Singleton Methods
+ (id)sharedManager 
{
    static CCNetworkCredentials *sharedManager = nil;
    if (!sharedManager) {
        sharedManager = [[CCNetworkCredentials alloc] init];
    }
    return sharedManager;
}

- (id)retain 
{
	return self;
}

- (unsigned)retainCount 
{
	return UINT_MAX; // denotes an object that cannot be released
}

- (void)release 
{
	// never release
}

- (id)autorelease 
{
	return self;
}
@end
