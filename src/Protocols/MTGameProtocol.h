//
//  MTGameProtocol.h
//  wordPuzzle
//
//  Created by Michael on 12/22/19.
//  Copyright © 2019 Michael Thomason. All rights reserved.
//

#ifndef MTGameProtocol_h
#define MTGameProtocol_h

#import "MTTileType.h"

@class WFGameView, MNSGame, WFTileData, MNSMessage;

@protocol MTGameProtocol <NSObject>

@required

- (void)game:(MNSGame *)game showPreLevelScreen:(NSString *)identifier;

- (void)game:(MNSGame *)game didPressPauseButton:(id)context;
- (void)game:(MNSGame *)game didPressShuffleButton:(id)context;

- (void)game:(MNSGame *)game didDisableCheckButtonAnimated:(bool)animated;
- (void)game:(MNSGame *)game didDisablePauseButtonAnimated:(bool)animated;
- (void)game:(MNSGame *)game didDisableShuffleButtonAnimated:(bool)animated;

- (void)game:(MNSGame *)game enablePauseButton:(bool)animated;
- (void)game:(MNSGame *)game enableCheckButton:(bool)animated;
- (void)game:(MNSGame *)game enableShuffleButton:(bool)animated;

- (void)game:(MNSGame *)game removeGameTile:(WFTileData *)tile animated:(bool)animated;
- (void)game:(MNSGame *)game removeAllTilesFromScreen:(bool)animated;

- (void)game:(MNSGame *)game displayMessage:(MNSMessage *)message;

- (void)game:(MNSGame *)game dismissPauseScreen:(bool)animated;

@optional

- (void)handleShuffleButton:(MNSGame *)game __attribute__((deprecated));
- (void)animatePlayFailed:(MNSGame *)game;
- (void)animatePlaySucceeded:(MNSGame *)game withBonusModifier:(MNSTileType)typeTypeModifier;

- (void)showControlScreenBackground:(BOOL)show animated:(BOOL)animated;
- (void)updateControlScreen:(MNSGame *)game;

- (void)flashIndicatorsToColor:(UIColor *)toColor forDuration:(NSTimeInterval)interval;

- (void)gameDidEnd:(MNSGame *)sender;
- (void)levelDidEnd:(MNSGame *)sender;
- (void)updateGameBoardBackground:(MNSGame *)game;

@end

#endif /* MTGameProtocol_h */
