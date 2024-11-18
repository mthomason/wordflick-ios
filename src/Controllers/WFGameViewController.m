//
//  WFGameViewController.m
//  wordPuzzle
//
//  Created by Michael Thomason on 5/29/09.
//  Copyright Michael Thomason 2023. All rights reserved.
//

#import "WFGameViewController.h"
#import "MNSUser.h"
#import "MNSGame.h"
#import "MNSAudio.h"
#import "WFGameView.h"
#import "MTGameBoard.h"
#import "DatabaseWords.h"
#import "WFIntroductionViewController.h"
#import "WFLevelStatistics.h"
#import "WFGoalView.h"
#import "WFTileView.h"
#import "WFToolBarView.h"
#import "WFTileData.h"
#import "MUIViewGameControlScreen.h"
#import "MUIViewControllerPauseScreen.h"
#import "MTScrabbleLetterEnumerator.h"
#import "MNSMessage.h"
#import "WFGlowLabelView.h"
#import "UIColor+Wordflick.h"
#import "Constants.h"
#import "WFMath_Extras.h"

#import "MTTileDataProtocol.h"

#import "MTDeviceHelper.h"

#ifndef WF_OFFSET_LENGTH
#define WF_OFFSET_LENGTH		400.0
#endif

#define square(x) ( (x) * (x) )

double const kCGFloatButtonFlipDuration = (2.0/3.0);	//0.66666666

static inline CGAffineTransform AffineTransformTileScatteredState(void);

static inline double CGInterceptBySlope(CGPoint, double);
static inline double CGSlope(CGPoint, CGPoint);
static inline double CGIntercept(double, CGPoint, CGPoint);
static inline double CGInterceptYIntercept(double, double, double);
static inline double CGInterceptSlope(double, double, double, double);

static inline CGAffineTransform AffineTransformTileInitalState(void);
static inline CGRect CGRectMakeRandomOffscreen(CGSize);
static inline CGPoint CGPointMakeRandomOffscreen(void);
static inline CGPoint CGPointOnLine(CGFloat, CGPoint, CGPoint);

static void disableButtonAnimated(UIButton *, bool);
static void viewDidLoadNeedsUpdatedLayoutConstraints(WFGameViewController *, UILayoutGuide *);
static void moveTileToOriginPoint(WFGameViewController *, BOOL, WFTileView *);
static UIColor *colorForModifierType(MNSTileType);
static UIColor *randomColor(void);
static void userSpelledWordCompleted(WFGameViewController *);

#pragma mark -
#pragma mark Static Inline

static inline CGAffineTransform AffineTransformTileScatteredState(void) {
	CGFloat loc = ((double)(uint32_t)arc4random_uniform(15)) / 3.0;
	return CGAffineTransformConcat(CGAffineTransformMakeRotation(((double)(arc4random_uniform(720)) - 360.0) * (M_PI / 180.0)),
								   CGAffineTransformMakeScale(loc, loc));
}

static inline double CGInterceptBySlope(CGPoint p2, double m) {
	return ( p2.y - (m * p2.x) );
}

static inline double CGSlope(CGPoint p1, CGPoint p2) {
	return ( ( p2.y - p1.y ) / ( p2.x - p1.x ) );
}

static inline double CGIntercept(double y, CGPoint p1, CGPoint p2) {
	//y = m x + b;
	double m = CGInterceptSlope(p2.y, p1.y, p2.x, p1.x);          // ( (p2.y - p1.y) / (p2.x - p1.x) );
	//double b = CGInterceptYIntercept(m, p1.x, p1.y);            // p1.y - ( m * p1.x )
	return (y - ( CGInterceptYIntercept(m, p1.x, p1.y) ) ) / ( m );
}

static inline double CGInterceptYIntercept(double m, double p1x, double p1y) {
	return ( p1y - ( m * p1x ) );
}

static inline double CGInterceptSlope(double p2y, double p1y, double p2x, double p1x) {
	return ( ( p2y - p1y ) / ( p2x - p1x ) );
}

static inline CGAffineTransform AffineTransformTileInitalState(void) {
	return CGAffineTransformConcat(CGAffineTransformMakeRotation(0.0),
								   CGAffineTransformMakeScale(1.0, 1.0));
}

static inline CGRect CGRectMakeRandomOffscreen(CGSize size) {
	switch (arc4random_uniform(4)) {
		case 0:
			return CGRectMake((double)arc4random_uniform(1024), 0.0 - WF_OFFSET_LENGTH, size.width, size.height);
			break;
		case 1:
			return CGRectMake(0.0 - WF_OFFSET_LENGTH, (double)arc4random_uniform(1024), size.width, size.height);
			break;
		case 2:
			return CGRectMake((double)arc4random_uniform(1024), 1024.0 + WF_OFFSET_LENGTH, size.width, size.height);
			break;
		case 3:
			return CGRectMake(1024.0 + WF_OFFSET_LENGTH, (double)arc4random_uniform(1024), size.width, size.height);
			break;
		default:
			return CGRectZero;
			break;
	}
}

static inline CGPoint CGPointMakeRandomOffscreen(void) {
	switch (arc4random_uniform(4)) {
		case 0:
			return CGPointMake((double)arc4random_uniform(1024), 0.0 - WF_OFFSET_LENGTH);
			break;
		case 1:
			return CGPointMake(0.0 - WF_OFFSET_LENGTH, (double)arc4random_uniform(1024));
			break;
		case 2:
			return CGPointMake((double)arc4random_uniform(1024), 1024.0 + WF_OFFSET_LENGTH);
			break;
		case 3:
			return CGPointMake(1024.0 + WF_OFFSET_LENGTH, (double)arc4random_uniform(1024));
			break;
		default:
			return CGPointZero;
			break;
	}
}

static inline CGPoint CGPointOnLine(CGFloat distanceFrom, CGPoint originalPoint, CGPoint withVelocity) {
	double slope = CGSlope(CGPointZero, withVelocity);
	double yIntercept = CGInterceptBySlope(originalPoint, slope);
	
	CGPoint p2 = CGPointZero;

	/*
	p2.x = (withVelocity.x < 0) ?
	(-sqrt(-1*square(yIntercept) -2*yIntercept*slope*originalPoint.x+2*yIntercept*originalPoint.y+square(distanceFrom)*square(slope)+square(distanceFrom)-square(slope)*square(originalPoint.x)+2*slope*originalPoint.x*originalPoint.y-square(originalPoint.y))-yIntercept*slope+slope*originalPoint.y+originalPoint.x)/(square(slope)+1)
	:
	(sqrt(-1*square(yIntercept) -2*yIntercept*slope*originalPoint.x+2*yIntercept*originalPoint.y+square(distanceFrom)*square(slope)+square(distanceFrom)-square(slope)*square(originalPoint.x)+2*slope*originalPoint.x*originalPoint.y-square(originalPoint.y))-yIntercept*slope+slope*originalPoint.y+originalPoint.x)/(square(slope)+1);
	 */
	double slopeSqr = square(slope);
	double distanceSqr = square(distanceFrom);
	p2.x = (withVelocity.x < 0) ?
				( -sqrt(
						-1.0 * square(yIntercept) -
							2.0 * yIntercept * slope*originalPoint.x +
							2.0 * yIntercept * originalPoint.y +
							distanceSqr * slopeSqr +
							distanceSqr -
							slopeSqr * square(originalPoint.x) +
							2.0 * slope * originalPoint.x * originalPoint.y -
							square(originalPoint.y)
						) -
				 yIntercept * slope +
					slope * originalPoint.y +
					originalPoint.x
				 )
	/ (slopeSqr + 1)
			  :
				(sqrt( -1.0 * square(yIntercept) -2.0 * yIntercept * slope * originalPoint.x + 2.0 * yIntercept *originalPoint.y + distanceSqr * slopeSqr + distanceSqr - slopeSqr * square(originalPoint.x) + 2.0 * slope * originalPoint.x * originalPoint.y - square(originalPoint.y) ) - yIntercept * slope + slope * originalPoint.y + originalPoint.x) / ( slopeSqr + 1.0);
	p2.y = slope * p2.x + yIntercept;
	return p2;
}

#pragma mark -
#pragma mark Static

static void removeTileView(WFGameViewController *controller, bool animated, WFTileView *tileView) {
	if (animated) {
		__strong WFTileView *t = tileView;

		CGRect b = CGRectMake(0.0, 0.0, t.bounds.size.width, t.bounds.size.height);
		CGPoint c = CGPointMakeRandomOffscreen();
		CGAffineTransform transf = AffineTransformTileScatteredState();
		[UIView animateWithDuration: 0.5
							  delay: 0.0
							options: UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
						 animations: ^{
			if (t != nil) {
				t.bounds = b;
				t.center = c;
				t.transform = transf;
			}
		} completion:^(BOOL finished) {
			if (finished) {
				[t removeMotionEffect: controller.tileMotionEffects];
				if (t.superview != nil) {
					[t removeFromSuperview];
				}
			}
		}];
		
	} else {
		[tileView removeMotionEffect: controller.tileMotionEffects];
		[tileView removeFromSuperview];
	}
}

static void setInGoalTileSizeForGoalHeight(double height, CGSize *inGoalSize) {
	inGoalSize->height = inGoalSize->width = height * (2.0 / 3.0);
}

__attribute__((unused))
static void disableButtonAnimated(UIButton *button, bool animated) {
	if (animated) {
		[UIView transitionWithView: button
						  duration: kCGFloatButtonFlipDuration
						   options: UIViewAnimationOptionTransitionFlipFromRight
						animations: ^{
							button.enabled = NO;
							[button setImage:nil forState:UIControlStateNormal];
						}
						completion: nil];
	} else {
		button.enabled = NO;
		[button setImage: nil forState: UIControlStateNormal];
	}
}

static void disableWFButtonAnimated(WFButton *v, bool animated) {
	if (animated) {
		
		[UIView transitionWithView: v
						  duration: kCGFloatButtonFlipDuration
						   options: UIViewAnimationOptionTransitionFlipFromRight
						animations: ^{
			//v.alpha = 0.0;
			v.button.enabled = NO;
			[v setNeedsDisplay];
						}
						completion: NULL];
	} else {
		v.button.enabled = NO;
	}
}

