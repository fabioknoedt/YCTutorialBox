//
//  YCTutorialBox.h
//  YU - YUPPIU
//
//  Created by Fabio Knoedt on 26/08/14.
//  Copyright (c) 2014 Datedicted. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FXBlurView/FXBlurView.h>

@interface YCTutorialBox : FXBlurView

/*!
 *  @brief  Initialize the view with a headline.
 *  @param headline The Headline of the box.
 *  @return the initialized object.
 */
- (id)initWithHeadline:(NSString *)headline;

/*!
 *  @brief  Initialize the view with a headline and a help text.
 *  @param headline headline The Headline of the box.
 *  @param helpText headline The help text or description of the box.
 *  @return the initialized object.
 */
- (id)initWithHeadline:(NSString *)headline withHelpText:(NSString *)helpText;

/*!
 *  @brief  Initialize the view with a headline, help text and a completion block.
 *  @param headline headline The Headline of the box.
 *  @param helpText headline The help text or description of the box.
 *  @param completion A completion block to be executed after the view is dismissed.
 *  @return the initialized object.
 */
- (id)initWithHeadline:(NSString *)headline withHelpText:(NSString *)helpText withCompletionBlock:(void (^)())completion;

/*!
 *  @brief  Show the box on the screen.
 */
- (void)show;

/*!
 *  @brief  Show the box on the screen with focus on the view selected.
 *  @param view The view to make focus on.
 */
- (void)showAndFocusView:(UIView *)view;

@end
