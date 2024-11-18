//
//  MUIViewControllerIntroduction.m
//  wordPuzzle
//
//  Created by Michael Thomason on 10/11/09.
//  Copyright 2020 Michael Thomason. All rights reserved.
//

//#define WORD_NERD_BACKGROUND_TIMER

#import "WFIntroductionViewController.h"
#import <GameKit/GameKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import "MNSUser.h"
#import "MNSGame.h"
#import "MNSAudio.h"
#import "wordPuzzleAppDelegate.h"
#import "MTGameActionProtocol.h"
#import "WFGameViewController.h"
#import "MUIViewControllerPreGame.h"
#import "WFPostLevelViewController.h"
#import "MUIViewControllerLoot.h"
#import "MUIViewControllerAbout.h"
#import "MTIntroductionDataSource.h"
#import "MTIntroductionDelegate.h"
#import "MTWordflickButtonType.h"
#import "MTGameScreen.h"

#import "MTSettingsDataSource.h"
#import "MTSettingsDelegate.h"

#import "WFTileData.h"

@interface WFIntroductionViewController ()
	<GKGameCenterControllerDelegate, MTGameActionProtocol, MTSettingsControllerCompletedProtocol,
		WFTileViewDataSource, WFTileViewDelegate>

@property (nonatomic, retain) IBOutlet UIButton *infoButton;
@property (nonatomic, retain) IBOutlet UIButton *soundButton;
@property (nonatomic, retain) IBOutlet UIView *infoButtonView;

@property (nonatomic, assign) NSTimer *backgroundTimer;

@property (nonatomic, retain) NSObject <UITableViewDataSource> *introductionDataSource;
@property (nonatomic, retain) NSObject <UITableViewDelegate> *introductionDelegate;

@property (nonatomic, strong) NSDictionary <NSNumber *, WFTileData *> *logoTileData;
@property (nonatomic, strong) NSDictionary <NSNumber *, NSNumber *> *logoTileTransforms;

@property (retain, nonatomic) IBOutletCollection(WFTileView) NSArray <WFTileView *> *logoTileViews;

- (IBAction)infoButtonDidTouchUpInside:(id)sender;
- (IBAction)soundButtonDidTouchUpInside:(id)sender;

@end

@implementation WFIntroductionViewController

- (void)dealloc {

	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: @"MTUserDidUpdateNotification"
												  object: appCoordinator()];

#ifdef WORD_NERD_BACKGROUND_TIMER
	//[_backgroundColorTimer		invalidate];
	_backgroundColorTimer = nil;