static void viewDidLoadNeedsUpdatedLayoutConstraints(WFGameViewController *object, UILayoutGuide *guide) {

	[NSLayoutConstraint deactivateConstraints: @[object.toolBarTopConstraint,
												 object.toolBarLeadingConstraint,
												 object.toolBarTrailingConstraint]];

	object.toolBarTopConstraint = [NSLayoutConstraint constraintWithItem: object.toolBarView
															   attribute: NSLayoutAttributeTop
															   relatedBy: NSLayoutRelationEqual
																  toItem: guide
															   attribute: NSLayoutAttributeTopMargin
															  multiplier: 1.0f
																constant: 0.0f];
	
	object.toolBarLeadingConstraint = [NSLayoutConstraint constraintWithItem: object.toolBarView
																   attribute: NSLayoutAttributeLeading
																   relatedBy: NSLayoutRelationEqual
																	  toItem: guide
																   attribute: NSLayoutAttributeLeading
																  multiplier: 1.0f
																	constant: 0.0f];
	
	
	object.toolBarTrailingConstraint = [NSLayoutConstraint constraintWithItem: object.toolBarView
																	attribute: NSLayoutAttributeTrailing
																	relatedBy: NSLayoutRelationEqual
																	   toItem: guide
																	attribute: NSLayoutAttributeTrailing
																   multiplier: 1.0f
																	 constant: 0.0f];
	
	[NSLayoutConstraint activateConstraints: @[object.toolBarTopConstraint,
											   object.toolBarLeadingConstraint,
											   object.toolBarTrailingConstraint]];
	
	object.toolBarTopConstraint.active = YES;
	object.toolBarLeadingConstraint.active = YES;
	object.toolBarTrailingConstraint.active = YES;
}

static void moveTileToOriginPoint(WFGameViewController *gameController, BOOL animated, WFTileView *tileView) {
	MNSGame *game = [MNSUser CurrentUser].game;
	
	MTGameBoard *gameBoardLayoutCurrent = [gameController gameBoardLayoutCurrent];
	__strong WFTileData *tileData =  game.gamePieceData[tileView.tileID];

	CGPoint initalPoint = [gameBoardLayoutCurrent gamePieceCenter: tileData.position];
	CGSize gamePiceSize;

	if ([game.gamePieceInGoalIndex containsObject: tileView.tileID]) {
		setInGoalTileSizeForGoalHeight(gameController.bottomGoal.bounds.size.height, &gamePiceSize);
	} else {
		gamePiceSize = gameBoardLayoutCurrent.tileSize;
	}
	

	if (animated) {

		const CGAffineTransform initalState = AffineTransformTileInitalState();
		tileView.transform = AffineTransformTileScatteredState();
		[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			tileView.transform = initalState;
			tileView.frame = CGRectMake(initalPoint.x, initalPoint.y, gamePiceSize.width, gamePiceSize.height);
		} completion: NULL];

	} else {

		tileView.transform = AffineTransformTileScatteredState();
		tileView.transform = AffineTransformTileInitalState();
		tileView.frame = CGRectMake(initalPoint.x, initalPoint.y, gamePiceSize.width, gamePiceSize.height);

	}
	tileData = nil;
}

static UIColor *colorForModifierType(MNSTileType type) {
	switch (type) {
		case MNSTileExtraNormal:
			return [UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:0.5f];
			break;
		case MNSTileExtraPoints:
			return [UIColor colorWithRed:(144.0f/255.0f) green:(238.0f/255.0f) blue:(144.0f/255.0f) alpha:0.5f];
			break;
		case MNSTileExtraShuffle:
			return [UIColor cottenCandyAlpha5];
			break;
		case MNSTileExtraSpecial:
			return [UIColor richElectricBlueAlpha5];
			break;
		case MNSTileExtraTime:
			return [UIColor psychedelicPurpleAlpha5];
			break;
		default:
			return [UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:0.5f];
			break;
	}
}

static UIColor *randomColor() {
	return [UIColor colorWithRed: RandomFractionalValue()
						   green: RandomFractionalValue()
							blue: RandomFractionalValue() alpha: 1.0f];
}

static void userSpelledWordCompleted(WFGameViewController *object) {
	[UIView animateWithDuration:0.3 animations:^{
		object.toolBarView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		object.flasherView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	}];
}

static void tileViewAnimatieFlip(UIViewAnimationTransition transition, WFTileView *tileView) {
	
	[UIView animateWithDuration:5.7 / 9.0 animations:^{
		[UIView setAnimationTransition:transition forView:tileView cache:YES];
		[tileView setNeedsDisplay];
	}];
	
	//[UIView beginAnimations: nil context: nil];
	//[UIView setAnimationDuration: 5.7 / 9.0 ];
	//[UIView setAnimationTransition: transition
	//					   forView: tileView
	//						 cache: YES];
	//[tileView setNeedsDisplay];
	//[UIView commitAnimations];
}


@interface WFGameViewController()
	<UIGestureRecognizerDelegate, WFTileViewDelegate, WFTileViewDataSource, MTTileDataProtocol> {
	CGRect _auxRect;
	CGPoint _auxPoint0; CGPoint _auxPoint1;
	bool _showedControlScreen;
}

//@property (nonatomic, retain) IBOutlet UIView *topGroupView;
@property (nonatomic, retain) IBOutlet UIImageView *wordflickLogo;

@property (nonatomic, retain) NSMutableArray <MNSMessage *> *messages;

@property (nonatomic, retain) NSMutableArray <WFTileView *> *tileViews;
@property (nonatomic, retain) NSMutableArray <WFTileView *> *tileViewsRemoved;

@property (nonatomic, retain) NSMutableDictionary <UITraitCollection *, MTGameBoard *> *gameBoardLayout;

@property (nonatomic, retain) IBOutlet NSLayoutConstraint *gameViewBottomConstraint;
@property (nonatomic, retain) IBOutlet NSLayoutConstraint *gameViewLeadingConstraint;
@property (nonatomic, retain) IBOutlet NSLayoutConstraint *gameViewTrailingConstraint;

- (void)displayMessage;

- (IBAction)buttonCheckDidTouchUpInside:(id)sender forEvent:(UIEvent*)event;
- (IBAction)buttonPauseDidTouchUpInside:(id)sender forEvent:(UIEvent*)event;
- (IBAction)buttonShuffleDidTouchUpInside:(id)sender forEvent:(UIEvent*)event;

@end

@implementation WFGameViewController

+ (UIMotionEffectGroup *)newMotionEffectGroup:(double)relativeValue {

	UIMotionEffectGroup *motionGroup = [[UIMotionEffectGroup alloc] init];

	UIInterpolatingMotionEffect *xAxis, *yAxis;
	xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath: @"center.x"
															type: UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
	xAxis.maximumRelativeValue = [NSNumber numberWithDouble: relativeValue];
	xAxis.minimumRelativeValue = [NSNumber numberWithDouble: -relativeValue];

	yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath: @"center.y"
															type: UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
	yAxis.maximumRelativeValue = [NSNumber numberWithDouble: relativeValue];
	yAxis.minimumRelativeValue = [NSNumber numberWithDouble: -relativeValue];

	motionGroup.motionEffects = @[xAxis, yAxis];

	//[xAxis release];
	//[yAxis release];

	return motionGroup;
}

#pragma mark -
#pragma mark NSObject

- (void)dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: UIApplicationWillResignActiveNotification
												  object: nil];

	[_wordflickLogo removeMotionEffect: _controlMotionEffects];
	[_buttonPause removeMotionEffect: _controlMotionEffects];

	[_checkButton removeMotionEffect: _controlMotionEffects];
	[_shuffleButton removeMotionEffect: _controlMotionEffects];
	[_pauseButton removeMotionEffect: _controlMotionEffects];

	[_controlScreenBackground removeMotionEffect: _controlMotionEffects];

	_controlMotionEffects = nil;
	_tileMotionEffects = nil;

	_messages = nil;
	_toolBarView = nil;
	_controlScreen = nil;
	_controlScreenBackground = nil;
	_buttonPause = nil;
	_checkButton = nil;
	_shuffleButton = nil;
	_pauseButton = nil;
	_flasherLabel = nil;
	_bottomGoal = nil;
	_gameBoardLayout = nil;
	_backgroundView = nil;
	_flasherLabelBackground = nil;
	_flasherView = nil;
	_wordflickLogo = nil;
	_gameView = nil;
	_gameViewBottomConstraint = nil;
	_gameViewTrailingConstraint = nil;
	_gameViewLeadingConstraint = nil;
	_toolBarTopConstraint = nil;
	_toolBarLeadingConstraint = nil;
	_toolBarTrailingConstraint = nil;
	
	//[super dealloc];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		_showedControlScreen = false;
		_gameBoardLayout = [[NSMutableDictionary alloc] initWithCapacity: 2];
		_messages = [[NSMutableArray alloc] init];
		_tileViews = [[NSMutableArray alloc] initWithCapacity: WF_TILE_COUNT];
		_tileViewsRemoved = [[NSMutableArray alloc] initWithCapacity: WF_TILE_COUNT];
		_controlMotionEffects = [WFGameViewController newMotionEffectGroup: 13.0];
		_tileMotionEffects = [WFGameViewController newMotionEffectGroup: 15.0];
	}
	return self;
}

/*
 - (void)encodeWithCoder:(nonnull NSCoder *)coder {
 <#code#>
 }
 */

#pragma mark -
#pragma mark UIResponder

- (BOOL)canBecomeFirstResponder { return YES; }

#pragma mark -
#pragma mark UIViewController

