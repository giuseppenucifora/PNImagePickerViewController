//
//  PNCollectionViewCell.h
//  Pods
//
//  Created by Giuseppe Nucifora on 09/02/16.
//
//

#import <UIKit/UIKit.h>

@interface PNCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign) BOOL didUpdateConstraints;
@property (nonatomic, strong) UIImage *photoImage;

+ (NSString*) cellIdentifier;


@end
