//
//  MUIViewControllerPreLevel.m
//  wordPuzzle
//
//  Created by Michael Thomason on 7/14/09.
//  Copyright 2009 Michael Thomason. All rights reserved.
//

#import "MUIViewControllerPreLevel.h"
#import "MNSUser.h"
#import "MNSGame.h"
#import "WFLevelStatistics.h"
#import "MNSAudio.h"

@interface MUIViewControllerPreLevel()
	@property (nonatomic, retain) NSNumberFormatter *numberFormatterDecimal;
@end

@implementation MUIViewControllerPreLevel

#pragma mark Standard Overrides

- (void)dealloc {
	_numberFormatterDecimal = nil;
	_wordsTableView = nil;
	_wordForLevel = nil;
	_uITableViewCellSalesPitch = nil;
	_uILabelSalesPitch = nil;
	_uiButtonITunesLink = nil;
	_labelNextLevel = nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {

		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
		self.numberFormatterDecimal = numberFormatter;
		numberFormatter = nil;

		NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
		[self setWordForLevel: array];
		array = nil;

	}
	return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
	
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
		self.numberFormatterDecimal = numberFormatter;
		numberFormatter = nil;

		NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
		[self setWordForLevel: array];
		array = nil;

	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	UIView *backgroundView = [[UIView alloc] initWithFrame: self.wordsTableView.bounds];
	backgroundView.backgroundColor = [UIColor clearColor];
	self.wordsTableView.backgroundView = backgroundView;
	backgroundView = nil;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	WFLevelStatistics *nextLevel = [MNSUser CurrentUser].game.gameLevel;
	if (nextLevel != nil) {
		self.view.backgroundColor = nextLevel.backgroundColor;
	}
	self.labelNextLevel.text = NSLocalizedString(@"Next Level", @"The title of a screen that displays the goals for the next level.");
	NSString *text = [[NSString alloc] initWithFormat: NSLocalizedString(@"%@ sales pitch.", @"Wordflick sales pitch."), @"Wordflick"];
	self.uILabelSalesPitch.text = text;
	text = nil;
	self.wordsTableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.wordsTableView flashScrollIndicators];
}

- (IBAction)buttonCheckDidTouchUpInside:(id)sender {
	[MNSAudio playButtonPress];
	[self.delegate viewControllerPreLevelIsDone: self];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 44.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
		return NSLocalizedString(@"Next Level", @"The title of a screen that displays the goals for the next level.");
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	CGRect resultFrame = CGRectMake(CGPointZero.x, CGPointZero.y, self.view.bounds.size.width, 44.0);
	UIView *resultView = [[UIView alloc] initWithFrame:resultFrame];
	resultFrame.origin.x = resultFrame.origin.x + 20.0;
	resultFrame.size.width = resultFrame.size.width - 20.0;
	resultView.backgroundColor = [UIColor clearColor];

	UILabel *result = [[UILabel alloc] initWithFrame:resultFrame];
	result.textAlignment = NSTextAlignmentLeft;
	result.textColor = [UIColor whiteColor];
	result.shadowColor = [UIColor grayColor];
	result.backgroundColor = [UIColor clearColor];
	result.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:22.0];
	result.text = NSLocalizedString(@"Next Level", @"The title of a screen that displays the goals for the next level.");
	[resultView addSubview:result];
	result = nil;
	
	return resultView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"TVCLevelStats";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	if (indexPath.section == 0) {
		switch (indexPath.row){
			case 0: {
				cell.textLabel.text = NSLocalizedString(@"Level", @"A label that is next to the level number or name they are about to play.");
				NSString *text = [[NSString alloc] initWithFormat:@"%ld", (long)[MNSUser CurrentUser].game.gameLevel.levelNumber];
				cell.detailTextLabel.text = text;
				text = nil;
				break;
			} case 1: {
				cell.textLabel.text = NSLocalizedString(@"Goal", @"A label that is next to the display of the number of points required to successfully complete the next level.");
				NSString *formatString = NSLocalizedString(@"%@ points", @"A display of points.  For example: '100 points' where %@ is the number of points.");
				NSNumber *goal = [[NSNumber alloc] initWithLongLong: [MNSUser CurrentUser].game.gameLevel.goal];
				NSString *displayString = [self.numberFormatterDecimal stringFromNumber: goal];
				NSString *text = [[NSString alloc] initWithFormat: formatString, displayString];
				cell.detailTextLabel.text = text;
				displayString = nil;
				text = nil;
				goal = nil;
				break;
			} case 2: {
				cell.textLabel.text = NSLocalizedString(@"Time", @"A label that is next to the display of the number of seconds the user has to successfully complete the next level.");
				NSString *formatString = NSLocalizedString(@"%@ seconds", @"A display of seconds.  For example: '100 seconds' where %@ is the number of seconds.");
				NSNumber *seconds = [[NSNumber alloc] initWithLongLong: [MNSUser CurrentUser].game.gameLevel.levelTime];
				NSString *displayString = [self.numberFormatterDecimal stringFromNumber: seconds];
				NSString *text = [[NSString alloc] initWithFormat: formatString, displayString];
				cell.detailTextLabel.text = text;
				text = nil;
				displayString = nil;
				seconds = nil;
				break;
			} default: {
				break;
			}
		}
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath { }

@end
