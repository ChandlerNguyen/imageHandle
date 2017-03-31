//
//  DoubleCameraViewController.m
//  FilterShowcase
//
//  Created by wzkj on 2017/1/3.
//  Copyright © 2017年 Cell Phone. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "DoubleCameraViewController.h"
#import "LMDialView.h"

@interface DoubleCameraViewController ()<TimeSliderProtocol,LMDialViewDelegate>
@property (nonatomic, strong) AVCaptureSession *frontSession;
@property (nonatomic, strong) AVCaptureSession *backSession;
@property (nonatomic, strong) AVCaptureDevice *frontDevice;
@property (nonatomic, strong) AVCaptureDevice *backDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *frontInput;
@property (nonatomic, strong) AVCaptureDeviceInput *backInput;
@property (nonatomic, strong) AVCaptureStillImageOutput *frontOutput;
@property (nonatomic, strong) AVCaptureStillImageOutput *backOutput;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *frontPreviewLayer;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *backPreviewLayer;

@property (nonatomic, strong)NSArray * hisBlockArray;
@property (nonatomic, strong) TimeSliderView *timeSliderView;
@end
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
@implementation DoubleCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.frontSession = [[AVCaptureSession alloc] init];
    self.backSession  = [[AVCaptureSession alloc] init];
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices){
        if ([device position] == AVCaptureDevicePositionBack){
            self.backDevice = device;
        }else if ([device position] == AVCaptureDevicePositionFront){
            self.frontDevice = device;
        }
    }
    
    self.frontPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.frontSession];
    self.backPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.backSession];
    [self.frontPreviewLayer setFrame:CGRectMake(0, 60, 320, 150)];
    [self.backPreviewLayer setFrame:CGRectMake(0, 212, 320, 100)];
    [self.view.layer addSublayer:self.frontPreviewLayer];
    [self.view.layer addSublayer:self.backPreviewLayer];
    
    
    [self.frontSession beginConfiguration];
    self.frontOutput = [[AVCaptureStillImageOutput alloc] init];
    NSError *error;
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    self.frontInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.frontDevice error:&error];
    [self.frontSession addInput:self.frontInput];
    [self.frontOutput setOutputSettings:outputSettings];
    [self.frontSession addOutput:self.frontOutput];
    [self.frontSession commitConfiguration];
    [self.frontSession startRunning];
    // -----------
    self.backOutput = [[AVCaptureStillImageOutput alloc] init];
    [self.backSession beginConfiguration];
    self.backInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.backDevice error:&error];
    [self.backSession addInput:self.backInput];
    [self.backOutput setOutputSettings:outputSettings];
    [self.backSession addOutput:self.backOutput];
    [self.backSession commitConfiguration];
    [self.backSession startRunning];
    
    
    self.timeSliderView = [[TimeSliderView alloc]initWithFrame:CGRectMake(0, 200, SCREEN_WIDTH, 110)];
    self.timeSliderView.timeDelegate = self;
    self.timeSliderView.currentTime = [NSDate date];
    //设置当天时间段
    self.hisBlockArray = @[@"2016-08-23 00:30:03",
                           @"2016-08-23 04:59:03",
                           @"2016-08-23 09:30:03",
                           @"2016-08-23 15:59:03",
                           @"2016-08-23 17:00:03",
                           @"2016-08-23 17:30:03"];
    NSMutableArray *arr = [NSMutableArray array];
    for (NSString *str  in self.hisBlockArray) {
        
        NSDate * date = [self dateformString:str];
        
        [arr addObject:date];
    }
    self.timeSliderView.hisBlockArray = arr;
    [self.view addSubview:_timeSliderView];
    [self.timeSliderView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [self.timeSliderView addObserver:self forKeyPath:@"isTimeDragging" options:NSKeyValueObservingOptionNew context:nil];
    
    
    LMDialView *dialView = [[LMDialView alloc] initWithFrame:CGRectMake(0, 350, CGRectGetWidth(self.view.frame)*3, 60)];
    dialView.numberOfScale = 10;
    dialView.scaleHeight = 20;
    dialView.numberStepPreScale = 5;
    //dialView.delegate = self;
    
    LMDialScrollView *dialScroll = [[LMDialScrollView alloc] initWithFrame:CGRectMake(0, 300, CGRectGetWidth(self.view.frame), 60) withDialView:dialView];
    [self.view addSubview:dialScroll];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 370, 50, 50)];
    [imageView setImage:[self generateColor:(CGSize){50,50} color:[UIColor lightGrayColor]]];
    [self.view addSubview:imageView];
    
    UIImageView *clipImageView = [[UIImageView alloc] initWithFrame:CGRectMake(90, 370, 30, 30)];
    [clipImageView setBackgroundColor:[UIColor blackColor]];
    [clipImageView setImage:[self genereateClipImage:(CGSize){30,30}]];
    [self.view addSubview:clipImageView];
}

