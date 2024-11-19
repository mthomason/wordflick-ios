//
//  MUIViewControllerPreGame.m
//  wordPuzzle
//
//  Created by Michael Thomason on 4/21/12.
//  Copyright (c) 2023 Michael Thomason. All rights reserved.
//

#import "MUIViewControllerPreGame.h"
#import "MNSAudio.h"
#import "MNSGame.h"
#import "MNSUser.h"
#import "UIColor+Wordflick.h"

@interface MUIViewControllerPreGame ()
	@property (nonatomic, assign) BOOL adDisplayed;
@end

@implementation MUIViewControllerPreGame

- (void)dealloc {
	_logoImage = nil;
	_storeBackgroundView = nil;
	_labelGoldTokens = nil;
	_labelSilverTokens = nil;
	_labelChadTokens = nil;
	_buttonQuit = nil;
	_tableViewMain = nil;
	_buttonStore = nil;
	_imageViewGoldCoin = nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
	
	}
	return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.storeBackgroundView.layer.cornerRadius = 5.0;
	[self setAdDisplayed:NO];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.tableViewMain setAlpha:0.0];
	[[self buttonQuit] setAlpha:0.0];

	UIEdgeInsets inset = UIEdgeInsetsMake(UIEdgeInsetsZero.top + 60.0, UIEdgeInsetsZero.left, UIEdgeInsetsZero.bottom, UIEdgeInsetsZero.right);
	[self.tableViewMain setScrollIndicatorInsets: inset];

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		
		BOOL isPortrait = false;
		
		if (@available(iOS 13.0, *)) {
			isPortrait = UIInterfaceOrientationIsPortrait(self.view.window.windowScene.interfaceOrientation);
		} else {
			// Fallback on earlier versions
			if (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
				isPortrait = YES;
			} else if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
				isPortrait = NO;
			} else {
				isPortrait = UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation);
			}
		}
		
		if (isPortrait) {
			CGPoint currentframeOrigin = self.tableViewMain.frame.origin;
			self.tableViewMain.frame = CGRectMake(currentframeOrigin.x, currentframeOrigin.y,
												  245.0f, 297.0f);
		} else {
			CGRect currentframe = self.tableViewMain.frame;
			self.tableViewMain.frame = CGRectMake(currentframe.origin.x, currentframe.origin.y,
												  currentframe.size.width,
												  300.0f - currentframe.origin.y);
		}
	}
	
	self.view.backgroundColor = [UIColor patternForId:([MNSUser CurrentUser].highestLevelUnlocked - 1)];

	self.tableViewMain.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];

	NSString *zero = [numberFormatter stringFromNumber: [NSNumber numberWithInteger:0]];
	self.labelGoldTokens.text = zero;
	self.labelSilverTokens.text = zero;
	self.labelChadTokens.text = zero;
	
	self.labelGoldTokens.font = [UIFont fontWithName: @"HelveticaNeue-CondensedBlack" size: 24.0f];
	self.labelGoldTokens.minimumScaleFactor = -4.0f;
	
	[self.buttonStore setTitle: NSLocalizedString(@"Store", @"Store")
					  forState: UIControlStateNormal];

	numberFormatter = nil;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[UIView animateWithDuration: 0.9
					 animations: ^{
		self.tableViewMain.alpha = 1.0f;
		self.buttonQuit.alpha = 1.0f;
	} completion:^(BOOL finished) {
		[self.tableViewMain flashScrollIndicators];
	}];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[UIView animateWithDuration: 0.9
					 animations: ^{
		self.tableViewMain.alpha = 0.0f;
		self.buttonQuit.alpha = 0.0f;
	} completion:^(BOOL finished) {
	}];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	self.tableViewMain.alpha = 0.0f;
	self.buttonQuit.alpha = 0.0f;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"seguePlay"]) {
		[segue.destinationViewController setDelegate: self];
		if (sender != nil) {    //This is the case when restarting
			NSInteger startingLevel = [sender longValue];
			MNSGame *game = [[MNSGame alloc] initWithType: [self gametype]
												   userID: @""
										 andStartingLevel: startingLevel];
			[game setDelegate:segue.destinationViewController];
			[[MNSUser CurrentUser] setGame:game];
			game = nil;
			[MNSAudio playButtonPress];
		}
	}
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection
			  withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
	[super willTransitionToTraitCollection: newCollection
				 withTransitionCoordinator: coordinator];
	if (newCollection.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
		BOOL isPortrait;
		if (@available(iOS 13.0, *)) {
			isPortrait = UIInterfaceOrientationIsPortrait(self.view.window.windowScene.interfaceOrientation);
		} else {
			// Fallback on earlier versions
			if (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
				isPortrait = YES;
			} else if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
				isPortrait = NO;
			} else {
				isPortrait = UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation);
			}
		}
		
		CGRect currentframe = self.tableViewMain.frame;
		CGRect newFrame = CGRectZero;
		if (isPortrait) {
			newFrame = CGRectMake(currentframe.origin.x, currentframe.origin.y, 245.0, 297.0);
		} else {
			newFrame = CGRectMake(currentframe.origin.x, currentframe.origin.y, currentframe.size.width, 300.0 - currentframe.origin.y);
		}
		[coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
			[context.containerView setNeedsDisplay];
		} completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
			[context.containerView setFrame:newFrame];
		}];
		//[UIView animateWithDuration:duration animations:^{
		//	[self.tableViewMain setFrame:newFrame];
		//}];
	}
}

