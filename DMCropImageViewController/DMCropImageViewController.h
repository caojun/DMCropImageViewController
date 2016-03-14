//
//  DMCropImageViewController.h
//  CropImageDemo
//
//  Created by Dream on 16/3/8.
//  Copyright © 2016年 Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DMCropImageViewController;

@protocol DMCropImageViewControllerDelegate <NSObject>

@optional
- (void)cropImageViewControllerDidClickCancel:(DMCropImageViewController *)viewController;
- (void)cropImageViewController:(DMCropImageViewController *)viewController
                      cropImage:(UIImage *)image;

@end

@interface DMCropImageViewController : UIViewController

@property (nonatomic, weak) id<DMCropImageViewControllerDelegate> delegate;

@property (nonatomic, strong) UIImage *image;

+ (instancetype)cropImageViewController;


@end
