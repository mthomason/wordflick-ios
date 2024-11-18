//
//  MTUserStatistics.m
//  wordPuzzle
//
//  Created by Michael Thomason on 7/15/10.
//  Copyright 2019 Michael Thomason. All rights reserved.
//

#import "WFUserStatistics.h"
#import "DatabaseUsers.h"

@implementation WFUserStatistics

- (void)reset {
	[super reset];
}

- (void)addNewStatistics:(WFStatisticsBase *)statistics {
	[super addNewStatistics:statistics];
}

- (void)gameCompleted:(WFStatisticsBase *)stats __unused {
	//Game completed++
	//Update database
}

@end
