//
//  PNCollectionViewCell.m
//  Pods
//
//  Created by Giuseppe Nucifora on 09/02/16.
//
//

#import "PNCollectionViewCell.h"
#import <PureLayout/PureLayout.h>
#import <DGActivityIndicatorView/DGActivityIndicatorView.h>

@interface PNCollectionViewCell()

@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) DGActivityIndicatorView *loadingSpinner;

@end

@implementation PNCollectionViewCell

+ (NSString *)cellIdentifier {
    return [NSStringFromClass([self class]) stringByAppendingString:@"Identifier"];
}

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];

        _photoImageView = [UIImageView newAutoLayoutView];
        [_photoImageView setContentMode:UIViewContentModeScaleAspectFill];
        [_photoImageView.layer setCornerRadius:4];
        [_photoImageView.layer setMasksToBounds:YES];

        [self.contentView addSubview:_photoImageView];

        _loadingSpinner = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeBallClipRotate tintColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.7] size:35];
        [_loadingSpinner setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:_loadingSpinner];

        [_loadingSpinner startAnimating];
    }
    return self;
}

- (void) updateConstraints {

    [super updateConstraints];

    if (!self.didUpdateConstraints) {

        self.didUpdateConstraints = YES;

        [self.contentView autoPinEdgesToSuperviewEdges];

        [_photoImageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:8];
        [_photoImageView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:8];
        [_photoImageView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:8];
        [_photoImageView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:8];
        [_photoImageView autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [_photoImageView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];


        [_loadingSpinner autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [_loadingSpinner autoAlignAxisToSuperviewAxis:ALAxisVertical];
    }
}

- (void) setPhotoImage:(UIImage *)photoImage {
    if (photoImage) {
        [_photoImageView setImage:photoImage];
        [_loadingSpinner stopAnimating];
        [_loadingSpinner setAlpha:0];
    }
}

@end
