//
//  ACMagnifyingView.m
//  MagnifyingGlass
//
//  Created by Arnaud Coomans on 30/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ACMagnifyingView.h"
#import "ACMagnifyingGlass.h"

static CGFloat const kACMagnifyingViewDefaultShowDelay = 0.5;

@interface ACMagnifyingView ()
@property (nonatomic, retain) NSTimer *touchTimer;
- (void)addMagnifyingGlassAtPoint:(CGPoint)point;
- (void)removeMagnifyingGlass;
- (void)updateMagnifyingGlassAtPoint:(CGPoint)point;
@end


@implementation ACMagnifyingView

@synthesize magnifyingGlass, magnifyingGlassShowDelay;
@synthesize touchTimer;


- (id)initWithFrame:(CGRect)frame
{
		self.magnifyingGlassShowDelay = kACMagnifyingViewDefaultShowDelay;
        self.imageView = [[UIImageView alloc]initWithFrame:self.frame];
    self.imageView2 = [[UIImageView alloc]initWithFrame:self.frame];
    
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"frame %@",NSStringFromCGRect(self.imageView.frame));
        self.imageView.frame = [self frameForImage:self.imageView.image inImageViewAspectFit:self.imageView];
        
        UIPanGestureRecognizer *pangesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureOccure:)];
//        self.imageView2.frame = actualRect;
        [self.imageView addGestureRecognizer:pangesture];
        if (_imageView.image.size.height > _imageView.image.size.width) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"ISPORTRAIT" object:nil userInfo:@{ @"value" : [NSNumber numberWithBool:1]}];
        } else {
             [[NSNotificationCenter defaultCenter]postNotificationName:@"ISPORTRAIT" object:nil userInfo:@{ @"value" : [NSNumber numberWithBool:0]}];
            NSLog(@"landscape");
        }
    });
    }
    return  self;
}

#pragma mark - touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	self.touchTimer = [NSTimer scheduledTimerWithTimeInterval:magnifyingGlassShowDelay
													   target:self
													 selector:@selector(addMagnifyingGlassTimer:)
													 userInfo:[NSValue valueWithCGPoint:[touch locationInView:self]]
													  repeats:NO];
//    actualRect = [self calculateClientRectOfImageInUIImageView:self.imageView];
//    NSLog(@"Frame %@",NSStringFromCGRect(self.imageView.frame));
    lastPoint = [touch locationInView:self];
}

-(void)panGestureOccure:(UIPanGestureRecognizer *)gesture
{
    CGPoint currentPoint = [gesture locationInView:self];
    
    if (lastPoint.x == 0 && lastPoint.y == 0)
    {
        lastPoint = currentPoint;
    }
    NSLog(@"currentPoint %@",NSStringFromCGPoint(currentPoint));
    
    [self updateMagnifyingGlassAtPoint:[gesture locationInView:self]];
    
    if (currentPoint.y >=gesture.view.frame.origin.y - self.width/2  + gesture.view.frame.size.height || currentPoint.y <= gesture.view.frame.origin.y + self.width/2 )
    {
        NSLog(@"Leess");
    }
    else if (currentPoint.x <= gesture.view.frame.origin.x + self.width/2 || currentPoint.x >= gesture.view.frame.origin.x+gesture.view.frame.size.width-self.width/2 )
    {
        
    }
    else
    {
        UIGraphicsBeginImageContext(self.frame.size);
        [_imageView2.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x , lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), _width);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), (237.0/255.0), (70.0/255.0), (72.0/255.0), 1.0);
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
        if (_isErasing)
        {
            CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeClear);
        }else{
            CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), (237.0/255.0), (70.0/255.0), (72.0/255.0), 1.0);
            CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
        }
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        _imageView2.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self setNeedsDisplay];
        lastPoint = currentPoint;
    }
    if(gesture.state == UIGestureRecognizerStateEnded)
    {
        [self.touchTimer invalidate];
        self.touchTimer = nil;
        [self removeMagnifyingGlass];
    }
   
}

