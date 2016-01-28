/**
 *  @class  ABGradientView ABGradientView.h "ABGradientView.h"
 *  @brief  NSView with colored background and border, also with optional rounded shape
 *
 *  @author  Luis Palacios
 *  @version 1.0
 *  @date    19/01/14
 *
 *  @par Description
 *
 *  NSView with colored background and border, also with optional rounded shape
 *
 *  Beyond its normal usage, I also use this view when debugging views, in particular
 *  I'm learning Autolayout/Constraints and helped me a lot actually seeing the views.
 *
 *  @verbatim
 *
 *  When used from Inteface Builder, simply assign this Class to your View and optionally
 *  set its attributes:
 *
 *  Identity Inspector
 *   |
 *   +->Custom Class->Class: ABGradientView
 *   |
 *   +->User defined runtime attributes:
 *      Key Path                    Type        Value
 *      ==================          =======     ======================================================
 *      roundedShape                BOOL        Yes or NO show Background/Border rounded. Default YES
 *      roundedRadius               Number      Radius to use in rounded corner. Defaults to 5
 *      backgroundStartingColor     Color       Background: Starting color (gradient). Default purple
 *      backgroundEndingColor       Color       Background: Ending color (gradient). Default purple
 *      backgroundGradientAngle     Number      Background: Gradient angle. Defaults to 270
 *      backgroundAlpha             Number      Background: Transparency. Defaults to 0.2
 *      borderColor                 Color       Border: Border color. Defaults to red
 *      borderAlpha                 Number      Border: Border Alpha. Defaults to 0.5
 *      showBorder                  BOOL        Border: YES or NO to show the border. Defaults YES
 *      borderWidth                 Number      Border: Border Width. Defaults to 2.
 *
 *@endverbatim
 *
 */

#import <Cocoa/Cocoa.h>

//--------------------------------------------------------------------------------------------------


// Notification when someone click inside the ABGradientView grips
// ////////////////////////////////////////////////////////////////////////
FOUNDATION_EXPORT NSString *const kABNotificationABGradientViewGripPressed;
NSString *const kABNotificationABGradientViewGripPressed = @"NotificationABGradientViewGripPressed";


@interface ABGradientView : NSView

typedef NS_OPTIONS(NSUInteger, RectCorner) {
    RectCornerTopLeft     = 1 << 0,
    RectCornerTopRight    = 1 << 1,
    RectCornerBottomLeft  = 1 << 2,
    RectCornerBottomRight = 1 << 3,
    RectCornerAllCorners  = ~0
};

// Definition of @property's to create the "Accessors"
//--------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Public Getters/Setters

// Rounded
@property (nonatomic, assign, getter=isRoundedShape) BOOL roundedShape;
@property (nonatomic, assign, getter=isRoundedBottom) BOOL roundedBottom;
@property (nonatomic, assign, getter=isRoundedTop) BOOL roundedTop;
@property (nonatomic, strong) NSNumber  *roundedRadius;

// Margins
@property (nonatomic, strong) NSNumber  *globalMargin;
@property (nonatomic, strong) NSNumber  *leftMargin;
@property (nonatomic, strong) NSNumber  *rightMargin;
@property (nonatomic, strong) NSNumber  *topMargin;
@property (nonatomic, strong) NSNumber  *bottomMargin;

// Background Color
@property (nonatomic, strong) NSColor   *backgroundStartingColor;
@property (nonatomic, strong) NSColor   *backgroundEndingColor;
@property (nonatomic, strong) NSNumber  *backgroundGradientAngle;
@property (nonatomic, strong) NSNumber  *backgroundAlpha;

// Triangle Grip
@property (nonatomic, assign, getter=isTriangleGrip) BOOL triangleGrip;

// Rectangular Grip
@property (nonatomic, assign, getter=isRectangularGrip) BOOL rectangularGrip;
@property (nonatomic, strong) NSTrackingArea *rectangleTrackingArea;
@property (nonatomic, assign, getter=isInsideRectangleTrackingArea) BOOL insideRectangleTrackingArea;

// Border Color
@property (nonatomic, strong) NSColor   *borderColor;
@property (nonatomic, strong) NSNumber  *borderAlpha;

// Border Show
@property (nonatomic, assign, getter=isShowBorder) BOOL showBorder;
@property (nonatomic, strong) NSNumber  *borderWidth;

// Background image
@property (nonatomic, strong) NSImage  *backgroundImage;
    

// Class or Public instance methods (placeholder)
//--------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Public Class Methods


#pragma mark -
#pragma mark Public Instance Methods



@end
