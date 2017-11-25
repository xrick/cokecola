//
//  CCNetworkImageService.h
//  coke
//
//  Created by Franky on 2/5/11.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import "CCNetwork.h"
//#define kNetworkImageServiceBaseURL [NSURL URLWithString:@"http://60.199.208.102/recognize/coca"]
#define kZIRSVersion 1
#define kNetworkImageServiceBaseURL [NSURL URLWithString:@"http://zirs.hiiir.com:8099/recognize/coca"]

@class CCNetworkImageService;

@protocol CCNetworkImageServiceDelegate <NSObject>
- (void)request:(CCNetworkImageService *)request didReceiveImageService:(NSDictionary *)dict;
- (void)request:(CCNetwork *)request hadStatusCodeError:(int)errorCode;
- (void)request:(CCNetwork *)request didFailWithError:(NSError *)error;
@end

@interface CCNetworkImageService : CCNetwork 
{
	id <CCNetworkImageServiceDelegate> _delegate;
}
- (void)postImageData:(NSData *)data;
@property (nonatomic,retain) id <CCNetworkImageServiceDelegate> delegate;

@end
