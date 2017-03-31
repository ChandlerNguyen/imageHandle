//
//  LMGPUImageView.h
//  FilterShowcase
//
//  Created by wzkj on 2017/1/10.
//  Copyright © 2017年 Cell Phone. All rights reserved.
//

#import "GPUImage.h"

@interface LMGPUImageView : GPUImageView
/** gl上下文 */
@property (nonatomic, strong) CIContext *ciContext;
/** 滤镜 */
@property (nonatomic, strong) CIFilter  *ciFilter;
/** 被处理图片 */
@property (nonatomic, strong) UIImage   *inputImage;

@end
