//
//  WFShuffleButton.h
//  wordPuzzle
//
//  Created by Michael on 2/19/23.
//  Copyright © 2023 Michael Thomason. All rights reserved.
//

#ifndef WFShuffleButton_h
#define WFShuffleButton_h

#import "WFButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface WFShuffleButton : WFButton

+ (void)BackgroundGradient:(CGGradientRef _Nullable * _Nonnull)gradient alpha:(CGFloat)a;

@end

NS_ASSUME_NONNULL_END

#endif
