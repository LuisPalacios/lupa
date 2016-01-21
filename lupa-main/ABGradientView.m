/**
 *  @class  ABGradientView ABGradientView.m "ABGradientView.m"
 *  @file   ABGradientView.m
 *  @brief  NSView with colored background and border, also with optional rounded shape
 *
 *  ------------------------------------------------------------------------------------------------
 *
 */


#import "ABGradientView.h"


// Private Constants. Preferred over in-line numbers or #define's
//--------------------------------------------------------------------------------------------------

static const CGFloat ABDefaultRoundedRadius             = 7.0f;     //!< Default Rounded radius
static const CGFloat ABDefaultBackgroundGradientAngle   = 270.0f;
static const CGFloat ABDefaultBackgroundAlpha           = 0.2f;
static const CGFloat ABDefaultBorderAlpha               = 0.5f;
static const CGFloat ABDefaultBorderWidth               = 2.0f;

static const CGFloat ABDefaultMargin                    = 0.0f;

static const CGFloat ABDefaultTriangleWidth             = 10.0f;
static const CGFloat ABDefaultTriangleHeight            = 5.0f;

static const CGFloat ABDefaultRectangleWidth             = 80.0f;
static const CGFloat ABDefaultRectangleHeight            = 5.0f;

// Interface, private instance variables declaration
//--------------------------------------------------------------------------------------------------

@interface ABGradientView () {
    
}
@end


//--------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Implementation

@implementation ABGradientView


//// Synthesize the instance variable using a declared property and
//// binding it to the name of the instance variable

@synthesize backgroundStartingColor = _backgroundStartingColor;
@synthesize backgroundEndingColor   = _backgroundEndingColor;
@synthesize backgroundAlpha         = _backgroundAlpha;


//--------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Object Init and Dealloc


/** @brief dealloc of the object
 *
 */
- (void)dealloc {

    // Log
    // LPLog(@"");
    
    // Clean the retained attributes
    self.roundedRadius = nil;
    self.backgroundStartingColor = nil;
    self.backgroundEndingColor = nil;
    self.backgroundGradientAngle = nil;
    self.backgroundAlpha = nil;
    self.borderColor = nil;
    self.borderAlpha = nil;
    self.borderWidth = nil;
    
    // super's dealloc
}

/** @brief Initializes the object
 *
 */
- (void)commonInit
{
    // do any initialization that's common to both -initWithFrame:
    // and -initWithCoder: in this method

    NSLog(@"");
    
    [self setRoundedShape:NO];
    [self setRoundedBottom:NO];
    [self setRoundedTop:NO];
    [self setRoundedRadius:[NSNumber numberWithFloat:ABDefaultRoundedRadius]];
    
    [self setBackgroundStartingColor:[NSColor purpleColor]];
    [self setBackgroundEndingColor:nil];
    [self setBackgroundGradientAngle:[NSNumber numberWithFloat:ABDefaultBackgroundGradientAngle]];
    [self setBackgroundAlpha:[NSNumber numberWithFloat:ABDefaultBackgroundAlpha]];
    
    [self setGlobalMargin:[NSNumber numberWithFloat:ABDefaultMargin]];
    [self setLeftMargin:[NSNumber numberWithFloat:ABDefaultMargin]];
    [self setRightMargin:[NSNumber numberWithFloat:ABDefaultMargin]];
    [self setTopMargin:[NSNumber numberWithFloat:ABDefaultMargin]];
    [self setBottomMargin:[NSNumber numberWithFloat:ABDefaultMargin]];
    
    [self setBorderColor:[NSColor redColor]];
    [self setShowBorder:YES];
    
    [self setBorderWidth:[NSNumber numberWithFloat:ABDefaultBorderWidth]];
    [self setBorderAlpha:[NSNumber numberWithFloat:ABDefaultBorderAlpha]];
    
    // Load the image
    //[self setBackgroundImage:[NSImage imageNamed:@"papel-empapelar.png"] ];

}

- (id)initWithFrame:(CGRect)aRect
{
    if ((self = [super initWithFrame:aRect])) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
        [self commonInit];
    }
    return self;
}


//--------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Drawing section


/** @brief Draw within the specified rectangle
 *
 */
