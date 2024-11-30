//
//  wordPuzzleAppDelegate.m
//  wordPuzzle
//
//  Created by Michael Thomason on 5/29/09.
//  Copyright Michael Thomason 2011. All rights reserved.
//

#import "wordPuzzleAppDelegate.h"
#import <GameKit/GameKit.h>
#import <Accounts/Accounts.h>
#import "Constants.h"
#import "DatabaseUsers.h"
#import "DatabaseWords.h"
#import "MTSqliteWrapper.h"
#import "MNSUser.h"
#import "MNSGame.h"
#import "MNSAudio.h"
#import "MTFileController.h"

typedef void (^rsltBlk_fbPermissiions)(BOOL user_about_me, BOOL email, BOOL publish_stream, BOOL publish_actions);

@interface wordPuzzleAppDelegate () {
	bool _gameCenterAuthenticationComplete;
}
	@property (copy) rsltBlk_fbPermissiions resultFacebookPermissions;
	@property (retain) ACAccount *facebookAccount;
	@property (retain) ACAccountStore *accountStore;
@end

@implementation wordPuzzleAppDelegate

void uncaughtExceptionHandler(NSException *exception) {
	NSLog(@"%@", exception);
}

+ (void)initialize {
	if (self == [wordPuzzleAppDelegate class]) {
		NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
		srandom((unsigned int)time(NULL));
	}
}

- (instancetype)init {
	if (self = [super init]) {
		_gameCenterAuthenticationComplete = false;
	}
	return self;
}

- (void)dealloc {
	_window = nil;
	_resultFacebookPermissions = nil;
	_facebookAccount = nil;
	_accountStore = nil;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
	return window.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPhone ?
	UIInterfaceOrientationMaskAllButUpsideDown : UIInterfaceOrientationMaskAll;
}

- (BOOL)attemptRecoveryFromError:(NSError *)error optionIndex:(NSUInteger)recoveryOptionIndex {
	return YES;
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions {
	return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions {
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"WordflickRunBefore"] == NO) {
		[MNSUser CurrentUser].desiresStylizedFonts = YES;
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WordflickRunBefore"];
	}
	
	//[application setStatusBarStyle: UIStatusBarStyleLightContent animated: NO];
	_gameCenterAuthenticationComplete = false;
	
	//Is game center available?
	Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
	NSString *reqSysVer = @"4.1";
	BOOL osVersionSupported = ([[UIDevice currentDevice].systemVersion compare: reqSysVer
																	   options: NSNumericSearch] != NSOrderedAscending);
	BOOL isGameCenterApiAvailable = (gcClass && osVersionSupported);
	
	//Game Center Login
	if (!isGameCenterApiAvailable) {
		[MNSUser MakeCurrentUserDefaultUser];
		_gameCenterAuthenticationComplete = NO;
	} else {
		
		[[GKLocalPlayer localPlayer] setAuthenticateHandler:^(UIViewController *viewcontroller, NSError *error) {
			if (!error && [GKLocalPlayer localPlayer].isAuthenticated) {
				self->_gameCenterAuthenticationComplete = YES;
				[MNSUser MakeCurrentUserGameKitUser];
				[[self player] loadStoredAchievements];
				//#warning For testing
				//[[self player] resetAchievements];
			} else {
				[MNSUser MakeCurrentUserDefaultUser];
				self->_gameCenterAuthenticationComplete = NO;
			}
		}];
	}

	return YES;
}

+ (UIStoryboard *)storyboard {
	return [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
}

- (MNSUser *)player {
	return [MNSUser CurrentUser];
}

- (void)applicationDidBecomeActive:(UIApplication *)application { }

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	__strong MNSUser *user = [MNSUser CurrentUser];
	__strong MNSGame *game = user.game;
	[game pressedPauseButton];
	[user saveYourGame];
	game = nil;
	user = nil;
}

- (void)applicationWillEnterForeground:(UIApplication *)application { }

- (void)applicationWillTerminate:(UIApplication *)application {
	[[[DatabaseWords sharedInstance] database] closeDatabase];
	[[[DatabaseUsers sharedInstance] database] closeDatabase];
}

@end
