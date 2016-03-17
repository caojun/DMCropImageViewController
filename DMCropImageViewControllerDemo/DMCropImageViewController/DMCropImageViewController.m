/**
 The MIT License (MIT)
 
 Copyright (c) 2016 Jun
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#import "DMCropImageViewController.h"
#import "DMCropImageCoverView.h"

@interface DMCropImageViewController () <UIScrollViewDelegate>

@property (nullable, nonatomic, strong) UIScrollView *m_scrollView;
@property (nullable, nonatomic, strong) UIImageView *m_imageView;

@property (nullable, nonatomic, strong) DMCropImageCoverView *m_coverView;

@end

@implementation DMCropImageViewController

+ (instancetype)cropImageViewControllerWithCropRect:(CGRect)cropRect;
{
    DMCropImageViewController *vc = [[self alloc] init];
    vc.m_cropRect = cropRect;
    
    return vc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor blackColor];
    
    [self createScrollView];
    [self setupImage];
    [self createBtn];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (nonnull UIButton *)createButtonWithTitle:(nonnull NSString *)title
                                 withAction:(SEL)action;
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:btn];

    return btn;
}

- (CGFloat)screenWidth
{
    return [UIScreen mainScreen].bounds.size.width;
}

- (CGFloat)screenHeight
{
    return [UIScreen mainScreen].bounds.size.height;
}

- (void)createBtn
{
    CGFloat btnW = 80;
    CGFloat btnH = 40;
    
    CGFloat btnCancelX = 15;
    CGFloat btnCancelY = [self screenHeight] - btnCancelX - btnH;
    UIButton *btnCancel = [self createButtonWithTitle:@"取消" withAction:@selector(btnCancelClick:)];
    btnCancel.frame = (CGRect){btnCancelX, btnCancelY, btnW, btnH};
    
    CGFloat btnConfirmX = [self screenWidth] - btnCancelX - btnW;
    CGFloat btnConfirmY = btnCancelY;
    UIButton *btnConfirm = [self createButtonWithTitle:@"确定" withAction:@selector(btnConfirmClick:)];
    btnConfirm.frame = (CGRect){btnConfirmX, btnConfirmY, btnW, btnH};
}

- (void)btnCancelClick:(nonnull UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(cropImageViewControllerDidClickCancel:)])
    {
        [self.delegate cropImageViewControllerDidClickCancel:self];
    }
}

- (nonnull UIImage *)screenShot
{
    CGRect rect = self.view.frame;
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:context];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGRect frame = self.m_coverView.m_clipRect;
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, 0);
    context = UIGraphicsGetCurrentContext();
    frame.origin.x = -frame.origin.x;
    frame.origin.y = -frame.origin.y;
    frame.size.width = rect.size.width;
    frame.size.height = rect.size.height;
    [img drawInRect:frame];
    
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)btnConfirmClick:(UIButton *)btn
{
    UIImage *image = [self screenShot];
    
    if ([self.delegate respondsToSelector:@selector(cropImageViewController:cropImage:)])
    {
        [self.delegate cropImageViewController:self cropImage:image];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self scrollViewAdjustFrame];
    [self coverViewAdjustFrame];
}

- (void)setM_cropRect:(CGRect)m_cropRect
{
    _m_cropRect = m_cropRect;
    
    [self setupImage];
}

- (void)scrollViewAdjustFrame
{
    self.m_scrollView.frame = self.m_cropRect;
    [self imageViewAdjustFrame];
}

- (void)createScrollView
{
    if (nil == _m_scrollView)
    {
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        [self.view addSubview:scrollView];
        _m_scrollView = scrollView;
        
        scrollView.delegate = self;
        scrollView.maximumZoomScale = 2.5;
        scrollView.minimumZoomScale = 1;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.bounces = YES;
        scrollView.alwaysBounceHorizontal = YES;
        scrollView.alwaysBounceVertical = YES;
        scrollView.scrollsToTop = NO;
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        scrollView.clipsToBounds = NO;
        
        [self createCoverView];
        
        [self createImageView];
    }
}

- (void)coverViewAdjustFrame
{
    self.m_coverView.frame = [UIScreen mainScreen].bounds;
}

- (void)createCoverView
{
    DMCropImageCoverView *view = [[DMCropImageCoverView alloc] init];
    [self.view addSubview:view];
    self.m_coverView = view;
    view.m_recieverView = self.m_scrollView;
    
    view.backgroundColor = [UIColor clearColor];
    view.m_clipRect = self.m_cropRect;
}

- (void)imageViewAdjustFrame
{
    CGRect frameToCenter = self.m_imageView.frame;
    
    // center horizontally
    if (CGRectGetWidth(frameToCenter) < CGRectGetWidth(self.m_scrollView.bounds))
    {
        frameToCenter.origin.x = (CGRectGetWidth(self.m_scrollView.bounds) - CGRectGetWidth(frameToCenter)) * 0.5f;
    }
    else
    {
        frameToCenter.origin.x = 0;
    }
    
    // center vertically
    if (CGRectGetHeight(frameToCenter) < CGRectGetHeight(self.m_scrollView.bounds))
    {
        frameToCenter.origin.y = (CGRectGetHeight(self.m_scrollView.bounds) - CGRectGetHeight(frameToCenter)) * 0.5f;
    }
    else
    {
        frameToCenter.origin.y = 0;
    }
    
    self.m_imageView.frame = frameToCenter;
}

- (void)createImageView
{
    if (nil == _m_imageView)
    {
        CGRect bgFrame = self.m_scrollView.bounds;
        UIView *imageBGView = [[UIView alloc] initWithFrame:bgFrame];
        [self.m_scrollView addSubview:imageBGView];

        imageBGView.backgroundColor = [UIColor blackColor];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageBGView addSubview:imageView];
        self.m_imageView = imageView;
        
        imageView.backgroundColor = [UIColor blackColor];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
}

- (void)setM_image:(UIImage *)m_image
{
    _m_image = m_image;
    
    [self setupImage];
}

- (void)setupImage
{
    if (nil != self.m_image)
    {
        CGFloat screenWidth = [self screenWidth];
        CGFloat screenHeight = [self screenHeight];
        
        CGFloat imageSrcWidth = self.m_image.size.width;
        CGFloat imageSrcHeight = self.m_image.size.height;
        
        CGFloat imageShowWidth = screenWidth;
        CGFloat imageShowHeight = floorf(imageShowWidth / imageSrcWidth * imageSrcHeight);
        
        self.m_imageView.image = self.m_image;
        self.m_imageView.frame = (CGRect){0, 0, imageShowWidth, imageShowHeight};
        self.m_scrollView.contentSize = CGSizeMake(imageShowWidth, imageShowHeight);
        
        CGFloat cropHeight = self.m_cropRect.size.height;
        
        CGFloat offsetX = 0;
        
        CGFloat offsetY = 0;
        if (imageShowHeight >= screenHeight)
        {
            offsetY = self.m_cropRect.origin.y;
        }
        else
        {
            if (cropHeight > imageShowHeight)
            {
                offsetY = (cropHeight - imageShowHeight) / 2;
            }
            else
            {
                offsetY = (imageShowHeight - cropHeight) / 2;
            }
        }
        
        self.m_scrollView.contentOffset = CGPointMake(offsetX, offsetY);
    }
}


#pragma mark - UIScrollViewDelegate
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.m_imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self imageViewAdjustFrame];
}

@end
