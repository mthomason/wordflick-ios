//
//  MTGameScreen.h
//  wordPuzzle
//
//  Created by Michael on 12/18/19.
//  Copyright © 2019 Michael Thomason. All rights reserved.
//

#ifndef MTGameScreen_h
#define MTGameScreen_h

typedef NS_ENUM(int, MUIGameScreen) {
	MUIGameScreenNone = 1,                //Game is loading, no game screen visable.
	MUIGameScreenIntro,
	MUIGameScreenLevelStats,
	MUIGameScreenPause,
	MUIGameScreenGameOn,
	MUIGameScreenGameOver,
	MUIGameScreenUserMaintance,
	MUIGameScreenUserMaintanceAddUser,
	MUIGameScreenUserMaintanceModUser,
	MUIGameScreenUserAddUserFirstTime,
	MUIGameScreenHighScores,
	MUIGameScreenDemo,
	MUIGameScreenPreLevel,
	MUIGameScreenAbout,
	MUIGameScreenAdsGameStart,          //Ads displayed before game starts
	MUIGameScreenAdsLevel,              //Ads displayed between level
	MUIGameScreenGameOverStats,
	MTGameScreenAchievements,
	MTGameScreenSettings,
	MTGameScreenLoot,
	MTGameScreenTwitterLogin,
	MTGameScreenFacebookLogin,
	MTGameScreenPlayerSettings
};

#endif /* MTGameScreen_h */
