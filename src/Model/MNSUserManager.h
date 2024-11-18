//
//  MNSUserManager.h
//  wordPuzzle
//
//  Created by Michael on 1/16/23.
//  Copyright © 2023 Michael Thomason. All rights reserved.
//

#ifndef MNSUserManager_h
#define MNSUserManager_h

@class UIViewController, GKLocalPlayer, NSError, MNSUser;

@interface MNSUserManager : NSObject

	+ (instancetype)sharedInstance;

	
	@property (nonatomic, retain, readonly) MNSUser *activeUser;

	- (void)authenticateUserFromViewController:(UIViewController *)fromViewController
									completion:(void (^)(GKLocalPlayer *, NSError *))completion;
	//- (MNSUser *)ActiveUser;
	//- (void)SetDefaultUserAsActive;
	//- (void)SetGameKitUserAsActive;

@end

#endif /* MNSUserManager_h */
