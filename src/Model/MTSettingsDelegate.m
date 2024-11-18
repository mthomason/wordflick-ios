//
//  MTSettingsDelegate.m
//  Wordflick-Pro
//
//  Created by Michael on 1/12/20.
//  Copyright © 2020 Michael Thomason. All rights reserved.
//

#import "MTSettingsDelegate.h"
#import "MNSUser.h"
#import "MTSettingsDataSource.h"
#import "MTWordflickButtonType.h"

@implementation MTSettingsDelegate

#pragma mark -
#pragma mark Table View Delegate Protocol

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSNumber *type = [(MTSettingsDataSource *)tableView.dataSource itemAtIndexPath:indexPath];
	MNSCellType cellType = type.intValue;
	
	switch (cellType) {
		case MNSCellTypeButtonDone:
			[self.controllerDelegate settingsControllerDidFinish:self];
			break;
		case MNSCellTypeButtonVolume:
			break;
		case MNSCellTypeButtonAllowSoundEffects:
			[MNSUser CurrentUser].desiresSoundEffects = ![MNSUser CurrentUser].desiresSoundEffects;
			[tableView cellForRowAtIndexPath:indexPath].accessoryType = [MNSUser CurrentUser].desiresSoundEffects ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
			break;
		case MNSCellTypeButtonAllowFancyLetters:
			[MNSUser CurrentUser].desiresStylizedFonts = ![MNSUser CurrentUser].desiresStylizedFonts;
			[tableView cellForRowAtIndexPath:indexPath].accessoryType = [MNSUser CurrentUser].desiresStylizedFonts ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
			break;

		default:
			break;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.row) {
		case 0:
			return 60.0;
			break;
		case 1:
			return 60.0;
			break;
		case 2:
			return 60.0;
			break;
		case 3:
			return 60.0;
			break;
		default:
			return 60.0;
			break;
	}
}

@end