- (void)drawRect:(NSRect)rect {
    
    
    if ( [self backgroundImage] != nil ) {

        [[self backgroundImage] drawInRect:rect];
        
    } else {
        
        // If no Ending color then set both the same for a flat (no gradient) color
        if (self.backgroundEndingColor == nil ) {
            [self setBackgroundEndingColor:[self backgroundStartingColor]];
        }
        
        // Grab the colors
        NSColor *cStart     = [[self backgroundStartingColor] colorWithAlphaComponent:[[self backgroundAlpha] floatValue]];
        NSColor *cEnd       = [[self backgroundEndingColor] colorWithAlphaComponent:[[self backgroundAlpha] floatValue]];
        NSColor *cBorder    = [[self borderColor] colorWithAlphaComponent:[[self borderAlpha] floatValue]];
        
        // Allways work with the total view bounds
        CGFloat globalMargin      = [[self globalMargin] floatValue];
        CGFloat leftMargin      = [[self leftMargin] floatValue];
        CGFloat rightMargin      = [[self rightMargin] floatValue];
        CGFloat topMargin      = [[self topMargin] floatValue];
        CGFloat bottomMargin      = [[self bottomMargin] floatValue];
        NSRect  newRect     = [self bounds];
        if ( globalMargin != 0.0f ) {
            newRect     =  NSMakeRect([self bounds].origin.x+globalMargin, [self bounds].origin.y+globalMargin, [self bounds].size.width-(globalMargin*2.0f), [self bounds].size.height-(globalMargin*2.0f));
        } else if ( leftMargin != 0.0f ||  rightMargin != 0.0f ||  topMargin != 0.0f ||  bottomMargin != 0.0f ) {
            newRect     =  NSMakeRect([self bounds].origin.x+leftMargin, [self bounds].origin.y+bottomMargin, [self bounds].size.width-(leftMargin+rightMargin), [self bounds].size.height-(bottomMargin+topMargin));
        }
        
        // RECT TO DRAW (with borders if requested)
        // ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
        CGFloat         radius  = ([self isRoundedShape]||[self isRoundedBottom]||[self isRoundedTop]) ? [[self roundedRadius] floatValue] : 0.0f;
        NSBezierPath    *path;
        
        if ( [self isRoundedShape] ) {
            path   = [NSBezierPath bezierPathWithRoundedRect:newRect xRadius:radius yRadius:radius];
        } else {
            NSUInteger rCorners=0;
            if ( [self isRoundedTop] || [self isRoundedBottom]  ) {
                if ( [self isRoundedTop] ) {
                    rCorners |= RectCornerTopLeft|RectCornerTopRight;
                }
                if ([self isRoundedBottom]) {
                    rCorners |= RectCornerBottomLeft|RectCornerBottomRight;
                }
                path = [self bezierPathWithRoundedRect:newRect byRoundingCorners:rCorners cornerRadii:CGSizeMake(radius, radius)];
            } else {
                path   = [NSBezierPath bezierPathWithRoundedRect:newRect xRadius:0.0 yRadius:0.0];
            }
        }
        
        // BACKGROUND: COLOR FILL
        // ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
        NSGradient* aGradient = [[NSGradient alloc] initWithStartingColor:cStart endingColor:cEnd];
        [aGradient drawInBezierPath:path angle:[[self backgroundGradientAngle] floatValue]];
        
        // BORDER:
        // ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
        if ( [self isShowBorder] ) {
            [path setLineWidth:[[self borderWidth] floatValue]];
            [cBorder set];
            [path stroke];
        }
        
    }

    // Triangle Grip
    if ( [self isTriangleGrip] ) {
        NSBezierPath *tPath = [NSBezierPath bezierPath];
        [tPath moveToPoint:NSMakePoint((self.bounds.size.width/2) - (ABDefaultTriangleWidth/2), 0)];
        [tPath lineToPoint:NSMakePoint((self.bounds.size.width/2), ABDefaultTriangleHeight)];
        [tPath lineToPoint:NSMakePoint((self.bounds.size.width/2) + (ABDefaultTriangleWidth/2), 0)];
        [tPath closePath];
        [[NSColor grayColor] set];
        [tPath fill];
    }
    

    // Rectangular Grip
    if ( [self isRectangularGrip] ) {
        NSBezierPath *rPath = [NSBezierPath bezierPath];
        [rPath moveToPoint:NSMakePoint((self.bounds.size.width/2) - (ABDefaultRectangleWidth/2), 0)];
        [rPath lineToPoint:NSMakePoint((self.bounds.size.width/2) - (ABDefaultRectangleWidth/2), ABDefaultRectangleHeight)];
        [rPath lineToPoint:NSMakePoint((self.bounds.size.width/2) + (ABDefaultRectangleWidth/2), ABDefaultRectangleHeight)];
        [rPath lineToPoint:NSMakePoint((self.bounds.size.width/2) + (ABDefaultRectangleWidth/2), 0)];
        [rPath closePath];
        [[NSColor grayColor] set];
        [rPath stroke];
    }
    
    [super drawRect:rect];
}


