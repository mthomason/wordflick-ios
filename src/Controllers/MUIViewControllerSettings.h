//
//  MUIViewControllerSettings.h
//  wordPuzzle
//
//  Created by Michael Thomason on 05/29/12.
//  Copyright 2012 Michael Thomason. All rights reserved.
//

#ifndef MUIViewControllerSettings_h
#define MUIViewControllerSettings_h

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "wordPuzzleAppDelegate.h"
#import "UIColor+Wordflick.h"
#import "WFGameView.h"
#import "MTControllerCompletedProtocol.h"

@protocol MUIViewControllerSettingsDelegate <NSObject>
    - (void)viewControllerDidFinish:(id)sender;
@end

@interface MUIViewControllerSettings : UITableViewController

	@property (nonatomic, assign) id <MTControllerCompletedProtocol> delegate;
	@property (nonatomic, retain) IBOutlet UISwitch *switchBackgroundMusic;
	@property (nonatomic, retain) IBOutlet UISwitch *switchSoundEffects;
	@property (nonatomic, retain) IBOutlet UISlider *sliderBackgroundMusic;
	@property (nonatomic, retain) IBOutlet UILabel *labelBackgroundMusic;
	@property (nonatomic, retain) IBOutlet UILabel *labelSoundEffects;
	@property (nonatomic, retain) IBOutlet UINavigationItem *navigationItemSettings;

	- (IBAction)switchBackgroundMusicDidChange:(UISwitch *)sender;
	- (IBAction)switchSoundEffectsDidChange:(UISwitch *)sender;
	- (IBAction)sliderVolumeBackgroundMusicValueDidChange:(UISlider *)sender;

@end

#endif
