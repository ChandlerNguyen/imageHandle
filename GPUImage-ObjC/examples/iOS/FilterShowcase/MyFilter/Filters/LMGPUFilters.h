//
//  LMGPUFilters.h
//  FilterShowcase
//
//  Created by wzkj on 2017/1/20.
//  Copyright © 2017年 Cell Phone. All rights reserved.
//

#if __has_include(<GPUImage/GPUImageFramework.h>)
#import <GPUImage/GPUImageFramework.h>
#else
#import "GPUImage.h"
#endif

typedef NS_ENUM(NSInteger, FilterType) {
    FilterTypeNormal,
    FilterTypeSutro,
    FilterTypeAmaro,
    FilterTypeRise,
    FilterTypeHudson,
};


@interface LMGPUFilters : GPUImageFilter

-(instancetype)initWithFilterType:(FilterType)type;

@end
