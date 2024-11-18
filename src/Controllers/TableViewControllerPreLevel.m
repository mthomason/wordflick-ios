//
//  TableViewControllerPreLevel.m
//  wordPuzzle
//
//  Created by Michael Thomason on 3/25/12.
//  Copyright (c) 2023 Michael Thomason. All rights reserved.
//

#import "TableViewControllerPreLevel.h"
#import "MNSUser.h"
#import "MNSGame.h"
#import "WFLevelStatistics.h"

@interface TableViewControllerPreLevel ()

@end

@implementation TableViewControllerPreLevel

- (void)dealloc {
	_labelGameName = nil;
	_labelGameNameDetail = nil;
	_labelLevelNumber = nil;
	_labelLevelNumberDetail = nil;
	_labelLevelName = nil;
	_labelLevelNameDetail = nil;
	_labelObjective = nil;
	_labelObjectiveDetail = nil;
	_labelTime = nil;
	_labelTimeDetail = nil;
	_labelShuffles = nil;
	_labelShufflesDetail = nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {

	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	UITableView *tableView = self.tableView;
	UIView *backgroundView = [[UIView alloc] initWithFrame: tableView.bounds];
	tableView.backgroundView = backgroundView;
	backgroundView = nil;
	tableView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear: animated];
	self.tableView.backgroundView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	self.labelGameName.text = NSLocalizedString(@"Game Name", @"Game Name");
	self.labelLevelName.text = NSLocalizedString(@"Level Name", @"Level Name");
	self.labelLevelNumber.text = NSLocalizedString(@"Level Number", @"Level Number");
	self.labelObjective.text = NSLocalizedString(@"Objective", @"Objective");
	self.labelTime.text = NSLocalizedString(@"Time", @"A label that is next to the display of the number of seconds the user has to successfully complete the next level.");
	self.labelShuffles.text = NSLocalizedString(@"Shuffles", @"Shuffles");

	MNSGame *game = [MNSUser CurrentUser].game;
	
	self.labelGameNameDetail.text = game.displayName;
	self.labelLevelNameDetail.text = game.levelName;
	
	WFLevelStatistics *gameLevel = game.gameLevel;
	
	self.labelLevelNumberDetail.text = gameLevel.levelNumberDisplay;
	self.labelObjectiveDetail.text = gameLevel.levelGoalDisplay;
	
	self.labelTimeDetail.text = gameLevel.levelTimeDetailDisplay;
	self.labelShufflesDetail.text = gameLevel.levelShuffleDetailDisplay;
	
	gameLevel = nil;
	game = nil;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.tableView flashScrollIndicators];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath { }

@end
