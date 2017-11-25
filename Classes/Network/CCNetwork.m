//
//  CCNetwork.m
//
//  Created by Chin-Hao Hu on 1/26/11.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import "CCNetwork.h"
#define kTimeOutSecond 300


@implementation CCNetwork
@synthesize responseData = _responseData;
@synthesize url = _url;
@synthesize endSelector = _endSelector;
@synthesize responseStatusCode = _responseStatusCode;

+ (id)requestToURL:(NSURL *)url delegate:(id)del
{
	return nil;
//    CCNetwork *request = [[CCNetwork alloc] init];
//    
//    [request setUrl:url];
//    [request setDelegate:del];
//    [request setEndSelector:nil];
//    
//    return request;
}

- (void)sendRequest:(ASIHTTPRequest *)req
{
	[req setTimeOutSeconds:kTimeOutSecond];
	[req setCachePolicy:ASIDoNotReadFromCacheCachePolicy];
	[req setUseSessionPersistence:NO];
	[req setShouldContinueWhenAppEntersBackground:YES];	
	[req startAsynchronous];
}

@end
