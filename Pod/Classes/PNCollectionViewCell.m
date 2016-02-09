//
//  PNCollectionViewCell.m
//  Pods
//
//  Created by Giuseppe Nucifora on 09/02/16.
//
//

#import "PNCollectionViewCell.h"
#import <PureLayout/PureLayout.h>

@interface PNCollectionViewCell()

@property (nonatomic, strong) UIImageView *photoImageView;

@end

@implementation PNCollectionViewCell

+ (NSString *)cellIdentifier {
    return [NSStringFromClass([self class]) stringByAppendingString:@"Identifier"];
}

- (instancetype) init {
    self = [super init];

    if (self) {
        [self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];

        _photoImageView = [UIImageView newAutoLayoutView];
		[_photoImageView setContentMode:UIViewContentModeScaleAspectFill];

        [self.contentView addSubview:_photoImageView];
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];

        _photoImageView = [UIImageView newAutoLayoutView];
        [_photoImageView setContentMode:UIViewContentModeScaleAspectFill];

        [self.contentView addSubview:_photoImageView];
    }
    return self;
}

- (void) updateConstraints {

    [super updateConstraints];

    if (!self.didUpdateConstraints) {

        self.didUpdateConstraints = YES;


        [self.contentView autoPinEdgesToSuperviewEdges];

        [_photoImageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];
        [_photoImageView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
        [_photoImageView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:10];
        [_photoImageView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:10];
        [_photoImageView autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [_photoImageView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    }
}

- (void) setPhotoImage:(UIImage *)photoImage {
    if (photoImage) {
        [_photoImageView setImage:photoImage];
    }
}

@end