#endif

	_backgroundTimer = nil;

	_menuTableView.dataSource = nil;
	_menuTableView.delegate = nil;
	
	_logoTileViews = nil;
	_infoButton = nil;
	_soundButton = nil;
	_infoButtonView = nil;
	_introductionDataSource = nil;
	_introductionDelegate = nil;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	if (self = [super initWithCoder:coder]) {

		_introductionDataSource = [[MTIntroductionDataSource alloc] init:nil];
		_introductionDelegate = [[MTIntroductionDelegate alloc] initGameActionDelegate:self];

		self.logoTileTransforms = @{
			@101 : @((35.0f * M_PI) / 18.0f),
			@102 : @((357.0f * M_PI) / 180.0f),
			@103 : @(M_PI / 36.0f),
			@104 : @(M_PI / 18.0f),
			@105 : @((35.0f * M_PI) / 18.0f),
			@106 : @((59.0f * M_PI) / 30.0f),
			@107 : @((359.0f * M_PI) / 180.0f),
			@108 : @(M_PI / 36.0f),
			@109 : @(M_PI / 18.0f),
		};

		for (WFTileView *tileView in self.logoTileViews) {
			tileView.dataSource = self;
			tileView.delegate = self;
		}

		WFTileData *tileW = [[WFTileData alloc] initWithCharacter: 'W'
													   type: MNSTileExtraPoints
												 identifier: 101];

		WFTileData *tileO = [[WFTileData alloc] initWithCharacter: 'O'
													   type: MNSTileExtraNormal
												 identifier: 101];

		WFTileData *tileR = [[WFTileData alloc] initWithCharacter: 'R'
													   type: MNSTileExtraTime
												 identifier: 101];

		WFTileData *tileD = [[WFTileData alloc] initWithCharacter: 'D'
													   type: MNSTileExtraPoints
												 identifier: 101];

		WFTileData *tileF = [[WFTileData alloc] initWithCharacter: 'F'
													   type: MNSTileExtraNormal
												 identifier: 101];

		WFTileData *tileL = [[WFTileData alloc] initWithCharacter: 'L'
													   type: MNSTileExtraSpecial
												 identifier: 101];

		WFTileData *tileI = [[WFTileData alloc] initWithCharacter: 'I'
															 type: MNSTileExtraShuffle
													   identifier: 101];

		WFTileData *tileC = [[WFTileData alloc] initWithCharacter: 'C'
															 type: MNSTileExtraNormal
													   identifier: 101];

		WFTileData *tileK = [[WFTileData alloc] initWithCharacter: 'K'
															 type: MNSTileExtraPoints
													   identifier: 101];

		self.logoTileData = @{
			@101 : tileW,
			@102 : tileO,
			@103 : tileR,
			@104 : tileD,
			@105 : tileF,
			@106 : tileL,
			@107 : tileI,
			@108 : tileC,
			@109 : tileK,
		};
		
		tileW = nil;
		tileO = nil;
		tileR = nil;
		tileD = nil;
		tileF = nil;
		tileL = nil;
		tileI = nil;
		tileC = nil;
		tileK = nil;

	}
	return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder { 
	[super encodeWithCoder:coder];
}

- (void)awakeFromNib {
	[super awakeFromNib];
	//for (WFTileView *tileView in self.logoTileViews) {
	//	tileView.dataSource = self;
	//	tileView.delegate = self;
	//}
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	for (WFTileView *tileView in self.logoTileViews) {
		tileView.dataSource = self;
		tileView.delegate = self;
	}

	self.view.autoresizesSubviews = YES;
	self.view.backgroundColor = [UIColor whiteColor];

	self.infoButtonView.opaque = NO;
	self.infoButtonView.backgroundColor = [UIColor clearColor];
	self.infoButton.alpha = 0.0000f;
	self.soundButton.alpha = 0.0000f;
	[self.infoButton bringSubviewToFront:self.infoButtonView];
	self.infoButton.backgroundColor = [UIColor clearColor];
	self.soundButton.backgroundColor = [UIColor clearColor];
	self.infoButton.tintColor = [UIColor whiteColor];
	self.soundButton.tintColor = [UIColor whiteColor];
		
	self.menuTableView.dataSource = self.introductionDataSource;
	self.menuTableView.delegate = self.introductionDelegate;

	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(userDidUpdate:)
												 name: @"MTUserDidUpdateNotification"
											   object: appCoordinator()];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	self.menuTableView.alpha = 0.0000f;
	self.infoButton.alpha = 0.0000f;
	self.soundButton.alpha = 0.0000f;

	self.view.backgroundColor = [UIColor blackColor];

	if (self.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
		if (self.view) {
			CGPoint currentFrameOrigin = self.menuTableView.frame.origin;
			self.menuTableView.frame = CGRectMake(currentFrameOrigin.x, currentFrameOrigin.y, 245.0, 297.0);
		} else {
			CGRect currentFrame = self.menuTableView.frame;
			self.menuTableView.frame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y, currentFrame.size.width, 300.0 - currentFrame.origin.y);
		}
	}

	self.menuTableView.scrollIndicatorInsets = UIEdgeInsetsMake(UIEdgeInsetsZero.top + 60.0, UIEdgeInsetsZero.left, UIEdgeInsetsZero.bottom, UIEdgeInsetsZero.right);
	self.menuTableView.scrollsToTop = YES;
	self.menuTableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;

	/*__weak UIView *weakSelfView = self.view;
	self.backgroundTimer = [NSTimer scheduledTimerWithTimeInterval: 3.5
														   repeats: YES
															 block: ^(NSTimer * _Nonnull timer) {
		__strong UIView *sview = weakSelfView;
		if (sview != nil && !sview.isHidden) {
			UIColor *randomColor = [UIColor colorWithRed: (double)arc4random_uniform(UINT32_MAX) / (double)UINT32_MAX
												   green: (double)arc4random_uniform(UINT32_MAX) / (double)UINT32_MAX
													blue: (double)arc4random_uniform(UINT32_MAX) / (double)UINT32_MAX
												   alpha: 1.0];

			__weak UIView *wview = sview;
			[UIView animateWithDuration:3.0 animations:^{
				wview.backgroundColor = randomColor;
			}];
		}
	}];*/
	
	#if WORDFLICKLAUNCHIMAGES == 0

	#ifdef WORD_NERD_BACKGROUND_TIMER

	self.backgroundColorTimer = [NSTimer scheduledTimerWithTimeInterval: 3.5 repeats: YES
																  block: ^(NSTimer * _Nonnull timer) {
		if (self.view != nil && !self.view.isHidden) {
			CGFloat c[] = {RandomFractionalValue(), RandomFractionalValue(), RandomFractionalValue(), 1.0};
			UIColor *randomColor = [UIColor colorWithRed: RandomFractionalValue() green: RandomFractionalValue() blue: RandomFractionalValue() alpha: 1.0];
			
			[UIView animateWithDuration:3.0 animations:^{
				self.view.backgroundColor = randomColor;
			}];

			//[UIView beginAnimations: nil context: nil];
			//[UIView setAnimationDuration: 3.0];
			//self.view.backgroundColor = randomColor;
			//[UIView commitAnimations];
		}
	}];

	#endif

	#endif
	
	[self.menuTableView reloadData];

}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[UIView animateWithDuration:0.9 animations:^{
		self.menuTableView.alpha = 1.0;
		self.infoButton.alpha = 1.0;
		self.soundButton.alpha = 1.0;
	} completion:^(BOOL finished) {
		if (finished) {
			[self.menuTableView flashScrollIndicators];
		}
	}];

	[MNSAudio downloadMusic];
}

