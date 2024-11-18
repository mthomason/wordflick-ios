//
//  Constants.h
//  wordPuzzle
//
//  Created by Michael Thomason on 4/4/10.
//  Copyright 2010 Michael Thomason. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#define TRUE			1
#define FALSE			0

#define fequal(a,b) (fabs((a) - (b)) < FLT_EPSILON)
#define fequalzero(a) (fabs(a) < FLT_EPSILON)
#define square(x) ( (x) * (x) )

extern double const kCGFloatViewControllerSlideDuration;

extern NSInteger	const kChadTokensNeededToCreateSilver;
extern NSInteger	const kSilverTokensNeededToCreateGold;
extern NSInteger	const kMUIViewGameGoalBottomTag;
extern BOOL			const DeviceBuiltForIPhone;
extern BOOL			const kAds;

extern NSString *const kUserClassConsumableGoldCoin;
extern NSString *const kUserClassConsumableSilverCoin;
extern NSString *const kUserClassConsumableChadCoin;

extern NSString * const kNSStringAppleApplicationIDWordflickPro;

#endif
