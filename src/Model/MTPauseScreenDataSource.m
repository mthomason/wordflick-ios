//
//  MTPauseScreenDataSource.m
//  Wordflick-Pro
//
//  Created by Michael on 1/14/20.
//  Copyright © 2020 Michael Thomason. All rights reserved.
//

#import "MTPauseScreenDataSource.h"
#import "MNSUser.h"
#import "MNSGame.h"
#import "WFLevelStatistics.h"
#import "MTAbortView.h"

@interface MTPauseScreenDataSource () {
	bool _abortButtonEnabled;
}

@end

@implementation MTPauseScreenDataSource

- (instancetype)init {
	if (self = [super init]) {
		_abortButtonEnabled = false;
	}
	return self;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 4;
			break;
		case 1:
			return 3;
			break;
		default:
			return 0;
			break;
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 3) {
		[((MTAbortView *)cell.accessoryView).abortButton addTarget:self action:@selector(abortButtonDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
		[((MTAbortView *)cell.accessoryView).saftySwitch addTarget:self action:@selector(switchAbortLevelValueDidChange:) forControlEvents:UIControlEventValueChanged];
	}
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 3) {
		[((MTAbortView *)cell.accessoryView).abortButton removeTarget:self action:@selector(abortButtonDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
		[((MTAbortView *)cell.accessoryView).saftySwitch removeTarget:self action:@selector(switchAbortLevelValueDidChange:) forControlEvents:UIControlEventValueChanged];
	}
}

static NSString * _Nonnull totalPointsDetailDisplay(MNSGame *game) {
	return [NSString stringWithFormat:@"%ld/%ld", (long)[game.gameLevel totalPoints], (long)game.gameLevel.goal];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *detailIdentifier = @"MTPauseDetailTableViewCellIdentifier";
	static NSString *abortIdentifier = @"MTPauseAbortTableViewCellIdentifier";
	UITableViewCell *cell;
	switch (indexPath.section) {
		case 0:
			
			switch (indexPath.row) {
				case 0:
					cell = [tableView dequeueReusableCellWithIdentifier: detailIdentifier];
					cell.textLabel.text = NSLocalizedString(@"Points", @"Points");
					cell.detailTextLabel.text = totalPointsDetailDisplay([MNSUser CurrentUser].game);
					break;
				case 1:
					cell = [tableView dequeueReusableCellWithIdentifier: detailIdentifier];
					cell.textLabel.text = NSLocalizedString(@"Time", @"Label");
					cell.detailTextLabel.text = [[MNSUser CurrentUser].game timerDisplay];
					break;
					
				case 2:
					cell = [tableView dequeueReusableCellWithIdentifier: detailIdentifier];
					cell.textLabel.text = NSLocalizedString(@"Shuffles", @"Shuffles");
					cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)[MNSUser CurrentUser].game.numberOfShakes];
					break;

				case 3:
					cell = [tableView dequeueReusableCellWithIdentifier: abortIdentifier];
					cell.textLabel.text = NSLocalizedString(@"Abort Level", @"Abort Level");
					((MTAbortView *)cell.accessoryView).abortButton.titleLabel.text = NSLocalizedString(@"Abort", @"Abort");
					((MTAbortView *)cell.accessoryView).abortButton.enabled = _abortButtonEnabled;
					[((MTAbortView *)cell.accessoryView).saftySwitch setOn: _abortButtonEnabled ? YES : NO];
					break;

				default:
					@throw NSInvalidArgumentException;
					break;
			}
			
			break;

		default:
			@throw NSInvalidArgumentException;
			break;
	}
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return NSLocalizedString(@"Level Status", @"Level Status");
			break;
		default:
			return @"";
			break;
	}
}

- (IBAction)abortButtonDidTouchUpInside:(id)sender {
	[self.delegate pauseScreenDidAbortLevel];
}

- (IBAction)switchAbortLevelValueDidChange:(UISwitch *)sender {
	_abortButtonEnabled = sender.isOn ? true : false;
}

@end
