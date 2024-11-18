//
//  MNSUserManager.m
//  Wordflick-Pro
//
//  Created by Michael on 1/16/23.
//  Copyright © 2023 Michael Thomason. All rights reserved.
//

#import "MNSUserManager.h"
#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface MNSUserManager()
	@property (nonatomic, retain, readwrite) MNSUser *activeUser;
@end

@implementation MNSUserManager

static bool _isFirstAccess = true;
static MNSUserManager *_sharedInstance = nil;

+ (BOOL)operatingSystemSupportVersion:(NSString *)requiredVersion {
	return [[UIDevice currentDevice].systemVersion compare: requiredVersion
												   options: NSNumericSearch] != NSOrderedAscending;
}

+ (BOOL)gameCenterApiIsAvailable {
	return ((NSClassFromString(@"GKLocalPlayer")) && [MNSUserManager operatingSystemSupportVersion:@"4.1"]);
}

+ (NSString *)GameKitIdentifierOrDefault {
	return ([MNSUserManager gameCenterApiIsAvailable] &&
			[GKLocalPlayer localPlayer].authenticated &&
			[GKLocalPlayer localPlayer].playerID != nil) ? [GKLocalPlayer localPlayer].playerID :
														   @"nogamekituser";
}

+ (instancetype)sharedInstance {
	static dispatch_once_t _dispatchToken;
	dispatch_once(&_dispatchToken, ^{
		_isFirstAccess = false;
		_sharedInstance = [[super allocWithZone:NULL] init];

	});
	return _sharedInstance;
}

+ (instancetype)allocWithZone:(NSZone *)zone {
	return [self sharedInstance];
}

- (void)dealloc {
	_activeUser = nil;
}

- (instancetype)init {
	if (_sharedInstance) return _sharedInstance;
	if (_isFirstAccess) [self doesNotRecognizeSelector:_cmd];
	self = [super init];
	return self;
}

- (void)authenticateUserFromViewController:(UIViewController *)fromViewController
								completion:(void (^)(GKLocalPlayer *, NSError *))completion {

	[[GKLocalPlayer localPlayer] setAuthenticateHandler:^(UIViewController * _Nullable viewController, NSError * _Nullable error) {
		
		if (viewController != nil) {
			// Present the view controller so the player can sign in.
			return;
		}
		
		if (error != nil) {
			// Player could not be authenticated.
			// Disable Game Center in the game.
			return;
		}
		
		
		if ([GKLocalPlayer localPlayer].isUnderage) {
			// Hide explicit game content.
		}

		//if (GKLocalPlayer.localPlayer.isMultiplayerGamingRestricted) {
			// Disable multiplayer game features.
		//}
		
		//if (GKLocalPlayer.localPlayer.isPersonalizedCommunicationRestricted) {
			// Disable in game communication UI.
		//}
		
	}];
	
}

#pragma mark -
#pragma mark Singleton methods

- (id)mutableCopyWithZone:(struct _NSZone *)zone { return self; }

- (id)copyWithZone:(struct _NSZone *)zone { return self; }

@end

