//
//  FaceBookManager.m
//  FaceBookZoaksTest
//
//  Created by Hsu John on 2011/3/5.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FaceBookManager.h"
#import "CCNetworkAPI.h"
#import "CCNetworkCredentials.h"
#import "ZSLocationManager.h"

@interface FaceBookManager(private)
- (BOOL)handleOpenURL:(NSURL *)url;
@end

@implementation FaceBookManager
@synthesize fbInstance, isLoggedIn;
- (id) init
{
	self = [super init];
	if (self != nil) {
		isLoggedIn = NO;
		fbInstance = [[Facebook alloc] initWithAppId:@"208348795849285"];
		permissions =  [[NSArray alloc] initWithObjects:
						  @"read_stream", @"publish_stream",@"user_photos", @"offline_access" ,@"email", @"read_friendlists", nil];

	}
	return self;
}

-(void)postRankInfoWithRankNumber:(int)number
{

//	NSLog(@"postRankInfoWithRankArray:%@",arr);
//	NSMutableArray *ranks = [NSMutableArray array];
/*
	for (int i=0; i<[arr count]; i++) {
		NSDictionary *dict = [arr objectAtIndex:i];
		NSString *rankString = [NSString stringWithFormat:@"第%@名 %@ 數量%@",[dict objectForKey:@"user_rank"],[dict objectForKey:@"user_fb_name"],[dict objectForKey:numberKeyNameString]];
		NSDictionary *rankDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:rankString,@"#",nil] forKeys:[NSArray arrayWithObjects:@"text",@"href",nil]];
		[ranks addObject:rankDict];
	}
	NSString *caption = nil;
	if ([numberKeyNameString isEqualToString:@"rank_counts"]) {
		caption = @"收集總量數";
	}
	else if ([numberKeyNameString isEqualToString:@"rank_styles"]) {
		caption = @"收集款式數";
	}
	else if ([numberKeyNameString isEqualToString:@"rank_missions"]) {
		caption = @"破解任務數";
	}
	else {
		NSAssert(NO,@"unknown rank type defined");
	}

*/
	NSString *name = [NSString stringWithFormat:@"我現在排名第%d名，快來跟我一起收集可口可樂。",number];
	
	NSString *line1 = @"歡慶可口可樂125周年，CokeCollector活動開跑囉！";
	NSString *line2 = @"只要安裝CokeCollector，利用手機進行指定商家招牌拍攝，就可收藏可口可樂紀念瓶在自己";
	NSString *line3 = @"手機中，完整收藏多款可口可樂紀念款，即有機會獲得可口可樂125周年限量紀";
	NSString *line4 = @"念商品及其他優惠！邁向可口可樂收藏家之路，等你來收藏！";
	NSString *description = [[[line1 stringByAppendingString:line2] stringByAppendingString:line3] stringByAppendingString:line4];
	
	SBJSON *jsonWriter = [[SBJSON new] autorelease];
	
	NSDictionary* actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
														   @"CokeCollector",@"text",@"http://www.icoke.com.tw/",@"href", nil], nil];
	
	NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];
	NSDictionary* imageShare = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"image", @"type",
                                @"http://cocacola.hiiir.com/admin/images/coca_icon.png", @"src",
								@"http://www.icoke.com.tw/", @"href",
                                nil];
	
	NSDictionary* attachment = [NSDictionary dictionaryWithObjectsAndKeys:
								name, @"name",
								@"CokeCollector", @"caption",
								description ,@"description",
								//ranks, @"properties",
								[NSArray arrayWithObjects:imageShare, nil ], @"media",
								@"http://www.icoke.com.tw/", @"href", nil];
	NSString *attachmentStr = [jsonWriter stringWithObject:attachment];
	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   @"Share on Facebook",  @"user_message_prompt",
								   actionLinksStr, @"action_links",
								   attachmentStr, @"attachment",
								   nil];
	
	[fbInstance dialog:@"stream.publish" andParams:params andDelegate:self];

}
-(void)postDiscountWithDictionary:(NSDictionary *)dict
{
//	NSLog(@"postDiscountWithDictionary:%@",dict);
	SBJSON *jsonWriter = [[SBJSON new] autorelease];
	
	NSDictionary* actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
														   @"CokeCollector",@"text",@"http://www.icoke.com.tw/",@"href", nil], nil];
	
	NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];
	NSDictionary* imageShare = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"image", @"type",
                                [dict objectForKey:@"discountMsg_image"], @"src",
								@"http://www.icoke.com.tw/", @"href",
                                nil];
	
	NSDictionary* attachment = [NSDictionary dictionaryWithObjectsAndKeys:
								@"可口可樂-優惠訊息", @"name",
								[dict objectForKey:@"discount_name"], @"caption",
								[dict objectForKey:@"discountMsg_description"], @"description",
								[NSArray arrayWithObjects:imageShare, nil ], @"media",
								@"http://www.icoke.com.tw/", @"href", nil];
	NSString *attachmentStr = [jsonWriter stringWithObject:attachment];
	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   @"Share on Facebook",  @"user_message_prompt",
								   actionLinksStr, @"action_links",
								   attachmentStr, @"attachment",
								   nil];
	[fbInstance dialog:@"stream.publish" andParams:params andDelegate:self];
}