- (BOOL)prefersStatusBarHidden { return YES; }

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	if (@available(iOS 14.0, *)) {

		[self.shuffleButton.button addAction: [UIAction actionWithHandler:^(__kindof UIAction * _Nonnull action) {
			pressedShuffleButton();
		}]
							forControlEvents: UIControlEventTouchUpInside];

		[self.checkButton.button addAction: [UIAction actionWithHandler:^(__kindof UIAction * _Nonnull action) {
			pressedCheckButton();
		}]
						  forControlEvents: UIControlEventTouchUpInside];

		[self.pauseButton.button addAction: [UIAction actionWithHandler:^(__kindof UIAction * _Nonnull action) {
			pressedPauseButton();
		}]
						  forControlEvents: UIControlEventTouchUpInside];

	} else {

		[self.shuffleButton.button addTarget: self
									  action: @selector(buttonShuffleDidTouchUpInside:forEvent:)
							forControlEvents: UIControlEventTouchUpInside];

		[self.checkButton.button addTarget: self
									action: @selector(buttonCheckDidTouchUpInside:forEvent:)
						  forControlEvents: UIControlEventTouchUpInside];

		[self.pauseButton.button addTarget: self
									action: @selector(buttonPauseDidTouchUpInside:forEvent:)
						  forControlEvents: UIControlEventTouchUpInside];

	}

	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(applicationWillResignActive:)
												 name: UIApplicationWillResignActiveNotification
											   object: nil];

	self.backgroundView.backgroundColor = [UIColor purpleColor];
	self.backgroundView.alpha = 1.0;
	self.backgroundView.opaque = YES;
	
	[MNSUser CurrentUser].game.currentGameScreen = MUIGameScreenIntro;
	
	self.buttonPause.enabled = NO;
	
	self.checkButton.button.enabled = NO;
	self.shuffleButton.button.enabled = NO;
	self.pauseButton.button.enabled = NO;
	
	self.controlScreenBackground.alpha = 0.0;
	self.bottomGoal.tag = kMUIViewGameGoalBottomTag;
	
	[self.buttonPause setImage:nil forState:UIControlStateNormal];
	
	[self.wordflickLogo addMotionEffect: self.controlMotionEffects];
	[self.buttonPause addMotionEffect: self.controlMotionEffects];

	[self.checkButton addMotionEffect: self.controlMotionEffects];
	[self.shuffleButton addMotionEffect: self.controlMotionEffects];
	[self.pauseButton addMotionEffect: self.controlMotionEffects];

	[self.controlScreenBackground addMotionEffect: self.controlMotionEffects];
	
	self.toolBarView.backgroundColor = [UIColor blueColor];
	
	if (@available(iOS 11.0, *)) {
		viewDidLoadNeedsUpdatedLayoutConstraints(self, self.view.safeAreaLayoutGuide);
	} else {
		viewDidLoadNeedsUpdatedLayoutConstraints(self, self.view.layoutMarginsGuide);
	}
	
	[self.view setNeedsLayout];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self updateGameBoardBackground: [MNSUser CurrentUser].game];
	
	self.flasherLabel.fontSize = self.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPad ?
										48.0f : 18.0f;
	self.controlScreenBackground.alpha = 0.0f;
	self.bottomGoal.backgroundColor = [UIColor patternGradentCarbonFiber];
	self.controlScreen.displaying = NO;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	MNSGame *game = [MNSUser CurrentUser].game;
	if (game != nil && !game.gamePlayHasBegun) {
		[self showControlScreenBackground: YES animated: animated];
		[self game: game startNextLevel: animated ? true : false];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"segueGamePreLevelStats"]) {
		[segue.destinationViewController setDelegate: self];
		
	} else if ([segue.identifier isEqualToString:@"segueGamePostLevelStats"]) {
		[segue.destinationViewController setDelegate: self];
		
	} else if ([segue.identifier isEqualToString:@"segueGameOverStats"]) {
		[segue.destinationViewController setDelegate: self];
		
	} else if ([segue.identifier isEqualToString:@"seguePauseGameCustom"]) {
		MUIViewControllerPauseScreen *pauseViewController;
		pauseViewController = segue.destinationViewController;
		pauseViewController.delegate = self;
		
	} else if ([segue.identifier isEqualToString:@"segueGamePauseScreen"]) {
		NSAssert([segue.destinationViewController isKindOfClass:[UINavigationController class]],
				 @"Expect this to be a navigation controller.");
		UINavigationController *navcontroller = segue.destinationViewController;
		MUIViewControllerPauseScreen *pauseViewController;
		if (navcontroller) {
			pauseViewController = navcontroller.viewControllers.firstObject;
			pauseViewController.delegate = self;
		}
	}
	[MNSAudio playShelfHide];
}

#pragma mark -
#pragma mark Notification Handlers

- (void)applicationWillResignActive:(NSNotification *)notification {
	[self buttonPauseDidTouchUpInside: nil];
	[[MNSUser CurrentUser] saveYourGame];
}

#pragma mark -
#pragma mark Actions

- (void)displayMessage {
	if (self.flasherLabel.messageIsDisplaying || self.messages.count <= 0) return;
	
	if ([self.flasherLabel displayMessage:self.messages.firstObject completion:^(BOOL finished) {
		if (finished) { [self displayMessage]; }
	}]) {
		[self.messages removeObjectAtIndex:0];
	}
}
- (void)game:(MNSGame *)game displayMessage:(MNSMessage *)message {
	[self.messages addObject:message];
	[self displayMessage];
}

- (MTGameBoard *)gameBoardLayoutCurrent {
	return [self gameBoardLayout: self.gameView.traitCollection];
}

- (MTGameBoard *)gameBoardLayout:(UITraitCollection *)traitCollection {
	MTGameBoard *gameBoard = [self.gameBoardLayout objectForKey:traitCollection];
	if (gameBoard == nil) {
		CGRect gvB = self.gameView.bounds;
		CGRect bgB = self.bottomGoal.bounds;
		
		//NSLog(@"Game view (frame): %@", NSStringFromCGRect(self.gameView.frame));
		//NSLog(@"Game view (bounds): %@", NSStringFromCGRect(gvB));
		//NSLog(@"Play view (bounds): %@", NSStringFromCGRect(CGRectMake(CGPointZero.x, CGPointZero.y, self.gameView.frame.size.width, self.gameView.frame.size.height - (self.backgroundViewFlasher.bounds.size.height + self.bottomGoal.bounds.size.height))));
		//NSLog(@"Play view (bounds): %@", NSStringFromCGRect(CGRectMake(CGPointZero.x, CGPointZero.y, self.gameView.frame.size.width, self.gameView.frame.size.height - (self.backgroundViewFlasher.bounds.size.height + self.bottomGoal.bounds.size.height))));
		//NSLog(@"EdgeInserts 1: %@", NSStringFromUIEdgeInsets(self.view.safeAreaInsets));
		//NSLog(@"EdgeInserts 2: %@", NSStringFromUIEdgeInsets(self.view.layoutMargins));
		
		MTGameBoard *gameBoardNew = [[MTGameBoard alloc] initWithBounds: CGRectMake(0.0, 0.0,
																					gvB.size.width,
																					gvB.size.height - (self.flasherLabel.bounds.size.height + 10.0 + bgB.size.height + self.bottomGoal.layoutMargins.bottom))
													 userInterfaceIdiom: traitCollection.userInterfaceIdiom
													  verticalSizeClass: traitCollection.verticalSizeClass
													horizontalSizeClass: traitCollection.horizontalSizeClass];
		
		[self.gameBoardLayout setObject:gameBoardNew forKey:traitCollection];
		gameBoard = gameBoardNew;

	}
	return gameBoard;
	
}

- (void)clearTiles:(MNSGame *)game animated:(bool)animated {
	/*
	 for (MNSTile *gameTileInGoal in game.gamePiecesInGoal) {
	 MUIViewGameTile <MTTileDataProtocol> *gameTileViewInGoal = gameTileInGoal.delegate;
	 for (__kindof UIGestureRecognizer *gestureRecognizer in gameTileViewInGoal.gestureRecognizers) {
	 [gameTileViewInGoal removeGestureRecognizer: gestureRecognizer];
	 }
	 gameTileInGoal.delegate = nil;
	 gameTileViewInGoal.delegate = nil;
	 gameTileViewInGoal = nil;
	 }
	 for (MNSTile *gameTile in game.gamePieces) {
	 MUIViewGameTile <MTTileDataProtocol> *gameTileView = gameTile.delegate;
	 for (__kindof UIGestureRecognizer *gestureRecognizer in gameTileView.gestureRecognizers) {
	 [gameTileView removeGestureRecognizer: gestureRecognizer];
	 }
	 gameTile.delegate = nil;
	 gameTileView = nil;
	 gameTileView.delegate = nil;
	 }
	 */

	[self.tileViews removeAllObjects];
	[self.tileViewsRemoved removeAllObjects];

	for (NSNumber *tileID in game.gamePieceData) {
		WFTileData *tileData = game.gamePieceData[tileID];
		[tileData invalidate];
	}

	[game.gamePieceData removeAllObjects];
	[game.gamePieceIndex removeAllObjects];
	[game.gamePieceInGoalIndex removeAllObjects];
}

- (void)dealTiles:(NSUInteger)count forGame:(MNSGame *)game animated:(BOOL)animated {
	
	NSUInteger idx = 0;
	MTGameBoard *gameBoard = [self gameBoardLayoutCurrent];
	MTScrabbleLetterEnumerator *scrabbleLetters = [[MTScrabbleLetterEnumerator alloc] initWithCapacity:count];

	//NSMutableArray<MNSTile *> *gameTiles = [[NSMutableArray alloc] initWithCapacity: count];

	CGSize tileSize = [self gameBoardLayoutCurrent].tileSize;
	
	int64_t levelNumber = game.gameLevel.levelNumber;
	int64_t levelTime = game.gameLevel.levelTime;

	for (NSNumber *letter in scrabbleLetters) {
		
		WFTileData *tileData = [[WFTileData alloc] initWithCharacter: letter.charValue
													  position: idx
												   levelNumber: levelNumber
													 levelTime: levelTime
											  andRemainingTime: game.remainingTime];
		
		WFTileView *tileView = [[WFTileView alloc] initWithFrame: CGRectMakeRandomOffscreen(tileSize)
															tile: tileData];

		tileView.autoresizingMask = UIViewAutoresizingNone;
		tileView.delegate = self;
		tileView.dataSource = self;
		tileData.delegate = self;
		
		UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget: self
																					 action: @selector(panPiece:)];
		panGesture.maximumNumberOfTouches = 1;
		panGesture.minimumNumberOfTouches = 1;

		[tileView addGestureRecognizer:panGesture];

		if (tileView.motionEffects.count == 0) {
			[tileView addMotionEffect: self.tileMotionEffects];
		}
		
		CGPoint center = [gameBoard gamePieceCenter: idx];
		
		tileView.transform = animated ? AffineTransformTileScatteredState() : AffineTransformTileInitalState();
		
		if (!animated) {
			tileView.bounds = CGRectMake(0.0, 0.0, tileView.bounds.size.width, tileView.bounds.size.height);
			tileView.center = center;
		}

		[self.gameView addSubview: tileView];
		
		if (animated) {
			[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
				tileView.bounds = CGRectMake(0.0, 0.0,
											 tileView.bounds.size.width, tileView.bounds.size.height);
				tileView.center = center;
				tileView.transform = AffineTransformTileInitalState();
			} completion:^(BOOL finished) {
				//if (finished) {
				//    [tileView setNeedsDisplay];
				//}
			}];
		}
		
		self.tileViews[idx] = tileView;

		game.gamePieceData[@(idx)] = tileData;
		game.gamePieceIndex[idx] = @(idx);
		
		//[gameTiles addObject:tileData];
		//[tileViews addObject:tileView];
		//[tileData release];
		//[tileView release];
		//[panGesture release];
		idx++;
	}
	//[self.tileViews setObject: atIndexedSubscript:]
	//game.gamePieces = gameTiles;
	
	//[timer release];
	//[gameTiles release];
	//[tileViews release];
	//[motionGroup release];
	//[scrabbleLetters release];
}

- (void)game:(MNSGame *)game startNextLevel:(bool)animated {
	[game startNextLevel];
	[self game: game removeAllTilesFromScreen: animated];
	
	
	[self clearTiles:  game animated: animated];
	[self dealTiles: WF_TILE_COUNT forGame: game animated: animated];
	[self game: game enablePauseButton: animated];
	[self game: game enableCheckButton: animated];
	[self showControlScreenBackground: YES animated: animated];
	[self updateGameBoardBackground: game];
	[self updateControlScreen: game];
}

#pragma mark - IB Actions

