//
//  LMCamera.m
//  FilterShowcase
//
//  Created by wzkj on 2016/12/19.
//  Copyright © 2016年 Cell Phone. All rights reserved.
//

#import "LMCamera.h"
#import "GPUImage.h"
#import "LMGPUBeautyFilter.h"
#import "LMGPUImageView.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
#import "FilterShowcase-Swift.h"
//******************//
@interface LMCamera ()
{
    GPUImageMovieWriter *movieWriter;
}

/** 视频文件临时保存位置 */
@property (nonatomic, strong) NSURL         *fileURLForTempMovie;
/** 媒体类型 */
@property (nonatomic, assign) LMMediaType   mediaType;
/** 相机 摄像机 */
@property (nonatomic, strong) GPUImageStillCamera *camera;
/** 滤镜 */
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;
/** 图片原图 */
@property (nonatomic, strong) GPUImagePicture *sourcePicture;
/** 过滤视图 */
@property (nonatomic, strong) GPUImageView    *filterView;
/** filter view */
@property (nonatomic, strong) LMFilterCollectionView *filterCollectionView;
/** effect view */
@property (nonatomic, strong) LMEffectTableView *effectTableView;
/** 底部工具栏 */
@property (nonatomic, weak)   UIToolbar         *toolBar;


@end

@implementation LMCamera

-(instancetype)initWithMediaTyp:(LMMediaType)mediaType sessionPresset:(NSString *)sessionPreset cameraPosition:(AVCaptureDevicePosition)cameraPosition
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.mediaType = mediaType;
        _camera = [[GPUImageStillCamera alloc] initWithSessionPreset:sessionPreset cameraPosition:cameraPosition];
        _camera.outputImageOrientation = UIInterfaceOrientationPortrait;
        _camera.horizontallyMirrorFrontFacingCamera = NO;
        _camera.horizontallyMirrorRearFacingCamera = NO;
        [self setup];
        [_camera addTarget:self.filter];
        [self.filter addTarget:self.filterView];
        [_camera startCameraCapture];
    }
    return self;
}

-(instancetype)initWithImage:(UIImage *)sourceImage
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.mediaType = LMMediaTypeImage;
        @try {
            self.sourcePicture = [[GPUImagePicture alloc] initWithImage:sourceImage smoothlyScaleOutput:YES];
        } @catch (NSException *exception) {
            
        } @finally {
            if (self.sourcePicture) {
                [self setup];
                [self.sourcePicture addTarget:self.filterView];
                [self.filter forceProcessingAtSize:self.filterView.sizeInPixels];
                [self.sourcePicture addTarget:self.filter];
                [self.filter addTarget:self.filterView];
                LMGPUBeautyFilter *beautyFilter = [[LMGPUBeautyFilter alloc] init];
                [self.filter addTarget:beautyFilter];
                [self.sourcePicture processImage];
            }
        }
    }
    return self;
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.filterView];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:(CGRect){CGPointMake(0, CGRectGetMaxY(self.view.frame)),CGSizeMake(CGRectGetWidth(self.view.frame), 0)}];
    [self.view addSubview:toolBar];
    
    UIBarButtonItem *filterItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showFilterPreview:)];
    UIBarButtonItem *effectItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(showEffectPreview:)];
    [toolBar setItems:@[filterItem,effectItem]];
    self.toolBar = toolBar;
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.filterView setFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 64 - 44)];
    [self.toolBar setFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 44, CGRectGetWidth(self.view.frame), 44)];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // Map UIDeviceOrientation to UIInterfaceOrientation.
    UIInterfaceOrientation orient = UIInterfaceOrientationPortrait;
    switch ([[UIDevice currentDevice] orientation]){
        case UIDeviceOrientationLandscapeLeft:
            orient = UIInterfaceOrientationLandscapeLeft;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            orient = UIInterfaceOrientationLandscapeRight;
            break;
            
        case UIDeviceOrientationPortrait:
            orient = UIInterfaceOrientationPortrait;
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            orient = UIInterfaceOrientationPortraitUpsideDown;
            break;
            
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationUnknown:
            // When in doubt, stay the same.
            orient = fromInterfaceOrientation;
            break;
    }
    _camera.outputImageOrientation = orient;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES; // Support all orientations.
}

#pragma mark ------------- setter
-(void)setIsHighQuality:(BOOL)isHighQuality
{
    if (_isHighQuality^isHighQuality) {
        _isHighQuality = isHighQuality;
        self.filterView.layer.contentsScale = isHighQuality ? 2.0f : 1.0f;
    }
}