// Implementation
//--------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Setters and Getters


/** @brief Setter to change the Gradient starting color
 *
 */
- (void)setRectangularGrip:(BOOL)boolValue
{
    _rectangularGrip = boolValue;
    if ( _rectangularGrip ) {
        [self updateTrackingAreas];
    }
}

/** @brief Setter to change the Gradient starting color
 *
 */
- (void)setBackgroundStartingColor:(NSColor *)newColor
{
    _backgroundStartingColor = newColor;
    [self setNeedsDisplay:YES];
}

/** @brief Setter to change the Gradient ending color
 *
 */
- (void)setBackgroundEndingColor:(NSColor *)newColor {

	_backgroundEndingColor = newColor;
	[self setNeedsDisplay:YES];
}

/** @brief Setter to change the Border color
 *
 */
- (void)setBorderColor:(NSColor *)newColor {

	_borderColor = newColor;
	[self setNeedsDisplay:YES];
}

- (NSBezierPath *) bezierPathWithRoundedRect:(CGRect)rect byRoundingCorners:(RectCorner)corners cornerRadii:(CGSize)cornerRadii
{
    CGMutablePathRef path = CGPathCreateMutable();

    const CGPoint topLeft = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
    const CGPoint topRight = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    const CGPoint bottomLeft = rect.origin;
    const CGPoint bottomRight = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
    
    if (corners & RectCornerBottomLeft) {
        CGPathMoveToPoint(path, NULL, bottomLeft.x+cornerRadii.width, bottomLeft.y);
    } else {
        CGPathMoveToPoint(path, NULL, bottomLeft.x, bottomLeft.y);
    }

    if (corners & RectCornerBottomRight) {
        CGPathAddLineToPoint(path, NULL, bottomRight.x-cornerRadii.width, bottomRight.y); //-cornerRadii.height);
        CGPathAddCurveToPoint(path, NULL, bottomRight.x, bottomRight.y, bottomRight.x, bottomRight.y+cornerRadii.height, bottomRight.x, bottomRight.y+cornerRadii.height);
    } else {
        CGPathAddLineToPoint(path, NULL, bottomRight.x, bottomRight.y);
    }

    if (corners & RectCornerTopRight) {
        CGPathAddLineToPoint(path, NULL, topRight.x, topRight.y-cornerRadii.height);
        CGPathAddCurveToPoint(path, NULL, topRight.x, topRight.y, topRight.x-cornerRadii.width, topRight.y, topRight.x-cornerRadii.width, topRight.y);
    } else {
        CGPathAddLineToPoint(path, NULL, topRight.x, topRight.y);
    }
    
    if (corners & RectCornerTopLeft) {
        CGPathAddLineToPoint(path, NULL, topLeft.x+cornerRadii.width, topLeft.y);
        CGPathAddCurveToPoint(path, NULL, topLeft.x, topLeft.y, topLeft.x, topLeft.y-cornerRadii.height, topLeft.x, topLeft.y-cornerRadii.height);
    } else {
        CGPathAddLineToPoint(path, NULL, topLeft.x, topLeft.y);
    }
    
    if (corners & RectCornerBottomLeft) {
        CGPathAddLineToPoint(path, NULL, bottomLeft.x, bottomLeft.y+cornerRadii.height);
        CGPathAddCurveToPoint(path, NULL, bottomLeft.x, bottomLeft.y, bottomLeft.x+cornerRadii.width, bottomLeft.y, bottomLeft.x+cornerRadii.width, bottomLeft.y);
    } else {
        CGPathAddLineToPoint(path, NULL, bottomLeft.x, bottomLeft.y);
    }
      
    CGPathCloseSubpath(path);
    
    NSBezierPath *result = [NSBezierPath bezierPath];
    [self bezierPath:result setCGPath:path];
    CGPathRelease(path);
    
    return result;
}