- (void)viewWillDisappear:(BOOL)animated {
	
	[super viewWillDisappear:animated];
	[UIView animateWithDuration:0.9 animations:^{
		self.menuTableView.alpha = 0.0;
		self.infoButton.alpha = 0.0;
		self.soundButton.alpha = 0.0;
	} completion:^(BOOL finished) { }];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self.backgroundTimer invalidate];
	self.menuTableView.alpha = 0.0;
	self.infoButton.alpha = 0.0;
	self.soundButton.alpha = 0.0;
}

- (void)prepairForSeguePlayPreGame:(UIStoryboardSegue * _Nonnull)segue gameType:(MNSGameType)gameType {
	MUIViewControllerPreGame *pregameViewController = segue.destinationViewController;
	if (pregameViewController != nil) {
		pregameViewController.delegate = self;
		pregameViewController.gametype = gameType;
	}
	pregameViewController = nil;
}

- (void)prepairForSeguePlay:(UIStoryboardSegue * _Nonnull)segue gameType:(MNSGameType)gameType {
	WFGameViewController *viewControllerGameWordPuzzle = segue.destinationViewController;
	if (viewControllerGameWordPuzzle != nil) {
		viewControllerGameWordPuzzle.delegate = self;
		MNSGame *game = [[MNSGame alloc] initWithType: gameType
											   userID: @""
									 andStartingLevel:	1];
		game.delegate = viewControllerGameWordPuzzle;
		[MNSUser CurrentUser].game = game;
		game = nil;
		[MNSAudio playButtonPress];
	}
	viewControllerGameWordPuzzle = nil;
}

