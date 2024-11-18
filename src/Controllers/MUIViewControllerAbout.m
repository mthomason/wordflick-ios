//
//  MUIViewControllerAbout.m
//  wordPuzzle
//
//  Created by Michael Thomason on 10/28/09.
//  Copyright 2009 Michael Thomason. All rights reserved.
//

#import "MUIViewControllerAbout.h"
#import <Twitter/Twitter.h>
#import "WFTileView.h"
#import "WFTileData.h"
#import "UIColor+Wordflick.h"
#import "MNSAudio.h"
#import "MUIViewControllerWebBrowser.h"
#import "MTURLUtility.h"

@interface MUIViewControllerAbout ()
	<WFTileViewDataSource, WFTileViewDelegate>

	typedef NS_ENUM(short, MUIViewControllerAboutCell) {
		MUIViewControllerAboutCellLootDetails = 1213,
		MUIViewControllerAboutCellLikeUsFb = 1214,
		MUIViewControllerAboutCellReviewAppStore = 1215,
		MUIViewControllerAboutCellTweetAboutIt = 1216,
		MUIViewControllerAboutCellOtherCredit = 1217,
		MUIViewControllerAboutCellEmailUs = 1218,
		MUIViewControllerAboutCellViewAppStore = 1219,
		MUIViewControllerAboutCellEverydayAppsCom = 1220,
		MUIViewControllerAboutCellFacebook = 1221,
		MUIViewControllerAboutCellTwitter = 1222,
		MUIViewControllerAboutCellGooglePlus = 1223
	};

	@property (nonatomic, strong) NSDictionary <NSNumber *, WFTileData *> *tileData;
	@property (nonatomic, retain) IBOutlet UITableViewCell *firstTipTableViewCell;
	@property (nonatomic, retain) IBOutlet UITableViewCell *secondTipTableViewCell;
	@property (nonatomic, retain) IBOutlet UITableViewCell *normalTileTableViewCell;
	@property (nonatomic, retain) IBOutlet UITableViewCell *extraPointsTableViewCell;
	@property (nonatomic, retain) IBOutlet UITableViewCell *extraShufflesTableViewCell;
	@property (nonatomic, retain) IBOutlet UITableViewCell *extraTimeTableViewCell;
	@property (nonatomic, retain) IBOutlet UITableViewCell *multipleBonusesTableViewCell;
	@property (nonatomic, retain) IBOutlet UITableViewCell *createdByTableViewCell;
	@property (nonatomic, retain) IBOutlet UILabel *normalTileLabel;
	@property (nonatomic, retain) IBOutlet UILabel *extraPointsLabel;
	@property (nonatomic, retain) IBOutlet UILabel *extraShufflesLabel;
	@property (nonatomic, retain) IBOutlet UILabel *extraTimerLabel;
	@property (nonatomic, retain) IBOutlet UILabel *multipleBonusesLabel;

	@property (nonatomic, retain) IBOutlet WFTileView *tileViewNormal;
	@property (nonatomic, retain) IBOutlet WFTileView *tileViewExtraPoints;
	@property (nonatomic, retain) IBOutlet WFTileView *tileViewExtraShuffles;
	@property (nonatomic, retain) IBOutlet WFTileView *tileViewExtraTime;
	@property (nonatomic, retain) IBOutlet WFTileView *tileViewMultipleBonuses;

@end

@implementation MUIViewControllerAbout

static NSString * _Nonnull TitleForSection(NSInteger section) {
	switch (section) {
		case 0:
			return NSLocalizedString(@"Wordflick Tips", @"From the about screen.  Gives details on how to play the game.");
			break;
		case 1:
			return NSLocalizedString(@"Tell Your Friends", @"From the about screen.");
			break;
		case 2:
			return NSLocalizedString(@"About Us", @"From the about screen.");
			break;
		case 3:
			return NSLocalizedString(@"Find Us Online", @"From the about screen.");
			break;
		default:
			return @"";
			break;
	}
}


