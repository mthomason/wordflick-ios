//
//  MTIntroductionDelegate.m
//  Wordflick-Pro
//
//  Created by Michael on 1/4/20.
//  Copyright © 2020 Michael Thomason. All rights reserved.
//

#import "MTIntroductionDelegate.h"
#import <GameKit/GameKit.h>
#import "MTGameActionProtocol.h"
#import "MTIntroductionDataSource.h"
#import "MNSAudio.h"
#import "MTWordflickButtonType.h"
#import "MTGameType.h"

@interface MTIntroductionDelegate()
	@property (nonatomic, assign) id<MTGameActionProtocol> wordNerdActionDelegate;
@end

@implementation MTIntroductionDelegate

- (void)dealloc {
	_wordNerdActionDelegate = nil;
}

- (instancetype)initGameActionDelegate:(id<MTGameActionProtocol>)gameActionDelegate {
	if (self = [super init]) {
		_wordNerdActionDelegate = gameActionDelegate;
	}
	return self;
}

#pragma mark -
#pragma mark Table View Delegate Protocol

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	//NSAssert([tableView.dataSource isKindOfClass:[MTIntroductionDataSource class]], @"Expect a MTIntroductionDataSource.");

	NSNumber *type = [(MTIntroductionDataSource *)tableView.dataSource itemAtIndexPath:indexPath];
	MNSCellType cellType = type.intValue;
	
	[MNSAudio playButtonPress];
	
	switch (cellType) {
		case MNSCellTypeButtonPlayerSettings:
			[self.wordNerdActionDelegate showGameScreen:self screenType:MTGameScreenPlayerSettings];
			break;
		case MNSCellButtonAbout:
			[self.wordNerdActionDelegate showGameScreen:self screenType:MUIGameScreenAbout];
			break;
		case MNSCellTypeButtonSettings:
			[self.wordNerdActionDelegate showGameScreen:self screenType:MTGameScreenSettings];
			break;
		case MNSCellTypeButtonLoot:
			[self.wordNerdActionDelegate showGameScreen:self screenType:MTGameScreenLoot];
			break;
		case MNSCellTypeButtonStart:
			[self.wordNerdActionDelegate playGame:self gameType:Wordflick];
			break;
		case MNSCellTypeButtonWordflickClassic:
			[self.wordNerdActionDelegate playGame:self gameType:WordflickClassic];
			break;
		case MNSCellTypeButtonWordflickFastBreak:
			[self.wordNerdActionDelegate playGame:self gameType:WordflickFastBreak];
			break;
		case MNSCellTypeButtonWordflickFreePlay:
			[self.wordNerdActionDelegate playGame:self gameType:WordflickFreePlay];
			break;
		case MNSCellTypeButtonWordflickJr:
			[self.wordNerdActionDelegate playGame:self gameType:WordflickJr];
			break;
		case MNSCellTypeButtonWordflickDebug:
			[self.wordNerdActionDelegate playGame:self gameType:WordflickDebug];
			break;
		case MNSCellTypeButtonResume:
			[self.wordNerdActionDelegate resumeGame:self];
			break;
		case MNSCellTypeButtonHighScores:
			[self.wordNerdActionDelegate showGameScreen:self screenType:MUIGameScreenHighScores];
			break;
		case MNSCellTypeButtonAchievements:
			[self.wordNerdActionDelegate showGameScreen:self screenType:MTGameScreenAchievements];
		case MNSCellTypeButtonTwitterLogin:
			[self.wordNerdActionDelegate showGameScreen:self screenType:MTGameScreenTwitterLogin];
			break;
		case MNSCellTypeButtonFacebookLogin:
			[self.wordNerdActionDelegate showGameScreen:self screenType:MTGameScreenFacebookLogin];
			break;
		default:
			NSAssert(false, @"Didn't expect to get here");
			break;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60.0f;
}

@end
