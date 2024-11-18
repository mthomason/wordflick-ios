//
//  CGGeometry-Extras.h
//  wordPuzzle
//
//  Created by Michael Thomason on 7/13/10.
//  Copyright 2010 Michael Thomason. All rights reserved.
//

#ifndef CGGeometry_Extras_h
#define CGGeometry_Extras_h

static inline double RandomFractionalValue(void);
static inline double RandomFractionalValue(void) {
	return (double)arc4random_uniform(UINT32_MAX) / (double)UINT32_MAX;
}

#endif
