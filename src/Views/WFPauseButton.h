//
//  WFPauseButton.h
//  wordPuzzle
//
//  Created by Michael on 2/22/23.
//  Copyright © 2023 Michael Thomason. All rights reserved.
//

#ifndef WFPauseButton_h
#define WFPauseButton_h

#import "WFButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface WFPauseButton : WFButton

+ (void)BackgroundGradient:(CGGradientRef _Nullable * _Nonnull)gradient alpha:(CGFloat)a;

@end

NS_ASSUME_NONNULL_END

#endif
