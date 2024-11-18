//
//  WFGameViewController.h
//  wordPuzzle
//
//  Created by Michael Thomason on 5/29/09.
//  Copyright Michael Thomason 2023. All rights reserved.
//

#ifndef MUIViewControllerGameWordPuzzle_h
#define MUIViewControllerGameWordPuzzle_h

#import "MTGameProtocol.h"
#import "MTGameControllerProtocol.h"
#import "MTPreLevelControllerProtocol.h"
#import "MTPostLevelControllerProtocol.h"
#import "MTPauseScreenControllerProtocol.h"
#import "MTGameOverControllerProtocol.h"
#import "WFTileView.h"
#import "WFButton.h"
#import "WFShuffleButton.h"
#import "WFCheckButton.h"
#import "WFPauseButton.h"

@class WFGoalView, WFGlowLabelView, MUIViewGameControlScreen, WFToolBarView,
        WFGlowLabelBackgroundView, MTGameBoard;

@interface WFGameViewController : UIViewController
	<MTGameProtocol, MTPreLevelControllerProtocol,
		MTPostLevelControllerProtocol, MUIViewControllerGameOverDelegate,
		MTPauseScreenControllerProtocol>

@property (nonatomic, assign) id <MTGameControllerProtocol> delegate;

@property (nonatomic, retain) IBOutlet UIView *backgroundView;
@property (nonatomic, retain) IBOutlet WFToolBarView *toolBarView;
@property (nonatomic, retain) IBOutlet UIImageView *controlScreenBackground;
@property (nonatomic, retain) IBOutlet MUIViewGameControlScreen *controlScreen;
@property (nonatomic, retain) IBOutlet UIButton *buttonPause;
@property (nonatomic, retain) IBOutlet UIButton *buttonCheck;
@property (nonatomic, retain) IBOutlet UIButton *buttonRefresh;
@property (nonatomic, strong) IBOutlet WFCheckButton *checkButton;
@property (nonatomic, strong) IBOutlet WFShuffleButton *shuffleButton;
@property (nonatomic, strong) IBOutlet WFPauseButton *pauseButton;

@property (nonatomic, retain) IBOutlet WFGameView *gameView;
@property (nonatomic, retain) IBOutlet UIView *flasherView;
@property (nonatomic, retain) IBOutlet WFGlowLabelBackgroundView *flasherLabelBackground;
@property (nonatomic, retain) IBOutlet WFGlowLabelView *flasherLabel;
@property (nonatomic, retain) IBOutlet WFGoalView *bottomGoal;

@property (nonatomic, retain) IBOutlet NSLayoutConstraint *toolBarTopConstraint;
@property (nonatomic, retain) IBOutlet NSLayoutConstraint *toolBarLeadingConstraint;
@property (nonatomic, retain) IBOutlet NSLayoutConstraint *toolBarTrailingConstraint;

@property (nonatomic, retain) UIMotionEffectGroup *controlMotionEffects;
@property (nonatomic, retain) UIMotionEffectGroup *tileMotionEffects;

@property (nonatomic, assign) BOOL loadGameFromSaveFile;

- (MTGameBoard *)gameBoardLayoutCurrent;

@end

#endif
