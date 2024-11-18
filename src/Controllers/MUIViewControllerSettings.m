//
//  MUIViewControllerSettings.m
//  wordPuzzle
//
//  Created by Michael Thomason on 05/29/12.
//  Copyright 2012 Michael Thomason. All rights reserved.
//

#import "MUIViewControllerSettings.h"
#import "MNSUser.h"
#import "MNSAudio.h"

@implementation MUIViewControllerSettings

- (void)dealloc {
	_switchBackgroundMusic = nil;
	_sliderBackgroundMusic = nil;
	_switchSoundEffects = nil;
	_labelBackgroundMusic = nil;
	_labelSoundEffects = nil;
	_navigationItemSettings = nil;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	WFGameView *bgView = [[WFGameView alloc] initWithFrame: [[self tableView] bounds]];
	self.tableView.backgroundView = bgView;
	bgView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:YES];

	
	self.tableView.backgroundView.backgroundColor = [UIColor patternUIImagePatternGearsBlue];
	self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;

	self.switchSoundEffects.on = [MNSUser CurrentUser].desiresSoundEffects;
	BOOL backgroundMusicEnabled = [MNSUser CurrentUser].desiresBackgroundMusic;
	self.switchBackgroundMusic.on = backgroundMusicEnabled;
	self.sliderBackgroundMusic.enabled = backgroundMusicEnabled;
	
	self.sliderBackgroundMusic.value = [MNSUser CurrentUser].desiredVolume;
	self.sliderBackgroundMusic.minimumValueImage = [UIImage imageNamed:@"UIImageMinVol"];
	self.sliderBackgroundMusic.maximumValueImage = [UIImage imageNamed:@"UIImageMaxVol"];

	self.labelBackgroundMusic.text = NSLocalizedString(@"Background Music", @"A label for a switch that will allow the users to turn on or off the background music.");
	self.labelSoundEffects.text = NSLocalizedString(@"Sound Effects", @"A label for a switch that will allow the users to turn on or off the sound effects.");
	self.navigationItemSettings.title = NSLocalizedString(@"Settings", @"Title of a screen that allows users to change the settings.");
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if (animated) {
		[self.tableView flashScrollIndicators];
	}
}

- (IBAction)switchBackgroundMusicDidChange:(UISwitch *)sender {
	[MNSUser CurrentUser].desiresBackgroundMusic = sender.isOn;
	self.sliderBackgroundMusic.enabled = sender.isOn;
}

- (IBAction)switchSoundEffectsDidChange:(UISwitch *)sender {
	[MNSUser CurrentUser].desiresSoundEffects = sender.isOn;
}

- (IBAction)sliderVolumeBackgroundMusicValueDidChange:(UISlider *)sender {
	[MNSUser CurrentUser].desiredVolume = sender.value;
}

- (IBAction)doneButtonDidTouchUpInside:(id)sender {
	[[self delegate] viewControllerDidFinish: self];
	[MNSAudio playButtonPress];
}

@end
