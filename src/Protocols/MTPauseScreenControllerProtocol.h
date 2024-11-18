//
//  MTPauseScreenControllerProtocol.h
//  wordPuzzle
//
//  Created by Michael on 1/5/20.
//  Copyright © 2020 Michael Thomason. All rights reserved.
//

#ifndef MTPauseScreenControllerProtocol_h
#define MTPauseScreenControllerProtocol_h

@protocol MTPauseScreenControllerProtocol <NSObject>
	- (void)pauseScreenDidAbortLevel;
	- (void)pauseScreenDidResume;
@end

#endif /* MTPauseScreenControllerProtocol_h */
