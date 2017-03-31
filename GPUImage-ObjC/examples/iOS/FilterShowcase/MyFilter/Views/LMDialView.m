//
//  LMDialView.m
//  FilterShowcase
//
//  Created by wzkj on 2017/1/9.
//  Copyright © 2017年 Cell Phone. All rights reserved.
//

#import "LMDialView.h"
#import "ULCUIColor-Expanded.h"
#import <AudioToolbox/AudioToolbox.h>
// ********************** /
@interface LMDialView ()
/**
 获取某个点位置的刻度值
 
 @param point 点位置
 @return 刻度值
 */
-(CGFloat)scaleValueForTargetPoint:(CGPoint)point;
@end

@implementation LMDialView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

-(void)setup{
    self.horizentalMergin = 8;
    self.dialAlignment = LMDialAlignmentCenter;
    self.dialType = LMDialTypeHorizental;
    self.scaleHeight = 30;
    self.stepHeight = 10;
    self.numberOfScale = 10;
    self.numberStepPreScale = 5;
    self.scaleTitleFont = [UIFont systemFontOfSize:11];
    self.dialRatio = 1.0f;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context  = UIGraphicsGetCurrentContext();
    
    // 背景色
    CGContextSetFillColorWithColor(context, [UIColor colorWithRGBHex:0x999999].CGColor);
    CGContextAddRect(context, rect);
    CGContextFillPath(context);
    
    switch (self.dialType) {
        case LMDialTypeHorizental:{
            [self drawHorizentalDialInContext:context withRect:rect];
            break;
        }
            
        default:
            break;
    }
}

- (void)drawHorizentalDialInContext:(CGContextRef)context withRect:(CGRect)rect
{
    // 水平刻度线
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRGBHex:0xffffff].CGColor);
    NSInteger index = 0;
    NSInteger scales = self.numberOfScale * self.numberStepPreScale;
    NSDictionary *attributes = @{NSFontAttributeName : self.scaleTitleFont,NSForegroundColorAttributeName : [UIColor whiteColor]};
    CGFloat titleHeight = [@"1" sizeWithAttributes:attributes].height;
    CGFloat vSpace = (CGRectGetHeight(rect) - self.scaleHeight - titleHeight)/3;
    
    CGFloat minY = titleHeight + vSpace*2;
    CGFloat width = (CGRectGetWidth(rect)*1.0 - self.horizentalMergin*2)/scales;
    
    do {
        NSInteger scale = index % self.numberStepPreScale;
        CGFloat height = scale == 0 ? self.scaleHeight : self.stepHeight;
        CGFloat scaleMinY = minY + (CGRectGetHeight(rect) - minY - height)/2.0;
        CGFloat scaleMinX = self.horizentalMergin + index * width;
        // 大刻度文字标识
        if (scale == 0) {
            // 大刻度标识
            NSInteger dialIndex = index/self.numberStepPreScale;
            NSString *title = nil;
            if (self.delegate && [self.delegate respondsToSelector:@selector(scaleTitle:scaleIndex:)]) {
                title = [self.delegate scaleTitle:self scaleIndex:dialIndex];
            }else{
                title = [NSString stringWithFormat:@"%.1f",dialIndex * self.dialRatio / self.numberOfScale];
            }
            if (title) {
                CGSize size = [title sizeWithAttributes:attributes];
                CGPoint drawPoint = CGPointMake(scaleMinX + 1 - size.width/2.0, vSpace);
                [title drawAtPoint:drawPoint withAttributes:attributes];
            }
            
        }
        
        CGContextSetLineWidth(context, 1);
        CGContextMoveToPoint(context, scaleMinX, scaleMinY);
        CGContextAddLineToPoint(context, scaleMinX, scaleMinY+height);
        index++;
    } while (index<=scales);
    
    CGContextStrokePath(context);
}

