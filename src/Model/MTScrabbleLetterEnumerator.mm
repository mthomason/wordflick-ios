//
//  MTScrabbleLetterEnumerator.mm
//  Wordflick-Pro
//
//  Created by Michael on 11/17/19.
//  Copyright © 2019 Michael Thomason. All rights reserved.
//

#import "MTScrabbleLetterEnumerator.h"
#import <Foundation/Foundation.h>
#import <vector>
#import <array>

//static const wchar_t kScrabbleDeckEn[];
//static const char kScrabbleDeckEn[] = { 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'B', 'B', 'C', 'C', 'D', 'D', 'D', 'D', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'F', 'F', 'G', 'G', 'G', 'H', 'H', 'I', 'I', 'I', 'I', 'I', 'I', 'I', 'I', 'I', 'J', 'K', 'L', 'L', 'L', 'L', 'M', 'M', 'N', 'N', 'N', 'N', 'N', 'N', 'O', 'O', 'O', 'O', 'O', 'O', 'O', 'O', 'P', 'P', 'Q', 'R', 'R', 'R', 'R', 'R', 'R', 'S', 'S', 'S', 'S', 'T', 'T', 'T', 'T', 'T', 'T', 'U', 'U', 'U', 'U', 'V', 'V', 'W', 'W', 'X', 'Y', 'Y', 'Z' };
static const int kScrabbleDeckEnCount = 98;

struct MADDeckImpl;
struct MADDeckImpl {
    std::array<char, kScrabbleDeckEnCount> _container;// = { 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'B', 'B', 'C', 'C', 'D', 'D', 'D', 'D', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'F', 'F', 'G', 'G', 'G', 'H', 'H', 'I', 'I', 'I', 'I', 'I', 'I', 'I', 'I', 'I', 'J', 'K', 'L', 'L', 'L', 'L', 'M', 'M', 'N', 'N', 'N', 'N', 'N', 'N', 'O', 'O', 'O', 'O', 'O', 'O', 'O', 'O', 'P', 'P', 'Q', 'R', 'R', 'R', 'R', 'R', 'R', 'S', 'S', 'S', 'S', 'T', 'T', 'T', 'T', 'T', 'T', 'U', 'U', 'U', 'U', 'V', 'V', 'W', 'W', 'X', 'Y', 'Y', 'Z' };
    // (kScrabbleDeckEn, kScrabbleDeckEn + ( sizeof(kScrabbleDeckEn) / sizeof(kScrabbleDeckEn[0]) ));
};

@interface MTScrabbleLetterEnumerator() {
    struct MADDeckImpl *_impl;
    NSUInteger _containerLength;
    NSUInteger _capacity;
    NSUInteger _count;
}

@end

@implementation MTScrabbleLetterEnumerator

void durstenfeldShuffle(std::array<char, kScrabbleDeckEnCount> &deck, NSUInteger n);
void durstenfeldShuffle(std::array<char, kScrabbleDeckEnCount> &deck, NSUInteger n) {
    //NSUInteger n = _containerLength;
    NSUInteger k;
    while (n > 1) {
        n--;
        k = arc4random() % (n + 1);
        char tmp = deck[k];
        deck[k] = deck[n];
        deck[n] = tmp;
    }
}


- (void)dealloc {
    _impl->_container.empty();
    delete _impl;
}

// Designated initializer for this class.
// Since this is just a sample, we'll generate some random data
// for the enumeration to return later.
- (id)initWithCapacity:(NSUInteger)capacity {
    if (self = [super init]) {
        _impl = new MADDeckImpl;
        _containerLength = kScrabbleDeckEnCount;
        _impl->_container = { 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'B', 'B', 'C', 'C', 'D', 'D', 'D', 'D', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'F', 'F', 'G', 'G', 'G', 'H', 'H', 'I', 'I', 'I', 'I', 'I', 'I', 'I', 'I', 'I', 'J', 'K', 'L', 'L', 'L', 'L', 'M', 'M', 'N', 'N', 'N', 'N', 'N', 'N', 'O', 'O', 'O', 'O', 'O', 'O', 'O', 'O', 'P', 'P', 'Q', 'R', 'R', 'R', 'R', 'R', 'R', 'S', 'S', 'S', 'S', 'T', 'T', 'T', 'T', 'T', 'T', 'U', 'U', 'U', 'U', 'V', 'V', 'W', 'W', 'X', 'Y', 'Y', 'Z' };
        durstenfeldShuffle(_impl->_container, kScrabbleDeckEnCount);
        _capacity = capacity;
        _count = 0;
    }
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)capacity language:(MTLanguageType)language {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)reshuffle {
    
}

