//
//  MUITableViewControllerAchievements.m
//  wordPuzzle
//
//  Created by Michael Thomason on 3/21/12.
//  Copyright (c) 2014 Michael Thomason. All rights reserved.
//

#import "MUITableViewControllerAchievements.h"
#import "wordPuzzleAppDelegate.h"
#import "MNSUser.h"
#import "WFUserStatistics.h"

static inline double PercentageOfPointsFromBonus(long long, long long);
static inline double PercentageOfPointsFromBonus(long long pointsFromBonus, long long totalPoints) {
	return pointsFromBonus == 0 ? 0.0 : ((double)totalPoints / (double)pointsFromBonus) * 100.0;
}

@implementation MUITableViewControllerAchievements

- (void)dealloc {
	_tableViewCellAchievementTotalPoints = nil;
	_tableViewCellAchievementTotalPointsFromBonusTiles = nil;
	_tableViewCellAchievementTotalTime = nil;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.tableView.backgroundView.backgroundColor = [UIColor redColor];

	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;

	MNSUser *user = [MNSUser CurrentUser];

	NSString *format = NSLocalizedString(@"%@ points", @"A display of points.  For example: '100 points' where %@ is the number of points.");
	
	NSNumber *points = [[NSNumber alloc] initWithLongLong: user.statisticsUser.totalPoints];
	NSString *totalPoints = [numberFormatter stringFromNumber: points];
	points = nil;

	self.tableViewCellAchievementTotalPoints.textLabel.text = NSLocalizedString(@"Total Points Ever", @"Label for game statistics.");

	NSString *formattedString = [[NSString alloc] initWithFormat:format, totalPoints];
	self.tableViewCellAchievementTotalPoints.detailTextLabel.text = formattedString;
	formattedString = nil;
	numberFormatter = nil;
	
	double percentage = PercentageOfPointsFromBonus(user.statisticsUser.totalPointsFromBonusTiles, user.statisticsUser.totalPoints);
	NSMutableString *percentString = [[NSMutableString alloc] initWithFormat:@"%0.2f", percentage];
	[percentString appendString:@" %"];
	self.tableViewCellAchievementTotalPointsFromBonusTiles.textLabel.text = NSLocalizedString(@"% from bonus tiles", @"Label for game statistics.");
	self.tableViewCellAchievementTotalPointsFromBonusTiles.detailTextLabel.text = percentString;
	percentString = nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath { }

@end