-(CGFloat)scaleValueForTargetPoint:(CGPoint)point
{
    // 步宽
    CGFloat scaleWidth = (CGRectGetWidth(self.frame)*1.0 - self.horizentalMergin*2)/self.numberOfScale;
    CGFloat stepWidth = scaleWidth / self.numberStepPreScale;
    NSInteger scaleIndex = floorf(point.x / scaleWidth);
    NSInteger liveStepIndex = floorf((point.x - scaleIndex * scaleWidth) / stepWidth);
    return scaleIndex * 1.0/self.numberOfScale + liveStepIndex * 1.0 / (self.numberStepPreScale * self.numberOfScale);
}

@end


/**
 刻度盘中线类型
 
 - LMDialCenterLineTypeSingle: 单条线
 - LMDialCenterLineTypeDouble: 两边三角形
 - LMDialCenterLineTypeTop: 顶部三角形
 - LMDialCenterLineTypeBottom: 底部三角形
 - LMDialCenterLineTypeArcDouble: 两端圆弧
 - LMDialCenterLineTypeArcTop: 顶部圆弧
 - LMDialCenterLineTypeArcBottom: 底部圆弧
 */
typedef NS_ENUM(NSInteger,LMDialCenterLineType) {
    LMDialCenterLineTypeSingle,
    LMDialCenterLineTypeDouble,
    LMDialCenterLineTypeTop,
    LMDialCenterLineTypeBottom,
    LMDialCenterLineTypeArcDouble,
    LMDialCenterLineTypeArcTop,
    LMDialCenterLineTypeArcBottom
};

@interface LMDialCenterLineView : UIView
/** 类型 */
@property (nonatomic, assign) LMDialCenterLineType type;
/** 线条颜色 */
@property (nonatomic, strong) UIColor *lineColor;
/** 线宽 */
@property (nonatomic, assign) CGFloat lineWidth;
@end

@interface LMDialCenterLineView ()
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat height;
@end
@implementation LMDialCenterLineView

-(instancetype)init{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setUp];
    }
    return self;
}

-(void)setUp
{
    self.type = LMDialCenterLineTypeBottom;
    self.lineColor = [UIColor greenColor];
    self.lineWidth = 1;
    self.centerX = CGRectGetWidth(self.frame)/2;
    self.height = CGRectGetWidth(self.frame)/2;
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 背景色
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextAddRect(context, rect);
    CGContextFillPath(context);
    
    CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
    
    switch (self.type) {
        case LMDialCenterLineTypeSingle:
            [self drawLineInContext:context rect:rect];
            break;
        case LMDialCenterLineTypeDouble:
            [self drawTopInContext:context rect:rect];
            [self drawLineInContext:context rect:rect];
            [self drawBottomInContext:context rect:rect];
            break;
        case LMDialCenterLineTypeTop:
            [self drawTopInContext:context rect:rect];
            [self drawLineInContext:context rect:rect];
            break;
        case LMDialCenterLineTypeBottom:
            [self drawLineInContext:context rect:rect];
            [self drawBottomInContext:context rect:rect];
            break;
        case LMDialCenterLineTypeArcDouble:
            [self drawTopArcInContext:context rect:rect];
            [self drawLineInContext:context rect:rect];
            [self drawBottomArcInContext:context rect:rect];
            break;
        case LMDialCenterLineTypeArcTop:
            [self drawTopArcInContext:context rect:rect];
            [self drawLineInContext:context rect:rect];
            break;
        case LMDialCenterLineTypeArcBottom:
            [self drawLineInContext:context rect:rect];
            [self drawBottomArcInContext:context rect:rect];
            break;
        default:
            break;
    }
    
    CGContextStrokePath(context);
}

