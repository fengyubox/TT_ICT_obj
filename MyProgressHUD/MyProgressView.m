//
//  MyProgressView.m
//  PrograssBarTest
//
//  Created by Weidong Cao on 2019/9/26.
//  Copyright © 2019 Weidong Cao. All rights reserved.
//

#import "MyProgressView.h"
#include <QuartzCore/CoreAnimation.h>

#define Screen_height  270
#define Screen_width   480
#define DefaultRect     CGRectMake(0, 0, Screen_width, Screen_height)

#define GloomyBlackColor  [NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:.5]
#define GloomyClearCloler  [NSColor colorWithDeviceRed:1 green:1 blue:1 alpha:0]

@interface MyProgressView()
{
    //MacClickView *gloomyView;//深色背景
    NSTextField *titleTF;
    NSImageView *loadingImgView;
    CAShapeLayer *animLayer;
    bool animState;
    NSMutableArray *pointImgViewsMAry;
    NSMutableArray *quareViewsMAry;
    //MacClickView *progressView;
    double classSpeed;
    NSInteger amplitude;
}
@end
@implementation MyProgressView



- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
- (id)initWithFrame:(CGRect)frame

{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.wantsLayer = YES;
        self.layer.backgroundColor= [NSColor clearColor].CGColor;

        amplitude=20;
        [self setNeedsDisplay:YES];
        
    }
    return self;
}
-(void)setFramBackground:(NSColor *)color{
    self.wantsLayer = YES;
    self.layer.backgroundColor= [color CGColor];
}
//方块跳动
- (void)showWaitingWithsQuareColor:(NSColor *)color side:(NSInteger)len speed:(double)speed
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self->animState = YES;
        self->classSpeed = speed;
        
        self->quareViewsMAry = [[NSMutableArray alloc] init];
        NSInteger number = self.frame.size.width / (len + len / 3);
        self->amplitude = len / 2;
        //NSWindow *window = [NSApplication sharedApplication].keyWindow;
        //[window.contentView addSubview:gloomyView];
        
        
        CGFloat radiusX = 0;
        CGFloat radiusY = self.frame.size.height / 2;
        
        
        for (int i = 0; i<number; i++) {
            
            NSView *pointImgViewx = [[NSView alloc] initWithFrame:NSMakeRect(i*(len+len/3)+5, radiusY-len/3, len, len)];
            pointImgViewx.wantsLayer =YES;
            [pointImgViewx.layer setBackgroundColor:[color CGColor]];
            pointImgViewx.layer.cornerRadius = 3.5;
            [self addSubview:pointImgViewx];
            
            [self beatingAnimation:pointImgViewx currentNumber:i];
            [self->quareViewsMAry addObject:pointImgViewx];
        }
        
        
    });
    /*
    //自动消失
    double delayInSeconds = showTime;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //执行事件
        self->animState = NO;
        [self stopDisappear];
    });
     */
}
-(void)toDisappear:(BOOL )remove{
    animState = NO;
    //self.wantsLayer=YES;
    //[self.layer setBackgroundColor:[[NSColor clearColor] CGColor]];
    for (int i = 0; i<quareViewsMAry.count; i++) {
        
        NSView *pointImgViewx = quareViewsMAry[i];
        pointImgViewx.wantsLayer=YES;
        [pointImgViewx.layer setBackgroundColor:[[NSColor clearColor] CGColor]];
        
    }
    if (YES == remove) {
        [self removeFromSuperview];
    }
}
/**
 * 动画开始时
 */
- (void)animationDidStart:(CAAnimation *)theAnimation
{
    //NSLog(@"begin");
}

