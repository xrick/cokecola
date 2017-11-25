//
//  CCNetwork.h
//
//  Created by Chin-Hao Hu on 1/26/11.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

#define NSStringToURL(blah) [NSURL URLWithString:[blah stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]

@interface CCNetwork : NSObject 
{
	SEL _endSelector;
	NSData *_responseData;
	NSURL *_url;
	NSInteger _responseStatusCode;
}
+ (id)requestToURL:(NSURL *)url delegate:(id)del;
- (void)sendRequest:(ASIHTTPRequest *)req;
@property (retain) NSData *responseData;
@property (retain) NSURL *url;
@property (assign) SEL endSelector;
@property (assign) NSInteger responseStatusCode;
@end