-(void)drawTopInContext:(CGContextRef)context rect:(CGRect)rect
{
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextMoveToPoint(context, self.centerX - self.height, 0);
    CGContextAddLineToPoint(context, self.centerX, self.height);
    CGContextAddLineToPoint(context, self.centerX + self.height, 0);
    CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
    // 开始绘制  绘制带填充色
    CGContextDrawPath(context, kCGPathFillStroke);
    /*CGPathDrawingModekCGPathFill填充非零绕数规则,kCGPathEOFill表示用奇偶规则,kCGPathStroke路径,kCGPathFillStroke路径填充,kCGPathEOFillStroke表示描线 ，不是填充*/
}

-(void)drawLineInContext:(CGContextRef)context rect:(CGRect)rect
{
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    CGContextSetLineWidth(context, self.lineWidth);
    switch (self.type) {
        case LMDialCenterLineTypeTop:
        case LMDialCenterLineTypeArcTop:
            CGContextMoveToPoint(context, self.centerX, self.height);
            CGContextAddLineToPoint(context, self.centerX, CGRectGetHeight(rect));
            break;
        case LMDialCenterLineTypeDouble:
        case LMDialCenterLineTypeArcDouble:
            CGContextMoveToPoint(context, self.centerX, self.height);
            CGContextAddLineToPoint(context, self.centerX, CGRectGetHeight(rect) - self.height);
            break;
        case LMDialCenterLineTypeBottom:
        case LMDialCenterLineTypeArcBottom:
            CGContextMoveToPoint(context, self.centerX, 0);
            CGContextAddLineToPoint(context, self.centerX, CGRectGetHeight(rect) - self.height);
            break;
        default:
            CGContextMoveToPoint(context, self.centerX, 0);
            CGContextAddLineToPoint(context, self.centerX, CGRectGetHeight(rect));
            break;
    }
    // 开始绘制 只是绘制路径
    CGContextStrokePath(context);
}

-(void)drawBottomInContext:(CGContextRef)context rect:(CGRect)rect{
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextMoveToPoint(context, self.centerX - self.height, CGRectGetHeight(rect));
    CGContextAddLineToPoint(context, self.centerX, CGRectGetHeight(rect) - self.height);
    CGContextAddLineToPoint(context, self.centerX + self.height, CGRectGetHeight(rect));
    CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextDrawPath(context, kCGPathFillStroke);
}

-(void)drawTopArcInContext:(CGContextRef)context rect:(CGRect)rect
{
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextMoveToPoint(context, self.centerX - self.height, 0);
    CGContextAddArcToPoint(context, self.centerX, 0, self.centerX, self.height, self.height);
    CGContextAddArcToPoint(context, self.centerX, 0, self.centerX + self.height, 0, self.height);
    CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
    // 开始绘制  绘制带填充色
    CGContextDrawPath(context, kCGPathFillStroke);
    /*CGPathDrawingModekCGPathFill填充非零绕数规则,kCGPathEOFill表示用奇偶规则,kCGPathStroke路径,kCGPathFillStroke路径填充,kCGPathEOFillStroke表示描线 ，不是填充*/
}

-(void)drawBottomArcInContext:(CGContextRef)context rect:(CGRect)rect{
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextMoveToPoint(context, self.centerX - self.height, CGRectGetHeight(rect));
    CGContextAddArcToPoint(context, self.centerX, CGRectGetHeight(rect), self.centerX, CGRectGetHeight(rect) - self.height, self.height);
    CGContextAddArcToPoint(context, self.centerX, CGRectGetHeight(rect), self.centerX + self.height, CGRectGetHeight(rect), self.height);
    CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextDrawPath(context, kCGPathFillStroke);
}


@end

@interface LMDialScrollView ()<UIScrollViewDelegate>
@property (nonatomic, weak) LMDialView *dial;
@property (nonatomic, weak) UIScrollView   *dialScrollView;
/** centerLine */
@property (nonatomic, weak) LMDialCenterLineView *indicateLine;

@end

