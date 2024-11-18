//
//  MNSAudio.h
//  wordPuzzle
//
//  Created by Michael Thomason on 11/3/09.
//  Copyright 2020 Michael Thomason. All rights reserved.
//

#ifndef MNSAudio_h
#define MNSAudio_h

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface MNSAudio : NSObject

+ (void)downloadMusic;

- (void)playWelcome __attribute__((unused));
- (void)playTimeIsUp;
- (void)playThreeMinutes;
- (void)playTwoMinutes;
- (void)playOneMinute;
- (void)playThirtySeconds;
- (void)playFifteenSeconds;
- (void)playGameOver __attribute__((unused));

+ (void)playAchievement;
+ (void)playAchievement1 __attribute__((deprecated));
+ (void)playAchievement2 __attribute__((deprecated));
+ (void)playAchievement3 __attribute__((deprecated));
+ (void)playAchievement4 __attribute__((deprecated));

+ (void)playTileHitWood1;
+ (void)playTileHitWood2;
+ (void)playTileHit1;
+ (void)playTileHit2;
+ (void)playTileHit3;

+ (void)playBonusCoins;
+ (void)playCoinOne;
+ (void)playCoinShower;
+ (void)playBonusSaucer;
+ (void)playBonusLife;
+ (void)playBonusThunder;

+ (void)playSwapTiles __attribute__((unused));
+ (void)playFlipTileEnd;
+ (void)playFlipTileFlip;

+ (void)playPickupHealth1 __attribute__((unused));
+ (void)playPickupJewel __attribute__((unused));
+ (void)playPickupMagic __attribute__((unused));
+ (void)playPickupMetallic __attribute__((unused));
+ (void)playSlideSoft __attribute__((unused));
+ (void)playMouseMarble __attribute__((unused));
+ (void)playChimesNeg;
+ (void)playChimesNo;
+ (void)playChimesPos;
+ (void)playBonusBeep __attribute__((unused));
+ (void)playBonusBell __attribute__((unused));
+ (void)playTimeTickClock;
+ (void)playTimeTickHeartbeat;
+ (void)playShuffle;
+ (void)playShelfHide;
+ (void)playButtonPress;
+ (void)playButtonPressConfirm;

@end

#endif
