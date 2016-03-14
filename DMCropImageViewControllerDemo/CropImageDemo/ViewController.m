//
//  ViewController.m
//  CropImageDemo
//
//  Created by Dream on 16/3/8.
//  Copyright © 2016年 Dream. All rights reserved.
//

#import "ViewController.h"
#import "DMCropImageViewController.h"

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, DMCropImageViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *m_imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)btnClick
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = NO;
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = nil;
    
    if (picker.allowsEditing)
    {
        image = info[UIImagePickerControllerEditedImage];
    }
    else
    {
        image = info[UIImagePickerControllerOriginalImage];
    }

    DMCropImageViewController *vc = [DMCropImageViewController cropImageViewController];
    vc.image = image;
    vc.delegate = self;
    [picker pushViewController:vc animated:YES];
    
}

#pragma mark - DMCropImageViewControllerDelegate
- (void)cropImageViewControllerDidClickCancel:(DMCropImageViewController *)viewController;
{
    [viewController.navigationController popViewControllerAnimated:YES];
}

- (void)cropImageViewController:(DMCropImageViewController *)viewController
                      cropImage:(UIImage *)image
{
    NSLog(@"%@", image);
    
    self.m_imageView.image = image;
    
    [viewController dismissViewControllerAnimated:YES completion:nil];
}


@end
