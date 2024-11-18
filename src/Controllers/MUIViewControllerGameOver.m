//
//  MUIViewControllerGameOver.m
//  wordPuzzle
//
//  Created by Michael Thomason on 7/14/09.
//  Copyright 2019 Michael Thomason. All rights reserved.
//

#import "MUIViewControllerGameOver.h"
#import "MNSUser.h"
#import "MNSGame.h"
#import "WFLevelStatistics.h"
#import "MTWordValue.h"
#import "MNSAudio.h"
#import "WFGameStatistics.h"
#import "UIColor+Wordflick.h"

@implementation MUIViewControllerGameOver

#pragma mark Standard Overrides

- (void)dealloc {
	_wordsTableView = nil;
	_wordForLevel = nil;
	_uITableViewCellSalesPitch = nil;
	_uILabelSalesPitch = nil;
	_uiButtonITunesLink = nil;
	_labelGameOver = nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		_wordForLevel = [[MNSUser CurrentUser].game.wordsAndPoints copy];
	}
	return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		_wordForLevel = [[MNSUser CurrentUser].game.wordsAndPoints copy];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	UIView *bgView = [[UIView alloc] initWithFrame: self.wordsTableView.bounds];
	bgView.backgroundColor = [UIColor clearColor];
	self.wordsTableView.backgroundView = bgView;
	bgView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.labelGameOver.text = NSLocalizedString(@"Game Over", @"Game Over title bar display.");
	self.view.backgroundColor = [UIColor patternUIImagePatternClouds3];
	
	//[appReviewManager userDidSignificantEvent:YES];
	
	//self.wordsTableView.backgroundView.backgroundColor = [UIColor clearColor];
	NSString *salesPitchFormat = NSLocalizedString(@"%@ sales pitch.", @"Wordflick sales pitch.");
	NSString *salesPitch = [[NSString alloc] initWithFormat: salesPitchFormat, @"Wordflick"];
	self.uILabelSalesPitch.text = salesPitch;
	salesPitch = nil;
	self.wordsTableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if (animated) {
		[self.wordsTableView flashScrollIndicators];
	}
}

- (IBAction)buttonCheckDidTouchUpInside:(id)sender {
	[MNSAudio playButtonPress];
	[self.delegate viewControllerGameOverIsDone: self];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 3;
			break;
		case 1:
			return self.wordForLevel.count;
			break;
		default:
			return 0;
			break;
	}
}

static NSString * _Nonnull titleForSection(NSInteger section) {
	switch (section) {
		case 0:
			return NSLocalizedString(@"Game Over",  @"Game Over title bar display.");
			break;
		case 1:
			return NSLocalizedString(@"Words", @"The title of a screen that displays a list of words that the user got in the previous level.");
			break;
		default:
			return @"";
			break;
	}
}

/*
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	CGFloat returnVal;
	switch (section) {
		case 0:
			returnVal = 43.0000f;
			break;
		case 1:
			returnVal = 43.0000f;
			break;
		default:
			returnVal = 0.0000f;
			break;
	}
	return returnVal;
}
*/

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return titleForSection(section);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	CGRect resultFrame = CGRectMake(CGPointZero.x, CGPointZero.y, self.view.bounds.size.width, 44.0);
	UIView *resultView = [[UIView alloc] initWithFrame:resultFrame];
	resultFrame.origin.x = resultFrame.origin.x + 20.0;
	resultFrame.size.width = resultFrame.size.width - 20.0;
	UILabel *label = [[UILabel alloc] initWithFrame:resultFrame];
	[resultView setBackgroundColor:[UIColor clearColor]];
	label.textAlignment = NSTextAlignmentLeft;
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		label.textColor = [UIColor darkGrayColor];
	} else {
		label.textColor = [UIColor whiteColor];
	}
	label.shadowColor = [UIColor grayColor];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:22.0];
	label.text = titleForSection(section);
	[resultView addSubview:label];
	label = nil;
	return resultView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"TVCLevelStats";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1
									reuseIdentifier: CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	if (indexPath.section == 0) {
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
		switch (indexPath.row){
			case 0: {
				NSNumber *level = @([MNSUser CurrentUser].game.gameLevelArchive.lastObject.levelNumberMinusOne);
				cell.detailTextLabel.text = [numberFormatter stringFromNumber:level];
				cell.textLabel.text = NSLocalizedString(@"Completed Level", @"A label that is next to the level number or name they just completed.");
				break;
			} case 1: {
				cell.textLabel.text = NSLocalizedString(@"Points for Level", @"A label that is next to the number of points earned in the last level.");
				WFLevelStatistics *level = [MNSUser CurrentUser].game.gameLevelArchive.lastObject;
				NSString *atPoints = NSLocalizedString(@"%@ points", @"A display of points.  For example: '100 points' where %@ is the number of points.");
				NSString *formatString = [[NSString alloc] initWithFormat:@"%@ / %@", atPoints, atPoints];
				NSString *totalPointsString = [numberFormatter stringFromNumber: @(level.totalPoints)];
				NSString *goalPointsString = [numberFormatter stringFromNumber: @(level.goal)];
				NSString *detailLabel = [[NSString alloc] initWithFormat:formatString, totalPointsString, goalPointsString];
				cell.detailTextLabel.text = detailLabel;
				detailLabel = nil;
				formatString = nil;
				break;
			} case 2: {
				WFGameStatistics *gameStats = [MNSUser CurrentUser].game.statisticsGame;
				cell.textLabel.text = NSLocalizedString(@"Total Points", @"Label: Total Points");
				cell.detailTextLabel.text = gameStats.totalPointsValue;
				break;
			} default:
				break;
		}
		numberFormatter = nil;
	} else {
		//Not used in Pre Level ScreensMUIGameScreenPreLevel
		//These words are only displayed after a level is complete.
		MTWordValue *wfl = [self.wordForLevel objectAtIndex: indexPath.row];
		cell.textLabel.text = wfl.kidFriendlyWord.capitalizedString;
		cell.detailTextLabel.text = [NSString stringWithFormat: NSLocalizedString(@"%ld points", @"A display of points."),
									 wfl.points.longValue];
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath { }

@end
