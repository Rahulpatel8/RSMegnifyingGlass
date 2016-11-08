//
//  ACMagnifyingView.h
//  MagnifyingGlass
//
//  Created by Arnaud Coomans on 30/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ACMagnifyingGlass;

@interface ACMagnifyingView : UIView{
    CGRect actualRect;
    CGPoint lastPoint;
}

@property (nonatomic, retain) ACMagnifyingGlass *magnifyingGlass;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) IBOutlet UIImageView *imageView2;
@property (nonatomic) BOOL isErasing;
@property (nonatomic) CGFloat width;
@property (nonatomic, assign) CGFloat magnifyingGlassShowDelay;

@end