-(CGRect )calculateClientRectOfImageInUIImageView:(UIImageView *)imgView
{
    CGSize imgViewSize=imgView.frame.size;                  // Size of UIImageView
    CGSize imgSize=imgView.image.size;                      // Size of the image, currently displayed
    
    // Calculate the aspect, assuming imgView.contentMode==UIViewContentModeScaleAspectFit
    
    CGFloat scaleW = imgViewSize.width / imgSize.width;
    CGFloat scaleH = imgViewSize.height / imgSize.height;
    CGFloat aspect=fmin(scaleW, scaleH);
    
    CGRect imageRect={ {0,0} , { imgSize.width*=aspect, imgSize.height*=aspect } };
    
    // Note: the above is the same as :
    // CGRect imageRect=CGRectMake(0,0,imgSize.width*=aspect,imgSize.height*=aspect) I just like this notation better
    
    // Center image
    
    imageRect.origin.x=(imgViewSize.width-imageRect.size.width)/2;
    imageRect.origin.y=(imgViewSize.height-imageRect.size.height)/2;
    
    // Add imageView offset
    
    imageRect.origin.x+=imgView.frame.origin.x;
    imageRect.origin.y+=imgView.frame.origin.y;
    
    return(imageRect);
}


-(CGRect)frameForImage:(UIImage*)image inImageViewAspectFit:(UIImageView*)imageView
{
    float imageRatio = image.size.width / image.size.height;
    float viewRatio = imageView.frame.size.width / imageView.frame.size.height;
    if(imageRatio < viewRatio)
    {
        float scale = imageView.frame.size.height / image.size.height;
        float width = scale * image.size.width;
        float topLeftX = (imageView.frame.size.width - width) * 0.5;
        float heightscale = imageView.frame.size.width / image.size.width;
        float height = heightscale * image.size.height;
        return CGRectMake(topLeftX, 0, width, imageView.frame.size.height);
    }
    else
    {
        float scale = imageView.frame.size.width / image.size.width;
        float height = scale * image.size.height;
        float topLeftY = (imageView.frame.size.height - height) * 0.5;
        return CGRectMake(0, topLeftY, imageView.frame.size.width, height);
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
//	UITouch *touch = [touches anyObject];
//
//    CGPoint currentPoint = [touch locationInView:self];
//    lastPoint = [touch previousLocationInView:self];
//    
//    if (currentPoint.x < actualRect.origin.x && lastPoint.x < actualRect.origin.x)
//    {
//        currentPoint.x = actualRect.origin.x;
//        lastPoint.x = actualRect.origin.x;
//    }
//    if (currentPoint.y < actualRect.origin.y && lastPoint.y < actualRect.origin.y)
//    {
//        currentPoint.y = actualRect.origin.y;
//        lastPoint.y = actualRect.origin.y;
//    }
//    if (currentPoint.x > actualRect.size.width && lastPoint.x > actualRect.size.width)
//    {
//        currentPoint.x = actualRect.size.width;
//        lastPoint.x = actualRect.size.width;
//    }
//    if (currentPoint.y > actualRect.size.height && lastPoint.y > actualRect.size.height)
//    {
//        currentPoint.y = actualRect.size.height;
//        lastPoint.y = actualRect.size.height;
//    }
//    
//    UIGraphicsBeginImageContext(self.frame.size);
//    [_imageView2.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
//    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
//    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
//    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), _width);
//    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), (237.0/255.0), (70.0/255.0), (72.0/255.0), 1.0);
//    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
//    if (_isErasing)
//    {
//        CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeClear);
//    }else{
//        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), (237.0/255.0), (70.0/255.0), (72.0/255.0), 1.0);
//        CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
//    }
//    CGContextStrokePath(UIGraphicsGetCurrentContext());
//    _imageView2.image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self.touchTimer invalidate];
	self.touchTimer = nil;
	[self removeMagnifyingGlass];
}

#pragma mark - private functions

- (void)addMagnifyingGlassTimer:(NSTimer*)timer
{
	NSValue *v = timer.userInfo;
	CGPoint point = [v CGPointValue];
	[self addMagnifyingGlassAtPoint:point];
}

#pragma mark - magnifier functions

- (void)addMagnifyingGlassAtPoint:(CGPoint)point
{	
	if (!magnifyingGlass) {
		magnifyingGlass = [[ACMagnifyingGlass alloc] init];
	}
	
	if (!magnifyingGlass.viewToMagnify) {
		magnifyingGlass.viewToMagnify = self;
		
	}
	
	magnifyingGlass.touchPoint = point;
	[self.superview addSubview:magnifyingGlass];
	[magnifyingGlass setNeedsDisplay];
}

- (void)removeMagnifyingGlass {
	[magnifyingGlass removeFromSuperview];
}

- (void)updateMagnifyingGlassAtPoint:(CGPoint)point
{
	magnifyingGlass.touchPoint = point;
	[magnifyingGlass setNeedsDisplay];
}
@end
