//
//  MUIViewGameControlScreen.m
//  wordPuzzle
//
//  Created by Michael Thomason on 9/6/09.
//  Copyright 2019 Michael Thomason. All rights reserved.
//

#import "MUIViewGameControlScreen.h"
#import "wordPuzzleAppDelegate.h"
#import "MNSUser.h"
#import "MNSGame.h"
#import "WFLevelStatistics.h"
#import "MTControlDisplayState.h"
#import "UIColor+Wordflick.h"

static inline NSStringDrawingOptions DrawingOptions(void);
static inline displayState DisplayStateNumberOfShakes(NSInteger);
static inline displayState DisplayStateTimeRemaining(int64_t);

static inline NSStringDrawingOptions DrawingOptions(void) {
	return NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine;
}

static inline displayState DisplayStateNumberOfShakes(NSInteger s) {
	switch (s) {
		case 0:
			return alert;
		case 1:
			return warning;
		default:
			return standard;
	}
}

static inline displayState DisplayStateTimeRemaining(int64_t s) {
	switch (s) {
		case 0:
		case 1:
		case 2:
		case 3:
		case 4:
		case 5:
			return alert;
		case 6:
		case 7:
		case 8:
		case 9:
		case 10:
			return warning;
		default:
			return standard;
	}
}

@interface MUIViewGameControlScreen () {
	NSNumberFormatter *_numberFormatterInteger;
	NSNumberFormatter *_numberFormatterSecond;
	
	displayState _displayStateShuffles;
	displayState _displayStateTimer;
	displayState _displayStatePoints;

	NSRange _totalPointsStringRange;
	NSRange _totalShufflesStringRange;
	NSRange _timeRemainingStringRange;
	NSRange _goalStringRange;

	CGRect _totalPointsBoundingRect;
	CGRect _numberOfShakesBoundingRect;
	CGRect _pointsBoundingRect;
	CGRect _timeRemainingLabelBoundingRect;
	CGRect _timeRemainingBoundingRect;

	CGRect _shuffleImageRect;
	CGRect _timerImageRect;
	CGRect _goalBoundingRect;
	CGRect _goalLabelBoundingRect;
}

@property (nonatomic, strong) NSMutableAttributedString *stringTotalPoints;
@property (nonatomic, strong) NSMutableAttributedString *stringNumberOfShakes;
@property (nonatomic, strong) NSMutableAttributedString *stringTimeRemaining;
@property (nonatomic, strong) NSMutableAttributedString *stringGoal;
@property (nonatomic, strong) NSAttributedString *stringPointsLabel;
@property (nonatomic, strong) NSAttributedString *stringGoalLabel;
@property (nonatomic, strong) NSAttributedString *stringTimeRemainingLabel;

@property (nonatomic, strong) NSStringDrawingContext *totalPointsDrawingContext;
@property (nonatomic, strong) NSStringDrawingContext *shufflesRemainingDrawingContext;

@property (nonatomic, strong) UIColor *gradientBlue;
@property (nonatomic, strong) UIColor *gradientYellow;
@property (nonatomic, strong) UIColor *gradientRed;
@property (nonatomic, strong) UIColor *highlightColor;

static void ContextSetFillColorForState(MUIViewGameControlScreen *, CGContextRef, displayState);

@end

@implementation MUIViewGameControlScreen

static UIImage *_timerImage;
static UIImage *_shuffleImage;

static void ContextSetFillColorForState(MUIViewGameControlScreen *view, CGContextRef context,
										displayState state) {
	switch (state) {
		case alert:
			CGContextSetFillColorWithColor(context, view->_gradientRed.CGColor);
			break;
		case warning:
			CGContextSetFillColorWithColor(context, view->_gradientYellow.CGColor);
			break;
		case standard:
		default:
			CGContextSetFillColorWithColor(context, view->_gradientBlue.CGColor);
			break;
	}
	CGContextSetShadowWithColor(context, CGSizeMake( 0.0, -1.0 ), 1.0, view->_highlightColor.CGColor);
}