- (void)prepareForSegueAbout:(UIStoryboardSegue * _Nonnull)segue {
	if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
		UINavigationController *aboutNav = segue.destinationViewController;
		if (aboutNav != nil) {
			MUIViewControllerAbout *targetViewController = [aboutNav.viewControllers objectAtIndex:0];
			targetViewController.delegate = self;
			targetViewController = nil;
		}
	} else {
		[segue.destinationViewController setDelegate:self];
		segue.destinationViewController.modalPresentationStyle = UIModalPresentationFormSheet;
		segue.destinationViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	}
	[[MNSUser CurrentUser].game setCurrentGameScreen: MUIGameScreenAbout];
	[[MNSUser CurrentUser].game setAllowShuffle: NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
	if ([segue.identifier isEqualToString:@"seguePlay"]) {
		NSAssert([sender isKindOfClass:[NSNumber class]], @"Expecting a number (MNSGameType).");
		[self prepairForSeguePlay: segue gameType: (MNSGameType)[(NSNumber *)sender intValue]];

	} else if ([segue.identifier isEqualToString:@"segueAbout"]) {
		[self prepareForSegueAbout:segue];
		
	} else if ([segue.identifier isEqualToString:@"segueAchievements"]) {
		[segue.destinationViewController view].backgroundColor = [UIColor greenColor];

	} else if ([segue.identifier isEqualToString:@"segueLoot"]) {
		NSAssert([segue.destinationViewController isKindOfClass:[UINavigationController class]], @"Expect a navigation controller.");
		UINavigationController *navigationController = segue.destinationViewController;
		MUIViewControllerLoot *targetViewController = navigationController.viewControllers.firstObject;
		targetViewController.delegate = self;

	} else if ([segue.identifier isEqualToString:@"segueSettings"]) {
		NSAssert([segue.destinationViewController isKindOfClass:[UINavigationController class]], @"Expect a navigation controller.");
		UINavigationController *navigationController = segue.destinationViewController;
		MUIViewControllerSettings *targetViewController = navigationController.viewControllers.firstObject;
		targetViewController.delegate = self;
	}
}

- (void)settingsControllerDidFinish:(id)sender {
	MTIntroductionDataSource *dataSource = [[MTIntroductionDataSource alloc] init:nil];;
	MTIntroductionDelegate *delegate = [[MTIntroductionDelegate alloc] initGameActionDelegate:self];

	self.introductionDataSource = dataSource;
	
	self.introductionDelegate = delegate;

	self.menuTableView.dataSource = dataSource;
	self.menuTableView.delegate = delegate;

	[self.menuTableView beginUpdates];
	[self.menuTableView reloadSections: [NSIndexSet indexSetWithIndex:0]
					  withRowAnimation: UITableViewRowAnimationRight];
	[self.menuTableView endUpdates];

	
	dataSource = nil;
	delegate = nil;

}

- (void)viewControllerDidFinish:(id)sender {
	[self dismissViewControllerAnimated:YES completion:^{ }];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
	[super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
	[super preferredContentSizeDidChangeForChildContentContainer:container];
}

- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
	return [super sizeForChildContentContainer:container withParentContainerSize:parentSize];
}

- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
	[super systemLayoutFittingSizeDidChangeForChildContentContainer:container];
}

#pragma mark - Game Action Delegate

- (void)playGame:(id)sender gameType:(MNSGameType)gameType {
	switch (gameType) {
		case Wordflick:
			[self.gameControllerDelegate showGame:gameType animated:YES sender:self];
			break;
		case WordflickDebug:
			[self.gameControllerDelegate showGame:gameType animated:YES sender:self];
			[[MNSUser CurrentUser] resetAchievements];
			break;
		default:
			NSAssert(false, @"Unknown game type.");
			break;
	}
}