- (void)viewWillTransitionToSize:(CGSize)size
	   withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark -
#pragma mark Word Puzzle Delegate

- (void)gameIsOver:(id)sender {		//Nothing more to do here, go back to intro, yo
	[self.delegate gameIsOver: self];
}

#pragma mark -
#pragma mark Table View Data Source Protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = [NSString stringWithFormat:@"MUITableViewCellIntroductionButton%ld", (long)indexPath.row];
	MUITableViewCellIntroductionButton *cell = (MUITableViewCellIntroductionButton *)[tableView dequeueReusableCellWithIdentifier: identifier];
	
	NSArray *topLevelObjects  = [[NSBundle mainBundle] loadNibNamed:@"MUITableViewCellIntroductionButton" owner:self options:nil];
	for (id currentObject in topLevelObjects) {
		if ([currentObject isKindOfClass:[UITableViewCell class]]) {
			cell = (MUITableViewCellIntroductionButton *)currentObject;
			cell.textLabel.highlightedTextColor = [UIColor gradientBlue];
			cell.textLabel.textColor = [UIColor light];
			cell.textLabel.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:16.0];
			cell.textLabel.shadowColor = [UIColor gradientBlue];
			cell.textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
			if ([indexPath row] == 0) {
				UIImageView *uIViewSelectedBackgroundView = [[UIImageView alloc] initWithFrame:cell.frame];
				uIViewSelectedBackgroundView.backgroundColor = [UIColor clearColor];
				cell.selectedBackgroundView = uIViewSelectedBackgroundView;
				uIViewSelectedBackgroundView = nil;
			} else {
				BOOL firstTimeEver = [[NSUserDefaults standardUserDefaults] boolForKey:@"firstTimeEver"];
				if (firstTimeEver) {
					NSString *alertTitle = NSLocalizedString(@"Information", @"The title of an alert box says information.");
					NSString *alertMessage = NSLocalizedString(@"Each game cost one or more gold game tokens.", @"A short description of the cost to play.");
					NSString *alertButtonLabel = NSLocalizedString(@"Continue", @"Button Title");
					UIAlertController *alert = [UIAlertController alertControllerWithTitle: alertTitle
																				   message: alertMessage
																			preferredStyle: UIAlertControllerStyleAlert];
					UIAlertAction* defaultAction = [UIAlertAction actionWithTitle: alertButtonLabel
																			style: UIAlertActionStyleDefault
																		  handler: NULL];
					[alert addAction:defaultAction];
					[self presentViewController: alert animated: YES completion: NULL];
				}
				NSInteger lvl = [tableView numberOfRowsInSection: indexPath.section] - indexPath.row;
				cell.tag = lvl;
				NSInteger cost = [MNSGame costForGame:[self gametype] andLevel:lvl];
				
				cell.accessoryType = UITableViewCellAccessoryNone;
				cell.tintColor = [UIColor systemYellowColor];

				UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UIImageButtonMaster"]];
				cell.backgroundView = imageView;
				imageView = nil;

				UIImageView *imageViewActive = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UIImageButtonMasterActive"]];
				cell.selectedBackgroundView = imageViewActive;
				imageViewActive = nil;

				cell.imageView.image = [UIImage imageNamed:@"star.fill"];
				
				NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
				[numberFormatter setNumberStyle:NSNumberFormatterSpellOutStyle];
				
				NSNumber *levelNumber = [[NSNumber alloc] initWithInteger: lvl];
				NSString *levelNumberFormatted = [numberFormatter stringFromNumber: levelNumber];
				NSString *lbl = [NSString stringWithFormat:NSLocalizedString(@"Play Level %@", @"Play Level %@"), [levelNumberFormatted capitalizedString]];
				cell.textLabel.text = lbl;

				levelNumber = nil;

				BOOL hideprice = YES;
				hideprice = cost <= 0;
				numberFormatter = nil;
			}
			break;
		}
	}
	
	cell.backgroundColor = [UIColor clearColor];
	cell.opaque = NO;
	cell.autoresizingMask = UIViewAutoresizingNone;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [MNSUser CurrentUser].highestLevelUnlocked + 1;
}

#pragma mark -
#pragma mark Table View Delegate Protocol

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger lvl = [[tableView cellForRowAtIndexPath:indexPath] tag];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSInteger cost = [MNSGame costForGame:[self gametype] andLevel:lvl];
	if (lvl > 0) {
		[MNSAudio playButtonPress];
		[self performSegueWithIdentifier:@"seguePlay" sender:@(lvl)];
		if (cost > 0) {
			[MNSAudio playCoinOne];
		}
		[MNSUser CurrentUser].askToResume = NO;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60.0;
}

- (IBAction)buttonQuitDidTouchUpInside:(id)sender {
	[MNSAudio playButtonPress];
	[self.delegate gameIsOver: self];
}

@end
