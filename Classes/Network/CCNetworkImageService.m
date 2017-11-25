//
//  CCNetworkImageService.m
//  coke
//
//  Created by Franky on 2/5/11.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import "CCNetworkImageService.h"
#import "CJSONDeserializer.h"


@implementation CCNetworkImageService
@synthesize delegate = _delegate;

+ (id)requestToURL:(NSURL *)url delegate:(id)del
{
    CCNetworkImageService *request = [[CCNetworkImageService alloc] init];
    [request setUrl:url];
    [request setDelegate:del];    
    return request;
}

- (void)postImageData:(NSData *)data
{
	__block ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:_url];
	[req appendPostData:data];
	[req setRequestMethod:@"POST"];
	[req setDelegate:self];
	[req setCompletionBlock:^{
//		NSLog(@"setCompletionBlock: %@", [req responseString]);
		_responseData = [[NSData alloc] initWithData:[req responseData]];
		_responseStatusCode = [req responseStatusCode];
		if (_responseStatusCode >= 400) {
			if (self.delegate && [self.delegate respondsToSelector:@selector(request:hadStatusCodeError:)]) {
				[self.delegate request:self hadStatusCodeError:_responseStatusCode];
			}
			return;
		}
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didReceiveImageService:)]) {
			NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:_responseData error:nil];
			[self.delegate request:self didReceiveImageService:dict];
		}	
	}];
	[req setFailedBlock:^{
		NSError *err = [req error];
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
			[self.delegate request:self didFailWithError:err];
		}
	}];
	[self sendRequest:req];
}
@end