/**
 * 动画结束时
 */
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    
    if (animState == NO) {
        return;
    }
    
    //NSLog(@"Stop");
    
    if ([[theAnimation valueForKey:@"animType"] isEqual:@"strokeEnd"]) {
        [animLayer removeAllAnimations];
        [self animationReverse];
    };
    if ([[theAnimation valueForKey:@"animType"] isEqual:@"strokeStart"]) {
        [animLayer removeAllAnimations];
        [self animationPositive];
    };
    if ([[theAnimation valueForKey:@"animType"] isEqual:@"positionStart 5"]) {
        [self animationPositionEnd];
    };
    if ([[theAnimation valueForKey:@"animType"] isEqual:@"positionEnd 5"]) {
        [self animationPositionStart];
    };
    if ([[theAnimation valueForKey:@"animType"] isEqual:@"progressStart"]) {
        [self animationProgressEnd];
    };
    if ([[theAnimation valueForKey:@"animType"] isEqual:@"progressEnd"]) {
        [self animationProgressStart];
    };
    if ([[theAnimation valueForKey:@"animType"] isEqual:@"quareStart 4"]) {
        [self animationQuareEnd];
    };
    if ([[theAnimation valueForKey:@"animType"] isEqual:@"quareEnd 4"]) {
        [self animationQuareStart];
    };
    
}

- (void)animationQuareStart
{
    for (int i = 0; i<quareViewsMAry.count; i++) {
        
        NSView *pointImgViewx = quareViewsMAry[i];
        [self beatingAnimation:pointImgViewx currentNumber:i];
        
    }
}

- (void)animationQuareEnd
{
    for (int i = 0; i<quareViewsMAry.count; i++) {
        
        NSView *pointImgViewx = quareViewsMAry[i];
        [self beatingAnimationx:pointImgViewx currentNumber:i];
        
    }
}

- (void)animationProgressStart
{
    // 比例缩放
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    animation.delegate = (id)self;
    // 持续时间
    animation.duration = classSpeed;//2
    // 重复次数
    animation.repeatCount = 1;
    // 起始scale
    animation.fromValue = @(1.0);
    // 终止scale
    animation.toValue = @(10);
    //是否还原
    animation.removedOnCompletion = NO;
    
    animation.fillMode = kCAFillModeForwards;
    // 添加动画
    NSString *key = @"progressStart";
    [animation setValue:key forKey:@"animType"];
    [self.layer addAnimation:animation forKey:key];
}

- (void)animationProgressEnd
{
    // 比例缩放
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    animation.delegate = (id)self;
    // 持续时间
    animation.duration = classSpeed;//2
    // 重复次数
    animation.repeatCount = 1;
    // 起始scale
    animation.fromValue = @(10);
    // 终止scale
    animation.toValue = @(1.0);
    //是否还原
    animation.removedOnCompletion = NO;
    
    animation.fillMode = kCAFillModeForwards;
    // 添加动画
    NSString *key = @"progressEnd";
    [animation setValue:key forKey:@"animType"];
    [self.layer addAnimation:animation forKey:key];
}

- (void)animationPositionStart
{
    for (int i = 0; i<pointImgViewsMAry.count; i++) {
        
        NSView *pointImgViewx = pointImgViewsMAry[i];
        
        // 位置移动
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
        animation.delegate = (id)self;
        // 持续时间
        animation.duration = classSpeed;//2
        // 重复次数
        animation.repeatCount = 1;//CGFLOAT_MAX
        //是否还原
        animation.removedOnCompletion = NO;
        // 起始位置
        //        animation.fromValue = [NSValue valueWithPoint:pointImgViewx.layer.position];
        // 终止位置
        animation.toValue = [NSNumber numberWithFloat:i*amplitude];
        
        animation.fillMode = kCAFillModeForwards;
        // 添加动画
        NSString *key = [NSString stringWithFormat:@"positionStart %i",i];
        [animation setValue:key forKey:@"animType"];
        [pointImgViewx.layer addAnimation:animation forKey:key];
        
    }
}

