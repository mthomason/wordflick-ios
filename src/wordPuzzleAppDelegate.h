//
//  wordPuzzleAppDelegate.h
//  wordPuzzle
//
//  Created by Michael Thomason on 5/29/09.
//  Copyright Michael Thomason 2019. All rights reserved.
//

#ifndef WordPuzzleAppDelegate_h
#define WordPuzzleAppDelegate_h

@class wordPuzzleAppDelegate, MNSUser, MTFileController, ACAccountStore, ACAccount;

static inline wordPuzzleAppDelegate *appCoordinator(void);
static inline wordPuzzleAppDelegate *appCoordinator(void) {
	return (wordPuzzleAppDelegate *)[[UIApplication sharedApplication] delegate];
}

@interface wordPuzzleAppDelegate : UIResponder <UIApplicationDelegate>

	@property (nonatomic, retain)			UIWindow *window;
	@property (nonatomic, readonly)			MNSUser *player;

@end

#endif
