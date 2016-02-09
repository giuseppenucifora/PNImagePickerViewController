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
#import <PureLayout/PureLayout.h>


#pragma mark - PNImagePickerViewController -

@interface PNImagePickerViewController ()  <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

#define imagePickerHeight 280.0f

@property (readwrite) bool isVisible;
@property (readwrite) bool haveCamera;
@property (nonatomic) NSTimeInterval animationTime;

@property (nonatomic, strong) UIViewController *targetController;

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *imagePickerView;
@property (nonatomic, strong) UIView *separator1;
@property (nonatomic, strong) UIView *separator2;
@property (nonatomic, strong) UIView *separator3;

@property (nonatomic, strong) NSLayoutConstraint *hideConstraint;

@property (nonatomic) TransitionDelegate *transitionController;

@property (nonatomic, strong) NSMutableArray *assets;

@property (nonatomic, assign) BOOL didUpdateConstraints;

@end

@implementation PNImagePickerViewController

@synthesize delegate;
@synthesize transitionController;

- (id)init {
    self = [super init];
    if (self) {
        _assets = [[NSMutableArray alloc] init];
        _targetSize = CGSizeMake(1024, 1024);
        _haveCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
        _animationTime = 0.4;


    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];


    _imagePickerView = [UIView newAutoLayoutView];
    [_imagePickerView setBackgroundColor:[UIColor whiteColor]];

    _backgroundView = [UIView newAutoLayoutView];
    _backgroundView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.7];
    _backgroundView.alpha = 0;
    UITapGestureRecognizer *dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    _backgroundView.userInteractionEnabled = YES;
    [_backgroundView addGestureRecognizer:dismissTap];

    [self.view addSubview:_backgroundView];


    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];

    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:aFlowLayout];
    [_collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[PNCollectionViewCell class] forCellWithReuseIdentifier:[PNCollectionViewCell cellIdentifier]];

    UIFont *btnFont = [UIFont systemFontOfSize:19.0];

    _photoLibraryBtn = [UIButton newAutoLayoutView];
    [_photoLibraryBtn setTitle:NSLocalizedString(@"Photo Library",@"") forState:UIControlStateNormal];
    _photoLibraryBtn.titleLabel.font = btnFont;
    [_photoLibraryBtn addTarget:self action:@selector(selectFromLibraryWasPressed) forControlEvents:UIControlEventTouchUpInside];
    [_photoLibraryBtn setTitleColor:[@"0b60fe" colorFromHex] forState:UIControlStateNormal];
    [_photoLibraryBtn setTitleColor:[@"70b3fd" colorFromHex] forState:UIControlStateHighlighted];

    _cancelBtn = [UIButton newAutoLayoutView];
    [_cancelBtn setTitle:NSLocalizedString(@"Cancel",@"") forState:UIControlStateNormal];
    _cancelBtn.titleLabel.font = btnFont;
    [_cancelBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [_cancelBtn setTitleColor:[@"0b60fe" colorFromHex] forState:UIControlStateNormal];
    [_cancelBtn setTitleColor:[@"70b3fd" colorFromHex] forState:UIControlStateHighlighted];



    _separator2 = [UIView newAutoLayoutView];
    _separator2.backgroundColor = [@"cacaca" colorFromHex];
    [_imagePickerView addSubview:_separator2];

    _separator3 = [UIView newAutoLayoutView];
    _separator3.backgroundColor = [@"cacaca" colorFromHex];
    [_imagePickerView addSubview:_separator3];

    if(_haveCamera) {
        _cameraBtn = [UIButton newAutoLayoutView];
        [_cameraBtn setTitle:NSLocalizedString(@"Take Photo",@"") forState:UIControlStateNormal];
        _cameraBtn.titleLabel.font = btnFont;
        [_cameraBtn addTarget:self action:@selector(takePhotoWasPressed) forControlEvents:UIControlEventTouchUpInside];
        [_cameraBtn setTitleColor:[@"0b60fe" colorFromHex] forState:UIControlStateNormal];
        [_cameraBtn setTitleColor:[@"70b3fd" colorFromHex] forState:UIControlStateHighlighted];
        _cameraBtn.hidden = !_haveCamera;
        [_imagePickerView addSubview:_cameraBtn];

        _separator1 = [UIView newAutoLayoutView];
        _separator1.backgroundColor = [@"cacaca" colorFromHex];
        [_imagePickerView addSubview:_separator1];
    }


    [_imagePickerView addSubview:_collectionView];
    [_imagePickerView addSubview:_photoLibraryBtn];
    [_imagePickerView addSubview:_cancelBtn];

    [self.view addSubview:_imagePickerView];

    [self.view setNeedsUpdateConstraints];
    [_imagePickerView setNeedsUpdateConstraints];
    [_collectionView setNeedsUpdateConstraints];
    [_backgroundView setNeedsUpdateConstraints];

}

