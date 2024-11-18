//
//  MTGameActionProtocol.h
//  wordPuzzle
//
//  Created by Michael on 1/4/20.
//  Copyright © 2020 Michael Thomason. All rights reserved.
//

#ifndef MTGameActionProtocol_h
#define MTGameActionProtocol_h

#import "MTGameType.h"
#import "MTGameScreen.h"

@protocol MTGameActionProtocol <NSObject>
    - (void)playGame:(id)sender gameType:(MNSGameType)gameType;
    - (void)resumeGame:(id)sender;
    - (void)showGameScreen:(id)sender screenType:(MUIGameScreen)screenType;
@end

#endif /* MTGameActionProtocol_h */