+ (void)initialize {
	if (self == [MUIViewGameControlScreen class]) {
		static dispatch_once_t _dispatchToken;
		dispatch_once(&_dispatchToken, ^{
			_timerImage = [UIImage imageNamed:@"MUIImageTimerFlipped"];
			_shuffleImage = [UIImage imageNamed:@"MUIImageShuffle"];
		});
	}
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	if (self = [super initWithCoder:coder]) {
		
		_numberFormatterInteger = [[NSNumberFormatter alloc] init];
		_numberFormatterInteger.numberStyle = NSNumberFormatterDecimalStyle;
		_numberFormatterInteger.maximumFractionDigits = 0;
		
		_numberFormatterSecond = [[NSNumberFormatter alloc] init];
		_numberFormatterSecond.numberStyle = NSNumberFormatterDecimalStyle;
		_numberFormatterSecond.maximumFractionDigits = 0;
		_numberFormatterSecond.minimumIntegerDigits = 2;
		_numberFormatterSecond.maximumIntegerDigits = 2;

		_totalPointsStringRange = NSMakeRange(0, 0);
		_totalShufflesStringRange = NSMakeRange(0, 0);
		_timeRemainingStringRange = NSMakeRange(0, 0);
		_goalStringRange = NSMakeRange(0, 0);

		_displaying = NO;
		_displayStateShuffles = standard;
		_displayStateTimer = standard;
		_displayStatePoints = standard;
		
		_totalPointsDrawingContext = [[NSStringDrawingContext alloc] init];
		_shufflesRemainingDrawingContext = [[NSStringDrawingContext alloc] init];
		_shufflesRemainingDrawingContext.minimumScaleFactor =
		_totalPointsDrawingContext.minimumScaleFactor = 4.0 / 18.0;

		_totalPointsBoundingRect = CGRectMake(11.0, 16.0, 0.0, 0.0);
		_numberOfShakesBoundingRect = CGRectMake(71.0, 35.0, 0.0, 0.0);
		_pointsBoundingRect = CGRectMake(11.0, 7.0, 0.0, 0.0);
		_timeRemainingLabelBoundingRect = CGRectMake(91.0, 7.0, 0.0, 0.0);
		_timeRemainingBoundingRect = CGRectMake(91.0, 15.0, 0.0, 0.0);

		_goalBoundingRect = CGRectMake(54.0, 16.0, 0.0, 0.0);
		_goalLabelBoundingRect = CGRectMake(54.0, 7.0, 0.0, 0.0);

		_timerImageRect = CGRectMake(158.0, 1.0, _timerImage.size.width, _timerImage.size.height);
		_shuffleImageRect = CGRectMake(49.0, 35.0, _shuffleImage.size.width, _shuffleImage.size.height);
		_gradientBlue = [[UIColor alloc] initWithPatternImage: [UIImage imageNamed: @"MUIImageGradentControl"]];
		_gradientYellow = [[UIColor alloc] initWithPatternImage: [UIImage imageNamed: @"MUIImageGradentControlYellow"]];
		_gradientRed = [[UIColor alloc] initWithPatternImage: [UIImage imageNamed: @"MUIImageGradentControlRed"]];
		_highlightColor = [[UIColor alloc] initWithRed:2.0/255.0 green:197.0/255.0 blue:204.0/255.0 alpha:1.0];
		
		NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
		paragraphStyle.allowsDefaultTighteningForTruncation = YES;
		paragraphStyle.lineBreakMode = NSLineBreakByTruncatingMiddle;
		
		//Total Points String
		NSParagraphStyle *totalPointsParagraphStyle = paragraphStyle.copy;
		NSDictionary <NSAttributedStringKey, id> *totalPointsAttributes = @{
			NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:18.0],
			NSParagraphStyleAttributeName : totalPointsParagraphStyle,
			NSForegroundColorAttributeName : _gradientBlue
		};
		_stringTotalPoints = [[NSMutableAttributedString alloc] initWithString: @"0"
																	attributes: totalPointsAttributes];
		totalPointsParagraphStyle = nil;
		totalPointsAttributes = nil;

		//Total Shuffles String
		NSParagraphStyle *totalShufflesParagraphStyle = paragraphStyle.copy;
		NSDictionary <NSAttributedStringKey, id> *totalShufflesAttributes = @{
			NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:18.0],
			NSParagraphStyleAttributeName : totalShufflesParagraphStyle,
			NSForegroundColorAttributeName : _gradientBlue
		};
		_stringNumberOfShakes = [[NSMutableAttributedString alloc] initWithString: @"0"
																	   attributes: totalShufflesAttributes];
		totalShufflesParagraphStyle = nil;
		totalShufflesAttributes = nil;


		//Goal String
		NSParagraphStyle *goalParagraphStyle = paragraphStyle.copy;
		NSDictionary <NSAttributedStringKey, id> *goalAttributes = @{
			NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:18.0],
			NSParagraphStyleAttributeName : goalParagraphStyle,
			NSForegroundColorAttributeName : _gradientBlue
		};
		_stringGoal = [[NSMutableAttributedString alloc] initWithString: @"0"
															 attributes: goalAttributes];
		goalParagraphStyle = nil;
		goalAttributes = nil;

		NSParagraphStyle *timeRemainingParagraphStyle = paragraphStyle.copy;
		NSDictionary <NSAttributedStringKey, id> *timeRemainingAttributes = @{
			NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:48.0],
			NSParagraphStyleAttributeName : timeRemainingParagraphStyle,
			NSForegroundColorAttributeName : _gradientBlue
		};
		_stringTimeRemaining = [[NSMutableAttributedString alloc] initWithString: NSLocalizedString(@"0:00", @"0:00")
																	  attributes: timeRemainingAttributes];
		timeRemainingAttributes = nil;
		timeRemainingParagraphStyle = nil;

		NSParagraphStyle *pointsLabelParagraphStyle = paragraphStyle.copy;
		_stringPointsLabel = [[NSAttributedString alloc] initWithString: NSLocalizedString(@"POINTS", @"Control Screen Label")
															 attributes: @{
																 NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:8.0],
																 NSParagraphStyleAttributeName : pointsLabelParagraphStyle,
																 NSForegroundColorAttributeName : _gradientBlue
															 }
							  ];
		pointsLabelParagraphStyle = nil;
		
		NSParagraphStyle *goalLabelParagraphStyle = paragraphStyle.copy;
		_stringGoalLabel = [[NSAttributedString alloc] initWithString: NSLocalizedString(@"GOAL", @"Control Screen Label")
														   attributes: @{
															   NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:8.0],
															   NSParagraphStyleAttributeName : goalLabelParagraphStyle,
															   NSForegroundColorAttributeName : _gradientBlue
														   }
							];
		goalLabelParagraphStyle = nil;

		NSParagraphStyle *timeRemainingLabelParagraphStyle = paragraphStyle.copy;
		_stringTimeRemainingLabel = [[NSAttributedString alloc] initWithString: NSLocalizedString(@"TIME REMAINING", @"Control Screen Label")
															   attributes: @{
																   NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:8.0],
																   NSParagraphStyleAttributeName : timeRemainingLabelParagraphStyle,
																   NSForegroundColorAttributeName : _gradientBlue
															   }
									 ];
		timeRemainingLabelParagraphStyle = nil;
		
		paragraphStyle = nil;
		
		//self.backgroundColor = [UIColor blackColor];
	}
	return self;
}

