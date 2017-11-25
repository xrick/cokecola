//
//  UIImageView+ASIHttpDownload.h
//  fami
//
//  Created by John on 2011/3/18.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIButton (ASIHttpDownload)
-(void)setImageWithASIRequestByURLString:(NSString *)urlString;
-(void)setBackgroundImageWithASIRequestByURLString:(NSString *)urlString;

-(void)setNormalStateImage:(NSData *)imageData;
-(void)setNormalStateBackgroundImage:(NSData *)imageData;

@end

@interface UIImageView (ASIHttpDownload)
-(void)setImageWithASIRequestByURLString:(NSString *)urlString;
-(void)setImageWithASIRequestwithAutoResizeByURLString:(NSString *)urlString;
@end
