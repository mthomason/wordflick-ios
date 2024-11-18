//
//  MTScrabbleLetterEnumerator.h
//  wordPuzzle
//
//  Created by Michael on 11/18/19.
//  Copyright © 2019 Michael Thomason. All rights reserved.
//

#ifndef MTScrabbleLetterEnumerator_h
#define MTScrabbleLetterEnumerator_h

#import "MTLanguageType.h"

@interface MTScrabbleLetterEnumerator : NSEnumerator
	- (instancetype)initWithCapacity:(NSUInteger)capacity;
	- (instancetype)initWithCapacity:(NSUInteger)capacity language:(MTLanguageType)language;
@end

#endif /* MTScrabbleLetterEnumerator_h */
