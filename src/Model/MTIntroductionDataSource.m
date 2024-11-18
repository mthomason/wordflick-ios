//
//  UIArrayDataSource.m
//  Wordflick-Pro
//
//  Created by Michael on 11/18/19.
//  Copyright © 2019 Michael Thomason. All rights reserved.
//

#import "MTIntroductionDataSource.h"
#import "MUITableViewCellIntroductionButton.h"
#import "WFIntroductionViewController.h"
#import "MTWordflickButtonType.h"
#import "MNSUser.h"

@interface MTIntroductionDataSource ()

@property (nonatomic, retain) NSArray <NSNumber *> *items;
@property (copy) MTTableViewCellConfigureBlock configureCell;

@end

@implementation MTIntroductionDataSource

- (void)dealloc {
	_items = nil;
	_configureCell = nil;
}

- (nullable instancetype)init {
	return nil;
}

- (instancetype)init:(void (^ __nullable)(__kindof UITableViewCell *cell, id item))configureCell {
	if (self = [super init]) {
		self.items = [MNSUser CurrentUser].askToResume ?
							@[@(MNSCellTypeButtonBlank),
							  @(MNSCellTypeButtonResume),
							  @(MNSCellTypeButtonStart),
							  //@(MNSCellTypeButtonWordflickFastBreak),
							  //@(MNSCellTypeButtonWordflickFreePlay),
							  @(MNSCellTypeButtonAchievements),
							  @(MNSCellTypeButtonHighScores),
							  @(MNSCellTypeButtonSettings)] :
							@[@(MNSCellTypeButtonBlank),
							  @(MNSCellTypeButtonStart),
							  //@(MNSCellTypeButtonWordflickFastBreak),
							  //@(MNSCellTypeButtonWordflickFreePlay),
							  @(MNSCellTypeButtonAchievements),
							  @(MNSCellTypeButtonHighScores),
							  @(MNSCellTypeButtonSettings)];

		_configureCell = [configureCell copy];
	}
	return self;
}

