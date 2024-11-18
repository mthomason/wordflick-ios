//
//  MTUserStatistics.h
//  wordPuzzle
//
//  Created by Michael Thomason on 7/15/10.
//  Copyright 2019 Michael Thomason. All rights reserved.
//

#ifndef MTUserStatistics_h
#define MTUserStatistics_h

#import "WFStatisticsBase.h"

@interface WFUserStatistics : WFStatisticsBase

- (void)addNewStatistics:(WFStatisticsBase *)statistics;

@end

#endif
