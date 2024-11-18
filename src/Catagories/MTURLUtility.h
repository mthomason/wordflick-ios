//
//  MTUrlUtility.h
//  wordPuzzle
//
//  Created by Michael on 10/18/23.
//  Copyright © 2023 Michael Thomason. All rights reserved.
//

#ifndef MTUrlUtility_h
#define MTUrlUtility_h

typedef void (^URLOpenCompletion)(NSError * _Nullable error);

@interface MTURLUtility : NSObject

+ (void)openURLString:(NSString *_Nonnull)urlString
		   completion:(URLOpenCompletion _Nullable )completion;

@end

#endif /* MTUrlUtility_h */