#pragma mark ------------- getter
-(LMFilterCollectionView *)filterCollectionView
{
    if (!_filterCollectionView) {
        UIImage *image = [UIImage imageNamed:@"WID-small.jpg"];
        _filterCollectionView = [[LMFilterCollectionView alloc] initWithFrame:(CGRect){CGPointZero,(CGSize){CGRectGetWidth(self.view.frame),0}} image:image];
    }
    return _filterCollectionView;
}

-(LMEffectTableView *)effectTableView
{
    if (!_effectTableView) {
        _effectTableView = [[LMEffectTableView alloc] initWithFrame:(CGRect){CGPointZero,(CGSize){CGRectGetWidth(self.view.frame),0}} style:UITableViewStyleGrouped];
    }
    return _effectTableView;
}


#pragma mark ------------- private
- (NSURL *)fileURLForTempMovie
{
    static NSURL *tempMoviewURL = nil;
    @synchronized(self) {
        if (tempMoviewURL == nil) {
            tempMoviewURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"temp.m4v"]];
        }
    }
    return tempMoviewURL;
}

-(void)setup
{
    self.filterView = [[GPUImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    UITapGestureRecognizer *signalTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [signalTap setNumberOfTapsRequired:1];
    [signalTap setNumberOfTouchesRequired:1];
    [self.view/*filterView*/ addGestureRecognizer:signalTap];
    self.filter = [[GPUImageSepiaFilter alloc] init];
}

-(void)tapAction:(UIGestureRecognizer *)gesture
{
    
}
#define ToolsViewHeight 80
-(void)showFilterPreview:(id)sender
{
    if (self.filterCollectionView.superview == nil) {
        [self.filterCollectionView setFrame:CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), ToolsViewHeight)];
        
        [self.view insertSubview:self.filterCollectionView belowSubview:self.toolBar];
    }
    [UIView animateWithDuration:0.5 animations:^{
        [self.filterView setFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 64 - 44 - ToolsViewHeight)];
        [self.filterCollectionView setFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 44 - ToolsViewHeight, CGRectGetWidth(self.view.frame), ToolsViewHeight)];
        [self.toolBar setFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 44, CGRectGetWidth(self.view.frame), 44)];
    }];
}

-(void)showEffectPreview:(id)sender
{
    if (self.effectTableView.superview == nil) {
        [self.effectTableView setFrame:CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), ToolsViewHeight)];
        [self.view insertSubview:self.effectTableView belowSubview:self.toolBar];
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.filterView setFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 64 - 44 - ToolsViewHeight)];
        [self.effectTableView setFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 44 - ToolsViewHeight, CGRectGetWidth(self.view.frame), ToolsViewHeight)];
        [self.toolBar setFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 44, CGRectGetWidth(self.view.frame), 44)];
    }];
}
typedef enum {CubeAnimationTypeHorizontal, CubeAnimationTypeVertical} CubeAnimationType;

#define TIME_ANIMATION 1.0
#define PERSPECTIVE -1.0 / 200.0

#pragma mark - Cube animating methods
/**
 Function that creates the cube animation transition between fromImage and toImage
 */
- (void) makeCubeAnimationFrom:(UIView *)fromView to: (UIView *)toView direction:(CubeAnimationType)animationType isReverse:(BOOL)isReverse withCompletion:(void(^)(void))completion
{
    //We need to calculate the animation direcction
    int dir=!isReverse ? 1 : -1;
    
    //We create a content view for do the translate animation
    UIView *generalContentView = [[UIView alloc] initWithFrame:fromView.frame];
    
    [generalContentView setBackgroundColor:[UIColor redColor]];
    CGRect frame = fromView.frame;
    frame.origin = CGPointZero;
    fromView.frame = frame;
    toView.frame = frame;
    [generalContentView addSubview:fromView];
    [generalContentView addSubview:toView];
    //Crete the differents 3D animations
    CATransform3D viewFromTransform;
    CATransform3D viewToTransform;
    
    switch (animationType) {
        case CubeAnimationTypeHorizontal:
            viewFromTransform = CATransform3DMakeRotation(dir*M_PI_2, 0.0, 1.0, 0.0);
            viewToTransform = CATransform3DMakeRotation(-dir*M_PI_2, 0.0, 1.0, 0.0);
            [toView.layer setAnchorPoint:CGPointMake(!isReverse?0:1, 0.5)];
            [fromView.layer setAnchorPoint:CGPointMake(!isReverse?1:0, 0.5)];
            break;
            
        case CubeAnimationTypeVertical:
            viewFromTransform = CATransform3DMakeRotation(M_PI_2, 1.0, 0.0, 0.0);
            viewFromTransform = CATransform3DMakeRotation(-dir*M_PI_2, 1.0, 0.0, 0.0);
            viewToTransform = CATransform3DMakeRotation(dir*M_PI_2, 1.0, 0.0, 0.0);
            [toView.layer setAnchorPoint:CGPointMake(0.5, !isReverse?0:1)];
            [fromView.layer setAnchorPoint:CGPointMake(0.5, !isReverse?1:0)];
            break;
            
        default:
            break;
    }
    
    viewFromTransform.m34 = PERSPECTIVE;
    viewToTransform.m34 = PERSPECTIVE;
    
    toView.layer.transform = viewToTransform;
    
    //Add the subviews
    [self.view addSubview:generalContentView];
    //Make the animation
    [UIView animateWithDuration:TIME_ANIMATION*20 animations:^{
        fromView.layer.transform = viewFromTransform;
        toView.layer.transform = CATransform3DIdentity;
    }completion:^(BOOL finished) {
        
        [fromView removeFromSuperview];
        [toView removeFromSuperview];
        toView.frame = generalContentView.frame;
        [self.view insertSubview:toView aboveSubview:self.toolBar];
        [generalContentView removeFromSuperview];
        if(completion){
            completion();
        }
    }];
}



