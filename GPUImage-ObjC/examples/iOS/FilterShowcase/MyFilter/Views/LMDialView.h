//
//  LMDialView.h
//  FilterShowcase
//
//  Created by wzkj on 2017/1/9.
//  Copyright © 2017年 Cell Phone. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 刻度线对齐方式
 
 - LMDialAlignmentTop: 顶对齐
 - LMDialAlignmentCenter: 居中
 - LMDialAlignmentBottom: 底对齐
 */
typedef NS_ENUM(NSInteger, LMDialAlignment) {
    LMDialAlignmentTop,
    LMDialAlignmentCenter,
    LMDialAlignmentBottom
};



/**
 刻度线排列类型
 
 - LMDialTypeCircle: 圆形
 - LMDialTypeHorizental: 水平
 - LMDialTypeVertical: 垂直
 - LMDialTypeTopSector: 顶部扇形
 - LMDialTypeBottomSector: 底部扇形
 */
typedef NS_ENUM(NSInteger, LMDialType) {
    LMDialTypeCircle,
    LMDialTypeHorizental,
    LMDialTypeVertical,
    LMDialTypeTopSector,
    LMDialTypeBottomSector
};

@class LMDialView;

@protocol LMDialViewDelegate <NSObject>
@optional
/**
 提供大刻度的文字标识
 
 @param dialView 刻度视图
 @param scaleIndex 刻度索引位置
 @return 刻度文字标识
 */
-(NSString *)scaleTitle:(LMDialView *)dialView scaleIndex:(NSInteger)scaleIndex;

@end

/** 刻度盘视图 */
@interface LMDialView : UIView
/** 显示比例 默认1 */
@property (nonatomic, assign) CGFloat      dialRatio;
/** 刻度的水平边距 */
@property (nonatomic, assign) CGFloat      horizentalMergin;
/** 代理 */
@property (nonatomic, strong) id<LMDialViewDelegate> delegate;
/** 刻度数量  大刻度*/
@property (nonatomic, assign) NSUInteger   numberOfScale;
/** 分刻度数 小刻度*/
@property (nonatomic, assign) NSUInteger   numberStepPreScale;
/** 大刻度线高度 */
@property (nonatomic, assign) CGFloat      scaleHeight;
/** 小刻度线高度 */
@property (nonatomic, assign) CGFloat      stepHeight;
/** 大刻度文字标识字体大小 */
@property (nonatomic, strong) UIFont       *scaleTitleFont;

/** 刻度线对齐方式 */
@property (nonatomic, assign) LMDialAlignment dialAlignment;
/** 刻度线排列类型 */
@property (nonatomic, assign) LMDialType dialType;
@end


@interface LMDialScrollView : UIView
/** dialView.frame.size.width 必须大于等于 frame.size.width 才可以滑动 */
-(instancetype)initWithFrame:(CGRect)frame withDialView:(LMDialView *)dialView;

@end



// demo

@interface UIView (TTCategory)

/**
 * Shortcut for frame.origin.x.
 *
 * Sets frame.origin.x = left
 */
@property (nonatomic) CGFloat left;

/**
 * Shortcut for frame.origin.y
 *
 * Sets frame.origin.y = top
 */
@property (nonatomic) CGFloat top;

/**
 * Shortcut for frame.origin.x + frame.size.width
 *
 * Sets frame.origin.x = right - frame.size.width
 */
@property (nonatomic) CGFloat right;

/**
 * Shortcut for frame.origin.y + frame.size.height
 *
 * Sets frame.origin.y = bottom - frame.size.height
 */
@property (nonatomic) CGFloat bottom;

/**
 * Shortcut for frame.size.width
 *
 * Sets frame.size.width = width
 */
@property (nonatomic) CGFloat width;

/**
 * Shortcut for frame.size.height
 *
 * Sets frame.size.height = height
 */
@property (nonatomic) CGFloat height;

/**
 * Shortcut for center.x
 *
 * Sets center.x = centerX
 */
@property (nonatomic) CGFloat centerX;

/**
 * Shortcut for center.y
 *
 * Sets center.y = centerY
 */
@property (nonatomic) CGFloat centerY;

/**
 * Return the x coordinate on the screen.
 */
@property (nonatomic, readonly) CGFloat ttScreenX;

/**
 * Return the y coordinate on the screen.
 */
@property (nonatomic, readonly) CGFloat ttScreenY;

/**
 * Return the x coordinate on the screen, taking into account scroll views.
 */
@property (nonatomic, readonly) CGFloat screenViewX;

/**
 * Return the y coordinate on the screen, taking into account scroll views.
 */
@property (nonatomic, readonly) CGFloat screenViewY;

/**
 * Return the view frame on the screen, taking into account scroll views.
 */
@property (nonatomic, readonly) CGRect screenFrame;

/**
 * Shortcut for frame.origin
 */
@property (nonatomic) CGPoint origin;

/**
 * Shortcut for frame.size
 */
@property (nonatomic) CGSize size;

- (void)showIndicator:(NSUInteger) maxSeconds;

@end

@protocol TimeSliderProtocol <NSObject>
-(void)onTimeSliderSelectedTime:(NSDate*)time;
@end

@interface TimeSliderView : UIScrollView <UIScrollViewDelegate>
@property (nonatomic) NSDate *currentTime;         //当前时间
@property (weak) id<TimeSliderProtocol> timeDelegate;

@property (nonatomic) BOOL isTimeDragging;
@property (nonatomic, strong) NSArray *hisBlockArray;

- (NSDate *)getDateForOffset;

@property (nonatomic) BOOL isShowDoubleTime;//时间轴是否放大

@end


@interface TimeView : UIView

@property (nonatomic,copy) NSDate *currentDate;
@property (nonatomic, copy) NSArray *hisBlockArray;

@end

