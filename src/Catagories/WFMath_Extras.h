//
//  WFMath_Extras.h
//  wordPuzzle
//
//  Created by Michael on 2/18/23.
//  Copyright © 2023 Michael Thomason. All rights reserved.
//

#ifndef WFMath_Extras_h
#define WFMath_Extras_h

static inline double RandomFractionalValue(void);
static inline double RandomFractionalValue(void) {
	return (double)arc4random_uniform(UINT32_MAX) / (double)UINT32_MAX;
}

#endif
