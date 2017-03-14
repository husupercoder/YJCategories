//
//  UIBarButtonItem+YJBadge.m
//  YJCategoriesGather
//
//  Created by YJHou on 2015/3/17.
//  Copyright © 2015年 侯跃军 houmanager@Hotmail.com. All rights reserved.
//

#import "UIBarButtonItem+YJBadge.h"
#import <objc/runtime.h>

static char const *const kUIBarButtonItemBadegeLabelKey = "kUIBarButtonItemBadegeLabelKey";
static char const *const kUIBarButtonItemBadegeOriginXKey = "kUIBarButtonItemBadegeOriginXKey";
static char const *const kUIBarButtonItemBadegeOriginYKey = "kUIBarButtonItemBadegeOriginYKey";





NSString const *jk_UIBarButtonItem_badgeBGColorKey = @"jk_UIBarButtonItem_badgeBGColorKey";
NSString const *jk_UIBarButtonItem_badgeTextColorKey = @"jk_UIBarButtonItem_badgeTextColorKey";
NSString const *jk_UIBarButtonItem_badgeFontKey = @"jk_UIBarButtonItem_badgeFontKey";
NSString const *jk_UIBarButtonItem_badgePaddingKey = @"jk_UIBarButtonItem_badgePaddingKey";
NSString const *jk_UIBarButtonItem_badgeMinSizeKey = @"jk_UIBarButtonItem_badgeMinSizeKey";
NSString const *jk_UIBarButtonItem_shouldHideBadgeAtZeroKey = @"jk_UIBarButtonItem_shouldHideBadgeAtZeroKey";
NSString const *jk_UIBarButtonItem_shouldAnimateBadgeKey = @"jk_UIBarButtonItem_shouldAnimateBadgeKey";
NSString const *jk_UIBarButtonItem_badgeValueKey = @"jk_UIBarButtonItem_badgeValueKey";


@implementation UIBarButtonItem (YJBadge)

// 初始化设置
- (void)yj_badgeInitial{

    UIView *superView = nil;
    CGFloat defaultOriginX = 0.0f;
    if (self.customView) {
        superView = self.customView;
        defaultOriginX = superView.frame.size.width - self.yj_badgeLabel.frame.size.width * 0.5;
        superView.clipsToBounds = NO; // 防止动画收缩时裁剪
    }else if ([self respondsToSelector:@selector(view)] && [(id)self view]){
        superView = [(id)self view];
        defaultOriginX = superView.frame.size.width - self.yj_badgeLabel.frame.size.width;
    }
    [superView addSubview:self.yj_badgeLabel];
    
    // 初始配置
    self.yj_badgeBgColor = [UIColor redColor];
    self.yj_badgeTextColor = [UIColor whiteColor];
    self.yj_badgeFont = [UIFont systemFontOfSize:12.0f];
    self.yj_badgePadding = 6.0f;
    self.yj_badgeMinHeight = 8.0f;
    self.yj_badgeOriginX = defaultOriginX;
    self.yj_badgeOriginY = -4.0f;
    self.yj_hideBadgeWhenZero = YES;
    self.yj_animateBadgeEnable = YES;
    
    
}

#pragma mark - Utility methods

// Handle badge display when its properties have been changed (color, font, ...)
- (void)jk_refreshBadge
{
    // Change new attributes
    self.jk_badge.textColor        = self.jk_badgeTextColor;
    self.jk_badge.backgroundColor  = self.jk_badgeBGColor;
    self.jk_badge.font             = self.jk_badgeFont;
    
    if (!self.jk_badgeValue || [self.jk_badgeValue isEqualToString:@""] || ([self.jk_badgeValue isEqualToString:@"0"] && self.jk_shouldHideBadgeAtZero)) {
        self.jk_badge.hidden = YES;
    } else {
        self.jk_badge.hidden = NO;
        [self jk_updateBadgeValueAnimated:YES];
    }
    
}