@implementation LMDialScrollView
-(instancetype)initWithFrame:(CGRect)frame withDialView:(LMDialView *)dialView
{
    frame.size.height = CGRectGetHeight(dialView.frame);
    self = [super initWithFrame:frame];
    if (self) {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:(CGRect){CGPointZero,frame.size}];
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.delegate = self;
        [self addSubview:scrollView];
        self.dialScrollView = scrollView;
        
        CGFloat dis = CGRectGetWidth(frame) - CGRectGetWidth(dialView.frame);
        // dis <= 0 scrollview的宽度足够把dialview包住
        CGSize contentSize = CGSizeMake(dis<=0 ? CGRectGetWidth(frame) + CGRectGetWidth(dialView.frame) : CGRectGetWidth(dialView.frame) + CGRectGetWidth(frame) / 2.0, CGRectGetHeight(dialView.frame));
        scrollView.contentSize = contentSize;
        dialView.frame = CGRectMake((scrollView.contentSize.width - CGRectGetWidth(dialView.frame))/2, 0, CGRectGetWidth(dialView.frame), CGRectGetHeight(dialView.frame));
        [scrollView addSubview:dialView];
        self.dial = dialView;
        
        LMDialCenterLineView *line = [[LMDialCenterLineView alloc] initWithFrame:CGRectMake(scrollView.contentSize.width/2-15, 0, 30, CGRectGetHeight(frame))];
        line.type = LMDialCenterLineTypeArcDouble;
        [scrollView addSubview:line];
        self.indicateLine = line;
        
        [scrollView scrollRectToVisible:CGRectMake((scrollView.contentSize.width - CGRectGetWidth(scrollView.frame))/2, 0, CGRectGetWidth(scrollView.frame), CGRectGetHeight(scrollView.frame)) animated:YES];
    }
    
    return self;
}

#pragma mark ------------- UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint contentOffset = scrollView.contentOffset;
    CGRect indicateLineFrame = self.indicateLine.frame;
    if (contentOffset.x >= self.dial.horizentalMergin && contentOffset.x <= (scrollView.contentSize.width - CGRectGetWidth(self.frame) - self.dial.horizentalMergin)) {
        indicateLineFrame.origin.x = contentOffset.x + CGRectGetWidth(self.dialScrollView.frame)/2 - CGRectGetWidth(self.indicateLine.frame) / 2;
        NSLog(@"scrollOffset ===>%@  indicateLineFrame.origin.x ===>%@,value ==>%@",@(contentOffset.x),@(indicateLineFrame.origin.x),@([self.dial scaleValueForTargetPoint:CGPointMake(contentOffset.x+self.dial.horizentalMergin, 0)]));
        SystemSoundID soundID;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:@"/System/Library/Audio/UISounds/Descent.caf"], &soundID);
        AudioServicesPlaySystemSound(soundID);
        //        contentOffset.x - self.dial.scaleInsets.left
        
    }else if(contentOffset.x < self.dial.horizentalMergin){
        indicateLineFrame.origin.x = CGRectGetWidth(self.dialScrollView.frame)/2 - CGRectGetWidth(self.indicateLine.frame) / 2 + self.dial.horizentalMergin;
    }else{
        indicateLineFrame.origin.x = self.dialScrollView.contentSize.width - CGRectGetWidth(self.dialScrollView.frame) / 2 - CGRectGetWidth(self.indicateLine.frame) / 2 - self.dial.horizentalMergin;
    }
    self.indicateLine.frame = indicateLineFrame;
}

@end


// demo
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
static CGFloat TimeImageViewLenght  = 0.0f;
static CGFloat step                 = 5.0;
static int salce                    = 1.0;
@interface TimeSliderView ()
@property (nonatomic,strong) TimeView *timeView;
@property (nonatomic,strong) UIImageView *tipImageView;
@end