// This is where all the magic happens.
// You have two choices when implementing this method:
// 1) Use the stack based array provided by stackbuf. If you do this, then you must respect the value of 'len'.
// 2) Return your own array of objects. If you do this, return the full length of the array returned until you run out of objects, then return 0. For example, a linked-array implementation may return each array in order until you iterate through all arrays.
// In either case, state->itemsPtr MUST be a valid array (non-nil). This sample takes approach #1, using stackbuf to store results.
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
								  objects:(__unsafe_unretained id * _Nonnull)stackbuf
									count:(NSUInteger)len {
    
    NSUInteger count = 0;
    // This is the initialization condition, so we'll do one-time setup here.
    // Ensure that you never set state->state back to 0, or use another method to detect initialization
    // (such as using one of the values of state->extra).
    if(state->state == 0) {
        // We are not tracking mutations, so we'll set state->mutationsPtr to point into one of our extra values,
        // since these values are not otherwise used by the protocol.
        // If your class was mutable, you may choose to use an internal variable that is updated when the class is mutated.
        // state->mutationsPtr MUST NOT be NULL.
        state->state = 1;
        state->mutationsPtr = &state->extra[0];
    }
    // Now we provide items, which we track with state->state, and determine if we have finished iterating.
    if(state->state != 2) {
        // Set state->itemsPtr to the provided buffer.
        // Alternate implementations may set state->itemsPtr to an internal C array of objects.
        // state->itemsPtr MUST NOT be NULL.
        state->itemsPtr = stackbuf;
        // Fill in the stack array, either until we've provided all items from the list
        // or until we've provided as many items as the stack based buffer will hold.
        
        char random_c;
        count = 0;
        //NSUInteger n = len;
        //NSUInteger cl = _containerLength;
        NSUInteger k;
        state->itemsPtr = stackbuf;
        while (_containerLength > 1 && count < len && _count < _capacity) {
            _containerLength--;
            k = arc4random_uniform((uint32_t)(_containerLength + 1)); //() % (_containerLength + 1);
            random_c = _impl->_container.at(k);
            _impl->_container[k] = _impl->_container.at(_containerLength);
            _impl->_container[_containerLength] = random_c;
            stackbuf[count] = [NSNumber numberWithChar: random_c];

            //[self exchangeObjectAtIndex: k
            //          withObjectAtIndex: n];
            count++; _count++;
        }

        if (count == 0)             state->state = 2;

        /*while((count < len) && (_count < _total)) {
            
            // For this sample, we generate the contents on the fly.
            // A real implementation would likely just be copying objects from internal storage.
            size_t s = _impl ->_container.size();
            
            NSAssert(_total <= s , @"Expect this to be with range.");
            uint32_t p = arc4random_uniform((uint32_t)s);
            char c = _impl->_container.at(p);
            
            NSNumber *result = [[NSNumber alloc] initWithChar: c];
            stackbuf[count] = result;
            [result release];
            
            //char last = _impl->_container.at(_total - _count);
            char tmp = _impl->_container.at(_total - 1);
            _impl->_container[p] = tmp;
            _impl->_container.resize(s - 1);
            
            state->state++;
            count++;
            _count++;
            _total--;
        } */
    } else {
        // We've already provided all our items, so we signal we are done by returning 0.
        count = 0;
    }
    return count;
}

@end
