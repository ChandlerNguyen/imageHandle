//
//  LMGPUBeautyFilter.h
//  FilterShowcase
//
//  Created by wzkj on 2017/1/5.
//  Copyright © 2017年 Cell Phone. All rights reserved.
//

#if __has_include(<GPUImage/GPUImageFramework.h>)
#import <GPUImage/GPUImageFramework.h>
#else
#import "GPUImage.h"
#endif
@interface LMGPUBeautyFilter : GPUImageFilter
@property (nonatomic, assign) CGFloat beautyLevel;
@property (nonatomic, assign) CGFloat brightLevel;
@property (nonatomic, assign) CGFloat toneLevel;
@end