@implementation TimeSliderView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = [UIColor colorWithRGBHex:0xf0f0f0].CGColor;
        self.layer.borderWidth = 1;
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        salce = 1;
        TimeImageViewLenght = 24*10*salce*step;
        self.timeView = [[TimeView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2.0 - 30.0, 0, TimeImageViewLenght, self.height)];
        
        [self addSubview:self.timeView];
        [self addSubview:self.tipImageView];
        self.contentSize = CGSizeMake(SCREEN_WIDTH  + TimeImageViewLenght, self.height);
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDouble)];
        tap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:tap];//双击改变时间轴比例
    }
    return self;
}

-(UIImageView *)tipImageView{
    if (!_tipImageView) {
        _tipImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tipiamge"]];
        self.tipImageView.frame = CGRectMake(SCREEN_WIDTH/2-7, 30, 14, self.height-30);
    }
    return _tipImageView;
}
- (void)awakeFromNib{
    [super awakeFromNib];
    self.layer.borderColor = [UIColor colorWithRGBHex:0xf0f0f0].CGColor;
    self.layer.borderWidth = 1;
    self.delegate = self;
    salce = 1;
    TimeImageViewLenght = 24*10*salce*step;
    self.timeView = [[TimeView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2.0 - 30.0, 0, TimeImageViewLenght, self.height)];
    [self addSubview:self.timeView];
    self.contentSize = CGSizeMake(SCREEN_WIDTH  + TimeImageViewLenght, self.height);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDouble)];
    tap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:tap];
}

- (void)showDouble{
    self.isShowDoubleTime = !self.isShowDoubleTime;
}

- (void)setHisBlockArray:(NSArray *)hisBlockArray{
    _hisBlockArray = hisBlockArray;
    
    self.timeView.hisBlockArray = _hisBlockArray;
}

- (void)setIsShowDoubleTime:(BOOL)isShowDoubleTime{
    _isShowDoubleTime = isShowDoubleTime;
    if (isShowDoubleTime) {
        salce = 6;
    }else{
        salce = 1;
    }
    TimeImageViewLenght = 24*10*salce*step;
    self.contentSize = CGSizeMake(SCREEN_WIDTH  + TimeImageViewLenght, self.height);
    [self.timeView setNeedsLayout];
    [self.timeView setNeedsDisplay];
    [self updateOffset];
    
}

- (void)setCurrentTime:(NSDate *)currentTime{
    if (self.isTimeDragging) {
        return ;
    }
    _currentTime = currentTime;
    self.timeView.currentDate = self.currentTime;
    [self updateOffset];
}

-(void)updateOffset{
    [self setOffsetForDate:self.currentTime];
}

#pragma mark - 根据时间设置offset
- (void)setOffsetForDate:(NSDate *)date{
    NSArray * dateArr = [self timeForDate:date];
    NSInteger  hour = [dateArr[0] integerValue];
    NSInteger  minute = [dateArr[1] integerValue];
    NSInteger  second = [dateArr[2] integerValue];
    CGFloat xOffset  = hour * hourOffset() + minute * minuteOffset() + second * secondOffset() ;
    [self setContentOffset:CGPointMake(xOffset, self.contentOffset.y) animated:YES];
}

- (CGFloat)maxOffset{
    NSInteger nowDate = [self zeroOfDate].timeIntervalSince1970;
    NSInteger current = self.currentTime.timeIntervalSince1970;
    if (nowDate > current) {
        return TimeImageViewLenght;
    }
    NSArray * timeArr = [self timeForDate:[NSDate date]];
    NSInteger  hour = [timeArr[0] integerValue];
    NSInteger  minute = [timeArr[1] integerValue];
    NSInteger  second = [timeArr[2] integerValue];
    CGFloat xOffset  = hour * hourOffset() + minute * minuteOffset() + second * secondOffset() ;
    return xOffset;
}

- (NSArray *)timeForDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm:ss";
    NSString *dateStr = [formatter stringFromDate:date];
    return [dateStr componentsSeparatedByString:@":"];
}

- (NSDate *)zeroOfDate{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSUIntegerMax fromDate:[NSDate date]];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    NSTimeInterval ts = (double)(long int)[[calendar dateFromComponents:components] timeIntervalSince1970];
    return [NSDate dateWithTimeIntervalSince1970:ts];
}


