//
//  PNCollectionViewCell.h
//  Pods
//
//  Created by Giuseppe Nucifora on 09/02/16.
//
//

#import "PNImagePickerViewController.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "PNCollectionViewCell.h"
#import "NSString+HexColor.h"


#pragma mark - PNImagePickerViewController -

@interface PNImagePickerViewController ()  <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

#define imagePickerHeight 280.0f

@property (readwrite) bool isVisible;
@property (readwrite) bool haveCamera;
@property (nonatomic) NSTimeInterval animationTime;

@property (nonatomic, strong) UIViewController *targetController;
@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *imagePickerView;

@property (nonatomic) CGRect imagePickerFrame;
@property (nonatomic) CGRect hiddenFrame;

@property (nonatomic) TransitionDelegate *transitionController;

@property (nonatomic, strong) NSMutableArray *assets;

@end

@implementation PNImagePickerViewController

@synthesize delegate;
@synthesize transitionController;

- (id)init {
    self = [super init];
    if (self) {
        self.assets = [[NSMutableArray alloc] init];
        _targetSize = CGSizeMake(1024, 1024);
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.view.backgroundColor = [UIColor clearColor];
    self.window = [UIApplication sharedApplication].keyWindow;

    self.haveCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    CGFloat localImagePickerHeight = imagePickerHeight;
    if (!self.haveCamera) {
        localImagePickerHeight -= 47.0f;
    }
    self.imagePickerFrame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-localImagePickerHeight, [UIScreen mainScreen].bounds.size.width, localImagePickerHeight);
    self.hiddenFrame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, localImagePickerHeight);
    self.imagePickerView = [[UIView alloc] initWithFrame:self.hiddenFrame];
    self.imagePickerView.backgroundColor = [UIColor whiteColor];



    self.backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.7];
    self.backgroundView.alpha = 0;
    UITapGestureRecognizer *dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    self.backgroundView.userInteractionEnabled = YES;
    [self.backgroundView addGestureRecognizer:dismissTap];



    self.animationTime = 0.2;

    [self.window addSubview:self.backgroundView];
    [self.window addSubview:self.imagePickerView];

    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.imagePickerView.frame.size.width, 50)];
    [btn setTitle:@"Hello!" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(setDefaults) forControlEvents:UIControlEventTouchUpInside];

    [self.imagePickerView addSubview:btn];

    [self imagePickerViewSetup];
    [self getCameraRollImages];
}

- (void)imagePickerViewSetup {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;

    const CGRect collectionViewFrame = CGRectMake(7, 8, screenWidth-7-7, 122);
    const CGRect libraryBtnFrame = CGRectMake(0, 149, screenWidth, 30);
    const CGRect cameraBtnFrame = CGRectMake(0, self.haveCamera ? 196 : 0, screenWidth, 30);
    const CGRect cancelBtnFrame = CGRectMake(0, self.haveCamera ? 242 : 196, screenWidth, 30);

    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.collectionView = [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:aFlowLayout];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[PNCollectionViewCell class] forCellWithReuseIdentifier:[PNCollectionViewCell cellIdentifier]];

    UIFont *btnFont = [UIFont systemFontOfSize:19.0];

    self.photoLibraryBtn = [[UIButton alloc] initWithFrame:libraryBtnFrame];
    [self.photoLibraryBtn setTitle:@"Photo Library" forState:UIControlStateNormal];
    self.photoLibraryBtn.titleLabel.font = btnFont;
    [self.photoLibraryBtn addTarget:self action:@selector(selectFromLibraryWasPressed) forControlEvents:UIControlEventTouchUpInside];

    self.cameraBtn = [[UIButton alloc] initWithFrame:cameraBtnFrame];
    [self.cameraBtn setTitle:@"Take Photo" forState:UIControlStateNormal];
    self.cameraBtn.titleLabel.font = btnFont;
    [self.cameraBtn addTarget:self action:@selector(takePhotoWasPressed) forControlEvents:UIControlEventTouchUpInside];
    self.cameraBtn.hidden = !self.haveCamera;

    self.cancelBtn = [[UIButton alloc] initWithFrame:cancelBtnFrame];
    [self.cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    self.cancelBtn.titleLabel.font = btnFont;
    [self.cancelBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];

    for (UIButton *btn in @[self.photoLibraryBtn, self.cameraBtn, self.cancelBtn]) {
        [btn setTitleColor:[@"0b60fe" colorFromHex] forState:UIControlStateNormal];
        [btn setTitleColor:[@"70b3fd" colorFromHex] forState:UIControlStateHighlighted];
    }

    UIView *separator1 = [[UIView alloc] initWithFrame:CGRectMake(0, 140, screenWidth, 1)];
    separator1.backgroundColor = [@"cacaca" colorFromHex];
    [self.imagePickerView addSubview:separator1];

    UIView *separator2 = [[UIView alloc] initWithFrame:CGRectMake(25, 187, screenWidth-25, 1)];
    separator2.backgroundColor = [@"cacaca" colorFromHex];
    [self.imagePickerView addSubview:separator2];
    UIView *separator3 = [[UIView alloc] initWithFrame:CGRectMake(25, 234, screenWidth-25, 1)];
    separator3.backgroundColor = [@"cacaca" colorFromHex];
    [self.imagePickerView addSubview:separator3];

    [self.imagePickerView addSubview:self.collectionView];
    [self.imagePickerView addSubview:self.photoLibraryBtn];
    [self.imagePickerView addSubview:self.cameraBtn];
    [self.imagePickerView addSubview:self.cancelBtn];
}