- (void)drawRect:(CGRect)rect {

	if (!self.displaying) return;
	
	CGRect boundingRect;
	CGSize boundingConstraint = CGSizeZero;
	
	MNSGame *game = [MNSUser CurrentUser].game;
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	ContextSetFillColorForState(self, context, standard);

	_totalPointsStringRange.length = _stringTotalPoints.length;
	[_stringTotalPoints replaceCharactersInRange: _totalPointsStringRange
									  withString: [_numberFormatterInteger stringFromNumber:@(game.gameLevel.totalPoints)]];
	
	boundingConstraint.width = 41.0;
	boundingRect = [_stringTotalPoints boundingRectWithSize: boundingConstraint
													options: DrawingOptions()
													context: _totalPointsDrawingContext];
	
	_totalPointsBoundingRect.size.width = 41.0;
	_totalPointsBoundingRect.size.height = boundingRect.size.height;
	[_stringTotalPoints drawWithRect: _totalPointsBoundingRect options: DrawingOptions()
							 context: _totalPointsDrawingContext];
		
	_displayStateShuffles = DisplayStateNumberOfShakes(game.numberOfShakes);
	
	_totalShufflesStringRange.length = _stringNumberOfShakes.length;
	[_stringNumberOfShakes replaceCharactersInRange: _totalShufflesStringRange
										 withString: [_numberFormatterInteger stringFromNumber:@(game.numberOfShakes)]];
	
	boundingConstraint.width = 21.0;
	boundingRect = [_stringNumberOfShakes boundingRectWithSize: boundingConstraint
													   options: DrawingOptions()
													   context: _shufflesRemainingDrawingContext];
	
	_numberOfShakesBoundingRect.size.width = 21.0;
	_numberOfShakesBoundingRect.size.height = boundingRect.size.height;
	[_stringNumberOfShakes drawWithRect: _numberOfShakesBoundingRect options: DrawingOptions()
								context: _shufflesRemainingDrawingContext];

	long remainingTime = game.remainingTime;
	_displayStateTimer = DisplayStateTimeRemaining(remainingTime);

	_timeRemainingStringRange.length = _stringTimeRemaining.length;

	[_stringTimeRemaining replaceCharactersInRange: _timeRemainingStringRange
										withString: [[[_numberFormatterInteger stringFromNumber:@(remainingTime / 60)] stringByAppendingString: @":"]
													 stringByAppendingString: [_numberFormatterSecond stringFromNumber:@(labs(remainingTime % 60))]]];

	boundingConstraint.width = 94.0;
	boundingRect = [_stringTimeRemaining boundingRectWithSize: boundingConstraint
													  options: DrawingOptions()
													  context: nil];
	
	_timeRemainingBoundingRect.size = boundingRect.size;
	[_stringTimeRemaining drawWithRect: _timeRemainingBoundingRect
							   options: DrawingOptions()
							   context: nil];

	_goalStringRange.length = _stringGoal.length;
	[_stringGoal replaceCharactersInRange: _goalStringRange
							   withString: [_numberFormatterInteger stringFromNumber: @(game.gameLevel.goal)]];
	
	boundingConstraint.width = 41.0;
	boundingRect = [_stringGoal boundingRectWithSize: boundingConstraint
											 options: DrawingOptions()
											 context: nil];
	
	_goalBoundingRect.size = boundingRect.size;
	[_stringGoal drawWithRect: _goalBoundingRect
					  options: DrawingOptions()
					  context: nil];

	boundingConstraint.width = 41.0;
	boundingRect = [_stringPointsLabel boundingRectWithSize: boundingConstraint
													options: DrawingOptions() context: nil];
	
	_pointsBoundingRect.size = boundingRect.size;
	[_stringPointsLabel drawWithRect: _pointsBoundingRect
							 options: DrawingOptions()
							 context: nil];
	
	boundingConstraint.width = 39.0;
	boundingRect = [_stringGoalLabel boundingRectWithSize: boundingConstraint
												  options: DrawingOptions()
												  context: nil];
	
	_goalLabelBoundingRect.size.width = boundingRect.size.width;
	_goalLabelBoundingRect.size.height = boundingRect.size.height;
	[_stringGoalLabel drawWithRect: _goalLabelBoundingRect
						   options: DrawingOptions()
						   context: nil];
	
	boundingConstraint.width = 94.0;
	boundingRect = [_stringTimeRemainingLabel boundingRectWithSize: boundingConstraint
														   options: DrawingOptions()
														   context: nil];

	_timeRemainingLabelBoundingRect.size = boundingRect.size;
	[_stringTimeRemainingLabel drawWithRect: _timeRemainingLabelBoundingRect
									options: DrawingOptions()
									context: nil];

	CGContextSaveGState (context);

	ContextSetFillColorForState(self, context, _displayStateShuffles);

	CGContextClipToMask(context, _shuffleImageRect, _shuffleImage.CGImage);
	CGContextFillRect(context, _shuffleImageRect);
	
	CGContextRestoreGState (context);
	ContextSetFillColorForState(self, context, _displayStateTimer);

	CGContextClipToMask(context, _timerImageRect, _timerImage.CGImage);
	CGContextFillRect(context, _timerImageRect);

	game = nil;
}

- (void)setIsDisplaying:(BOOL)d {
	self.displaying = d;
	[self setNeedsDisplay];
}

@end