#pragma mark - 根据offset获取时间
- (NSDate *)getDateForOffset{
    CGFloat xOffset =  self.contentOffset.x;
    if (xOffset < 0) {
        xOffset = 0;
    }
    if (xOffset > TimeImageViewLenght) {
        xOffset = TimeImageViewLenght;
    }
    NSInteger  hour = xOffset/hourOffset();
    hour %= 24;
    NSInteger  minute = xOffset/minuteOffset();
    minute %= 60;
    NSInteger second = xOffset/secondOffset();
    second %= 60;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateStr = [formatter stringFromDate:self.currentTime];
    NSString *tempStr = [NSString stringWithFormat:@" %ld%ld:%ld%ld:%ld%ld",hour/10, hour%10, minute/10, minute%10,second/10, second%10];
    dateStr = [dateStr stringByAppendingString:tempStr];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [formatter dateFromString:dateStr];
}

#pragma mark - offset/时间
CGFloat hourOffset(){
    return TimeImageViewLenght/24.0;
}

CGFloat minuteOffset(){
    return hourOffset()/60.0;
}
CGFloat secondOffset(){
    return minuteOffset()/60.0;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.isTimeDragging = YES;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.tipImageView.frame = CGRectMake(SCREEN_WIDTH/2-7+scrollView.contentOffset.x, 30, 14, self.height-30);
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.isTimeDragging = NO;
#if 1//如果滑动时间超过当前时间，将通过currentTime set方法重新设置为当前时间的偏移量
    if (self.contentOffset.x > [self maxOffset] || self.contentOffset.x < 0) {
        self.currentTime = [NSDate date];
        return ;
    }
#endif
    if ([self.timeDelegate respondsToSelector:@selector(onTimeSliderSelectedTime:)]) {
        NSDate *date = [self getDateForOffset];
        _currentTime = date;
        [self.timeDelegate onTimeSliderSelectedTime:date];
    }
}

@end

@implementation TimeView
/**
 *  构建时间所用数据
 */

const CGFloat hourlineHieght    =   16.0;
const CGFloat mintelineHieght   =   8.0;
const CGFloat hourlineWidth     =   1.0;
const CGFloat mintelineWidth    =   1.0;
const CGFloat fontSize          =   10.0;

const CGFloat offset            =   30.0;
const CGFloat distance          =   10.0;
const CGFloat dataHeight        =   80.0;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, offset +24*10*salce*step + offset, frame.size.height);
        self.backgroundColor = [UIColor lightGrayColor];
    }
    return self;
}

