//
//  WFButton.h
//  wordPuzzle
//
//  Created by Michael on 2/19/23.
//  Copyright © 2023 Michael Thomason. All rights reserved.
//

#ifndef WFButton_h
#define WFButton_h

#import <UIKit/UIKit.h>

typedef NS_ENUM(short, WFButtonType) {
	WFButtonTypeDefault = 0,
	WFButtonTypeShuffle = 1,
	WFButtonTypePause = 2,
	WFButtonTypeCheck = 3,
};

typedef NS_ENUM(short, WFButtonColor) {
	WFButtonColorDefault = 0,
	WFButtonColorBlue = 1,
	WFButtonColorRed = 2,
	WFButtonColorGreen = 3,
	WFButtonColorYellow = 4,
};

NS_ASSUME_NONNULL_BEGIN

@interface WFButton : UIView

@property (nonatomic, strong) IBOutlet UIButton *button;

@property (readonly) WFButtonType buttonType;
@property (readonly) WFButtonColor buttonColor;

+ (void)BackgroundGradient:(CGGradientRef _Nullable * _Nonnull)gradient alpha:(CGFloat)a;

@end

NS_ASSUME_NONNULL_END

#endif
