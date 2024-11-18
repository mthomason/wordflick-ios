//
//  MUIViewLabelGlow.h
//  wordPuzzle
//
//  Created by Michael Thomason on 8/30/09.
//  Copyright 2020 Michael Thomason. All rights reserved.
//

#ifndef MUIViewLabelGlow_h
#define MUIViewLabelGlow_h

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MNSMessage;

@interface WFGlowLabelView : UIView

@property(readwrite) CGFloat fontSize;
@property(readonly, nonatomic, assign) BOOL messageIsDisplaying;

- (instancetype)initWithFrame:(CGRect)frame setText:(NSString *)t andFontSize:(CGFloat)s;
- (BOOL)displayMessage:(MNSMessage *)message completion:(void (^ __nullable)(BOOL finished))completion;

@end

NS_ASSUME_NONNULL_END

#endif
