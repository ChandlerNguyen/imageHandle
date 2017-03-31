//
//  LMGPUImageView.m
//  FilterShowcase
//
//  Created by wzkj on 2017/1/10.
//  Copyright © 2017年 Cell Phone. All rights reserved.
//

#import "LMGPUImageView.h"

@implementation LMGPUImageView

-(instancetype)init
{
    if (self = [super init]) {
        [self setUp];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}

-(void)setUp{
    self.inputImage = [UIImage imageNamed:@"WID-small.jpg"];
}

-(void)setCiFilter:(CIFilter *)ciFilter
{
    [GPUImageContext useImageProcessingContext];
    self.ciContext = [CIContext contextWithEAGLContext:[GPUImageContext sharedImageProcessingContext].context];
    _ciFilter = ciFilter;
    [self drawRect:self.bounds];
}

-(void)drawRect:(CGRect)rect
{
    if (self.ciContext != nil && self.inputImage != nil && self.ciFilter != nil) {
        CIImage *ciInputImage = [[CIImage alloc] initWithImage:_inputImage];
        [self.ciFilter setValue:ciInputImage forKey:kCIInputImageKey];
        
        CIImage *ciOutputImage = self.ciFilter.outputImage;
        if (ciOutputImage) {
            [self clearnBackground];
            CGRect inputBounds = ciInputImage.extent;
            CGRect targetBounds = [self imageBoundsForContentMode:inputBounds toRect:self.bounds];
            [self.ciContext drawImage:ciOutputImage inRect:targetBounds fromRect:inputBounds];
        }
    }
}


-(void)clearnBackground
{
    CGFloat r = 0;
    CGFloat g = 0;
    CGFloat b = 0;
    CGFloat a = 0;
    [self.backgroundColor getRed:&r green:&g blue:&b alpha:&a];
    
    glClearColor(r, g,b,a);
    glClear(GL_COLOR_BUFFER_BIT);
}

-(CGRect)aspectFit:(CGRect)fromRect toRect:(CGRect)toRect
{
    CGFloat fromAspectRatio = fromRect.size.width / fromRect.size.height;
    CGFloat toAspectRatio = toRect.size.width / toRect.size.height;
    
    CGRect fitRect = toRect;
    
    if (fromAspectRatio > toAspectRatio) {
        fitRect.size.height = toRect.size.width / fromAspectRatio;
        fitRect.origin.y += (toRect.size.height - fitRect.size.height) * 0.5;
    } else {
        fitRect.size.width = toRect.size.height  * fromAspectRatio;
        fitRect.origin.x += (toRect.size.width - fitRect.size.width) * 0.5;
    }
    
    return CGRectIntegral(fitRect);
}

-(CGRect)aspectFill:(CGRect)fromRect toRect:(CGRect)toRect
{
    CGFloat fromAspectRatio = fromRect.size.width / fromRect.size.height;
    CGFloat toAspectRatio = toRect.size.width / toRect.size.height;
    
    CGRect fillRect = toRect;
    
    if (fromAspectRatio > toAspectRatio) {
        fillRect.size.width = toRect.size.height  * fromAspectRatio;
        fillRect.origin.x += (toRect.size.width - fillRect.size.width) * 0.5;
    } else {
        fillRect.size.height = toRect.size.width / fromAspectRatio;
        fillRect.origin.y += (toRect.size.height - fillRect.size.height) * 0.5;
    }
    
    return CGRectIntegral(fillRect);
}

-(CGRect)imageBoundsForContentMode:(CGRect)fromRect toRect:(CGRect)toRect
{
    CGRect rect = CGRectZero;
    switch (self.contentMode) {
        case UIViewContentModeScaleAspectFit:
            [self aspectFit:fromRect toRect:toRect];
            break;
        case UIViewContentModeScaleAspectFill:
            [self aspectFill:fromRect toRect:toRect];
            break;
            
        default:
            rect = fromRect;
            break;
    }
    return rect;
}

@end
