//
//  MNSTimer.h
//  wordPuzzle
//
//  Created by Michael Thomason on 7/7/09.
//  Copyright 2020 Michael Thomason. All rights reserved.
//

#ifndef MNSTimer_h
#define MNSTimer_h

#import <Foundation/Foundation.h>
#import "MTTimerProtocol.h"

@interface MNSTimer : NSObject

@property (assign) id <MTTimerDelegate> delegate;
@property (assign, getter=isPaused) BOOL paused;
@property (assign) long seconds;
@property (assign) long secondsCounterForLevel;
@property (assign) NSTimer *secondsTimer;

+ (NSTimeInterval)standardTick;
- (long)pause;
- (void)resume;
- (void)startTimer:(long)s;
- (void)extendTimer:(long)time;
- (void)allocTimer;
- (void)deallocTimer;

@end

#endif