/**
 * Show the authorization dialog.
 */
- (void)login {
	if (isLoggedIn) {
		[self logout];
	}
	[fbInstance authorize:permissions delegate:self];
}

/**
 * Invalidate the access token and clear the cookie.
 */
- (void)logout {
	if (!isLoggedIn) {
		return;
	}
	isLoggedIn = NO;
	[fbInstance logout:self];
	[[CCNetworkCredentials sharedManager] setFacebookID:@"" accessToken:@""];
	[[CCNetworkAPI requestToURL:kNetworkAPIBaseURL delegate:self] closeToServer];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
// private
- (BOOL)handleOpenURL:(NSURL *)url
{
	if (isLoggedIn) {
//		NSLog(@"already logged in, ignoring");
		return YES;
	}
	return [fbInstance handleOpenURL:url];
}
///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark Facebook Delegates
/**
 * Called when the user has logged in successfully.
 */
- (void)fbDidLogin {
//	NSLog(@"fbDidLogin");
//	isLoggedIn = YES;
//	[[NSNotificationCenter defaultCenter] postNotificationName:FBDidSuccessLoginNotication object:nil];

//	[[NSNotificationCenter defaultCenter] postNotificationName:FBStartFetchUserDataNotification object:nil];
	[fbInstance requestWithGraphPath:@"me" andDelegate:self];  
/*	[fbInstance requestWithGraphPath:@"me" andParams:						 [NSMutableDictionary dictionaryWithObjectsAndKeys:@"read_stream,publish_stream,user_photos,email",@"scope",nil]

 						 andDelegate:self];  
*/
}

/**
 * Called when the user canceled the authorization dialog.
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
	isLoggedIn = NO;
	ZSLog(@"did not login");
//	[[NSNotificationCenter defaultCenter] postNotificationName:FBDidFetchUserDataNotification object:nil];
}

/**
 * Called when the request logout has succeeded.
 */
- (void)fbDidLogout {
//	[[NSNotificationCenter defaultCenter] postNotificationName:FBDidFetchUserDataNotification object:nil];
	ZSLog(@"fbDidLogout");
	isLoggedIn = NO;
//	[(cokeAppDelegate *)[[UIApplication sharedApplication] delegate] switchToLoginVC];
}


////////////////////////////////////////////////////////////////////////////////
// FBRequestDelegate

/**
 * Called when the Facebook API request has returned a response. This callback
 * gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
	ZSLog(@"received response:%@",response);
}

/**
 * Called when a request returns and its response has been parsed into
 * an object. The resulting object may be a dictionary, an array, a string,
 * or a number, depending on the format of the API response. If you need access
 * to the raw response, use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
	id obj = result;
	if ([obj isKindOfClass:[NSArray class]]) {
		obj = [result objectAtIndex:0];
	}
//	NSLog(@"%@",result);
	if ([obj objectForKey:@"owner"]) {
		ZSLog(@"request didLoad:Photo upload Success");
	} 
	else if ([obj objectForKey:@"name"]) {
//		NSLog(@"request didLoad:%@",result);
		[[CCNetworkCredentials sharedManager] setFacebookID:[obj objectForKey:@"id"] accessToken:[fbInstance accessToken]];
		[[CCNetworkCredentials sharedManager] setFacebookUserName:[NSString stringWithFormat:@"%@", [obj objectForKey:@"name"]]];
		[[CCNetworkCredentials sharedManager] setFacebookEmail:[NSString stringWithFormat:@"%@", [obj objectForKey:@"email"]]];

		[[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithString:[obj objectForKey:@"id"]] forKey:UserDefaultFBIdKey];
		NSString *token = [NSString stringWithString:[[[FaceBookManager sharedManager] fbInstance] accessToken]];
		[[NSUserDefaults standardUserDefaults] setValue:token forKey:UserDefaultFBTokenKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
	/*
		if ([[NSUserDefaults standardUserDefaults] valueForKey:UserDefaultUserNameKey]) {
			[[CCNetworkAPI requestToURL:kNetworkAPIBaseURL delegate:self] restart];
		}
		else {
			[[CCNetworkAPI requestToURL:kNetworkAPIBaseURL delegate:self] registerToServer];
		}
		[(cokeAppDelegate *)[[UIApplication sharedApplication] delegate] switchToTabVC];
*/
		[[NSNotificationCenter defaultCenter] postNotificationName:FBDidFetchUserDataNotification object:nil];
//		[[NSNotificationCenter defaultCenter] postNotificationName:FBDidSuccessLoginNotication object:nil];
		
	}
	isLoggedIn = YES;
};

/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	ZSLog(@"request didFailWithError:%@",[error localizedDescription]);
};


////////////////////////////////////////////////////////////////////////////////
// FBDialogDelegate

/**
 * Called when a UIServer Dialog successfully return.
 */
- (void)dialogDidComplete:(FBDialog *)dialog {
	ZSLog(@"publish successfully");
}

#pragma mark Singleton Methods
+ (id)sharedManager
{
	static FaceBookManager *sharedFaceBookManager = nil;
	if (!sharedFaceBookManager) {
		sharedFaceBookManager = [[FaceBookManager alloc] init];
	}
	return sharedFaceBookManager;
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