static void sPathApplier(void *info, const CGPathElement *element)
{
    NSBezierPath *path = (__bridge NSBezierPath *)info;
    
    CGPoint QP1;
    CGPoint QP2;
    
    switch (element->type) {
        case kCGPathElementMoveToPoint:
            [path moveToPoint:element->points[0]];
            break;
            
        case kCGPathElementAddLineToPoint:
            [path lineToPoint:element->points[0]];
            break;
            
        case kCGPathElementAddQuadCurveToPoint:
            // [path addQuadCurveToPoint: element->points[1]
            // controlPoint: element->points[0]];
            
            QP2 = element->points[1];
            QP1 = element->points[0];
            
            CGPoint QP0 = [path currentPoint];
            CGPoint CP3 = QP2;
            
            CGPoint CP1 = CGPointMake(
                                      //  QP0   +   2   / 3    * (QP1   - QP0  )
                                      QP0.x + ((2.0 / 3.0) * (QP1.x - QP0.x)),
                                      QP0.y + ((2.0 / 3.0) * (QP1.y - QP0.y))
                                      );
            
            CGPoint CP2 = CGPointMake(
                                      //  QP2   +  2   / 3    * (QP1   - QP2)
                                      QP2.x + (2.0 / 3.0) * (QP1.x - QP2.x),
                                      QP2.y + (2.0 / 3.0) * (QP1.y - QP2.y)
                                      );
            
            [path curveToPoint:CP3 controlPoint1:CP1 controlPoint2:CP2];

            break;
            
        case kCGPathElementAddCurveToPoint:
            [path curveToPoint: element->points[2]
                 controlPoint1: element->points[0]
                 controlPoint2: element->points[1]];
            
            break;
            
        case kCGPathElementCloseSubpath:
            [path closePath];
            break;
    }
}

- (void) bezierPath:(NSBezierPath *)bezierPath setCGPath:(CGPathRef)CGPath
{
    [bezierPath removeAllPoints];
    if (CGPathIsEmpty(CGPath)) return;
    
    CGPathApply(CGPath, (__bridge void *) bezierPath, sPathApplier);
}


////
//
//
//

- (void)updateTrackingAreas {
    if ( _rectangularGrip ) {
        if ( [self rectangleTrackingArea] != nil ) {
            [self removeTrackingArea:[self rectangleTrackingArea]];
        }
        NSRect box = NSMakeRect( (self.bounds.size.width/2) - (ABDefaultRectangleWidth/2), 0, ABDefaultRectangleWidth, ABDefaultRectangleHeight );
        // LPLog(@"box: %@   self.bounds:%@", NSStringFromRect(box), NSStringFromRect(self.bounds));
        [self setRectangleTrackingArea: [[NSTrackingArea alloc] initWithRect:box
                                                                     options: (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow )
                                                                       owner:self userInfo:nil] ];
        [self addTrackingArea:[self rectangleTrackingArea]];
    }
}

- (void)mouseEntered:(NSEvent *)theEvent {
    // NSPoint punto = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    [self setInsideRectangleTrackingArea:YES];
}
- (void)mouseExited:(NSEvent *)theEvent {
    [self setInsideRectangleTrackingArea:NO];
}

- (void)mouseDown:(NSEvent *)theEvent {
    [self setNeedsDisplay:YES];
    
    //if ([theEvent clickCount] == 1) {
        if ( [self isInsideRectangleTrackingArea] ) {
            // NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
            // LPLog(@"PRESSED INSED THE BOX!!!!!: %@", NSStringFromPoint(curPoint));
            
            //  Inform everybody :)
            [[NSNotificationCenter defaultCenter]
             postNotificationName:kABNotificationABGradientViewGripPressed
             object:nil];

        }
    //}
}



@end