- (void)resumeGame:(id)sender {
	NSAssert([MNSUser CurrentUser].askToResume, @"If we are here, we expect that someone asked to resume");
	if (![MNSUser CurrentUser].askToResume) return;
	//MNSGame *game = [MNSUser CurrentUser].game;
	///???: Check this out... I'm turning a dictionary into a class...
	MNSGame *game = (MNSGame *)[[MNSUser CurrentUser] restartData];
	if (game != nil) {

		[MNSUser CurrentUser].game = game;
		
		UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
		MUIViewControllerPreGame *pregame = [sb instantiateViewControllerWithIdentifier:@"MUIViewControllerPreGame"];
		pregame.delegate = self;
		pregame.gametype = [MNSUser CurrentUser].game.gameType;
		
		[self presentViewController:pregame animated:NO completion:^{
			
			WFGameViewController *wp = [sb instantiateViewControllerWithIdentifier:@"MUIViewControllerGameWordPuzzle"];
			[wp setDelegate:pregame];
			[[MNSUser CurrentUser].game setDelegate:wp];
			
			[pregame presentViewController:wp animated:NO completion:^{

				switch ([(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"currentscreen"] integerValue]) {
					case MUIGameScreenGameOn:
						[[MNSUser CurrentUser].game restartLevel];
						break;
					
					case MUIGameScreenPause:
						[wp performSegueWithIdentifier:@"seguePauseGameCustom" sender:wp];
						break;

					case MUIGameScreenPreLevel:
						[wp performSegueWithIdentifier:@"segueGamePreLevelStats" sender:wp];
						break;
						
					case MUIGameScreenLevelStats:
						[wp performSegueWithIdentifier:@"segueGamePostLevelStats" sender:wp];
						break;

					case MUIGameScreenGameOver:
						break;
						
					default:
						break;
				}
				[MNSUser CurrentUser].askToResume = NO;
			}];
		}];
		[MNSUser CurrentUser].askToResume = NO;
	}
	game = nil;

}

- (void)showGameScreen:(id)sender screenType:(MUIGameScreen)screenType {

	switch (screenType) {

		case MTGameScreenAchievements:
			[self showAchievements:self];
			break;

		case MUIGameScreenHighScores:
			[self showHighScores:self];
			break;

		case MUIGameScreenAbout:
			[self performSegueWithIdentifier:@"segueAbout" sender:self];
			break;

		case MTGameScreenLoot:
			[self performSegueWithIdentifier:@"segueLoot" sender:self];
			break;

		case MTGameScreenSettings: {

			MTSettingsDelegate *setttingsDelegate = [[MTSettingsDelegate alloc] init];
			MTSettingsDataSource *settingsDataSource = [[MTSettingsDataSource alloc] init];
			setttingsDelegate.controllerDelegate = self;
			self.introductionDelegate = setttingsDelegate;
			self.introductionDataSource = settingsDataSource;
			self.menuTableView.dataSource = settingsDataSource;
			self.menuTableView.delegate = setttingsDelegate;
			
			setttingsDelegate = nil;
			settingsDataSource = nil;

			[self.menuTableView beginUpdates];
			[self.menuTableView reloadSections: [NSIndexSet indexSetWithIndex:0]
							  withRowAnimation: UITableViewRowAnimationLeft];
			[self.menuTableView endUpdates];
			}
			break;

		case MTGameScreenPlayerSettings:
			[self performSegueWithIdentifier:@"segueAchievements" sender:self];
			break;

		case MTGameScreenTwitterLogin:
			break;

		case MTGameScreenFacebookLogin:
			break;

		default:
			break;
	}
}

- (void)showHighScores:(id)sender {
	MNSGame *game = [MNSUser CurrentUser].game;
	game.currentGameScreen = MUIGameScreenHighScores;
	game.allowShuffle = NO;
	game = nil;

	GKGameCenterViewController *gameCenterController = nil;
	
	if (@available(iOS 14.0, *)) {
		gameCenterController = [[GKGameCenterViewController alloc] initWithLeaderboardID: @"grp.com.everydayapps.game.wordflick.highscores"
																			 playerScope: GKLeaderboardPlayerScopeGlobal
																			   timeScope: GKLeaderboardTimeScopeAllTime];
	} else {
		gameCenterController = [[GKGameCenterViewController alloc] init];
		if (gameCenterController != nil) {
			gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
			gameCenterController.leaderboardTimeScope = GKLeaderboardTimeScopeAllTime;
			gameCenterController.leaderboardIdentifier = @"grp.com.everydayapps.game.wordflick.highscores";
		}
	}
	
	if (gameCenterController != nil) {
		gameCenterController.modalTransitionStyle = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? UIModalTransitionStyleFlipHorizontal : UIModalTransitionStyleCoverVertical;
		gameCenterController.gameCenterDelegate = self;
		[self presentViewController: gameCenterController animated: YES completion:^{
			NSLog(@"Game Center display is complete.");
		}];
	}
	gameCenterController = nil;
}

