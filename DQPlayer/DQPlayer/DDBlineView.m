//
//  DDBlineView.m
//  DQPlayer
//
//  Created by 林兴栋 on 2016/12/20.
//  Copyright © 2016年 林兴栋. All rights reserved.
//

#import "DDBlineView.h"

@implementation DDBlineView

- (void)drawRect:(CGRect)rect {
    // Drawing code
    UIColor *color = [UIColor redColor];
    [color set];
    UIBezierPath * be = [UIBezierPath bezierPath];
    [be moveToPoint:CGPointMake(0, 100)];
    [be addLineToPoint:CGPointMake(0, 10)];
    [be addQuadCurveToPoint:CGPointMake(0, 0) controlPoint:CGPointMake(10, 0)];
    [be addLineToPoint:CGPointMake(300, 0)];
    [be closePath];
}


@end
