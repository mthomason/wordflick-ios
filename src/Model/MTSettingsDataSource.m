//
//  MTSettingsDataSource.m
//  Wordflick-Pro
//
//  Created by Michael on 1/12/20.
//  Copyright © 2020 Michael Thomason. All rights reserved.
//

#import "MTSettingsDataSource.h"
#import "MNSUser.h"
#import "MTWordflickButtonType.h"
#import "MUITableViewCellIntroductionButton.h"

@interface MTSettingsDataSource ()
	@property (nonatomic, retain) NSArray <NSNumber *> *items;
@end

@implementation MTSettingsDataSource

- (void)dealloc {
	_items = nil;
}

- (instancetype)init {
	if (self = [super init]) {
		_items = [[NSArray alloc] initWithObjects:
				  @(MNSCellTypeButtonBlank),
				  @(MNSCellTypeButtonDone),
				  @(MNSCellTypeButtonAllowSoundEffects),
				  @(MNSCellTypeButtonAllowFancyLetters),
				  //@(MNSCellTypeButtonVolume),
				  nil];
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
	NSString *identifier = [NSString stringWithFormat:@"MUITableViewCellSettings%ld", (long)indexPath.row];
	cell = (MUITableViewCellIntroductionButton *)[tableView dequeueReusableCellWithIdentifier: identifier];

	NSArray *topLevelObjects  = [[NSBundle mainBundle] loadNibNamed:@"MUITableViewCellIntroductionButton" owner:self options:nil];
		for (id currentObject in topLevelObjects) {
			if ([currentObject isKindOfClass:[UITableViewCell class]]) {
				cell = (MUITableViewCellIntroductionButton *)currentObject;
				cell.textLabel.highlightedTextColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"MUIImageGradentControl"]];
				cell.textLabel.textColor = [UIColor colorWithRed:252.0f/255.0f green:251.0f/255.0f
															blue:251.0f/255.0f alpha:1.0f];

				cell.textLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleHeadline] size:16.0];
				//cell.textLabel.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:16.0];
				cell.textLabel.shadowColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"MUIImageGradentControl"]];
				cell.textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
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

- (MUITableViewCellIntroductionButton *)setupCell:(MUITableViewCellIntroductionButton *)cell asCellType:(MNSCellType)celltype {

	switch (celltype) {
			
		case MNSCellTypeButtonDone: {
			UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UIImageButtonMaster"]];
			cell.backgroundView = imageView;
			imageView = nil;

			UIImageView *imageViewActive = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UIImageButtonMasterActive"]];
			cell.selectedBackgroundView = imageViewActive;
			imageViewActive = nil;

			cell.imageView.image = [UIImage imageNamed:@"xmark.circle.fill"];
			cell.textLabel.text = NSLocalizedString(@"Dismiss", @"Dismiss");;
			//cell.textLabel.text = NSLocalizedString(@"Dismiss", @"Dismiss");
			cell.tintColor = [UIColor systemYellowColor];
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		break;
		
		case MNSCellTypeButtonVolume: {
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.tintColor = [UIColor systemYellowColor];

			UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UIImageButtonMaster"]];
			cell.backgroundView = imageView;
			imageView = nil;

			UIImageView *imageViewActive = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UIImageButtonMasterActive"]];
			cell.selectedBackgroundView = imageViewActive;
			imageViewActive = nil;

			cell.imageView.image = [UIImage imageNamed:@"gear"];

			UISlider *slider = nil;
			if (cell.accessoryView != nil) {
				 slider = [[UISlider alloc] initWithFrame:cell.accessoryView.bounds];
				[cell.accessoryView addSubview:slider];
			} else {
				slider = [[UISlider alloc] initWithFrame:cell.accessoryView.bounds];
				cell.accessoryView = slider;
				slider = nil;
			}
			slider.value = [MNSUser CurrentUser].desiredVolume;;
			slider.minimumValueImage = [UIImage imageNamed:@"UIImageMinVol"];
			slider.maximumValueImage = [UIImage imageNamed:@"UIImageMaxVol"];
			[slider addTarget:self action:@selector(sliderVolumeBackgroundMusicValueDidChange:) forControlEvents:UIControlEventValueChanged];

			cell.textLabel.text = NSLocalizedString(@"Setting", @"Button title for the settings menu.");
		}

		break;
		case MNSCellTypeButtonAllowSoundEffects: {
			cell.accessoryType = [MNSUser CurrentUser].desiresSoundEffects ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
			cell.tintColor = [UIColor systemYellowColor];

			UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UIImageButtonMaster"]];
			cell.backgroundView = imageView;
			imageView = nil;
			
			UIImageView *imageViewActive = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UIImageButtonMasterActive"]];
			cell.selectedBackgroundView = imageViewActive;
			imageViewActive = nil;
			
			cell.imageView.image = [UIImage imageNamed:@"speaker.fill"];
			cell.textLabel.text = NSLocalizedString(@"Sound Effects", @"A label for a switch that will allow the users to turn on or off the sound effects.");
		}

		break;
		case MNSCellTypeButtonAllowFancyLetters: {
			cell.accessoryType = [MNSUser CurrentUser].desiresStylizedFonts ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
			cell.tintColor = [UIColor systemYellowColor];

			UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UIImageButtonMaster"]];
			cell.backgroundView = imageView;
			imageView = nil;

			UIImageView *imageViewActive = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UIImageButtonMasterActive"]];
			cell.selectedBackgroundView = imageViewActive;
			imageViewActive = nil;

			cell.imageView.image = [UIImage imageNamed:@"gear"];
			cell.textLabel.text = NSLocalizedString(@"Stylized Tiles", @"Stylized Tiles");
		}

			break;

		default: {
			UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.frame];
			imageView.backgroundColor = [UIColor clearColor];
			cell.selectedBackgroundView = imageView;
			imageView = nil;
		}
			break;
	}
	return cell;
}

- (IBAction)sliderVolumeBackgroundMusicValueDidChange:(UISlider *)sender {
	[MNSUser CurrentUser].desiredVolume = sender.value;
}

@end
