//
//  ACMagnifyingGlass.m
//  MagnifyingGlass
//

#import "ACMagnifyingGlass.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const kACMagnifyingGlassDefaultRadius = 40;
static CGFloat const kACMagnifyingGlassDefaultOffset = -40;
static CGFloat const kACMagnifyingGlassDefaultScale = 1.5;

@interface ACMagnifyingGlass ()
@end

@implementation ACMagnifyingGlass

@synthesize viewToMagnify, touchPoint, touchPointOffset, scale, scaleAtTouchPoint;

- (id)init {
    self = [self initWithFrame:CGRectMake(0, 0, kACMagnifyingGlassDefaultRadius*2, kACMagnifyingGlassDefaultRadius*2)];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
    {
		self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
		self.layer.borderWidth = 3;
//		self.layer.cornerRadius = frame.size.width / 2;
		self.layer.masksToBounds = YES;
		self.touchPointOffset = CGPointMake(0, 0);
		self.scale = kACMagnifyingGlassDefaultScale;
		self.viewToMagnify = nil;
		self.scaleAtTouchPoint = YES;
	}
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(isPortrait:) name:@"ISPORTRAIT" object:nil];
	return self;
}

- (void)setFrame:(CGRect)f
{
	super.frame = f;
//	self.layer.cornerRadius = f.size.width / 2;
}

-(BOOL)isPortrait:(NSNotification *)notification
{
    NSNumber *number = notification.userInfo[@"value"];
    if ([number boolValue]) {
        isPortrait = true;
    }
    else{
        isPortrait = false;
    }
    return true;
}

- (void)setTouchPoint:(CGPoint)point
{
	touchPoint = point;
//	self.center = CGPointMake(point.x, point.y);
}

- (void)drawRect:(CGRect)rect
{
        CGContextRef context = UIGraphicsGetCurrentContext();
    
    int x,y;
    if (isPortrait) {
        if ([UIScreen mainScreen].bounds.size.height > 568)
        {
            x = 78;
            y = 45;
        }
        else
        {
            x = 90;
            y = 50;
        }
    }
    else
    {
        if ([UIScreen mainScreen].bounds.size.height > 568)
        {
            x = 45;
            y = 150;
        }
        if ([UIScreen mainScreen].bounds.size.height > 667)
        {
            x = 45;
            y = 170;
        }
        else
        {
            x = 50;
            y = 120;
        }
    }
    
        if(touchPoint.x < x)
        {
            touchPoint.x = x;
        }
        else if (touchPoint.x > self.viewToMagnify.frame.size.width-x)
        {
            touchPoint.x = self.viewToMagnify.frame.size.width-x;
        }
        if(touchPoint.y < y)
        {
            touchPoint.y = y;
        }
        else if (touchPoint.y > self.viewToMagnify.frame.size.height-y)
        {
            touchPoint.y = self.viewToMagnify.frame.size.height-y;
        }
        
        CGContextTranslateCTM (context, self.frame.size.width/2, self.frame.size.height/2 );
        //    CGContextScaleCTM(context, scale*sqrt(pow(self.viewToMagnify.transform.a, 2) + pow(self.viewToMagnify.transform.c, 2)), scale*sqrt(pow(self.viewToMagnify.transform.b, 2) + pow(self.viewToMagnify.transform.d, 2)));
        CGContextScaleCTM(context, scale, scale);
        //    CGContextTranslateCTM(context, -touchPoint.x, -touchPoint.y);
        CGContextTranslateCTM(context, -touchPoint.x, -touchPoint.y);
    
        [self.viewToMagnify.layer renderInContext:context];

}

@end
