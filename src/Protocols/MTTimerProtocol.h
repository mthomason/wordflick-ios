//
//  MTTimerProtocol.h
//  wordPuzzle
//
//  Created by Michael on 12/22/19.
//  Copyright © 2019 Michael Thomason. All rights reserved.
//

#ifndef MTTimerProtocol_h
#define MTTimerProtocol_h

@protocol MTTimerDelegate <NSObject>
- (void)setTime:(long long)t;
- (void)timeIsUp;
@end

#endif /* MTTimerProtocol_h */
