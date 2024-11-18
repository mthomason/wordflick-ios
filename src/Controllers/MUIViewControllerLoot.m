//
//  MUIViewControllerLoot.m
//  wordPuzzle
//
//  Created by Michael Thomason on 05/29/12.
//  Copyright 2023 Michael Thomason. All rights reserved.
//

#import "MUIViewControllerLoot.h"
#import "MNSAudio.h"
#import <MessageUI/MessageUI.h>
#import "wordPuzzleAppDelegate.h"
#import "WFGameView.h"
#import "UIColor+Wordflick.h"

@implementation MUIViewControllerLoot

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {

	}
	return self;
}


- (void)viewDidLoad {
	[super viewDidLoad];
	
	WFGameView *bgView = [[WFGameView alloc] initWithFrame: self.tableView.bounds];
	self.tableView.backgroundView = bgView;
	bgView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:YES];
	self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	self.labelShuffleBoosterCount.text = NSLocalizedString(@"0", @"Zer0");
	self.labelTimeBoosterCount.text = NSLocalizedString(@"0", @"Zer0");
	self.labelGoldTokenCount.text = NSLocalizedString(@"0", @"Zer0");
	self.labelSilverTokenCount.text = NSLocalizedString(@"0", @"Zer0");
	self.labelChadTokenCount.text = NSLocalizedString(@"0", @"Zer0");
	self.labelGoldTokens.text = NSLocalizedString(@"Gold Tokens", @"Label");
	self.labelSilverTokens.text = NSLocalizedString(@"Silver Tokens", @"Label");
	self.labelChadTokens.text = NSLocalizedString(@"Chad Tokens", @"Label");
	self.labelShuffleBoosters.text = NSLocalizedString(@"Bonus Shuffles", @"Label");
	self.labelTimeBoosters.text = NSLocalizedString(@"Time Boosters", @"Label");
	self.navigationItemLoot.title = NSLocalizedString(@"Total Loot", @"Navigation Title");
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:YES];
	[self.tableView flashScrollIndicators];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"segueLootDetails"]) {
		[MNSAudio playButtonPress];
	}
}

- (IBAction)doneButtonDidTouchUpInside:(id)sender {
	[self.delegate viewControllerDidFinish: self];
	[MNSAudio playButtonPress];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {

}

@end