#pragma mark - Image Reflection

CGImageRef CreateGradientImage(NSInteger pixelsWide, NSInteger pixelsHigh)
{
    CGImageRef theCGImage = NULL;
    
    // gradient is always black-white and the mask must be in the gray colorspace
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // create the bitmap context
    CGContextRef gradientBitmapContext = CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh,
                                                               8, 0, colorSpace, kCGImageAlphaNone);
    
    // define the start and end grayscale values (with the alpha, even though
    // our bitmap context doesn't support alpha the gradient requires it)
    CGFloat colors[] = {0.0, 1.0, 1.0, 1.0};
    
    // create the CGGradient and then release the gray color space
    CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
    CGColorSpaceRelease(colorSpace);
    
    // create the start and end points for the gradient vector (straight down)
    CGPoint gradientStartPoint = CGPointZero;
    CGPoint gradientEndPoint = CGPointMake(0, pixelsHigh);
    
    // draw the gradient into the gray bitmap context
    CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint,
                                gradientEndPoint, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(grayScaleGradient);
    
    // convert the context into a CGImageRef and release the context
    theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
    CGContextRelease(gradientBitmapContext);
    
    // return the imageref containing the gradient
    return theCGImage;
}

CGContextRef MyCreateBitmapContext(NSInteger pixelsWide, NSInteger pixelsHigh)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create the bitmap context
    CGContextRef bitmapContext = CGBitmapContextCreate (NULL, pixelsWide, pixelsHigh, 8,
                                                        0, colorSpace,
                                                        // this will give us an optimal BGRA format for the device:
                                                        (kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
    CGColorSpaceRelease(colorSpace);
    
    return bitmapContext;
}

- (UIImage *)reflectedImage:(UIImageView *)fromImage withHeight:(NSInteger)height
{
    if (height == 0)
        return nil;
    
    // create a bitmap graphics context the size of the image
    CGContextRef mainViewContentContext = MyCreateBitmapContext(fromImage.bounds.size.width, height);
    
    // create a 2 bit CGImage containing a gradient that will be used for masking the
    // main view content to create the 'fade' of the reflection.  The CGImageCreateWithMask
    // function will stretch the bitmap image as required, so we can create a 1 pixel wide gradient
    CGImageRef gradientMaskImage = CreateGradientImage(1, height);
    
    // create an image by masking the bitmap of the mainView content with the gradient view
    // then release the  pre-masked content bitmap and the gradient bitmap
    CGContextClipToMask(mainViewContentContext, CGRectMake(0.0, 0.0, fromImage.bounds.size.width, height), gradientMaskImage);
    CGImageRelease(gradientMaskImage);
    
    // In order to grab the part of the image that we want to render, we move the context origin to the
    // height of the image that we want to capture, then we flip the context so that the image draws upside down.
    CGContextTranslateCTM(mainViewContentContext, 0.0, height);
    CGContextScaleCTM(mainViewContentContext, 1.0, -1.0);
    
    // draw the image into the bitmap context
    CGContextDrawImage(mainViewContentContext, fromImage.bounds, fromImage.image.CGImage);
    
    // create CGImageRef of the main view bitmap content, and then release that bitmap context
    CGImageRef reflectionImage = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);
    
    // convert the finished reflection image to a UIImage
    UIImage *theImage = [UIImage imageWithCGImage:reflectionImage];
    
    // image is retained by the property setting above, so we can release the original
    CGImageRelease(reflectionImage);
    
    return theImage;
}
#pragma mark - Image Reflection end
@end
