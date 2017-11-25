//
//  UIImageView+ASIHttpDownload.m
//  fami
//
//  Created by John on 2011/3/18.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import "UIButton+ASIHttpDownloadImage.h"
#import "ASIDownloadCache.h"

@implementation UIButton (ASIHttpDownloadImage)
-(void)setImageWithASIRequestByURLString:(NSString *)urlString
{
	__block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString] usingCache:[ASIDownloadCache sharedCache] andCachePolicy:ASIUseDefaultCachePolicy];
	[request setCompletionBlock:^{
		[self performSelectorOnMainThread:@selector(setNormalStateImage:) withObject:[[NSData alloc] initWithData:[request responseData]] waitUntilDone:YES];
	}];
	[request setFailedBlock:^{
		ZSLog(@"[UIButton setImageWithASIRequestByURLString]: fetch image failed at :%@", urlString);
	}];
	[request startAsynchronous];
}
-(void)setBackgroundImageWithASIRequestByURLString:(NSString *)urlString
{
	__block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString] usingCache:[ASIDownloadCache sharedCache] andCachePolicy:ASIUseDefaultCachePolicy];
	[request setCompletionBlock:^{
		[self performSelectorOnMainThread:@selector(setNormalStateBackgroundImage:) withObject:[[NSData alloc] initWithData:[request responseData]] waitUntilDone:YES];
	}];
	[request setFailedBlock:^{
		ZSLog(@"[UIButton setBackgroundImageWithASIRequestByURLString]: fetch image failed at :%@", urlString);
	}];
	[request startAsynchronous];
	
}

-(void)setNormalStateImage:(NSData *)imageData
{
	[self setImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
	[imageData release];
}

-(void)setNormalStateBackgroundImage:(NSData *)imageData
{
	UIImage *tempImage = [UIImage imageWithData:imageData];
	float scale = tempImage.size.width / 70.0f;
	NSLog(@"scale:%f",scale);
	UIImage *resizedImage = [UIImage imageWithCGImage:tempImage.CGImage scale:1/scale orientation:UIImageOrientationUp];
	[self setBackgroundImage:resizedImage forState:UIControlStateNormal];
	[imageData release];
}

@end

@implementation UIImageView (ASIHttpDownloadImage)
-(void)setImageWithASIRequestByURLString:(NSString *)urlString
{
	__block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
	[request setCompletionBlock:^{
		[self setImage:[UIImage imageWithData:[request responseData]]];
	}];
	[request setFailedBlock:^{
		ZSLog(@"[UIImageView setImageWithASIRequestByURLString]: fetch image failed at :%@", urlString);
	}];
	[request startAsynchronous];
}

-(void)setImageWithASIRequestwithAutoResizeByURLString:(NSString *)urlString
{
	__block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
	[request setCompletionBlock:^{
		[self setImage:[UIImage imageWithData:[request responseData]]];
		[self sizeToFit];
	}];
	[request setFailedBlock:^{
		ZSLog(@"[UIImageView setImageWithASIRequestByURLString]: fetch image failed at :%@", urlString);
	}];
	[request startAsynchronous];
}

@end