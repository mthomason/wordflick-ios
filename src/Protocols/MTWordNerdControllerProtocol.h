//
//  MTWordNerdControllerProtocol.h
//  wordPuzzle
//
//  Created by Michael on 1/5/20.
//  Copyright © 2020 Michael Thomason. All rights reserved.
//

#ifndef MTWordNerdControllerProtocol_h
#define MTWordNerdControllerProtocol_h

#import "MTGameType.h"

@protocol MTWordNerdProtocol <NSObject>

	- (void)showIntroduction:(id)sender;
	- (void)showGame:(MNSGameType)gameType animated:(BOOL)animated sender:(id)sender;
	- (void)showPause:(id)sender;
	- (void)showSettings:(BOOL)animated sender:(id)sender;

@end

#endif /* MTWordNerdControllerProtocol_h */