- (void)setHisBlockArray:(NSArray *)hisBlockArray
{
    _hisBlockArray = hisBlockArray;
    
    [self setNeedsDisplay];
    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, offset +24*10*salce*step + offset, self.frame.size.height);
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat hourY = fontSize + 2*distance;
    //数据域
    CGFloat dataY = hourY;
    // 灰色条
    CGContextSetFillColorWithColor(context, [UIColor colorWithRGBHex:0x999999].CGColor);
    CGRect dataRect = CGRectMake(offset, dataY, 24*10*salce*step , dataHeight);
    CGContextAddRect(context, dataRect);
    CGContextFillPath(context);
    //有色区
    
    for (int i = 0 ; i < self.hisBlockArray.count/2; i++) {
        
        CGFloat start =  [self offsetForDate:self.hisBlockArray[i*2]];
        CGFloat end = [self offsetForDate:self.hisBlockArray[i*2 + 1]];
        
        CGContextSetFillColorWithColor(context, [UIColor colorWithRGBHex:0x40b2a9].CGColor);
        CGRect dataRect = CGRectMake(start, dataY, end-start, dataHeight);
        CGContextAddRect(context, dataRect);
        CGContextFillPath(context);
    }
    
    //时间轴
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRGBHex:0xffffff].CGColor);
    for (int i = 0 ; i <= 24*10*salce; i++) {
        if (i%10) {
            CGContextSetLineWidth(context, mintelineWidth);
            CGContextMoveToPoint(context, offset + i*step, hourY);
            CGContextAddLineToPoint(context, offset + i*step, hourY + mintelineHieght);
            
            CGContextMoveToPoint(context, offset + i*step, hourY + dataHeight - mintelineHieght);
            CGContextAddLineToPoint(context, offset + i*step, hourY + dataHeight);
        }else{
            CGContextSetLineWidth(context, hourlineWidth);
            CGContextMoveToPoint(context, offset + i*step, hourY);
            CGContextAddLineToPoint(context, offset + i*step, hourY + hourlineHieght);
            
            CGContextMoveToPoint(context, offset + i*step, hourY + dataHeight - hourlineHieght);
            CGContextAddLineToPoint(context, offset + i*step, hourY + dataHeight);
        }
    }
    CGContextStrokePath(context);
    //时间点
    CGFloat timeY = /*(rect.size.height + hourlineWidth)/2.0 + */distance;
    for (int i = 0; i <= 24*salce; i++) {
        NSInteger hour = i*60/salce/60;
        NSInteger minute = i*60/salce%60;
        NSString *time = [NSString stringWithFormat:@"%.2d:%.2d",(int)hour,(int)minute];
        CGSize size = [time sizeWithAttributes:[self attributes]];
        CGPoint drawPoint = CGPointMake(offset + i*step*10 - size.width/2.0, timeY);
        [time drawAtPoint:drawPoint withAttributes:[self attributes]];
    }
}

- (NSDictionary *)attributes
{
    return @{NSFontAttributeName : [UIFont systemFontOfSize:fontSize],
             NSForegroundColorAttributeName : [UIColor colorWithRGBHex:0x6d6d6d]};
}

- (CGFloat)offsetForDate:(NSDate *)date
{
    NSInteger time = [self timeForDate:date];
    return offset + step*24*10*salce*time/(24*60*60);
}

- (NSInteger)timeForDate:(NSDate *)date
{
    
    NSInteger timeInterval = date.timeIntervalSince1970 - self.currentDate.timeIntervalSince1970;
    if (timeInterval > 0) {
        return timeInterval;
    }else{
        return 0;
    }
}

- (void)setCurrentDate:(NSDate *)currentDate
{
    _currentDate = [currentDate copy];
    _currentDate = [self zeroOfDate:_currentDate];
}

- (NSDate *)zeroOfDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSUIntegerMax fromDate:date];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    NSTimeInterval ts = (double)(long int)[[calendar dateFromComponents:components] timeIntervalSince1970];
    return [NSDate dateWithTimeIntervalSince1970:ts];
}
@end

@implementation UIView (TTCategory)

- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)ttScreenX {
    CGFloat x = 0.0f;
    for (UIView* view = self; view; view = view.superview) {
        x += view.left;
    }
    return x;
}

- (CGFloat)ttScreenY {
    CGFloat y = 0.0f;
    for (UIView* view = self; view; view = view.superview) {
        y += view.top;
    }
    return y;
}

- (CGFloat)screenViewX {
    CGFloat x = 0.0f;
    for (UIView* view = self; view; view = view.superview) {
        x += view.left;
        
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView* scrollView = (UIScrollView*)view;
            x -= scrollView.contentOffset.x;
        }
    }
    
    return x;
}

- (CGFloat)screenViewY {
    CGFloat y = 0;
    for (UIView* view = self; view; view = view.superview) {
        y += view.top;
        
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView* scrollView = (UIScrollView*)view;
            y -= scrollView.contentOffset.y;
        }
    }
    return y;
}

- (CGRect)screenFrame {
    return CGRectMake(self.screenViewX, self.screenViewY, self.width, self.height);
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (void)showIndicator:(NSUInteger) maxSeconds{
    
}

@end
