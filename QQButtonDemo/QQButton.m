//
//  QQButton.m
//  QQButtonDemo
//
//  Created by liranhui on 2017/3/14.
//  Copyright © 2017年 liranhui. All rights reserved.
//

#import "QQButton.h"
@interface QQButton()
@property(nonatomic,strong)CAShapeLayer         *shapeLayer;
@property(nonatomic,strong)UIView               *smallCircleView;
@end
@implementation QQButton
{
    CGFloat     _maxDistance;//可以拉的最大距离
}
- (instancetype)initWithFrame:(CGRect)frame AddToView:(UIView*)toView
{
    if(self = [super initWithFrame:frame])
    {
        [toView addSubview:self];
        //初始化按钮
        [self configButton];
    }
    return self;
}
- (CAShapeLayer*)shapeLayer
{
    if(!_shapeLayer)
    {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.fillColor = self.backgroundColor.CGColor;
        [self.superview.layer insertSublayer:_shapeLayer below:self.layer];
    }
    return _shapeLayer;
}
- (UIView*)smallCircleView
{
    if(!_smallCircleView)
    {
        _smallCircleView = [[UIView alloc]init];
        _smallCircleView.backgroundColor = self.backgroundColor;
        [self.superview insertSubview:_smallCircleView belowSubview:self];
    }
    return _smallCircleView;
}
- (void)configButton
{
    CGFloat radius = (self.bounds.size.height>self.bounds.size.width)?self.bounds.size.width/2:self.bounds.size.height/2;
   //按钮圆形化
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
    //按钮颜色
    self.backgroundColor = [UIColor redColor];
    //设置小圆位置大小
    
    CGRect smallBound = CGRectMake(0,0,radius*1.5,radius*1.5);
    self.smallCircleView.bounds = smallBound;
    self.smallCircleView.center = self.center;
    self.smallCircleView.layer.cornerRadius = self.smallCircleView.bounds.size.width/2;
    self.smallCircleView.layer.masksToBounds = YES;
    //初始化最大拉动距离
    _maxDistance = radius*4;
    //给按钮添加手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(buttonPaned:)];
    [self addGestureRecognizer:pan];
    //按钮点击事件
    [self addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
}
- (CGFloat)distanceBetweenPointA:(CGPoint)point1 toPointB:(CGPoint)point2
{
    CGFloat distance = sqrt((point2.x-point1.x)*(point2.x-point1.x)+(point2.y-point1.y)*(point2.y-point1.y));
    return distance;
}
- (void)buttonPaned:(UIPanGestureRecognizer*)gesture
{
    CGPoint translation = [gesture translationInView:self];
    CGPoint changeCenter = self.center;
    changeCenter.x += translation.x;
    changeCenter.y += translation.y;
    self.center = changeCenter;
    [gesture setTranslation:CGPointZero inView:self];
    CGFloat distance = [self distanceBetweenPointA:self.smallCircleView.center toPointB:self.center];
    if(distance>_maxDistance)
    {
        //拉动的距离已达到最大值
        [self.shapeLayer removeFromSuperlayer];
        [self.smallCircleView removeFromSuperview];
        self.smallCircleView = nil;
    }
    else
    {
        //没有达到最大值（距离越大，小圆圈视图半径越小）
        CGFloat smallRadius = self.layer.cornerRadius*1.5/2 - distance/10;
        self.smallCircleView.bounds = CGRectMake(0, 0, smallRadius*2, smallRadius*2);
        self.smallCircleView.layer.cornerRadius = smallRadius;
        //绘制不规则曲线
        self.shapeLayer.path = [self pathWithView:self.smallCircleView ToView:self].CGPath;
    }
    if(gesture.state == UIGestureRecognizerStateEnded)
    {
       if(distance<_maxDistance)
       {
           //最大距离范围之内
           [self.shapeLayer removeFromSuperlayer];
           self.shapeLayer = nil;
           self.smallCircleView.hidden = YES;
           [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveLinear animations:^{
               self.center = self.smallCircleView.center;
           } completion:^(BOOL finished) {
               self.smallCircleView.hidden = NO;
               CAKeyframeAnimation *oscillateAnimation = [CAKeyframeAnimation animation];
               oscillateAnimation.keyPath = @"transform.translation.x";
               oscillateAnimation.values = @[@(-2),@(2),@(2),@(-2)];
               oscillateAnimation.repeatCount = 2;
               oscillateAnimation.removedOnCompletion = NO;
               oscillateAnimation.fillMode = kCAFillModeForwards;
               oscillateAnimation.duration = 0.1;
               [self.layer addAnimation:oscillateAnimation forKey:@"KeyFrame"];
           }];
       }
       else
       {
           //手势结束
           [self.shapeLayer removeFromSuperlayer];
           self.shapeLayer = nil;
           [self.smallCircleView removeFromSuperview];
           self.shapeLayer = nil;
           [self removeFromSuperview];
       }
        
    }
}
- (UIBezierPath*)pathWithView:(UIView*)view1 ToView:(UIView*)view2
{
    CGPoint center1 = view1.center;
    CGPoint center2 = view2.center;
    CGFloat x1 = center1.x;
    CGFloat y1 = center1.y;
    CGFloat raduis1 = view1.layer.cornerRadius;
    CGFloat x2 = center2.x;
    CGFloat y2 = center2.y;
    CGFloat raduis2 = view2.layer.cornerRadius;
    CGFloat distance = [self distanceBetweenPointA:center1 toPointB:center2];
    CGFloat sinA = (x2-x1)/distance;
    CGFloat cosA = (y2-y1)/distance;
    CGPoint pointA = CGPointMake(x1-raduis1*cosA, y1+raduis1*sinA);
    CGPoint pointB = CGPointMake(x1+raduis1*cosA, y1-raduis1*sinA);
    CGPoint pointC = CGPointMake(x2+raduis2*cosA, y2-raduis2*sinA);
    CGPoint pointD = CGPointMake(x2-raduis2*cosA, y2+raduis2*sinA);
    CGPoint pointO = CGPointMake(pointA.x+distance/2*sinA, pointA.y+distance/2*cosA);
    CGPoint pointP = CGPointMake(pointB.x+distance/2*sinA, pointB.y+distance/2*cosA);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:pointA];
    [path addLineToPoint:pointB];
    [path addQuadCurveToPoint:pointC controlPoint:pointP];
    [path addLineToPoint:pointD];
    [path addQuadCurveToPoint:pointA controlPoint:pointO];
    return path;
}
- (void)buttonClicked:(UIButton*)button
{
    
}
@end
