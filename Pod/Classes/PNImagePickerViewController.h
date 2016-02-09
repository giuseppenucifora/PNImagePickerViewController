//
//  PNCollectionViewCell.h
//  Pods
//
//  Created by Giuseppe Nucifora on 09/02/16.
//
//

#import <UIKit/UIKit.h>

@class PNImagePickerViewController ;

@protocol PNImagePickerViewControllerDelegate <NSObject>

@required

- (void)imagePicker:(PNImagePickerViewController *)imagePicker didSelectImage:(UIImage *)image;

- (void)imagePicker:(PNImagePickerViewController *)imagePicker donwloadImageWithProgress:(double )progress;

@optional

- (void)imagePickerDidOpen;

- (void)imagePickerWillOpen;

- (void)imagePickerWillClose;

- (void)imagePickerDidClose;

- (void)imagePickerDidCancel;

@end

@interface PNImagePickerViewController : UIViewController

- (void)setAnimationTime:(NSTimeInterval)animationTime;

- (void)showImagePickerInController:(UIViewController *)controller;

- (void)showImagePickerInController:(UIViewController *)controller animated:(BOOL)animated;

- (void)dismiss;

- (void)dismissAnimated:(BOOL)animated;


@property (nonatomic, assign) id<PNImagePickerViewControllerDelegate> delegate;

@property (readonly) bool isVisible;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIButton *photoLibraryBtn;

@property (nonatomic, strong) UIButton *cameraBtn;

@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic) CGSize targetSize;

@end





@interface TransitionDelegate : NSObject <UIViewControllerTransitioningDelegate>

@end






@interface AnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL isPresenting;

@end





