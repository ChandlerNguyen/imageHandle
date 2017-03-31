//
//  LMCamera.h
//  FilterShowcase
//
//  Created by wzkj on 2016/12/19.
//  Copyright © 2016年 Cell Phone. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

typedef NS_ENUM(NSInteger, LMMediaType) {
    LMMediaTypePhoto,
    LMMediaTypeVideo,
    LMMediaTypeImage
};

@interface LMCamera : UIViewController
@property (nonatomic, assign) BOOL isHighQuality;
-(instancetype)initWithMediaTyp:(LMMediaType)mediaType sessionPresset:(NSString *)sessionPreset  cameraPosition:(AVCaptureDevicePosition)cameraPosition;
-(instancetype)initWithImage:(UIImage *)sourceImage;
@end
