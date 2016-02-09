//
//  PNImagePickerViewControllerViewController.m
//  PNImagePickerViewController
//
//  Created by Giuseppe Nucifora on 02/09/2016.
//  Copyright (c) 2016 Giuseppe Nucifora. All rights reserved.
//

#import "PNImagePickerViewControllerViewController.h"
#import "PNImagePickerViewController.h"
#import <PureLayout/PureLayout.h>

@interface PNImagePickerViewControllerViewController () <PNImagePickerViewControllerDelegate>

@property (nonatomic) BOOL didSetupConstraints;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation PNImagePickerViewControllerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _button = [UIButton newAutoLayoutView];
    [_button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_button setTitle:@"Show Picker" forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(showPicker) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];

    _imageView = [UIImageView newAutoLayoutView];
    [_imageView setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.6]];

    [self.view addSubview:_imageView];

    [self.view setNeedsUpdateConstraints];

	// Do any additional setup after loading the view, typically from a nib.
}

- (void) updateViewConstraints {
    if (!_didSetupConstraints) {
        _didSetupConstraints = YES;

        [self.view autoPinEdgesToSuperviewEdges];

        [_imageView autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [_imageView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
        [_imageView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
        [_imageView autoAlignAxisToSuperviewAxis:ALAxisVertical];

        [_button autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_imageView withOffset:20];
        [_button autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:20];
        [_button autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [_button autoSetDimension:ALDimensionHeight toSize:30];
        [_button autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:100 relation:NSLayoutRelationGreaterThanOrEqual];
        [_button autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:100 relation:NSLayoutRelationGreaterThanOrEqual];


    }
    [super updateViewConstraints];
}

- (void) showPicker {

    PNImagePickerViewController *imagePicker = [[PNImagePickerViewController alloc] init];
    imagePicker.delegate = self;
    [imagePicker showImagePickerInController:self animated:YES];

}

#pragma mark - PNImagePickerViewControllerDelegate

- (void)imagePicker:(PNImagePickerViewController *)imagePicker didSelectImage:(UIImage *)image {
    self.imageView.image = image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
