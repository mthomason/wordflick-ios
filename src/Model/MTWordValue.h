//
//  StringNumberWrapper.h
//  wordPuzzle
//
//  Created by Michael Thomason on 7/14/09.
//  Copyright 2009 Michael Thomason. All rights reserved.
//

#ifndef StringNumberWrapper_h
#define StringNumberWrapper_h

#import <Foundation/Foundation.h>

@interface MTWordValue : NSObject <NSCoding>

	@property (nonatomic, copy) NSString *word;
	@property (nonatomic, copy) NSNumber *points;
	@property (readonly,  copy) NSString *kidFriendlyWord;

	- (instancetype)init;
	- (instancetype)initWithCString:(char *)word andInteger:(NSInteger)value;
	- (instancetype)initWithString:(NSString *)w andInteger:(NSInteger)i;
	- (instancetype)initWithString:(NSString *)w andNumber:(NSNumber *)n;

	+ (NSString *)cleanSpanishString:(NSString *)displayString;

@end

#endif