//- (UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleDarkContent;
//}

- (instancetype)initWithCoder:(NSCoder *)coder {
	if (self = [super initWithCoder:coder]) {

		WFTileData *tileDataNormal = [[WFTileData alloc] initWithCharacter:'N' type:MNSTileExtraNormal identifier:self.tileViewNormal.tag];
		WFTileData *tileDataExtraTime = [[WFTileData alloc] initWithCharacter:'T' type:MNSTileExtraTime identifier:self.tileViewNormal.tag];
		WFTileData *tileDataExtraPoints = [[WFTileData alloc] initWithCharacter:'P' type:MNSTileExtraPoints identifier:self.tileViewNormal.tag];
		WFTileData *tileDataExtraShuffle = [[WFTileData alloc] initWithCharacter:'S' type:MNSTileExtraShuffle identifier:self.tileViewNormal.tag];
		WFTileData *tileDataMultiple = [[WFTileData alloc] initWithCharacter:'E' type:MNSTileExtraSpecial identifier:self.tileViewNormal.tag];

		NSMutableDictionary <NSNumber *, WFTileData *> *tileData = [[NSMutableDictionary alloc] initWithCapacity:5];
		tileData[tileDataNormal.tileID] = tileDataNormal;
		tileData[tileDataExtraTime.tileID] = tileDataExtraTime;
		tileData[tileDataExtraPoints.tileID] = tileDataExtraPoints;
		tileData[tileDataExtraShuffle.tileID] = tileDataExtraShuffle;
		tileData[tileDataMultiple.tileID] = tileDataMultiple;

	}
	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	self.tileViewNormal.delegate = self;
	self.tileViewNormal.dataSource = self;
	self.tileViewExtraTime.delegate = self;
	self.tileViewExtraTime.dataSource = self;
	self.tileViewExtraPoints.delegate = self;
	self.tileViewExtraPoints.dataSource = self;
	self.tileViewExtraShuffles.delegate = self;
	self.tileViewExtraShuffles.dataSource = self;
	self.tileViewMultipleBonuses.delegate = self;
	self.tileViewMultipleBonuses.dataSource = self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.tileViewNormal.tag = 90101;
	self.tileViewExtraTime.tag = 90102;
	self.tileViewExtraPoints.tag = 90103;
	self.tileViewExtraShuffles.tag = 90104;
	self.tileViewMultipleBonuses.tag = 90105;
	
	
	UILabel *labelCopyright = [[UILabel alloc] initWithFrame:CGRectMake(CGPointZero.x, CGPointZero.y, 200.0, 32.0)];
	labelCopyright.font = [UIFont systemFontOfSize:12.0000f];
	labelCopyright.backgroundColor = [UIColor clearColor];
	labelCopyright.numberOfLines = 2;
	labelCopyright.textAlignment = NSTextAlignmentCenter;
	NSString *copyrightFormat = NSLocalizedString(@"Copyright Michael Thomason %@.  All rights reserved.", @"Copyright statement.");
	labelCopyright.text = [NSString stringWithFormat:copyrightFormat, @"2023"];
	labelCopyright.textColor = [UIColor whiteColor];
	self.tableViewAbout.tableFooterView = labelCopyright;
	labelCopyright = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.tileViewNormal setNeedsDisplay];
	[self.tileViewExtraTime setNeedsDisplay];
	[self.tileViewExtraPoints setNeedsDisplay];
	[self.tileViewExtraShuffles setNeedsDisplay];
	[self.tileViewMultipleBonuses setNeedsDisplay];

	self.firstTipTableViewCell.textLabel.text = NSLocalizedString(@"Spell longer and more elaborate words to yield more points.", @"Game instructions.");
	self.secondTipTableViewCell.textLabel.text = NSLocalizedString(@"Drag or flick tiles to the drop zone located at the bottom of the screen.", @"Game instructions.");
	
	self.normalTileLabel.text = NSLocalizedString(@"Normal Tile", @"Caption, next to an image of the tile.");
	self.extraPointsLabel.text = NSLocalizedString(@"Extra Points Tile", @"Caption, next to an image of the tile.");;
	self.extraShufflesLabel.text = NSLocalizedString(@"Extra Shuffles Tile", @"Caption, next to an image of the tile.");;
	self.extraTimerLabel.text = NSLocalizedString(@"Extra Time Tile", @"Caption, next to an image of the tile.");;
	self.multipleBonusesLabel.text = NSLocalizedString(@"Multiple Bonuses Tile", @"Caption, next to an image of the tile.");;
	
	NSLog(@"self.tileViewNormal: %@", self.tileViewNormal);
	
	WFTileView *normalAccessoryView = [[WFTileView alloc] initWithFrame:CGRectMake(CGPointZero.x, CGPointZero.y, 32.0, 32.0) identifier:35];
	self.normalTileTableViewCell.textLabel.text = NSLocalizedString(@"Normal Tile", @"Caption, next to an image of the tile.");
	self.normalTileTableViewCell.textLabel.frame = CGRectMake(self.normalTileTableViewCell.textLabel.frame.origin.x + 20.0+32.0+8.0,
	                                                          self.normalTileTableViewCell.textLabel.frame.origin.y,
	                                                          self.normalTileTableViewCell.textLabel.frame.size.width - 20.0-32.0-8.0,
	                                                          self.normalTileTableViewCell.textLabel.frame.size.height);
	self.normalTileTableViewCell.accessoryView = normalAccessoryView;
	
	//[normalAccessoryView release];
	
	//MUIViewGameTile *extraAccessoryView = [[MUIViewGameTile alloc] initWithFrame:CGRectMake(CGPointZero.x, CGPointZero.y, 32.0, 32.0) identifier:36];
	//self.extraPointsTableViewCell.textLabel.text = NSLocalizedString(@"Extra Points Tile", @"Caption, next to an image of the tile.");
	//self.extraPointsTableViewCell.accessoryView = extraAccessoryView;
	//[extraAccessoryView release];
	
	
	//MUIViewGameTile *shuffleAccessoryView = [[MUIViewGameTile alloc] initWithFrame:CGRectMake(CGPointZero.x, CGPointZero.y, 32.0, 32.0) identifier:37];
	//self.extraShufflesTableViewCell.textLabel.text = NSLocalizedString(@"Extra Shuffles Tile", @"Caption, next to an image of the tile.");
	//self.extraShufflesTableViewCell.accessoryView = shuffleAccessoryView;
	//[shuffleAccessoryView release];
	
	//MUIViewGameTile *timeAccessoryView = [[MUIViewGameTile alloc] initWithFrame:CGRectMake(CGPointZero.x, CGPointZero.y, 32.0, 32.0) identifier:38];
	//self.extraTimeTableViewCell.textLabel.text = NSLocalizedString(@"Extra Time Tile", @"Caption, next to an image of the tile.");
	//self.extraTimeTableViewCell.accessoryView = timeAccessoryView;
	//self.extraTimeTableViewCell.accessoryView.frame = CGRectMake(self.extraTimeTableViewCell.textLabel.frame.origin.x, self.extraTimeTableViewCell.accessoryView.frame.origin.y,
	//                                                             32.0, 32.0);
	//self.extraTimeTableViewCell.textLabel.frame = CGRectMake(self.extraTimeTableViewCell.textLabel.frame.origin.x + 36.0, self.extraTimeTableViewCell.textLabel.frame.origin.y,
	//                                                             self.extraTimeTableViewCell.textLabel.frame.size.width, self.extraTimeTableViewCell.textLabel.frame.size.height);
	//[timeAccessoryView release];
	
	//MUIViewGameTile *accessoryView = [[MUIViewGameTile alloc] initWithFrame:CGRectMake(CGPointZero.x, CGPointZero.y, 32.0, 32.0) identifier:39];
	//self.multipleBonusesTableViewCell.textLabel.text = NSLocalizedString(@"Multiple Bonuses Tile", @"Caption, next to an image of the tile.");
	//self.multipleBonusesTableViewCell.accessoryView = accessoryView;
	//[accessoryView release];
	
	self.createdByTableViewCell.textLabel.text = NSLocalizedString(@"Created by Michael Thomason in Cincinnati, OH.", @"");
	[self.tableViewAbout setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if (animated) {
		[self.tableViewAbout flashScrollIndicators];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[MNSAudio playButtonPress];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark WFTileViewDataSource

- (nonnull NSString *)characterValueForTileView:(nonnull WFTileView *)tileView {
	return @"W";
}

- (MNSTileType)typeTypeForTileView:(nonnull WFTileView *)tileView {
	switch (tileView.tag) {
		default:
			return MNSTileExtraNormal;
			break;
	}
}

- (bool)isTileFlipping:(nonnull WFTileView *)tileView { return false; }
- (bool)hasInitalRotationForTileView:(WFTileView *)tileView { return true; }
- (CGFloat)initalRotationAngleForTileView:(WFTileView *)tileView { return 0.0f; }

- (void)sendEmail:(NSArray*)toRecipients {
	if ([MFMailComposeViewController canSendMail]) {
		
		MFMailComposeViewController	*mailController = [[MFMailComposeViewController alloc] init];
		mailController.delegate = self;
		mailController.mailComposeDelegate = self;
		mailController.toRecipients = toRecipients;
		mailController.subject = @"Wordflick";
		
		[self presentViewController:mailController animated:YES completion:^{
			
		}];
		mailController = nil;
		
	} else {
		UIAlertController *alertController = [UIAlertController alertControllerWithTitle: NSLocalizedString(@"Alert", @"Alert title")
																				 message: NSLocalizedString(@"Device is not configured for email.", @"Device is not configured for email.")
																		  preferredStyle: UIAlertControllerStyleAlert];
		
		UIAlertAction *action = [UIAlertAction actionWithTitle: NSLocalizedString(@"Continue", @"Continue playing button title.")
														 style: UIAlertActionStyleDefault
													   handler: ^(UIAlertAction * _Nonnull action) {
		}];
		[alertController addAction: action];
		
		[self presentViewController:alertController animated:YES completion:^{
			
		}];
	}
}

#pragma mark - Delegates

- (void)mailComposeController:(MFMailComposeViewController*)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError*)error {
	if (error != nil && result == MFMailComposeResultFailed) {
		UIAlertController *alertController = [UIAlertController alertControllerWithTitle: error.localizedDescription
																				 message: error.localizedFailureReason
																		  preferredStyle: UIAlertControllerStyleAlert];
		
		UIAlertAction *action = [UIAlertAction actionWithTitle: NSLocalizedString(@"Continue", @"Continue playing button title.")
														 style: UIAlertActionStyleDefault
													   handler: ^(UIAlertAction * _Nonnull action) {
			[MNSAudio playButtonPress];
		}];
		[alertController addAction: action];
		
		[self presentViewController:alertController animated:YES completion:^{
			
		}];
		alertController = nil;
	}
}

- (IBAction)emailMichael:(id)sender {
	NSArray *emailAddresses = [[NSArray alloc] initWithObjects:@"mthomason@gmail.com", nil];
	[self sendEmail: emailAddresses];
	emailAddresses = nil;
}

- (IBAction)doneButtonDidTouchUpInside:(id)sender {
	[self.delegate viewControllerDidFinish: self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 44.0000f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return TitleForSection(section);
}

/*
 - (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
 
 CGRect resultFrame = CGRectMake(CGPointZero.x, CGPointZero.y, self.view.bounds.size.width, 44.0000f);
 UIView *header = [[UIView alloc] initWithFrame:resultFrame];
 
 resultFrame.origin.x = resultFrame.origin.x + 20.0000f;
 resultFrame.size.width = resultFrame.size.width - 20.0000f;
 
 UILabel *label = [[UILabel alloc] initWithFrame:resultFrame];
 header.backgroundColor = [UIColor clearColor];
 label.textAlignment = NSTextAlignmentLeft;
 label.textColor = [UIColor lightTextColor];
 label.shadowColor = [UIColor grayColor];
 label.backgroundColor = [UIColor clearColor];
 label.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:22.0000f];
 label.text = TitleForSection(section);
 [header addSubview:label];
 [label release];
 
 return [header autorelease];
 }
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	switch (cell.tag) {
		case MUIViewControllerAboutCellFacebook: {
			[MTURLUtility openURLString:@"https://www.facebook.com/Wordflick" completion:nil];
			break;
		}
		case MUIViewControllerAboutCellGooglePlus: {
			break;
		}
		case MUIViewControllerAboutCellLikeUsFb: {
			[MTURLUtility openURLString:@"https://www.facebook.com/Wordflick" completion:nil];
			break;
		}
		case MUIViewControllerAboutCellLootDetails: {
			[self performSegueWithIdentifier:@"segueLootDetailsAbout" sender:nil];
			break;
		}
		case MUIViewControllerAboutCellOtherCredit: {
			[self performSegueWithIdentifier:@"segueOtherCredits" sender:nil];
			break;
		}
		case MUIViewControllerAboutCellReviewAppStore: {
#warning Update URL with new ID number or link.
			[MTURLUtility openURLString: @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id="
							 completion: nil];
			break;
		}
		case MUIViewControllerAboutCellTweetAboutIt: {
#warning Update message
			SLComposeViewController *tweetViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
			[tweetViewController setInitialText:@"I'm playing Wordflick on my iOS device."];
			[tweetViewController addURL:[NSURL URLWithString:@"http://goo.gl/EXAMPLE"]];
			[tweetViewController addURL:[NSURL URLWithString:@"http://goo.gl/EXAMPLE"]];
			[tweetViewController addURL:[NSURL URLWithString:@"http://goo.gl/EXAMPLE"]];
			[tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
				switch (result) {
					case TWTweetComposeViewControllerResultCancelled:
						[MNSAudio playButtonPress];
						break;
					case TWTweetComposeViewControllerResultDone:
						[MNSAudio playButtonPressConfirm];
						break;
					default:
						[MNSAudio playButtonPress];
						break;
				}
				[self dismissViewControllerAnimated:YES completion:nil];
			}];
			[MNSAudio playButtonPress];
			[self presentViewController:tweetViewController animated:YES completion:nil];
			break;
		}
		case MUIViewControllerAboutCellTwitter: {
			//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/#!/EverydayApps"]];
			break;
		}
		case MUIViewControllerAboutCellViewAppStore: {
#warning Update URL
			[MTURLUtility openURLString:@"http://itunes.apple.com/us/artist/everyday-apps-llc/id288772881"
							 completion:nil];
			break;
		}
		default: {
			break;
		}
	}
	
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
	switch (section) {
		case 0: {
			switch (row) {
				case 0:
#warning Update URL
					[MTURLUtility openURLString: @"https://example.com/"
									 completion: nil];
					break;
				default:
					break;
			}
			break;
		}
		default: {
			break;
		}
	}
	cell = nil;
}

#pragma mark - UINavigationController Delegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	[MNSAudio playButtonPress];
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	[MNSAudio playButtonPress];
}

#pragma mark - UIViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender { }

- (void)viewControllerDidFinish:(id)sender {
	[self dismissViewControllerAnimated: YES completion: nil];
}

- (void)dealloc { }

#pragma mark -
#pragma mark WFTileViewDelegate

- (void)tileViewTouchBegan:(WFTileView *)tileView {
	[tileView.superview bringSubviewToFront:tileView];
	//[tileView setNeedsDisplay];
}

@end