static void pressedCheckButton() {
	[[MNSUser CurrentUser].game pressedCheckButton];
}
static void pressedShuffleButton() {
	[[MNSUser CurrentUser].game pressedShuffleButton];
}
static void pressedPauseButton() {
	[MNSAudio playButtonPress];
	[[MNSUser CurrentUser].game pressedPauseButton];
}

- (IBAction)buttonCheckDidTouchUpInside:(id)sender {
	pressedCheckButton();
}

- (IBAction)buttonPauseDidTouchUpInside:(id)sender {
	pressedPauseButton();
}

- (IBAction)buttonShuffleDidTouchUpInside:(id)sender {
	pressedShuffleButton();
}

- (IBAction)buttonCheckDidTouchUpInside:(id)sender forEvent:(UIEvent*)event {
	pressedCheckButton();
}

- (IBAction)buttonPauseDidTouchUpInside:(id)sender forEvent:(UIEvent*)event {
	pressedPauseButton();
}

- (IBAction)buttonShuffleDidTouchUpInside:(id)sender forEvent:(UIEvent*)event {
	pressedShuffleButton();
}

#pragma mark -
#pragma mark Delegates

#pragma mark - MUI View Controller Level Stats Delegate

- (void)viewControllerPreLevelIsDone:(id)sender {
	disableWFButtonAnimated(self.checkButton, true);
	[self dismissViewControllerAnimated:YES completion:^{
		[self becomeFirstResponder];
		[self showControlScreenBackground: YES animated: YES];
		[self game: [MNSUser CurrentUser].game startNextLevel: true];
	}];
}

- (void)viewControllerPostLevelIsDone:(id)sender {
	[self dismissViewControllerAnimated:YES completion:^{
		[[MNSUser CurrentUser].game postLevelIsDone];
	}];
}

- (void)viewControllerGameOverIsDone:(id)sender {
	disableWFButtonAnimated(self.checkButton, true);
	[self dismissViewControllerAnimated:YES completion:^{
		[self.delegate gameIsOver: self];
	}];
}

#pragma mark - Game Delegate

- (void)game:(MNSGame *)game didPressPauseButton:(id)context {
	[self showControlScreenBackground: NO animated: YES];
	[self updateControlScreen: game];
	[self presentPauseScreenWithAnimation: YES];
}

- (void)game:(MNSGame *)game showPreLevelScreen:(NSString *)identifier {
	[self performSegueWithIdentifier:@"segueGamePreLevelStats" sender:self];
}

- (void)game:(MNSGame *)game showPostLevelScreen:(NSString *)identifier {
	[self performSegueWithIdentifier:@"segueGamePostLevelStats" sender:self];
}

- (void)game:(MNSGame *)game showGameOverScreen:(NSString *)identifier {
	[self performSegueWithIdentifier:@"segueGameOverStats" sender:self];
}

- (void)gameDidEnd:(MNSGame *)sender {
	[self performSegueWithIdentifier:@"segueGameOverStats" sender:self];
}

- (void)levelDidEnd:(MNSGame *)sender {
	[self performSegueWithIdentifier:@"segueGamePostLevelStats" sender:self];   //Send the level numer
}

- (void)game:(MNSGame *)game didPressShuffleButton:(id)context {
	self.buttonRefresh.enabled = NO;
	self.shuffleButton.button.enabled = NO;
	[NSTimer scheduledTimerWithTimeInterval:0.7 repeats:NO block:^(NSTimer * _Nonnull timer) {
		self.buttonRefresh.enabled = YES;
		self.shuffleButton.button.enabled = YES;
	}];
	[self dealTiles: WF_TILE_COUNT forGame: game animated: YES];
}

- (void)animatePlayFailed:(MNSGame *)game {
	UIColor *toolBarBackgroundColor = [UIColor colorWithRed: 1.0 green: 0.0
													   blue: 0.0 alpha: 0.5];
	UIColor *flasherViewBackgroundColor = [toolBarBackgroundColor copyWithZone: nil];
	[UIView animateWithDuration: 0.3 delay: 0.0
						options: UIViewAnimationOptionTransitionNone animations: ^{
		self.toolBarView.backgroundColor = toolBarBackgroundColor;
		self.flasherView.backgroundColor = flasherViewBackgroundColor;
	} completion: ^(BOOL finished) {
		if (finished) {
			userSpelledWordCompleted(self);
		}
	}];
}

- (void)animatePlaySucceeded:(MNSGame *)game withBonusModifier:(MNSTileType)typeTypeModifier {
	UIColor *toolBarBackgroundColor = colorForModifierType(typeTypeModifier);
	UIColor *flasherViewBackgroundColor = [toolBarBackgroundColor copyWithZone: nil];
	[UIView animateWithDuration: 0.3 delay: 0.0
						options: UIViewAnimationOptionTransitionNone animations: ^{
		self.toolBarView.backgroundColor = toolBarBackgroundColor;
		self.flasherView.backgroundColor = flasherViewBackgroundColor;
	} completion:^(BOOL finished) {
		if (finished) {
			userSpelledWordCompleted(self);
		}
	}];
}

- (void)flashIndicatorsToColor:(UIColor *)toColor forDuration:(NSTimeInterval)interval {
	[UIView animateWithDuration: interval
						  delay: 0.0
						options: UIViewAnimationOptionTransitionNone animations:^{
		self.toolBarView.backgroundColor = toColor;
		self.flasherView.backgroundColor = toColor;
	} completion:^(BOOL finished) {
		if (finished) {
			[self flashIndicatorsFromColor:interval];
		}
	}];
}

- (void)flashIndicatorsFromColor:(NSTimeInterval)interval {
	[UIView animateWithDuration: interval animations: ^{
		self.toolBarView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		self.flasherView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	}];
}

- (void)game:(MNSGame *)game removeAllTilesFromScreen:(bool)animated {
	NSMutableDictionary <NSNumber *, WFTileData *> *gamePieceData = game.gamePieceData;

	for (NSNumber *tileID in game.gamePieceIndex) {
		WFTileData *tileData = gamePieceData[tileID];
		WFTileView *tileView = _tileViews[tileData.position];
		[tileData invalidate];
		removeTileView(self, animated, tileView);
		tileView.removed = YES;
		
		gamePieceData[tileView.tileID] = tileData;
		
		tileData = nil;
	}

	/*for (NSNumber *tileID in gamePieceData) {
		tileData = gamePieceData[tileID];
		WFTileView *tileView = _tileViews[tileData.position];
		removeTileView(self, animated, _tileViews[tileData.position]);
		[tileData invalidate];
		tileData = nil;
	}*/
	
	game = nil;
	[self.tileViewsRemoved setArray: self.tileViews];
	[self.tileViews removeAllObjects];
	//NSLog(@"%@", self.tileViewsRemoved);
}

- (void)game:(MNSGame *)game removeGameTile:(WFTileData *)tile animated:(bool)animated {
	WFTileView *tileView = self.tileViews[tile.position];
	removeTileView(self, animated, tileView);
	[tile invalidate];
}

- (void)updateGameBoardBackground:(MNSGame *)game {
	UIColor *color = game.gameLevel.backgroundColor;
	if (color == nil) {
		color = randomColor();
	}
	
	UIView * _Nullable gameboardView = self.backgroundView.subviews.firstObject;
	
	if (gameboardView != nil) {
		[UIView animateWithDuration:0.3 animations:^{
			gameboardView.backgroundColor = color;
			self.gameView.backgroundColor = color;
		}];
	}
}

- (void)updateControlScreen:(MNSGame *)game {
	switch (lround(game.remainingTime)) {
		case 10:
			//case  9:
		case  8:
			//case  7:
		case  6:
			[self flashIndicatorsToColor: [UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:0.5]
							 forDuration: ([MNSGame standardTick]  / 2.0)];
			break;
		case  5:
		case  4:
		case  3:
		case  2:
		case  1:
			[self flashIndicatorsToColor: [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5]
							 forDuration: ([MNSGame standardTick]  / 2.0)];
			break;
		default:
			break;
	}
	
	[self.controlScreen setNeedsDisplay];
}

- (void)showControlScreenBackground:(BOOL)show animated:(BOOL)animated {
	if (show) {
		if (_showedControlScreen) return;
		_showedControlScreen = true;
		if (animated) {
			self.controlScreenBackground.alpha = 0.0;
			[UIView animateWithDuration: kCGFloatButtonFlipDuration
								  delay: 0.0
								options: 0
							 animations: ^{
								 self.controlScreenBackground.alpha = 1.0;
							 } completion:^(BOOL finished) {
								 self.controlScreen.displaying = YES;
							 }];
		} else {
			self.controlScreenBackground.alpha = 1.0;
		}
	} else {
		if (!_showedControlScreen) return;
		_showedControlScreen = false;
		if (animated) {
			//self.controlScreen.displaying = NO;
			self.controlScreenBackground.alpha = 1.0;
			[UIView animateWithDuration: kCGFloatButtonFlipDuration
								  delay: 0.0
								options: 0
							 animations: ^{
								 self.controlScreenBackground.alpha = 0.0;
							 } completion:^(BOOL finished) {
								 self.controlScreen.displaying = NO;
							 }];
		} else {
			self.controlScreen.displaying = NO;
			self.controlScreenBackground.alpha = 0.0;
		}
	}
}

- (void)game:(MNSGame *)game enablePauseButton:(bool)animated {

/*
	[self.buttonPause setEnabled: YES];
	[UIView transitionWithView: self.buttonPause
					  duration: kCGFloatButtonFlipDuration
					   options: UIViewAnimationOptionTransitionFlipFromRight
					animations: ^{
						[self.buttonPause setImage: [UIImage imageNamed:@"MUIImageButtonPause"]
										  forState: UIControlStateNormal];
					} completion: NULL];
*/

	self.pauseButton.button.enabled = YES;
	[UIView transitionWithView: self.pauseButton
					  duration: kCGFloatButtonFlipDuration
					   options: UIViewAnimationOptionTransitionFlipFromRight
					animations: ^{
		[self.pauseButton setNeedsDisplay];
					} completion: NULL];

}

- (void)game:(MNSGame *)game enableCheckButton:(bool)animated {

/*
	 self.checkButton.button.enabled = YES;
	[UIView transitionWithView: self.buttonCheck
					  duration: kCGFloatButtonFlipDuration
					   options: UIViewAnimationOptionTransitionFlipFromRight
					animations: ^{
						[self.buttonCheck setImage: [UIImage imageNamed:@"MUIButtonCheck"]
										  forState: UIControlStateNormal];
					} completion: NULL];
*/

	self.checkButton.button.enabled = YES;
	[UIView transitionWithView: self.checkButton
					  duration: kCGFloatButtonFlipDuration
					   options: UIViewAnimationOptionTransitionFlipFromRight
					animations: ^{
		[self.checkButton setNeedsDisplay];
					} completion: NULL];

}

