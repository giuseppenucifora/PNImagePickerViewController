//
//  NSString+HexColor.h
//  Packman
//
//  Created by Giuseppe Nucifora on 20/10/12.
//  Copyright (c) 2015 Purplenetwork S.r.l. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HexColor)

- (UIColor*)colorFromHex;

@end