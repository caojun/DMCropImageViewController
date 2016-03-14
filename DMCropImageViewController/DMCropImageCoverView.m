//
//  DMCropImageCoverView.m
//  CropImageDemo
//
//  Created by Dream on 16/3/9.
//  Copyright © 2016年 Dream. All rights reserved.
//

#import "DMCropImageCoverView.h"

@implementation DMCropImageCoverView

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIColor *color = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextFillRect(ctx, rect);
    CGContextFillPath(ctx);
    
    CGContextSetBlendMode(ctx, kCGBlendModeClear);
    CGContextFillRect(ctx, self.m_clipRect);
    
    CGContextFillPath(ctx);
}

@end