- (void)game:(MNSGame *)game enableShuffleButton:(bool)animated {
	//self.buttonRefresh.enabled = YES;
	//self.shuffleButton.button.enabled = YES;
	self.shuffleButton.button.enabled = YES;
	//NSInteger shuffleCount = game.numberOfShakes;
	/*
	NSString *imageName = nil;
	if (shuffleCount > 1) {
		imageName = @"UIButtonShuffleBlue";
	} else if (shuffleCount == 1) {
		imageName = @"UIButtonShuffleYellow";
	} else {
		imageName = @"UIButtonShuffleRed";
	}
	*/
	if (animated) {
		[UIView animateWithDuration:kCGFloatButtonFlipDuration animations:^{
			[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
								   forView:self.shuffleButton cache:YES];
			[self.shuffleButton setNeedsDisplay];
		}];
		
		//[UIView transitionWithView: self.shuffleButton
		//				  duration: kCGFloatButtonFlipDuration
		//				   options: UIViewAnimationOptionTransitionFlipFromRight
		//				animations: ^{
			//self.shuffleButton.alpha = 1.0;
			//[self.shuffleButton setNeedsDisplay];
		//} completion:^(BOOL finished) {
		//}];
	}

	//[UIView transitionWithView: self.buttonRefresh
	//				  duration: kCGFloatButtonFlipDuration
	//				   options: UIViewAnimationOptionTransitionFlipFromRight
	//				animations: ^{
	//					[self.buttonRefresh setImage: [UIImage imageNamed:imageName]
	//										forState: UIControlStateNormal];
	//				} completion: NULL];
}

- (void)game:(MNSGame *)game didDisablePauseButtonAnimated:(bool)animated {
	disableWFButtonAnimated(self.pauseButton, animated);
}

- (void)game:(MNSGame *)game didDisableCheckButtonAnimated:(bool)animated {
	disableWFButtonAnimated(self.checkButton, animated);
}

- (void)game:(MNSGame *)game didDisableShuffleButtonAnimated:(bool)animated {
	disableWFButtonAnimated(self.shuffleButton, animated);
}

- (void)presentPauseScreenWithAnimation:(BOOL)animated {
	disableWFButtonAnimated(self.pauseButton, animated ? true : false);
	disableWFButtonAnimated(self.shuffleButton, animated ? true : false);
	disableWFButtonAnimated(self.checkButton, animated ? true : false);
	
	if (animated) {
		for (WFTileView *tileView in self.tileViews) {
			[UIView animateWithDuration: 0.5
								  delay: 0.0
								options: UIViewAnimationOptionCurveEaseIn animations:^{
				[self.gameView layoutIfNeeded];
			} completion:^(BOOL finished) {
				if (finished) {
					[tileView removeFromSuperview];
				}
			}];
		}
	} else {
		for (WFTileView *tileView in self.tileViews) {
			[tileView removeFromSuperview];
		}
	}
	
	if (animated) {
		[NSTimer scheduledTimerWithTimeInterval: 0.5
										 target: self
									   selector: @selector(timerPerformSegueWithIdentifierPause:)
									   userInfo: nil
										repeats: NO];
	}
}

- (void)timerPerformSegueWithIdentifierPause:(NSTimer *)timer {
	[self performSegueWithIdentifierSegueGamePauseScreen];
}

- (void)performSegueWithIdentifierSegueGamePauseScreen {
	[self performSegueWithIdentifier: @"seguePauseGameCustom" sender: self];
}

- (void)game:(MNSGame *)game dismissPauseScreen:(bool)animated {
	[self showControlScreenBackground: YES animated: animated ? YES : NO];
	[self updateControlScreen: game];
	if ([self presentedViewController] != nil) {
		[self dismissViewControllerAnimated: NO completion: nil];
	}
	self.gameView.positionTilesOffscreen = NO;
	[self restoreGameTiles: game];
	
	
	[self game: game alignGoalTiles: true];
	[self game: game enablePauseButton: true];
	[self game: game enableShuffleButton: true];
	[self game: game enableCheckButton: true];
}

- (void)restoreGameTiles:(MNSGame *)game {
	//NSMutableDictionary <NSNumber *, MNSTile *> *gamePieceData;
	CGSize tileSize = [self gameBoardLayoutCurrent].tileSize;
	for (WFTileView *tileView in self.tileViews) {
		tileView.frame = CGRectMakeRandomOffscreen(tileSize);
		tileView.removed = false;
		[self.gameView addSubview:tileView];
		[tileView setNeedsDisplay];
		
		if ([game.gamePieceInGoalIndex containsObject: tileView.tileID]) {
			setInGoalTileSizeForGoalHeight(self.bottomGoal.bounds.size.height, &tileSize);
			CGRect rectBounds = CGRectMake(tileView.bounds.origin.x, tileView.bounds.origin.y, tileSize.width, tileSize.height);
			CGPoint center = tileView.center;
			[UIView animateWithDuration:0.4 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
				tileView.bounds = rectBounds;
				tileView.center = center;
			} completion:^(BOOL finished) {
				if (finished) {
					[tileView setNeedsDisplay];
				}
			}];
		} else {
			moveTileToOriginPoint(self, YES, tileView);
		}
		
	}
	/*for (NSNumber *tileID in game.gamePieceData) {
		MNSTile *tile = game.gamePieceData[tileID];
		WFTileView *tileView = [[WFTileView alloc] initWithFrame: CGRectMakeRandomOffscreen(tileSize)
															tile: tile];
		
		UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget: self
																					 action: @selector(panPiece:)];
		panGesture.maximumNumberOfTouches = 1;
		panGesture.minimumNumberOfTouches = 1;
		//panGesture.delegate = delegate;
		[tileView addGestureRecognizer:panGesture];
		//[panGesture release];
		
		tileView.autoresizingMask = UIViewAutoresizingNone;
		//tileView.containerView = self.gameView;
		[self addTileToView:tileView animated:YES];
		
		if ([game.gamePieceInGoalIndex containsObject: tileID]) {
			setInGoalTileSizeForGoalHeight(self.bottomGoal.bounds.size.height, &tileSize);
			CGRect rectBounds = CGRectMake(tileView.bounds.origin.x, tileView.bounds.origin.y, tileSize.width, tileSize.height);
			CGPoint center = tileView.center;
			[UIView animateWithDuration:0.4 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
				tileView.bounds = rectBounds;
				tileView.center = center;
			} completion:^(BOOL finished) {
				if (finished) {
					[tileView setNeedsDisplay];
				}
			}];
		} else {
			//CGRect rectBounds = CGRectMake(tileView.bounds.origin.x, tileView.bounds.origin.y, tileSize.width, tileSize.height);
			//CGPoint center = tileView.center;
			//[UIView animateWithDuration:0.4 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
			//	tileView.bounds = rectBounds;
			//	tileView.center = center;
			//} completion:^(BOOL finished) {
			//	if (finished) {
			//		[tileView setNeedsDisplay];
			//	}
			//}];
		}

	}*/
}


- (void)addGameTiles:(MNSGame *)game {
	//NSMutableDictionary <NSNumber *, MNSTile *> *gamePieceData;
	
	CGSize tileSize = [self gameBoardLayoutCurrent].tileSize;
	for (NSNumber *tileID in game.gamePieceData) {
		WFTileData *tile = game.gamePieceData[tileID];
		WFTileView *tileView = [[WFTileView alloc] initWithFrame: CGRectMakeRandomOffscreen(tileSize)
															tile: tile];
		
		UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget: self
																					 action: @selector(panPiece:)];
		panGesture.maximumNumberOfTouches = 1;
		panGesture.minimumNumberOfTouches = 1;
		//panGesture.delegate = delegate;
		[tileView addGestureRecognizer:panGesture];
		//[panGesture release];
		
		tileView.autoresizingMask = UIViewAutoresizingNone;
		//tileView.containerView = self.gameView;
		[self addTileToView:tileView animated:YES];
		
		if ([game.gamePieceInGoalIndex containsObject: tileID]) {
			setInGoalTileSizeForGoalHeight(self.bottomGoal.bounds.size.height, &tileSize);
			CGRect rectBounds = CGRectMake(tileView.bounds.origin.x, tileView.bounds.origin.y, tileSize.width, tileSize.height);
			CGPoint center = tileView.center;
			[UIView animateWithDuration:0.4 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
				tileView.bounds = rectBounds;
				tileView.center = center;
			} completion:^(BOOL finished) {
				if (finished) {
					[tileView setNeedsDisplay];
				}
			}];
		} else {
			//CGRect rectBounds = CGRectMake(tileView.bounds.origin.x, tileView.bounds.origin.y, tileSize.width, tileSize.height);
			//CGPoint center = tileView.center;
			//[UIView animateWithDuration:0.4 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
			//	tileView.bounds = rectBounds;
			//	tileView.center = center;
			//} completion:^(BOOL finished) {
			//	if (finished) {
			//		[tileView setNeedsDisplay];
			//	}
			//}];
		}

	}
}