// Handle the badge changing value
- (void)jk_updateBadgeValueAnimated:(BOOL)animated
{
    // Bounce animation on badge if value changed and if animation authorized
    if (animated && self.jk_shouldAnimateBadge && ![self.jk_badge.text isEqualToString:self.jk_badgeValue]) {
        CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        [animation setFromValue:[NSNumber numberWithFloat:1.5]];
        [animation setToValue:[NSNumber numberWithFloat:1]];
        [animation setDuration:0.2];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:.4f :1.3f :1.f :1.f]];
        [self.jk_badge.layer addAnimation:animation forKey:@"bounceAnimation"];
    }
    
    // Set the new value
    self.jk_badge.text = self.jk_badgeValue;
    
    // Animate the size modification if needed
    if (animated && self.jk_shouldAnimateBadge) {
        [UIView animateWithDuration:0.2 animations:^{
            [self _yj_updateBadgeFrame];
        }];
    } else {
        [self _yj_updateBadgeFrame];
    }
}



- (void)jk_removeBadge
{
    // Animate badge removal
    [UIView animateWithDuration:0.2 animations:^{
        self.jk_badge.transform = CGAffineTransformMakeScale(0, 0);
    } completion:^(BOOL finished) {
        [self.jk_badge removeFromSuperview];
        self.jk_badge = nil;
    }];
}


