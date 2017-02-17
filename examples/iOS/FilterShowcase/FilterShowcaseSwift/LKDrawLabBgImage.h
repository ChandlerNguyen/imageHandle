//
//  LKDrawLabBgImage.h
//  FilterShowcase
//
//  Created by wzkj on 2017/2/3.
//  Copyright © 2017年 Sunset Lake Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

/** 将文字生成图片 */
@interface LKDrawLabBgImage : NSObject
/*
 UIFont *_strFont = [UIFont fontWithName: size:];
 传入字体大小和字体
 */

/*
 _strContent:要显示的内容
 */

+ (UIImageView*)getParameterCreateLabBgImage:(NSString*)_strContent strFont:(UIFont*)_strFont;

@end