- (void)showAchievements:(id)sender {
	MNSGame *game = [MNSUser CurrentUser].game;
	game.currentGameScreen = MUIGameScreenHighScores;
	game.allowShuffle = NO;
	game = nil;

	GKGameCenterViewController *gameCenterController = nil;
	if (@available(iOS 14.0, *)) {
		gameCenterController = [[GKGameCenterViewController alloc] initWithState: GKGameCenterViewControllerStateAchievements];
	} else {
		// Fallback on earlier versions
		gameCenterController = [[GKGameCenterViewController alloc] init];
		if (gameCenterController != nil) {
			gameCenterController.viewState = GKGameCenterViewControllerStateAchievements;
		}
	}
	
	if (gameCenterController != nil) {
		gameCenterController.modalTransitionStyle = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? UIModalTransitionStyleFlipHorizontal : UIModalTransitionStyleCoverVertical;
		gameCenterController.gameCenterDelegate = self;
		[self presentViewController: gameCenterController animated: YES completion:^{
			NSLog(@"Game Center display is complete.");
		}];
	}
}

#pragma mark Tables cell

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

#pragma mark -
#pragma mark GKGameCenterControllerDelegate

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
	[MNSAudio playButtonPress];
	[self dismissViewControllerAnimated:YES completion:^{ }];
}

#pragma mark -
#pragma mark User Delegate Protocol

- (void)userDidUpdate:(NSNotification *)notification {
	[self.menuTableView reloadData];
}

- (IBAction)infoButtonDidTouchUpInside:(id)sender {
	[MNSAudio playButtonPress];
	[self performSegueWithIdentifier:@"segueAbout" sender:nil];
}

- (IBAction)soundButtonDidTouchUpInside:(id)sender {
	[MNSAudio playButtonPress];
	//[self.gameControllerDelegate showSettings:YES sender:self];
	//[self performSegueWithIdentifier:@"segueSettings" sender:nil];
}

#pragma mark Game Delegate

//Delegate callback.
- (void)gameIsOver {
	[MNSUser CurrentUser].game.delegate = nil;
	[self dismissViewControllerAnimated:YES completion:^{ }];
}

- (void)gameIsOver:(id)sender {

}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
	[super traitCollectionDidChange:previousTraitCollection];
}

- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context
	   withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
	[super didUpdateFocusInContext:context withAnimationCoordinator:coordinator];
}

- (void)setNeedsFocusUpdate {
	[super setNeedsFocusUpdate];
}

- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
	return [super shouldUpdateFocusInContext:context];
}

- (void)updateFocusIfNeeded {
	[super updateFocusIfNeeded];
}

#pragma mark -
#pragma mark WFTileViewDataSource

- (nonnull NSString *)characterValueForTileView:(nonnull WFTileView *)tileView {
	return self.logoTileData[tileView.tileID].characterValue;
}

- (MNSTileType)typeTypeForTileView:(nonnull WFTileView *)tileView {
	return self.logoTileData[tileView.tileID].tileType;
}

- (bool)isTileFlipping:(nonnull WFTileView *)tileView {
	return false;
}

- (bool)hasInitalRotationForTileView:(WFTileView *)tileView {
	return true;
}

- (CGFloat)initalRotationAngleForTileView:(WFTileView *)tileView {
	return self.logoTileTransforms[tileView.tileID].floatValue;
}

#pragma mark -
#pragma mark WFTileViewDelegate

- (void)tileViewTouchBegan:(WFTileView *)tileView {
	[tileView.superview bringSubviewToFront:tileView];
	[MNSGame playTouchesBeganSound: [self typeTypeForTileView: tileView]];
}

@end
