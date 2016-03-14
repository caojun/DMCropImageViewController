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
@property (nullable, nonatomic, strong) UIView *m_imageBGView;
@property (nullable, nonatomic, strong) UIImageView *m_imageView;

@property (nullable, nonatomic, strong) DMCropImageCoverView *m_coverView;
@property (nonatomic, assign) CGFloat m_paddingTop;

@end

@implementation DMCropImageViewController

+ (instancetype)cropImageViewController
{
    return [[self alloc] init];
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

- (void)createScrollView
{
    if (nil == _m_scrollView)
    {
        CGRect frame = [UIScreen mainScreen].bounds;
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
        [self.view addSubview:scrollView];
        
        scrollView.delegate = self;
        scrollView.maximumZoomScale = 1;//2.5;
        scrollView.minimumZoomScale = 1;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        
        _m_scrollView = scrollView;
        
        [self createImageView];
        
        DMCropImageCoverView *view = [[DMCropImageCoverView alloc] initWithFrame:frame];
        [self.view addSubview:view];
        view.userInteractionEnabled = NO;
        view.backgroundColor = [UIColor clearColor];
        CGFloat clipX = 0;
        CGFloat clipW = [self screenWidth] - clipX * 2;
        CGFloat clipH = floor(clipW * 9 / 16);
        CGFloat clipY = floor(([self screenHeight] - clipH) / 2);
        view.m_clipRect = (CGRect){clipX, clipY, clipW, clipH};
        self.m_coverView = view;
    }
}


- (void)createImageView
{
    if (nil == _m_imageView)
    {
        CGRect bgFrame = self.m_scrollView.bounds;
        UIView *imageBGView = [[UIView alloc] initWithFrame:bgFrame];
        [self.m_scrollView addSubview:imageBGView];
        self.m_imageBGView = imageBGView;
        imageBGView.backgroundColor = [UIColor blackColor];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageBGView addSubview:imageView];
        self.m_imageView = imageView;
        
        imageView.backgroundColor = [UIColor blackColor];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
}



- (void)setupImage
{
    if (nil != self.image)
    {
        CGFloat scrollWidth = [self screenWidth];
        CGFloat scrollHeight = [self screenHeight];
        
        CGFloat imageSrcWidth = self.image.size.width;
        CGFloat imageSrcHeight = self.image.size.height;
        
        CGFloat imageShowWidth = scrollWidth;
        CGFloat imageShowHeight = floorf(imageShowWidth / imageSrcWidth * imageSrcHeight);

        CGRect clipRect = self.m_coverView.m_clipRect;
        
        self.m_imageView.image = self.image;
        
        if (imageShowHeight >= scrollHeight)
        {
            CGFloat scrollPadding = floor((scrollHeight - clipRect.size.height) / 2);
            
            CGFloat scrollPaddingW = scrollWidth - clipRect.size.width;
            CGRect imageFrame = (CGRect){0, 0, imageShowWidth, imageShowHeight};
            self.m_imageView.frame = imageFrame;
            imageFrame.origin.x = clipRect.origin.x;
            imageFrame.origin.y = scrollPadding;
            self.m_imageBGView.frame = imageFrame;
            
            self.m_scrollView.contentOffset = (CGPoint){clipRect.origin.x, scrollPadding};
            self.m_scrollView.contentSize = (CGSize){scrollWidth + scrollPaddingW, floor(imageShowHeight + scrollPadding * 2)};
        }
        else
        {
            CGFloat imagePadding = floor((scrollHeight - imageShowHeight) / 2);

            self.m_imageView.frame = (CGRect){0, imagePadding, imageShowWidth, imageShowHeight};
            
            CGFloat scrollPaddingW = scrollWidth - clipRect.size.width;
            CGFloat scrollPaddingH = floor((imageShowHeight - clipRect.size.height) / 2);
            CGRect imageBGFrame = self.m_imageBGView.frame;
            imageBGFrame.origin.y = scrollPaddingH;
            imageBGFrame.origin.x = clipRect.origin.x;
            self.m_imageBGView.frame = imageBGFrame;
            
            self.m_scrollView.contentOffset = (CGPoint){clipRect.origin.x, scrollPaddingH};
            self.m_scrollView.contentSize = (CGSize){scrollWidth + scrollPaddingW, floor(scrollHeight + scrollPaddingH * 2)};
        }
    }
}


#pragma mark - UIScrollViewDelegate
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.m_imageBGView;
}

@end