- (void)animationPositionEnd
{
    for (int i = 0; i<pointImgViewsMAry.count; i++) {
        
        NSView *pointImgViewx = pointImgViewsMAry[i];
        
        // 位置移动
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
        animation.delegate = (id)self;
        // 持续时间
        animation.duration = classSpeed;//2
        // 重复次数
        animation.repeatCount = 1;//CGFLOAT_MAX
        //是否还原
        animation.removedOnCompletion = NO;
        // 起始位置
        //        animation.fromValue = [NSValue valueWithPoint:pointImgViewx.layer.position];
        // 终止位置
        int x;
        if (i == 0) {
            x = 5;
        }else if(i == 1){
            x = 4;
        }else if(i == 2){
            x = 3;
        }else if(i == 3){
            x = 2;
        }else if(i == 4){
            x = 1;
        }else{
            x = 0;
        }
        animation.toValue = [NSNumber numberWithFloat:x*amplitude];
        
        animation.fillMode = kCAFillModeForwards;
        // 添加动画
        NSString *key = [NSString stringWithFormat:@"positionEnd %i",i];
        [animation setValue:key forKey:@"animType"];
        [pointImgViewx.layer addAnimation:animation forKey:key];
        
    }
}

- (void)animationPositive
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.delegate = (id)self;
    animation.fromValue = @(0);
    animation.toValue = @(1.f);
    animation.duration = classSpeed;//2
    animation.removedOnCompletion = NO;//是否还原
    //        [animation setRepeatCount:CGFLOAT_MAX];
    animation.fillMode  = kCAFillModeForwards;
    [animation setValue:@"strokeEnd" forKey:@"animType"];
    [animLayer addAnimation:animation forKey:@"strokeEnd"];
}

- (void)animationReverse
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    animation.delegate = (id)self;
    animation.fromValue = @(0);
    animation.toValue = @(1.f);
    animation.duration = classSpeed;//2
    animation.removedOnCompletion = NO;//是否还原
    //        [animation setRepeatCount:CGFLOAT_MAX];
    animation.fillMode  = kCAFillModeForwards;
    [animation setValue:@"strokeStart" forKey:@"animType"];
    [animLayer addAnimation:animation forKey:@"strokeStart"];
    
}

- (void)beatingAnimation:(NSView *)view currentNumber:(NSInteger)currentNumber
{
    // 位置移动
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animation.delegate = (id)self;
    // 持续时间
    animation.duration = classSpeed;//2
    // 重复次数
    animation.repeatCount = 1;
    //是否还原
    animation.removedOnCompletion = NO;
    // 起始位置
    //        animation.fromValue = [NSValue valueWithPoint:pointImgViewx.layer.position];
    // 终止位置
    if (currentNumber%2==0) {//如果是偶数
        animation.toValue = [NSNumber numberWithFloat:-amplitude];
    }else{//如果是奇数
        animation.toValue = [NSNumber numberWithFloat:amplitude];
    }
    
    animation.fillMode = kCAFillModeForwards;
    // 添加动画
    NSString *key = [NSString stringWithFormat:@"quareStart %li",(long)currentNumber];
    [animation setValue:key forKey:@"animType"];
    [view.layer addAnimation:animation forKey:key];
}

- (void)beatingAnimationx:(NSView *)view currentNumber:(NSInteger)currentNumber
{
    // 位置移动
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animation.delegate = (id)self;
    // 持续时间
    animation.duration = classSpeed;//2
    // 重复次数
    animation.repeatCount = 1;
    //是否还原
    animation.removedOnCompletion = NO;
    // 起始位置
    //        animation.fromValue = [NSValue valueWithPoint:pointImgViewx.layer.position];
    // 终止位置
    if (currentNumber%2!=0) {//如果不是偶数
        animation.toValue = [NSNumber numberWithFloat:-amplitude];
    }else{//如果不是奇数
        animation.toValue = [NSNumber numberWithFloat:amplitude];
    }
    
    animation.fillMode = kCAFillModeForwards;
    // 添加动画
    NSString *key = [NSString stringWithFormat:@"quareEnd %li",(long)currentNumber];
    [animation setValue:key forKey:@"animType"];
    [view.layer addAnimation:animation forKey:key];
}
@end