- (void)addTileToView:(WFTileView *)tile animated:(BOOL)animated {
	tile.delegate = self;
	if (tile.motionEffects.count == 0) {
		UIMotionEffectGroup *motionGroup = [WFGameViewController newMotionEffectGroup: 15.0];
		[tile addMotionEffect:motionGroup];
	}
	[self.gameView addSubview: tile];
	moveTileToOriginPoint(self, animated, tile);
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

#pragma mark Clean Up

- (BOOL)shouldAutorotate {
	return YES;
}

/*- (void)viewWillLayoutSubviews {
 UIApplication *sharedApp = [UIApplication sharedApplication];
 UIInterfaceOrientation sharedAppInterfaceOrientation = [sharedApp statusBarOrientation];
 if ([self lastInterfaceOrientation] != sharedAppInterfaceOrientation) {
 [self setLastInterfaceOrientation: sharedAppInterfaceOrientation];
 if (![[[[MNSUser CurrentUser] game] timer] isPaused]) {
 NSTimeInterval duration = 0.3000f;
 for (UIView *subview in [[self view] subviews]) {
 if ([subview isKindOfClass:[MUIViewGameTile class]]) {
 MUIViewGameTile *tv = [[(MUIViewGameTile *)subview retain] autorelease];
 __block CGPoint cb = UIInterfaceOrientationIsPortrait(sharedAppInterfaceOrientation) ? [[tv tileData] originalPointCenter] : [[tv tileData] originalPointCenterLandscape];
 CGSize sb;
 switch ([[tv tileData] tileSizeType]) {
 case MNSTileSizeLarge:
 sb = [[tv tileData] largeSize];
 break;
 case MNSTileSizeMedium:
 sb = [[tv tileData] originalSize];
 break;
 case MNSTileSizeSmall:
 sb = [[tv tileData] smallSize];
 break;
 default:
 sb = [[tv tileData] originalSize];
 break;
 }
 __block BOOL ingoal = ![[tv tileData] inPlay];
 if (ingoal) {
 sb = [[tv tileData] smallSize];
 }
 __block CGRect rb = CGRectMake(tv.bounds.origin.x, tv.bounds.origin.y, sb.width, sb.height);
 [UIView animateWithDuration: duration
 delay: 0.0000f
 options: UIViewAnimationCurveEaseOut animations:^{
 [tv setBounds: rb];
 if (!ingoal) {
 [tv setCenter: cb];
 }
 } completion:^(BOOL finished) {
 [tv setNeedsDisplay];
 }];
 }
 }
 
 [NSTimer scheduledTimerWithTimeInterval: duration + 0.1000f
 target: self
 selector: @selector(alignGoalTiles)
 userInfo: self
 repeats: NO];
 }
 }
 }
 
 - (void)viewDidLayoutSubviews {
 [super viewDidLayoutSubviews];
 if ([self wallpaperView] != nil) {
 [[self wallpaperView] setNeedsDisplay];
 if ([[[self wallpaperView] subviews] count] >= 1) {
 [[[[self wallpaperView] subviews] objectAtIndex:0] setNeedsDisplay];
 }
 }
 [self alignGameTiles:[[MNSUser CurrentUser] game]];
 }
 
 - (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
 [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
 }
 
 - (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
 [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
 if (![[[[MNSUser CurrentUser] game] timer] isPaused]) {
 UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
 NSTimeInterval duration = 0.3000f;
 for (UIView *subview in [[self view] subviews]) {
 if ([subview isKindOfClass:[MUIViewGameTile class]]) {
 MUIViewGameTile *tv = [[(MUIViewGameTile *)subview retain] autorelease];
 __block CGPoint cb = UIInterfaceOrientationIsPortrait(orientation) ? [[tv tileData] originalPointCenter] : [[tv tileData] originalPointCenterLandscape];
 CGSize sb;
 switch ([[tv tileData] tileSizeType]) {
 case MNSTileSizeLarge:
 sb = [[tv tileData] largeSize];
 break;
 case MNSTileSizeMedium:
 sb = [[tv tileData] originalSize];
 break;
 case MNSTileSizeSmall:
 sb = [[tv tileData] smallSize];
 break;
 default:
 sb = [[tv tileData] originalSize];
 break;
 }
 __block BOOL ingoal = ![[tv tileData] inPlay];
 if (ingoal) {
 sb = [[tv tileData] smallSize];
 }
 __block CGRect rb = CGRectMake(tv.bounds.origin.x, tv.bounds.origin.y, sb.width, sb.height);
 [UIView animateWithDuration: duration
 delay: 0.0000f
 options: UIViewAnimationCurveEaseOut animations:^{
 [tv setBounds: rb];
 if (!ingoal) {
 [tv setCenter: cb];
 }
 } completion:^(BOOL finished) {
 [tv setNeedsDisplay];
 }];
 }
 }
 
 [NSTimer scheduledTimerWithTimeInterval: duration + 0.1000f
 target: self
 selector: @selector(alignGoalTiles)
 userInfo: self
 repeats: NO];
 }
 } */

/*
 
 - (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
 MTGameBoard *currentLayout = [self gameBoardLayout:newCollection];
 
 MNSGame *game = [MNSUser CurrentUser].game;
 
 NSMutableSet <MNSTile *> *gamePieces = [NSMutableSet setWithArray:game.gamePieces];
 [gamePieces minusSet:[NSSet setWithArray:game.gamePiecesInGoal]];
 
 
 //NSUInteger totalGamePiceces = [MNSUser CurrentUser].game.gamePieces.count;
 //NSUInteger totalGoalPieces = [MNSUser CurrentUser].game.gamePiecesInGoal.count;
 CGSize size = currentLayout.tileSize;
 //size = [gamePieces containsObject:gameTile.tileData] ? [MTGameBoard tileSizeInGoalForGoalHeight:self.bottomGoal.bounds.size.height] :
 //gameBoard.tileSize;
 
 
 [self.gameView setNeedsLayout];
 [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
 
 NSLog(@"  animateAlongsideTransition");
 UIViewController *fromViewController = [context viewControllerForKey: UITransitionContextFromViewControllerKey];
 UIViewController *toViewController = [context viewControllerForKey: UITransitionContextToViewControllerKey];
 UIView *fromView = [context viewForKey: UITransitionContextFromViewKey];
 UIView *toView = [context viewForKey: UITransitionContextToViewKey];
 
 
 NSLog(@" containerView:      %@", context.containerView);
 NSLog(@" Is game background: %@", [context.containerView isKindOfClass:[MUIViewGameBackground class]] ? @"YES" : @"NO");
 NSLog(@" fromViewController: %@", fromViewController);
 NSLog(@" toViewController:   %@", toViewController);
 NSLog(@" fromView:           %@", fromView);
 NSLog(@" toView:             %@", toView);
 [self.gameView layoutIfNeeded];
 //t.delegate.
 //for (MNSTile *t in gamePieces) {
 //    t.delegate.bounds = CGRectMake(CGPointZero.x, CGPointZero.y, size.width, size.height);
 //    t.delegate.center = [currentLayout.gamePieces objectAtIndex:t.position].CGPointValue;
 //}
 
 } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
 [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
 }];
 }
 */

/*
 - (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection
 withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
 
 
 MTGameBoard *currentLayout = [self gameBoardLayout:newCollection];
 
 MNSGame *game = [MNSUser CurrentUser].game;
 
 NSMutableSet <MNSTile *> *gamePieces = [NSMutableSet setWithArray:game.gamePieces];
 [gamePieces minusSet:[NSSet setWithArray:game.gamePiecesInGoal]];
 
 
 NSUInteger totalGamePiceces = [MNSUser CurrentUser].game.gamePieces.count;
 NSUInteger totalGoalPieces = [MNSUser CurrentUser].game.gamePiecesInGoal.count;
 CGSize size = currentLayout.tileSize;
 
 [coordinator animateAlongsideTransitionInView:self.gameView animation:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
 NSLog(@"  animateAlongsideTransition");
 UIViewController *fromViewController = [context viewControllerForKey: UITransitionContextFromViewControllerKey];
 UIViewController *toViewController = [context viewControllerForKey: UITransitionContextToViewControllerKey];
 UIView *fromView = [context viewForKey: UITransitionContextFromViewKey];
 UIView *toView = [context viewForKey: UITransitionContextToViewKey];
 
 
 NSLog(@" containerView:      %@", context.containerView);
 NSLog(@" Is game background: %@", [context.containerView isKindOfClass:[MUIViewGameBackground class]] ? @"YES" : @"NO");
 NSLog(@" fromViewController: %@", fromViewController);
 NSLog(@" toViewController:   %@", toViewController);
 NSLog(@" fromView:           %@", fromView);
 NSLog(@" toView:             %@", toView);
 } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
 
 }];
 [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
 
 for (MNSTile *t in gamePieces) {
 t.delegate.bounds = CGRectMake(CGPointZero.x, CGPointZero.y, size.width, size.height);
 t.delegate.center = [currentLayout.gamePieces objectAtIndex:t.position].CGPointValue;
 }
 
 } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
 [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
 }];
 }
 
 */

//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
//    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
//    NSLog(@"viewWillTransitionToSize");

//CGRect bounds = CGRectMake(CGPointZero.x, CGPointZero.y, self.gameView.frame.size.width, self.gameView.frame.size.height - (self.backgroundViewFlasher.bounds.size.height + self.bottomGoal.bounds.size.height));
//CGPoint center = self.gameView.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ?
//                    CGPointCenterStaggerItemInRect(tileView.bounds.size, bounds, idx / numberOfColumns, numberOfRows, idx % numberOfColumns, numberOfColumns) :
//                    CGPointCenterGridItemInRect(   tileView.bounds.size, bounds, idx / numberOfColumns, numberOfRows, idx % numberOfColumns, numberOfColumns);

/*
 [coordinator animateAlongsideTransitionInView:self.view animation:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
 NSLog(@"  animateAlongsideTransitionInView");
 
 UIViewController *fromViewController = [context viewControllerForKey: UITransitionContextFromViewControllerKey];
 UIViewController *toViewController = [context viewControllerForKey: UITransitionContextToViewControllerKey];
 UIView *fromView = [context viewForKey: UITransitionContextFromViewKey];
 UIView *toView = [context viewForKey: UITransitionContextToViewKey];
 NSLog(@" containerView:      %@", context.containerView);
 NSLog(@" Is game background: %@", [context.containerView isKindOfClass:[MUIViewGameBackground class]] ? @"YES" : @"NO");
 NSLog(@" fromViewController: %@", fromViewController);
 NSLog(@" toViewController:   %@", toViewController);
 NSLog(@" fromView:           %@", fromView);
 NSLog(@" toView:             %@", toView);
 
 } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
 
 }];
 */

//    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
//        [self.view layoutIfNeeded];
/*
 NSLog(@"  animateAlongsideTransition");
 
 UIViewController *fromViewController = [context viewControllerForKey: UITransitionContextFromViewControllerKey];
 UIViewController *toViewController = [context viewControllerForKey: UITransitionContextToViewControllerKey];
 UIView *fromView = [context viewForKey: UITransitionContextFromViewKey];
 UIView *toView = [context viewForKey: UITransitionContextToViewKey];
 NSLog(@" containerView:      %@", context.containerView);
 NSLog(@" Is game background: %@", [context.containerView isKindOfClass:[MUIViewGameBackground class]] ? @"YES" : @"NO");
 NSLog(@" fromViewController: %@", fromViewController);
 NSLog(@" toViewController:   %@", toViewController);
 NSLog(@" fromView:           %@", fromView);
 NSLog(@" toView:             %@", toView);
 */


//    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
//        NSLog(@"  animateAlongsideTransition completion");

//    }];
//}

#pragma mark -
#pragma mark Core Motion

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	if (event.subtype == UIEventSubtypeMotionShake) {
		[[MNSUser CurrentUser].game pressedShuffleButton];
	}
	
	if ([super respondsToSelector:@selector(motionEnded:withEvent:)]) {
		[super motionEnded:motion withEvent:event];
	}
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event { }

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event { }

#pragma mark -
#pragma mark Pause Screen View Controller Delegate

- (void)pauseScreenDidAbortLevel {
	__weak MNSGame *weakGame = [MNSUser CurrentUser].game;
	[self dismissViewControllerAnimated:YES completion:^{
		MNSGame *game = weakGame;
		[game pressedDismissPauseScreenButton];
		[game pressedAbortButton];
	}];
}

- (void)pauseScreenDidResume {
	[[MNSUser CurrentUser].game pressedDismissPauseScreenButton];
}

#pragma mark -
#pragma mark Game Tile View Delegate

- (CGPoint)goalInterceptWithLineAtPoint:(CGPoint)l2p2 andPointTwo:(CGPoint)l2p1 {
	CGRect rect = self.bottomGoal.frame;
	CGPoint l1p1 = CGPointMake(rect.origin.x, -rect.origin.y);
	CGPoint l1p2 = CGPointMake(rect.origin.x + rect.size.width, -(rect.origin.y + rect.size.height));
	return CGPointMake(
					   ( (l1p1.x*l1p2.y-l1p1.y*l1p2.x)*(l2p1.x-l2p2.x) - ((l1p1.x-l1p2.x)*(l2p1.x*l2p2.y-l2p1.y*l2p2.x)) )/( (l1p1.x-l1p2.x)*(l2p1.y-l2p2.y) - ((l1p1.y - l1p2.y) * (l2p1.x - l2p2.x)) ),
					   -( (l1p1.x*l1p2.y-l1p1.y*l1p2.x)*(l2p1.y-l2p2.y) - ((l1p1.y-l1p2.y)*(l2p1.x*l2p2.y-l2p1.y*l2p2.x)) )/( (l1p1.x-l1p2.x)*(l2p1.y-l2p2.y) - ((l1p1.y - l1p2.y) * (l2p1.x - l2p2.x)) ));
}

- (bool)removeFromGameGoal:(WFTileData *)tile {
	tile.inPlay = YES;
	if ([[MNSUser CurrentUser].game.gamePieceInGoalIndex containsObject: tile.tileID]) {
		[[MNSUser CurrentUser].game.gamePieceInGoalIndex removeObject: tile.tileID];
		return true;
	} else {
		return false;
	}
}

- (void)addToGameGoal:(WFTileData *)tile {
	CGFloat xPoint;
	MNSGame *game = [MNSUser CurrentUser].game;
	WFTileView *tileView = self.tileViews[tile.position];
	NSAssert(tileView != nil, @"Expect a tileview.");

	if (tile.inPlay) {
		xPoint = tile.beginMoveInGoal ? tileView.center.x :
		[self goalInterceptWithLineAtPoint: tile.currentPoint andPointTwo: tile.lastPointPlusOne].x;
	} else {
		xPoint = CGIntercept((-1.0 * self.bottomGoal.frame.origin.y), tile.lastPointPlusOne, tile.currentPoint);
	}

	NSMutableOrderedSet <NSNumber *> *gamePiecesInGoalIndex = [game.gamePieceInGoalIndex mutableCopy];
	NSInteger insertPos = 0;

	if (gamePiecesInGoalIndex.count <= 0) { // if (goalTiles.count <= 0) { //If nothing, add at zero
		[gamePiecesInGoalIndex addObject: tile.tileID];	// [goalTiles addObject:tile];
	} else {
		if (xPoint > self.tileViews[gamePiecesInGoalIndex.lastObject.integerValue].center.x) {	// if (xPoint > goalTiles.lastObject.delegate.center.x) {    //If attaching to end, attach to end
			[gamePiecesInGoalIndex addObject: tile.tileID];	// [goalTiles addObject:tile];
			insertPos = gamePiecesInGoalIndex.count - 1; // insertPos = goalTiles.count - 1;
		} else {

			int i = 0;
			for (NSNumber *goalTileIndex in gamePiecesInGoalIndex) {
				WFTileView *someString = self.tileViews[goalTileIndex.integerValue];
				if (someString.center.x > xPoint) {
					insertPos = i;
					break;
				}
				i++;
			}
			//for (MNSTile *goalTile in goalTiles) {
			//	WFTileView *someString = goalTile.delegate; //[goalTile.delegate retain];
			//	if (someString.center.x > xPoint) {
			//		insertPos = i;
			//		//[someString release];
			//		break;
			//	} else {
			//		//[someString release];
			//	}
			//	i++;
			//}
			[gamePiecesInGoalIndex insertObject: tile.tileID atIndex: insertPos]; //[goalTiles insertObject:tile atIndex:insertPos];	//Add to array
		}
	}

	CGPoint origin = CGPointMake(0.0, self.bottomGoal.center.y);
	int i = 0;
	
	for (NSNumber *goalTileIndex in game.gamePieceInGoalIndex) { // for (MNSTile *goalTile in goalTiles) {
		WFTileView *someString = self.tileViews[goalTileIndex.integerValue]; // WFTileView *someString = goalTile.delegate; //[goalTile.delegate retain];
		origin.x += someString.frame.size.width;
		i++;
		if (i == insertPos) break;
	}
	//CGPoint returnValue = origin;

	[game.gamePieceInGoalIndex removeAllObjects];
	[game.gamePieceInGoalIndex addObjectsFromArray: gamePiecesInGoalIndex.array]; // [game setGamePiecesInGoal:goalTiles];

	[tile setInPlay: NO];
	[tileView setNeedsDisplay];

}

/*
 static BOOL pointInGameGoal(MUIViewControllerGameWordPuzzle *object, const CGPoint *point) {
 return (object.bottomGoal.frame.origin.y < point->y);
 }
 
 bool tileInGameGoal(MUIViewGameTile *tile, UIView *goal) {
 return (goal.frame.origin.y < tile.frame.origin.y + (tile.frame.size.height / 2.0));
 }
 */

- (BOOL)pointInGameGoal:(CGPoint)myPoint {
	//BOOL pointInGameGoalNew = ([self.bottomGoal convertPoint:self.bottomGoal.bounds.origin toView:self.gameView].y < myPoint.y);
	//BOOL pointInGameGoalOld = (self.bottomGoal.frame.origin.y < myPoint.y);
	//NSAssert(pointInGameGoalNew == pointInGameGoalOld, @"Why are these not equal.");
	return (self.bottomGoal.frame.origin.y < myPoint.y);
}

- (BOOL)tileViewInGameGoal:(WFTileView *)tileView {
	//BOOL tileViewInGameGoalNew = ([self.bottomGoal convertPoint:self.bottomGoal.bounds.origin toView:self.gameView].y < tileView.bounds.origin.y + tileView.bounds.size.height / 2.0);
	//BOOL tileViewInGameGoalOld = (self.bottomGoal.frame.origin.y < tileView.frame.origin.y + (tileView.frame.size.height / 2.0));
	//NSAssert(tileViewInGameGoalNew == tileViewInGameGoalOld, @"Why are these not equal.");
	return (self.bottomGoal.frame.origin.y < tileView.frame.origin.y + (tileView.frame.size.height / 2.0));
}

- (void)tileViewIsMovingThroughGameGoal:(WFTileView *)tileView {
	MNSGame *game = [MNSUser CurrentUser].game;
	NSUInteger gamePieceInGoalCount = game.gamePieceInGoalIndex.count;
	if (gamePieceInGoalCount == 0) return;
	
	CGPoint newCenter[gamePieceInGoalCount];
	CGSize inGoalSize = CGSizeZero;
	setInGoalTileSizeForGoalHeight(self.bottomGoal.bounds.size.height, &inGoalSize);

	double tileViewCenterX = tileView.center.x, inGoalPointX = 0.0;
	NSUInteger posCount = 0;
	
	WFTileView *myTile = nil;
	for (NSNumber *gamePieceInGoalIndex in game.gamePieceInGoalIndex) {
		myTile = self.tileViews[gamePieceInGoalIndex.integerValue];
		
		if (myTile != nil && ![tileView.tileID isEqual: myTile.tileID]) {
			inGoalPointX = (self.gameView.bounds.size.width / 2.0) - ((inGoalSize.width * gamePieceInGoalCount) / 2.0);
			
			for (NSNumber *tileIdentifier in game.gamePieceInGoalIndex) {
				if ([tileIdentifier isEqual: gamePieceInGoalIndex]) {
					inGoalPointX += inGoalSize.width / 2.0;
					break;
				} else {
					inGoalPointX += inGoalSize.width;
				}
			}
			
			newCenter[posCount] = inGoalPointX < tileViewCenterX ?
							CGPointMake(inGoalPointX - inGoalSize.width / 2.0, myTile.center.y) :
							CGPointMake(inGoalPointX + inGoalSize.width / 2.0, myTile.center.y);
		}
		posCount++;
	}
	
	posCount = 0;
	[UIView beginAnimations: NSStringFromSelector(@selector(tileViewIsMovingThroughGameGoal:))
					context: nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	for (NSNumber *gamePieceInGoalIndex in game.gamePieceInGoalIndex) {
		myTile = self.tileViews[gamePieceInGoalIndex.integerValue];
		if (myTile != nil && ![tileView.tileID isEqual: myTile.tileID]) {
			myTile.center = newCenter[posCount];
		}
		posCount++;
	}
	[UIView commitAnimations];

}

- (void)game:(MNSGame *)game alignGoalTiles:(bool)animated {
	NSUInteger totalInGoal = game.gamePieceInGoalIndex.count;
	if (totalInGoal == 0) return;

	CGFloat widthWindow = self.view.bounds.size.width;
	
	CGSize tileSize;
	setInGoalTileSizeForGoalHeight(self.bottomGoal.bounds.size.height, &tileSize);

	int tilePosition = 0;
	CGRect gameTileBounds = CGRectZero;
	CGPoint gameTileCenter = CGPointZero,
			gameTileOrigin = CGPointMake((widthWindow / 2.0) - ((self.tileViews[game.gamePieceInGoalIndex.firstObject.integerValue].bounds.size.width * totalInGoal) / 2.0),
										 self.bottomGoal.center.y);
	WFTileView *gameTile = nil;
	for (NSNumber *tileID in game.gamePieceInGoalIndex) {
		gameTile = self.tileViews[tileID.integerValue];
		gameTileBounds = CGRectMake(gameTile.bounds.origin.x, gameTile.bounds.origin.y,
									gameTile.bounds.size.width, gameTile.bounds.size.height);
		gameTileCenter = CGPointMake(gameTileOrigin.x + (tileSize.width / 2.0),
									 self.bottomGoal.center.y);
		[UIView beginAnimations: NSStringFromSelector(@selector(game:alignGoalTiles:))
						context: nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		gameTile.bounds = gameTileBounds;
		gameTile.center = gameTileCenter;
		[UIView commitAnimations];
		gameTileOrigin.x += tileSize.width;
		tilePosition++;
	}
}

+ (void)tileViewIsMovingThroughGameGoal:(NSString *)animationID finished:(BOOL)finished
								context:(void *)context { }

- (void)panPiece:(UIPanGestureRecognizer *)gestureRecognizer {
	
	NSAssert([gestureRecognizer.view isKindOfClass:[WFTileView class]], @"Expecting a game tile.");
	WFTileView *tileView = (WFTileView *)gestureRecognizer.view;
	if (tileView == nil) return;
	
	MNSGame *game = [MNSUser CurrentUser].game;
	__strong WFTileData *tileData = game.gamePieceData[tileView.tileID];
	
	switch (gestureRecognizer.state) {
		case UIGestureRecognizerStatePossible:
		case UIGestureRecognizerStateBegan: {
			
			[tileView startWobble: 1];
			tileData.isMoving = YES;

			if (game.isPaused) break;
			
			[self.gameView bringSubviewToFront:tileView];

			if (![self tileViewInGameGoal:tileView]) {
				
				MTGameBoard *gameBoard = [self gameBoardLayoutCurrent];
				
				[self.gameView bringSubviewToFront:tileView];
				CGRect b = CGRectMake(0.0, 0.0, gameBoard.tileSize.width, gameBoard.tileSize.height);
				CGPoint c = [gestureRecognizer locationInView: self.gameView];
				[UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
					tileView.bounds = b;
					tileView.center = c;
				} completion:^(BOOL finished) {
					[tileView setNeedsDisplay];
				}];
			}
			
			CGPoint locInView = [gestureRecognizer locationInView:self.gameView];
			tileData.lastPoint = CGPointMake(locInView.x, -locInView.y);
			tileData.currentPoint = CGPointMake(locInView.x, -locInView.y);
			tileData.beginMoveInGoal = (!tileData.inPlay && [self tileViewInGameGoal: tileView]);
			
			break;
		}
			
		case UIGestureRecognizerStateChanged: {
			CGPoint centerSave = [gestureRecognizer locationInView:self.gameView];
			tileView.center = centerSave;

			if ([self tileViewInGameGoal: tileView]) {

				CGSize tileInGoalSize;
				setInGoalTileSizeForGoalHeight(self.bottomGoal.bounds.size.height, &tileInGoalSize);

				[UIView beginAnimations: @"tileViewMakeSmall" context: (__bridge void * _Nullable)(tileView)];
				[UIView setAnimationDelegate: self];
				[UIView setAnimationWillStartSelector: @selector(animationDidStart:context:)];
				[UIView setAnimationDidStopSelector: @selector(animationFinished:finished:context:)];
				[UIView setAnimationCurve: UIViewAnimationCurveLinear];
				[UIView setAnimationDuration: 0.5];
				tileView.bounds = CGRectMake(0.0, 0.0, tileInGoalSize.width, tileInGoalSize.height);
				tileView.center = tileView.center;
				[UIView commitAnimations];
				
				[self tileViewIsMovingThroughGameGoal: tileView];

			} else {
				tileData.lastTimePlusOne = tileData.lastTime;
				tileData.lastTime = tileData.currentTime;
				
				tileData.lastPointPlusOne = tileData.lastPoint;
				tileData.lastPoint = tileData.currentPoint;
				tileData.currentPoint = CGPointMake(centerSave.x, (-1.0) * centerSave.y);
			}

			break;
		}
		case UIGestureRecognizerStateCancelled:
		case UIGestureRecognizerStateFailed:
		case UIGestureRecognizerStateEnded: {
			
			[tileView stopWobble];
			if (![MNSUser CurrentUser].game.isPaused) {
				
				CGPoint velocity = [gestureRecognizer velocityInView:self.gameView];
				if (isnan(velocity.x) || isnan(velocity.y)) {
					velocity = CGPointZero;
				}
				CGPoint location = tileView.center;
				BOOL currentPointInGameGoal = [self pointInGameGoal: location];
				
				double force;
				CGPoint newLocation;
				if (!currentPointInGameGoal) {
					force = sqrt( ( (velocity.x) * (velocity.x) )  + ( (velocity.y) * (velocity.y) ));
					newLocation = CGPointOnLine(force, location, velocity);
				} else {
					force = 0.0;
					newLocation = location;
				}
				
				if (isnan(newLocation.x) || isnan(newLocation.y) || force < 55.0) {
					newLocation = tileView.center;
					
				}
				
				tileData.isMoving = YES;
				[self removeFromGameGoal:tileData];
				if ([self pointInGameGoal:newLocation]) {                                    //Detect if in goal or not
					[self removeFromGameGoal:tileData];
					[self addToGameGoal: tileData];
				}
				
				BOOL pointInGoal = [self pointInGameGoal:newLocation];// pointInGameGoal(self, &newLocation);
				CGSize s;
				if (pointInGoal) {
					setInGoalTileSizeForGoalHeight(self.bottomGoal.bounds.size.height, &s);
				} else {
					s.width = tileView.bounds.size.width; s.height = tileView.bounds.size.height;
				}

				[UIView beginAnimations: @"tileViewIsMovingThroughGameGoal" context: (__bridge void * _Nullable)(tileView)];
				[UIView setAnimationDelegate:self];
				[UIView setAnimationWillStartSelector:@selector(animationDidStart:context:)];
				[UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
				[UIView setAnimationCurve:UIViewAnimationCurveLinear];
				tileView.bounds = CGRectMake(0.0, 0.0, s.width, s.height);
				tileView.center = newLocation;				//Slide to new center
				[UIView commitAnimations];
				
				if (tileData.inPlay) {
					if (pointInGoal) {						//Detect if in goal or not
						[self addToGameGoal: tileData];
					}
				} else {
					[self removeFromGameGoal: tileData];
					if (pointInGoal) {						//Detect if in goal or not
						[self addToGameGoal: tileData];
					}
				}
				
				if (!tileData.inPlay) {
					CGSize tileInGoalSize;
					setInGoalTileSizeForGoalHeight(self.bottomGoal.bounds.size.height, &tileInGoalSize);

					[UIView beginAnimations: @"tileViewMakeSmallAgain" context: (__bridge void * _Nullable)(tileView)];
					[UIView setAnimationDelegate: self];
					//[UIView setAnimationWillStartSelector:@selector(animationDidStart:context:)];
					[UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
					[UIView setAnimationCurve: UIViewAnimationCurveLinear];
					[UIView setAnimationDuration: 0.3];
					tileView.bounds = CGRectMake(tileView.bounds.origin.x, tileView.bounds.origin.y,
												 tileInGoalSize.width, tileInGoalSize.height);
					tileView.center = tileView.center;
					[UIView commitAnimations];
				}
				[self game: game alignGoalTiles: true];
			}
			break;
		}
			
		default: {
			break;
		}
	}
	
	tileData = nil;
}

- (void)animationDidStart:(NSString *)animationID context:(void *)context {
	//NSLog(@"-[animationDidStart:%@ context:%@", animationID, NSStringFromClass([(id)context class]));
	if ([animationID isEqualToString:@"tileViewMakeSmallAgain"] ||
		[animationID isEqualToString:@"tileViewIsMovingThroughGameGoal"] ||
		[animationID isEqualToString:@"tileViewMakeSmall"]) {
		[MNSAudio playFlipTileFlip];
	}
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context {
	//NSLog(@"-[animationFinished:%@ finished:%@ context:%@", animationID, finished ? @"YES" : @"NO", NSStringFromClass([(__bridge id)context class]));
	
	if ([animationID isEqualToString:@"tileViewIsMovingThroughGameGoal"]) {
		
		//NSAssert([(id)context isKindOfClass:[MUIViewGameTile class]], @"Expect a MUIViewGameTile.");
		
		//MUIViewGameTile *gameTile = [(MUIViewGameTile *)context retain];
		WFTileView *gameTile = (__bridge WFTileView *)context;
		MNSGame *game = [MNSUser CurrentUser].game;
		WFTileData *tileData = game.gamePieceData[gameTile.tileID];
		
		if (tileData.inPlay) {
			[MNSAudio playFlipTileFlip];
			
			MTGameBoard *gameBoard = [self gameBoardLayoutCurrent];
			CGPoint newCenter = [gameBoard gamePieceCenter: tileData.position];
			CGSize gamePiceSize;
			if ([game.gamePieceInGoalIndex containsObject: tileData.tileID]) {
				setInGoalTileSizeForGoalHeight(self.bottomGoal.bounds.size.height, &gamePiceSize);
			} else {
				gamePiceSize = gameBoard.tileSize;
			}
			
			[UIView animateWithDuration:0.6 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
				gameTile.bounds = CGRectMake(gameTile.bounds.origin.x, gameTile.bounds.origin.y, gamePiceSize.width, gamePiceSize.height);
				gameTile.center = newCenter;
			} completion:^(BOOL complete) {
				tileData.isMoving = NO;
				if (complete) {
					[gameTile setNeedsDisplay];
				}
			}];
			[self removeFromGameGoal:tileData];
			
		} else {
			tileData.isMoving = NO;
			[MNSAudio playFlipTileEnd];
			[self game: game alignGoalTiles: true];
		}
		//[gameTile release];
		//gameTile = nil;
		
	} else if ([animationID isEqualToString:@"tileViewMakeSmall"]) {
		//NSAssert([(id)context isKindOfClass:[MUIViewGameTile class]], @"Expect a MUIViewGameTile.");
		[(__bridge WFTileView *)context setNeedsDisplay];
		
	} else if ([animationID isEqualToString:@"tileViewMakeSmallAgain"]) {
		//NSAssert([(id)context isKindOfClass:[MUIViewGameTile class]], @"Expect a MUIViewGameTile.");
		[MNSUser CurrentUser].game.gamePieceData[((__bridge WFTileView *)context).tileID].isMoving = NO;
		[(__bridge WFTileView *)context setNeedsDisplay];
		
		
	}
}

#pragma mark -
#pragma mark WFTileViewDataSource

- (MNSTileType)typeTypeForTileView:(nonnull WFTileView *)tileView {
	return [MNSUser CurrentUser].game.gamePieceData[tileView.tileID].tileType;
}

- (nonnull NSString *)characterValueForTileView:(nonnull WFTileView *)tileView {
	return [MNSUser CurrentUser].game.gamePieceData[tileView.tileID].characterValue;
}

- (bool)isTileFlipping:(nonnull WFTileView *)tileView {
	return [MNSUser CurrentUser].game.gamePieceData[tileView.tileID].tileIsFlipping;
}

#pragma mark -
#pragma mark WFTileViewDelegate

- (void)tileViewTouchBegan:(nonnull WFTileView *)tileView {
	__strong WFTileData *tileData = [MNSUser CurrentUser].game.gamePieceData[tileView.tileID];
	
	if (tileData.tileIsFlipping) {
		[tileData reversePieceChange];
		tileViewAnimatieFlip(UIViewAnimationTransitionFlipFromLeft, tileView);
	}
	
	[tileView.superview bringSubviewToFront:tileView];
	[MNSGame playTouchesBeganSound:tileData.tileType];
}

- (void)tileWithDataUpdateDisplay:(WFTileData *)tileData {
	[self.tileViews objectAtIndex: tileData.position];
	WFTileView *tileView = self.tileViews[tileData.position];
	tileViewAnimatieFlip(UIViewAnimationTransitionFlipFromRight, tileView);
}

- (bool)isTouched:(WFTileData *)tileData {
	return self.tileViews[tileData.position].touched ? true : false;
}

- (bool)hasInitalRotationForTileView:(WFTileView *)tileView {
	return false;
}

- (CGFloat)initalRotationAngleForTileView:(WFTileView *)tileView {
	return 0.0f;
}

#pragma mark -
#pragma mark Animation Delegates

@end