#pragma mark - Collection view

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MIN(20, self.assets.count);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PNCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PNCollectionViewCell cellIdentifier] forIndexPath:indexPath];

    PHAsset *asset = self.assets[self.assets.count-1 - indexPath.row];

    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = YES;
    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        /*
         Progress callbacks may not be on the main thread. Since we're updating
         the UI, dispatch to the main queue.
         */
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(imagePicker:donwloadImageWithProgress:)]) {
                [delegate imagePicker:self donwloadImageWithProgress:progress];
            }
        });
    };

    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(300, 300) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        // Check if the request was successful.
        if (!result) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell setPhotoImage:result];
            [cell setNeedsUpdateConstraints];
        });
    }];


    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];

    PHAsset *asset = self.assets[self.assets.count-1 - indexPath.row];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = YES;
    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        /*
         Progress callbacks may not be on the main thread. Since we're updating
         the UI, dispatch to the main queue.
         */
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(imagePicker:donwloadImageWithProgress:)]) {
                [delegate imagePicker:self donwloadImageWithProgress:progress];
            }
        });
    };

    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:_targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        // Hide the progress view now the request has completed.


        // Check if the request was successful.
        if (!result) {
            return;
        }

        // Show the UIImageView and use it to display the requested image.
        if ([delegate respondsToSelector:@selector(imagePicker:didSelectImage:)]) {
            [delegate imagePicker:self didSelectImage:result];
        }

        [self dismissAnimated:YES];
    }];

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(170, 114);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0f;
}

#pragma mark - Image library


- (void)getCameraRollImages {
	_assets = [@[] mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^{

        PHFetchOptions *allPhotosOptions = [PHFetchOptions new];
        allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];

        PHFetchResult *allPhotosResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:allPhotosOptions];
        [allPhotosResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
            NSLog(@"asset %@", asset);
            if(asset) {
                [self.assets addObject:asset];
            }
        }];

        [self.collectionView reloadData];
    });
}

#pragma mark - Image picker

- (void)takePhotoWasPressed {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {

        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];

        [myAlertView show];

    } else {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];

        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)selectFromLibraryWasPressed {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];

    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];

    [picker dismissViewControllerAnimated:YES completion:^{
        if ([delegate respondsToSelector:@selector(imagePicker:didSelectImage:)]) {
            [delegate imagePicker:self didSelectImage:chosenImage];
        }
        [self dismissAnimated:YES];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Show

- (void)showImagePickerInController:(UIViewController *)controller {
    [self showImagePickerInController:controller animated:YES];
}

- (void)showImagePickerInController:(UIViewController *)controller animated:(BOOL)animated {
    if (self.isVisible != YES) {
        if ([delegate respondsToSelector:@selector(imagePickerWillOpen)]) {
            [delegate imagePickerWillOpen];
        }
        self.isVisible = YES;

        [self setTransitioningDelegate:transitionController];
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;

        [controller presentViewController:self animated:NO completion:nil];

        if (animated) {
            [UIView animateWithDuration:self.animationTime
                                  delay:0
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 [self.imagePickerView setFrame:self.imagePickerFrame];
                                 [self.backgroundView setAlpha:1];
                             }
                             completion:^(BOOL finished) {
                                 if ([delegate respondsToSelector:@selector(imagePickerDidOpen)]) {
                                     [delegate imagePickerDidOpen];
                                 }
                             }];
        } else {
            [self.imagePickerView setFrame:self.imagePickerFrame];
            [self.backgroundView setAlpha:0];
        }
    }
}

#pragma mark - Dismiss

- (void)dismiss {
    [self dismissAnimated:YES];
}

- (void)dismissAnimated:(BOOL)animated {
    if (self.isVisible == YES) {
        if ([delegate respondsToSelector:@selector(imagePickerWillClose)]) {
            [delegate imagePickerWillClose];
        }
        if (animated) {
            [UIView animateWithDuration:self.animationTime
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 [self.imagePickerView setFrame:self.hiddenFrame];
                                 [self.backgroundView setAlpha:0];
                             }
                             completion:^(BOOL finished) {
                                 [self.imagePickerView removeFromSuperview];
                                 [self.backgroundView removeFromSuperview];
                                 [self dismissViewControllerAnimated:NO completion:nil];
                                 if ([delegate respondsToSelector:@selector(imagePickerDidClose)]) {
                                     [delegate imagePickerDidClose];
                                 }
                             }];
        } else {
            [self.imagePickerView setFrame:self.imagePickerFrame];
            [self.backgroundView setAlpha:0];
        }

        // Set everything to nil
    }
}

@end



#pragma mark - TransitionDelegate -
@implementation TransitionDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    AnimatedTransitioning *controller = [[AnimatedTransitioning alloc] init];
    controller.isPresenting = YES;
    return controller;
}

@end




#pragma mark - AnimatedTransitioning -
@implementation AnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *inView = [transitionContext containerView];
    UIViewController *toVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

    [inView addSubview:toVC.view];

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [toVC.view setFrame:CGRectMake(0, screenRect.size.height, fromVC.view.frame.size.width, fromVC.view.frame.size.height)];

    [UIView animateWithDuration:0.25f
                     animations:^{
                         [toVC.view setFrame:CGRectMake(0, 0, fromVC.view.frame.size.width, fromVC.view.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [transitionContext completeTransition:YES];
                     }];
}


@end