- (void) updateViewConstraints {
    if (!_didUpdateConstraints) {
        _didUpdateConstraints = YES;

        [_backgroundView autoPinEdgesToSuperviewEdges];

        [_imagePickerView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
        [_imagePickerView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
        _hideConstraint = [_imagePickerView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:-imagePickerHeight];
        [_imagePickerView autoSetDimension:ALDimensionHeight toSize:100 relation:NSLayoutRelationGreaterThanOrEqual];


        [_cancelBtn autoPinEdgeToSuperviewEdge:ALEdgeLeading];
        [_cancelBtn autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
        [_cancelBtn autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [_cancelBtn autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:15];
        [_cancelBtn autoSetDimension:ALDimensionHeight toSize:30];
        [_cancelBtn autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:10];
        [_cancelBtn autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:10];

        [_separator3 autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:10];
        [_separator3 autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:10];
        [_separator3 autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:_cancelBtn withOffset:-10];
        [_separator3 autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [_separator3 autoSetDimension:ALDimensionHeight toSize:1];

        [_photoLibraryBtn autoPinEdgeToSuperviewEdge:ALEdgeLeading];
        [_photoLibraryBtn autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
        [_photoLibraryBtn autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [_photoLibraryBtn autoSetDimension:ALDimensionHeight toSize:30];
        [_photoLibraryBtn autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:_separator3 withOffset:-10];
        [_photoLibraryBtn autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:10];
        [_photoLibraryBtn autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:10];

        [_separator2 autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:10];
        [_separator2 autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:10];
        [_separator2 autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:_photoLibraryBtn withOffset:-10];
        [_separator2 autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [_separator2 autoSetDimension:ALDimensionHeight toSize:1];

        if (_haveCamera) {
            [_cameraBtn autoPinEdgeToSuperviewEdge:ALEdgeLeading];
            [_cameraBtn autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
            [_cameraBtn autoAlignAxisToSuperviewAxis:ALAxisVertical];
            [_cameraBtn autoSetDimension:ALDimensionHeight toSize:30];
            [_cameraBtn autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:_separator2 withOffset:-10];
            [_cameraBtn autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:10];
            [_cameraBtn autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:10];

            [_separator1 autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:10];
            [_separator1 autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:10];
            [_separator1 autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:_cameraBtn withOffset:-10];
            [_separator1 autoAlignAxisToSuperviewAxis:ALAxisVertical];
            [_separator1 autoSetDimension:ALDimensionHeight toSize:1];
        }

        [_collectionView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
        [_collectionView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
        [_collectionView autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [_collectionView autoSetDimension:ALDimensionHeight toSize:122];
        if (_haveCamera) {
            [_collectionView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:_separator1 withOffset:-15];
        }
        else {
            [_collectionView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:_separator2 withOffset:-15];
        }

        [_collectionView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10];

    }
    [super updateViewConstraints];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self getCameraRollImages];
}

#pragma mark - Collection view

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MIN(20, _assets.count);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PNCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PNCollectionViewCell cellIdentifier] forIndexPath:indexPath];

    PHAsset *asset = _assets[_assets.count-1 - indexPath.row];

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

    PHAsset *asset = _assets[_assets.count-1 - indexPath.row];
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
    return CGSizeMake(180, 120);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

#pragma mark - Image library


- (void)getCameraRollImages {

    dispatch_async(dispatch_get_main_queue(), ^{

        PHFetchOptions *allPhotosOptions = [PHFetchOptions new];
        allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        //[allPhotosOptions setFetchLimit:20];

        PHFetchResult *allPhotosResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:allPhotosOptions];
        [allPhotosResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
            if(asset) {
                [_assets addObject:asset];
            }
        }];
		[_collectionView reloadData];
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
    if (_isVisible != YES) {
        if ([delegate respondsToSelector:@selector(imagePickerWillOpen)]) {
            [delegate imagePickerWillOpen];
        }
        _isVisible = YES;

        [self setTransitioningDelegate:transitionController];
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;

        [controller presentViewController:self animated:NO completion:^{

            [_imagePickerView setNeedsUpdateConstraints];
            [_imagePickerView updateConstraintsIfNeeded];

            if (animated) {

                [UIView animateWithDuration:_animationTime
                                      delay:0.0
                     usingSpringWithDamping:1
                      initialSpringVelocity:0
                                    options:0
                                 animations:^{

                                     [_hideConstraint setConstant:0];

                                     [_backgroundView setAlpha:1];

                                     [_imagePickerView layoutIfNeeded];
                                 }
                                 completion:^(BOOL finished) {
                                     if ([delegate respondsToSelector:@selector(imagePickerDidOpen)]) {
                                         [delegate imagePickerDidOpen];
                                     }
                                 }];
            } else {
                
                [_hideConstraint setConstant:0];
                
                [_backgroundView setAlpha:1];
                
                [_imagePickerView layoutIfNeeded];
            }
        }];
    }
}

#pragma mark - Dismiss

- (void)dismiss {
    [self dismissAnimated:YES];
}

- (void)dismissAnimated:(BOOL)animated {
    if (_isVisible == YES) {
        if ([delegate respondsToSelector:@selector(imagePickerWillClose)]) {
            [delegate imagePickerWillClose];
        }
        [_imagePickerView setNeedsUpdateConstraints];
        [_imagePickerView updateConstraintsIfNeeded];

        if (animated) {

            [UIView animateWithDuration:_animationTime
                                  delay:0.0
                 usingSpringWithDamping:1
                  initialSpringVelocity:0
                                options:0
                             animations:^{

                                 [_hideConstraint setConstant:imagePickerHeight];

                                 [_backgroundView setAlpha:0];

                                 [_imagePickerView layoutIfNeeded];
                             }
                             completion:^(BOOL finished) {
                                 [self dismissViewControllerAnimated:YES completion:^{
                                     if ([delegate respondsToSelector:@selector(imagePickerDidClose)]) {
                                         [delegate imagePickerDidClose];
                                     }
                                 }];
                             }];
        } else {

            [_hideConstraint setConstant:imagePickerHeight];

            [_backgroundView setAlpha:0];

            [_imagePickerView layoutIfNeeded];

            [self dismissViewControllerAnimated:NO completion:^{
                if ([delegate respondsToSelector:@selector(imagePickerDidClose)]) {
                    [delegate imagePickerDidClose];
                }
            }];
        }
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