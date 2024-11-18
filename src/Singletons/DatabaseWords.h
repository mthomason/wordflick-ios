//
//  DatabaseWords.h
//  wordPuzzle
//
//  Created by Michael Thomason on 7/21/10.
//  Copyright 2019 Michael Thomason. All rights reserved.
//

#ifndef DatabaseWords_H
#define DatabaseWords_H

#import "MTLanguageType.h"

@class MTSqliteWrapper;

@interface DatabaseWords : NSObject
	+ (instancetype)sharedInstance;

	@property (nonatomic, retain) MTSqliteWrapper *database;
	@property (readonly) MTLanguageType language;
	@property (readonly) NSArray <NSString *> *letters;

	- (BOOL)validateWord:(NSString *)word;
	- (NSString *)randomLetterAvoiding:(NSString *)avoid;

@end

#endif
