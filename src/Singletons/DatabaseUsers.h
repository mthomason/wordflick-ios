//
//  DatabaseUsers.h
//  wordPuzzle
//
//  Created by Michael Thomason on 7/21/10.
//  Copyright 2010 Michael Thomason. All rights reserved.
//

#ifndef DatabaseUsers_H
#define DatabaseUsers_H

@class MTSqliteWrapper;

@interface DatabaseUsers : NSObject
	@property (nonatomic, retain) MTSqliteWrapper *database;
	+ (instancetype)sharedInstance;
@end

#endif