-(UIImage *)generateColor:(CGSize)size color:(UIColor *)color
{
    CGFloat width = MIN(size.width, size.height);
    CGFloat space = 5;
    UIGraphicsBeginImageContextWithOptions((CGSize){width,width}, NO, [UIScreen mainScreen].scale);
    // 圆半径 2 * r + 2 * space + 2 * r * cos30 = width
    CGFloat circleRadius = (width / 2 - space) / (1 + cos(30*M_PI/180)) * 1.2;
    // top circle
    UIBezierPath *topCieclePath = [UIBezierPath bezierPath];
    [topCieclePath addArcWithCenter:CGPointMake(width/2, circleRadius + space) radius:circleRadius startAngle:0 endAngle:M_PI*2 clockwise:YES];
    [color ? color : [UIColor redColor] setFill];
    [topCieclePath fillWithBlendMode:color ? kCGBlendModeMultiply : kCGBlendModePlusLighter alpha:1];
    // left circle
    UIBezierPath *leftCirclePath = [UIBezierPath bezierPath];
    [leftCirclePath addArcWithCenter:CGPointMake(circleRadius + space, width - circleRadius - space) radius:circleRadius startAngle:0 endAngle:M_PI*2 clockwise:YES];
    [color ? color : [UIColor greenColor] setFill];
    [leftCirclePath fillWithBlendMode:color ? kCGBlendModeMultiply : kCGBlendModePlusLighter alpha:1];
    // right circle
    UIBezierPath *rightCirclePath = [UIBezierPath bezierPath];
    [rightCirclePath addArcWithCenter:CGPointMake(width - circleRadius - space, width - circleRadius - space) radius:circleRadius startAngle:0 endAngle:M_PI*2 clockwise:YES];
    [color ? color : [UIColor blueColor] setFill];
    [rightCirclePath fillWithBlendMode:color ? kCGBlendModeMultiply : kCGBlendModePlusLighter alpha:1];
    
    
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(UIImage *)genereateClipImage:(CGSize)size
{
    /***
     裁剪框线 垂直超出的线的长度为 3 水平超出的为5
     中间的缝隙 为 2
     垂直超出线 距箭头 2
     右上角箭头弧线的圆心 x为裁剪框最右边x - 3  y为裁剪框最上边y - 3
     ***/
    
    CGFloat width = MIN(size.width, size.height);
    CGFloat clipAreaWidth = width / 3.0;
    
    UIGraphicsBeginImageContextWithOptions((CGSize){width,width}, NO, [UIScreen mainScreen].scale);
    
    UIBezierPath *clipImagePath = [UIBezierPath bezierPath];
    [clipImagePath moveToPoint:CGPointMake(clipAreaWidth - 2 - 3, clipAreaWidth)];
    [clipImagePath addLineToPoint:CGPointMake(clipAreaWidth * 2, clipAreaWidth)];
    [clipImagePath addLineToPoint:CGPointMake(clipAreaWidth * 2, clipAreaWidth * 2 - 2)];
    //    [clipImagePath closePath];
    
    [clipImagePath moveToPoint:CGPointMake(clipAreaWidth * 2, clipAreaWidth * 2 + 2)];
    [clipImagePath addLineToPoint:CGPointMake(clipAreaWidth * 2, clipAreaWidth * 2 + 2 + 3)];
    //    [clipImagePath closePath];
    
    [clipImagePath moveToPoint:CGPointMake(clipAreaWidth, clipAreaWidth - 2 - 3)];
    [clipImagePath addLineToPoint:CGPointMake(clipAreaWidth, clipAreaWidth - 2)];
    //    [clipImagePath closePath];
    
    [clipImagePath moveToPoint:CGPointMake(clipAreaWidth, clipAreaWidth + 2)];
    [clipImagePath addLineToPoint:CGPointMake(clipAreaWidth, clipAreaWidth * 2)];
    [clipImagePath addLineToPoint:CGPointMake(clipAreaWidth * 2 + 2 + 3, clipAreaWidth * 2)];
    //    [clipImagePath closePath];
    [[UIColor redColor] setStroke];
    [clipImagePath stroke];
    
    CGFloat dashs[] = {1,1};
    UIBezierPath *topRightPath = [UIBezierPath bezierPath];
    [topRightPath addArcWithCenter:CGPointMake(clipAreaWidth * 2 - 3, clipAreaWidth + 3) radius:2+3+2+3 startAngle:0 endAngle:-90*M_PI/180 clockwise:NO];
    [topRightPath setLineDash:dashs count:3 phase:0];
    [[UIColor redColor] setStroke];
    [topRightPath stroke];
    
    UIBezierPath *topRightArrowPath = [UIBezierPath bezierPath];
    // 三角形边长 4
    [topRightArrowPath moveToPoint:CGPointMake(clipAreaWidth * 2 - 3 - 4 * cos(30*M_PI/180), clipAreaWidth - 2 - 3 -2)];
    [topRightArrowPath addLineToPoint:CGPointMake(clipAreaWidth * 2 - 3, clipAreaWidth - 2 - 3 - 2 + 4/2)];
    [topRightArrowPath addLineToPoint:CGPointMake(clipAreaWidth * 2 - 3, clipAreaWidth - 2 - 3 - 2 - 4/2)];
    [topRightArrowPath closePath];
    [[UIColor redColor] setFill];
    [topRightArrowPath fill];
    
    UIBezierPath *leftBottonPath = [UIBezierPath bezierPath];
    [leftBottonPath addArcWithCenter:CGPointMake(clipAreaWidth + 3, clipAreaWidth*2 - 3) radius:2+3+2+3 startAngle:180*M_PI/180 endAngle:90*M_PI/180 clockwise:NO];
    [leftBottonPath setLineDash:dashs count:3 phase:0];
    [[UIColor redColor] setStroke];
    [leftBottonPath stroke];
    
    UIBezierPath *leftBottomArrowPath = [UIBezierPath bezierPath];
    [leftBottomArrowPath moveToPoint:CGPointMake(clipAreaWidth + 3 + 4 * cos(30*M_PI/180), clipAreaWidth * 2 + 2 + 3 + 2)];
    [leftBottomArrowPath addLineToPoint:CGPointMake(clipAreaWidth + 3, clipAreaWidth * 2 + 2+ 3 + 2 - 4/2)];
    [leftBottomArrowPath addLineToPoint:CGPointMake(clipAreaWidth + 3, clipAreaWidth * 2 + 2 +3 +2 + 4/2)];
    [leftBottomArrowPath closePath];
    [[UIColor redColor] setFill];
    [leftBottomArrowPath fill];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return  image;
}

//-(NSString *)scaleTitle:(LMDialView *)dialView scaleIndex:(NSInteger)scaleIndex
//{
//    CGFloat scale = scaleIndex * 1.0 /dialView.numberOfScale;
//    if (scale < 0.1) {
//        return @"0";
//    }
//    
//    if(scale == 1){
//        return @"1";
//    }
//    return [NSString stringWithFormat:@"%.1f",scale];
//}


- (NSDate *)dateformString:(NSString *)dateStr{
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *fromdate=[format dateFromString:dateStr];
    return fromdate;
}
-(void)onTimeSliderSelectedTime:(NSDate *)time{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm:ss";
    NSLog(@"time-- %@", [formatter stringFromDate:time]);
    
}
#pragma mark - 拖动显示时间
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]&&self.timeSliderView.isDragging) {
        [self showDate:[self.timeSliderView getDateForOffset]];
    }
    if ([keyPath isEqualToString:@"isTimeDragging"]&&!self.timeSliderView.isTimeDragging) {
        [timeshow removeFromSuperview];
        timeshow = nil;
    }
}

static UILabel *timeshow = nil;

- (void)showDate:(NSDate *)time
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    if (!timeshow) {
        timeshow = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 80, 150, 160, 40)];
        timeshow.textAlignment = NSTextAlignmentCenter;
        timeshow.textColor = [UIColor whiteColor];
        timeshow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        timeshow.font = [UIFont systemFontOfSize:15];
        timeshow.clipsToBounds = YES;
        timeshow.layer.cornerRadius = 5;
        [[UIApplication sharedApplication].keyWindow addSubview:timeshow];
    }
    timeshow.text = [formatter stringFromDate:time];
}


-(void)dealloc{
    [self.timeSliderView removeObserver:self forKeyPath:@"contentOffset"];
    [self.timeSliderView removeObserver:self forKeyPath:@"isTimeDragging"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