- (NSNumber *)itemAtIndexPath:(NSIndexPath *)indexPath {
	return self.items[(NSUInteger) indexPath.row];
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
	return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	MUITableViewCellIntroductionButton *cell;
	NSString *identifier = [NSString stringWithFormat:@"MUITableViewCellIntroductionButton%ld", (long)indexPath.row];
	cell = (MUITableViewCellIntroductionButton *)[tableView dequeueReusableCellWithIdentifier: identifier];

	NSArray *topLevelObjects  = [[NSBundle mainBundle] loadNibNamed: NSStringFromClass([MUITableViewCellIntroductionButton class])
															  owner: self
															options: nil];
		for (id currentObject in topLevelObjects) {
			if ([currentObject isKindOfClass:[UITableViewCell class]]) {
				cell = (MUITableViewCellIntroductionButton *)currentObject;
				UIImage *gradientControl = [UIImage imageNamed: @"MUIImageGradentControl"];
				cell.textLabel.highlightedTextColor = [UIColor colorWithPatternImage: gradientControl];
				
				cell.textLabel.textColor = [UIColor colorWithRed: 252.0 / 255.0
														   green: 251.0 / 255.0
															blue: 251.0 / 255.0
														   alpha: 1.0];

				cell.textLabel.font = [UIFont fontWithDescriptor: [UIFontDescriptor preferredFontDescriptorWithTextStyle: UIFontTextStyleHeadline]
															size: 16.0];
				cell.textLabel.shadowColor = [UIColor colorWithPatternImage: gradientControl];
				cell.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
				if ((NSUInteger)indexPath.row < self.items.count) {    //One of the standard buttons
					NSNumber *buttonTypes = [self.items objectAtIndex:indexPath.row];
					cell = [self setupCell:cell asCellType:(MNSCellType)buttonTypes.intValue];
				}
				break;
			}
		}
	cell.autoresizingMask = UIViewAutoresizingNone;
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath { }

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath { }

#pragma mark Helpers

__attribute__((deprecated))
static void setupTableViewCell(MUITableViewCellIntroductionButton *cell, NSString *imageName) {
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UIImageButtonMaster"]];
	UIImageView *imageViewActive = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UIImageButtonMasterActive"]];
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.tintColor = [UIColor systemYellowColor];
	cell.backgroundView = imageView;
	cell.selectedBackgroundView = imageViewActive;
	cell.imageView.image = [UIImage imageNamed: imageName];
	imageView = nil;
	imageViewActive = nil;
}

static void setupTableViewCellSystemImage(MUITableViewCellIntroductionButton *cell,
										  NSString *systemImageName) {
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UIImageButtonMaster"]];
	UIImageView *imageViewActive = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UIImageButtonMasterActive"]];
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.tintColor = [UIColor systemYellowColor];
	cell.backgroundView = imageView;
	cell.selectedBackgroundView = imageViewActive;
	if (@available(iOS 13.0, *)) {
		cell.imageView.image = [UIImage systemImageNamed: systemImageName];
	} else {
		cell.imageView.image = [UIImage imageNamed: systemImageName];
	}
	imageView = nil;
	imageViewActive = nil;
}

- (MUITableViewCellIntroductionButton *)setupCell:(MUITableViewCellIntroductionButton *)cell asCellType:(MNSCellType)celltype {
	switch (celltype) {
		case MNSCellTypeButtonSettings: {
			setupTableViewCellSystemImage(cell, @"gear");
			cell.textLabel.text = NSLocalizedString(@"Setting", @"Button Label");
			break;
		}
		case MNSCellTypeButtonLoot: {
			UIImageView *uIImageViewBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MUIImageButtonMoneyBags"]];
			cell.backgroundView = uIImageViewBackgroundView;
			uIImageViewBackgroundView = nil;

			UIImageView *uIImageViewSelectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MUIImageButtonMoneyBagsActive"]];
			cell.selectedBackgroundView = uIImageViewSelectedBackgroundView;
			uIImageViewSelectedBackgroundView = nil;

			cell.textLabel.text = NSLocalizedString(@"Loot", @"Button Label");
			break;
		}
		case MNSCellTypeButtonTwitterLogin:
			setupTableViewCellSystemImage(cell, @"star.fill");
			cell.textLabel.text = NSLocalizedString(@"Login to Twitter", @"Button Label");
			break;
		case MNSCellTypeButtonFacebookLogin:
			setupTableViewCellSystemImage(cell, @"star.fill");
			cell.textLabel.text = NSLocalizedString(@"Login to Facebook", @"Button Label");
			break;
		case MNSCellTypeButtonStart: {
			setupTableViewCellSystemImage(cell, @"star.fill");
			NSString *t;
			if ([MNSUser CurrentUser] != nil) {
				if ([[MNSUser displayUsername] isEqualToString:@""]) {
					t = NSLocalizedString(@"New Game", @"New Game");
				} else {
					t = [NSString stringWithFormat:NSLocalizedString(@"Play as %@", @"A button that when pressed will start the game as the user with the name '%@.'"), [MNSUser displayUsername]];
				}
			} else {
				t = NSLocalizedString(@"New Game", @"New Game");
			}
			cell.textLabel.text = t;
			break;
		}
		case MNSCellTypeButtonResume: {
			setupTableViewCellSystemImage(cell, @"star.fill");
			cell.textLabel.text = NSLocalizedString(@"Resume Game", @"Button Label");
			break;
		}
		case MNSCellTypeButtonWordflickDebug: {
			setupTableViewCellSystemImage(cell, @"star.fill");
			cell.textLabel.text = NSLocalizedString(@"Wordflick Debug", @"Button Label");
			break;
		}
		case MNSCellTypeButtonWordflickClassic: {
			setupTableViewCellSystemImage(cell, @"star.fill");
			cell.textLabel.text = NSLocalizedString(@"Wordflick Classic", @"Button Label");
			break;
		}
		case MNSCellTypeButtonWordflickFastBreak: {
			setupTableViewCellSystemImage(cell, @"star.fill");
			cell.textLabel.text = NSLocalizedString(@"Fast Play", @"Button Label");
			break;
		}
		case MNSCellTypeButtonWordflickFreePlay: {
			setupTableViewCellSystemImage(cell, @"star.fill");
			cell.textLabel.text = NSLocalizedString(@"Open Play", @"Button Label");
			break;
		}
		case MNSCellTypeButtonWordflickJr: {
			setupTableViewCellSystemImage(cell, @"star.fill");
			cell.textLabel.text = NSLocalizedString(@"Wordflick Jr.", @"Button Label");
			break;
		}
		case MNSCellTypeButtonPlayerSettings: {
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.tintColor = [UIColor systemYellowColor];
			UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UIImageButtonMaster"]];
			cell.backgroundView = imageView;
			imageView = nil;
			UIImageView *imageViewActive = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UIImageButtonMasterActive"]];
			cell.selectedBackgroundView = imageViewActive;
			imageViewActive = nil;
			cell.imageView.image = [UIImage imageNamed:@"gear"];
			cell.textLabel.text = NSLocalizedString(@"Player Settings", @"Player Settings");
			break;
		}
		case MNSCellTypeButtonAchievements: {
			UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UIImageButtonMaster"]];
			cell.backgroundView = bgImageView;
			bgImageView = nil;

			UIImageView *bgImageViewActive = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UIImageButtonMasterActive"]];
			cell.selectedBackgroundView = bgImageViewActive;
			bgImageViewActive = nil;

			cell.imageView.image = [UIImage imageNamed:@"rosette"];
			cell.tintColor = [UIColor systemYellowColor];

			cell.textLabel.text = NSLocalizedString(@"Achievements", @"Achievements");
			break;
		}
		case MNSCellTypeButtonHighScores: {
			UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UIImageButtonMaster"]];
			cell.backgroundView = bgImageView;
			bgImageView = nil;

			UIImageView *bgImageViewActive = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UIImageButtonMasterActive"]];
			cell.selectedBackgroundView = bgImageViewActive;
			bgImageViewActive = nil;

			cell.imageView.image = [UIImage imageNamed:@"rhombus.fill"];
			cell.tintColor = [UIColor systemYellowColor];

			cell.textLabel.text = NSLocalizedString(@"High Scores", @"High Scores");
			break;
		}
		case MNSCellButtonAbout: {
			UIImageView *uIImageViewBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MUIImageButtonLightbulb"]];
			cell.backgroundView = uIImageViewBackgroundView;
			uIImageViewBackgroundView = nil;

			UIImageView *uIImageViewSelectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MUIImageButtonLightbulbActive"]];
			cell.selectedBackgroundView = uIImageViewSelectedBackgroundView;
			uIImageViewSelectedBackgroundView = nil;

			cell.textLabel.text = NSLocalizedString(@"About", @"About");
			break;
		}
		case MNSCellTypeButtonBlank:
		default: {
			UIImageView *uIViewSelectedBackgroundView = [[UIImageView alloc] initWithFrame:[cell frame]];
			uIViewSelectedBackgroundView.backgroundColor = [UIColor clearColor];
			cell.selectedBackgroundView = uIViewSelectedBackgroundView;
			uIViewSelectedBackgroundView = nil;
			break;
		}
	}
	if (cell) {
		cell.backgroundColor = [UIColor clearColor];
		cell.opaque = NO;
	}
	return cell;
}

@end