// Badge value to be display
-(NSString *)jk_badgeValue {
    return objc_getAssociatedObject(self, &jk_UIBarButtonItem_badgeValueKey);
}
-(void)setJk_vadgeValue:(NSString *)badgeValue
{
    objc_setAssociatedObject(self, &jk_UIBarButtonItem_badgeValueKey, badgeValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // When changing the badge value check if we need to remove the badge
    [self jk_updateBadgeValueAnimated:YES];
    [self jk_refreshBadge];
}

// Badge background color
-(UIColor *)badgeBGColor {
    return objc_getAssociatedObject(self, &jk_UIBarButtonItem_badgeBGColorKey);
}
-(void)setBadgeBGColor:(UIColor *)badgeBGColor
{
    objc_setAssociatedObject(self, &jk_UIBarButtonItem_badgeBGColorKey, badgeBGColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.jk_badge) {
        [self jk_refreshBadge];
    }
}

// Badge text color
-(UIColor *)badgeTextColor {
    return objc_getAssociatedObject(self, &jk_UIBarButtonItem_badgeTextColorKey);
}
-(void)setBadgeTextColor:(UIColor *)badgeTextColor
{
    objc_setAssociatedObject(self, &jk_UIBarButtonItem_badgeTextColorKey, badgeTextColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.jk_badge) {
        [self jk_refreshBadge];
    }
}

// Badge font
-(UIFont *)badgeFont {
    return objc_getAssociatedObject(self, &jk_UIBarButtonItem_badgeFontKey);
}
-(void)setBadgeFont:(UIFont *)badgeFont
{
    objc_setAssociatedObject(self, &jk_UIBarButtonItem_badgeFontKey, badgeFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.jk_badge) {
        [self jk_refreshBadge];
    }
}

// Padding value for the badge
-(CGFloat) badgePadding {
    NSNumber *number = objc_getAssociatedObject(self, &jk_UIBarButtonItem_badgePaddingKey);
    return number.floatValue;
}
-(void) setBadgePadding:(CGFloat)badgePadding
{
    NSNumber *number = [NSNumber numberWithDouble:badgePadding];
    objc_setAssociatedObject(self, &jk_UIBarButtonItem_badgePaddingKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.jk_badge) {
        [self _yj_updateBadgeFrame];
    }
}

// Minimum size badge to small
-(CGFloat)jk_badgeMinSize {
    NSNumber *number = objc_getAssociatedObject(self, &jk_UIBarButtonItem_badgeMinSizeKey);
    return number.floatValue;
}
-(void) setJk_badgeMinSize:(CGFloat)badgeMinSize
{
    NSNumber *number = [NSNumber numberWithDouble:badgeMinSize];
    objc_setAssociatedObject(self, &jk_UIBarButtonItem_badgeMinSizeKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.jk_badge) {
        [self _yj_updateBadgeFrame];
    }
}



// In case of numbers, remove the badge when reaching zero
-(BOOL) shouldHideBadgeAtZero {
    NSNumber *number = objc_getAssociatedObject(self, &jk_UIBarButtonItem_shouldHideBadgeAtZeroKey);
    return number.boolValue;
}
- (void)setShouldHideBadgeAtZero:(BOOL)shouldHideBadgeAtZero
{
    NSNumber *number = [NSNumber numberWithBool:shouldHideBadgeAtZero];
    objc_setAssociatedObject(self, &jk_UIBarButtonItem_shouldHideBadgeAtZeroKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if(self.jk_badge) {
        [self jk_refreshBadge];
    }
}

// Badge has a bounce animation when value changes
-(BOOL) jk_shouldAnimateBadge {
    NSNumber *number = objc_getAssociatedObject(self, &jk_UIBarButtonItem_shouldAnimateBadgeKey);
    return number.boolValue;
}
- (void)setJk_shouldAnimateBadge:(BOOL)shouldAnimateBadge
{
    NSNumber *number = [NSNumber numberWithBool:shouldAnimateBadge];
    objc_setAssociatedObject(self, &jk_UIBarButtonItem_shouldAnimateBadgeKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if(self.jk_badge) {
        [self jk_refreshBadge];
    }
}

#pragma mark - Lazy
// 显示badge
- (void)setYj_badgeLabel:(UILabel *)yj_badgeLabel{
    objc_setAssociatedObject(self, kUIBarButtonItemBadegeLabelKey, yj_badgeLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UILabel *)yj_badgeLabel{
    
    UILabel *badgeLabel = objc_getAssociatedObject(self, kUIBarButtonItemBadegeLabelKey);
    if (!badgeLabel) {
        badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.yj_badgeOriginX, self.yj_badgeOriginY, 20, 20)];
        [self setYj_badgeLabel:badgeLabel];
        [self yj_badgeInitial];
        [self.customView addSubview:badgeLabel];
        badgeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return badgeLabel;
}

// 起始X
- (void)setYj_badgeOriginX:(CGFloat)yj_badgeOriginX{
    NSNumber *badgeOriginX = [NSNumber numberWithDouble:yj_badgeOriginX];
    objc_setAssociatedObject(self, kUIBarButtonItemBadegeOriginXKey, badgeOriginX, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.yj_badgeLabel) {
        [self _yj_updateBadgeFrame];
    }
}

- (CGFloat)yj_badgeOriginX{
    NSNumber *badgeOriginX = objc_getAssociatedObject(self, kUIBarButtonItemBadegeOriginXKey);
    return badgeOriginX.floatValue;
}

// 起始Y

- (void)setYj_badgeOriginY:(CGFloat)yj_badgeOriginY{
    NSNumber *badgeOriginY = [NSNumber numberWithDouble:yj_badgeOriginY];
    objc_setAssociatedObject(self, kUIBarButtonItemBadegeOriginYKey, badgeOriginY, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.yj_badgeLabel) {
        [self _yj_updateBadgeFrame];
    }
}

- (CGFloat)yj_badgeOriginY{
    NSNumber *badgeOriginX = objc_getAssociatedObject(self, kUIBarButtonItemBadegeOriginYKey);
    return badgeOriginX.floatValue;
}

#pragma mark - 更新Frame
- (void)_yj_updateBadgeFrame{

    CGSize expectedLabelSize = [self yj_badgeExpectedSize];
    CGFloat padding = self.yj_badgePadding;
    
    CGFloat minHeight = expectedLabelSize.height;
    minHeight = (minHeight < self.yj_badgeMinHeight)?self.yj_badgeMinHeight:expectedLabelSize.height;
    
    CGFloat minWidth = expectedLabelSize.width;
    minWidth = (minWidth < minHeight)?minHeight:expectedLabelSize.width;
    self.yj_badgeLabel.layer.masksToBounds = YES;
    self.yj_badgeLabel.frame = CGRectMake(self.yj_badgeOriginX, self.yj_badgeOriginY, minWidth + padding, minHeight + padding);
    self.yj_badgeLabel.layer.cornerRadius = (minHeight * padding) * 0.5;
}

// 适配字体
- (CGSize)yj_badgeExpectedSize{
    UILabel *frameLabel = [self yj_duplicateLabel:self.yj_badgeLabel];
    [frameLabel sizeToFit];
    return frameLabel.frame.size;
}

/** 复制 */
- (UILabel *)yj_duplicateLabel:(UILabel *)labelToCopy{
    UILabel *duplicateLabel = [[UILabel alloc] initWithFrame:labelToCopy.frame];
    duplicateLabel.text = labelToCopy.text;
    duplicateLabel.font = labelToCopy.font;
    return duplicateLabel;
}








@end
