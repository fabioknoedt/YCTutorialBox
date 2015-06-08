//
//  YCTutorialBox.m
//  YU - YUPPIU
//
//  Created by Fabio Knoedt on 26/08/14.
//  Copyright (c) 2014 Datedicted. All rights reserved.
//

#import "YCTutorialBox.h"
#import <FXLabel/FXLabel.h>

#define distanceBetweenViewAndBox 20

@interface YCTutorialBox ()

@property (weak, nonatomic) IBOutlet UIView *box;
@property (weak, nonatomic) IBOutlet FXLabel *boxHeadline;
@property (weak, nonatomic) IBOutlet FXLabel *boxHelpText;

@property (strong, nonatomic) UIView *viewInFocus;
@property (nonatomic, copy) void (^completionBlock)();

@end

@implementation YCTutorialBox

/*!
 *  @brief  Initialize the view with a headline.
 *  @param headline The Headline of the box.
 *  @return the initialized object.
 */
- (id)initWithHeadline:(NSString *)headline;
{
    return [self initWithHeadline:headline withHelpText:nil withCompletionBlock:nil];
}

/*!
 *  @brief  Initialize the view with a headline and a help text.
 *  @param headline headline The Headline of the box.
 *  @param helpText headline The help text or description of the box.
 *  @return the initialized object.
 */
- (id)initWithHeadline:(NSString *)headline withHelpText:(NSString *)helpText;
{
    return [self initWithHeadline:headline withHelpText:helpText withCompletionBlock:nil];
}

/*!
 *  @brief  Initialize the view with a headline, help text and a completion block.
 *  @param headline headline The Headline of the box.
 *  @param helpText headline The help text or description of the box.
 *  @param completion A completion block to be executed after the view is dismissed.
 *  @return the initialized object.
 */
- (id)initWithHeadline:(NSString *)headline withHelpText:(NSString *)helpText withCompletionBlock:(void (^)())completion;
{
    /// Init the view.
    self = [[[NSBundle mainBundle] loadNibNamed:@"YCTutorialBox" owner:self options:nil] lastObject];
    
    if (self) {
        
        /// Set the texts.
        _boxHeadline.text = headline;
        _boxHelpText.text = helpText;
        
        /// Set the completion block.
        _completionBlock = completion;
    }
    
    return self;
}

/*!
 *  @brief  Show the box on the screen.
 */
- (void)show;
{
    [self showAndFocusView:nil];
}

/*!
 *  @brief  Show the box on the screen with focus on the view selected.
 *  @param view The view to make focus on.
 */
- (void)showAndFocusView:(UIView *)view;
{
    /// Add itself to the main window.    
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    [currentWindow addSubview:self];
    
    /// Set the view to focus.
    if (view) {
        [self setViewInFocus:view];
        [self setNeedsLayout];
    }
}

#pragma mark - Private methods

- (void)positionBox:(UIView *)view
{
    /// If there is no view, display the box in the center of the screen.
    if (view) {
        
        /// Point in the window.
        CGPoint pointInWindow = [self convertPoint:view.bounds.origin fromView:view];
        
        /// Height between the view in focus and the top.
        CGFloat heightUp = pointInWindow.y;
        
        /// Height between the view in focus and the bottom.
        UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
        CGFloat heightDown = currentWindow.frame.size.height - pointInWindow.y - view.frame.size.height;
        
        /// Check what is the better place to place the box.
        
        /// Prio 1: Place the box in front of the element, if it is big enough.
        if (view.frame.size.height > 300.0f && view.frame.size.height > _box.frame.size.height) {
            
            [_box setCenter:CGPointMake(_box.center.x, pointInWindow.y + view.frame.size.height/2)];
        }
        
        /// Prio 2: Place the box above the element.
        else if (heightUp > heightDown && heightUp > _box.frame.size.height + 2*distanceBetweenViewAndBox) {
            
            [_box setFrame:CGRectMake(_box.frame.origin.x,
                                      MAX(0, pointInWindow.y - distanceBetweenViewAndBox - _box.frame.size.height),
                                      _box.frame.size.width,
                                      _box.frame.size.height)];
        }
        
        /// Prio 3: Place the box below the element.
        else if (heightDown > heightUp && heightDown > _box.frame.size.height + 2*distanceBetweenViewAndBox) {
           
            [_box setFrame:CGRectMake(_box.frame.origin.x,
                                      MIN(currentWindow.frame.size.height - _box.frame.size.height - 10, pointInWindow.y + view.frame.size.height + distanceBetweenViewAndBox),
                                      _box.frame.size.width,
                                      _box.frame.size.height)];
        }
        
        /// Prio 4: Place the box in the center of the screen.
        else {
            
            [_box setCenter:CGPointMake(_box.center.x, currentWindow.center.y)];
        }
    }
}

- (void)positionView:(UIView *)view
{
    /// Position the view in focus.
    CGPoint pointInWindow = [self convertPoint:view.bounds.origin fromView:view];
    UIImageView *viewInFocusImageView = [[UIImageView alloc] initWithImage:[self imageWithView:view]];
    viewInFocusImageView.frame = CGRectMake(pointInWindow.x, pointInWindow.y, view.frame.size.width, view.frame.size.height);
    [self addSubview:viewInFocusImageView];
    
    /// Bring the box to the front because it the most important view.
    [self bringSubviewToFront:_box];
}

/*!
 *  @brief  Creates a UIImage from a UIView.
 *  @param view The UIView to take the screenshot.
 *  @return the image created from the UIView screenshot.
 */
- (UIImage *)imageWithView:(UIView *)view
{
    if (( fabsf( ( double ) [[UIDevice currentDevice].systemVersion floatValue] >= 7.0 ) )) {
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0f);
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
        UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return snapshotImage;
        
    } else {
        
        UIGraphicsBeginImageContext(view.bounds.size);
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return img;
    }
}

#pragma mark - UIView delegate

/// Closes the UIView.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    /// Removes itself from the superview.
    [self removeFromSuperview];
    
    /// If there is a completion block, execute it.
    if (_completionBlock) {
        _completionBlock();
    }
}

/// Make the layout for subviews, if needed it.
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    /// If there is a view to focus on, change the layout of the box.
    if (_viewInFocus) {
        
        /// Positioning the box relative to the view in focus.
        [self positionBox:_viewInFocus];
        
        /// Positioning the view in the right place.
        [self positionView:_viewInFocus];
    }
    
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    [self setFrame:currentWindow.frame];
    
    /// Adjust subviews.
    [self layoutIfNeeded];
}

@end
