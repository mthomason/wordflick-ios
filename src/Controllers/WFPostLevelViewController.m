//
//  WFPostLevelViewController.m
//  wordPuzzle
//
//  Created by Michael Thomason on 7/14/09.
//  Copyright 2023 Michael Thomason. All rights reserved.
//

#import "WFPostLevelViewController.h"
#import "wordPuzzleAppDelegate.h"
#import "MNSUser.h"
#import "MNSGame.h"
#import "WFLevelStatistics.h"
#import "MTWordValue.h"
#import "MNSAudio.h"
#import "WFGameView.h"
#import "WFGameStatistics.h"
#import "MUIViewControllerLoot.h"

@interface WFPostLevelViewController () {
	bool _viewDidAlreadyDisplay;
}

@property (nonatomic, retain) NSArray <MTWordValue *> *wordsAndPointsForLevel;
@property (nonatomic, retain) NSMutableArray *achievementStrings;

@property (nonatomic, retain) IBOutlet UITableView *wordsTableView;
@property (nonatomic, retain) IBOutlet UILabel *labelLevelOver;
@property (nonatomic, retain) IBOutlet UILabel *labelSalesPitch;

@end

@implementation WFPostLevelViewController

static NSString * _Nonnull TitleForSection(NSInteger section) {
	switch (section) {
		case 0:
			return NSLocalizedString(@"Level Statistics", @"The title of a screen that displays statistics from the level they just played.");
			break;
		case 1:
			return NSLocalizedString(@"Achievements", @"Achievements");
			break;
		case 2:
			return NSLocalizedString(@"Level Loot", @"The title of a screen that displays statistics from the level they just played.");
			break;
		case 3:
			return NSLocalizedString(@"Total Loot", @"The title of a screen that displays the grand total loot earned by the player.");
			break;
		case 4:
			return NSLocalizedString(@"Words", @"The title of a screen that displays a list of words that the user got in the previous level.");
			break;
		default:
			return @"";
			break;
	}
}

#pragma mark -
#pragma mark Standard Overrides

- (void)dealloc {
	_wordsTableView = nil;
	_achievementStrings = nil;
	_wordsAndPointsForLevel = nil;
	_labelSalesPitch = nil;
	_labelLevelOver = nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		MNSGame *game = [MNSUser CurrentUser].game;
		
		NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[game wordsAndPoints]];
		[self setWordsAndPointsForLevel: array];
		array = nil;

		WFLevelStatistics *lastLevel = game.gameLevelArchive.lastObject;
		_achievementStrings = [lastLevel.tweetableMessages mutableCopy];
		lastLevel = nil;
		
	}
	return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		
		MNSGame *game = [MNSUser CurrentUser].game;
		NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[game wordsAndPoints]];
		[self setWordsAndPointsForLevel: array];
		array = nil;

		WFLevelStatistics *lastLevel = game.gameLevelArchive.lastObject;
		NSMutableArray *tweetableMessages = [[NSMutableArray alloc] initWithArray: lastLevel.tweetableMessages];
		[self setAchievementStrings: tweetableMessages];
		tweetableMessages = nil;
		lastLevel = nil;

	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	UIView *bgView = [[UIView alloc] initWithFrame: self.wordsTableView.bounds];
	bgView.backgroundColor = [UIColor clearColor];
	self.wordsTableView.backgroundView = bgView;
	bgView = nil;
	_viewDidAlreadyDisplay = false;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	WFLevelStatistics *lastLevel = [[[MNSUser CurrentUser].game gameLevelArchive] lastObject];
	[[self view] setBackgroundColor: [lastLevel backgroundColor]];

	[self.wordsTableView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
	
	self.labelLevelOver.text = NSLocalizedString(@"Level Over", @"Level Over title bar display.");
	self.labelSalesPitch.text = [NSString stringWithFormat:NSLocalizedString(@"%@ sales pitch.", @"Wordflick sales pitch."), @"Wordflick"];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.wordsTableView flashScrollIndicators];
	if (_viewDidAlreadyDisplay) {
		MNSGame *game = [MNSUser CurrentUser].game;
		NSMutableArray *levelArchive = [game gameLevelArchive];
		WFLevelStatistics *lastLevel = [levelArchive lastObject];
		if ([lastLevel totalPoints] > 0) {
			[MNSAudio playCoinShower];
		}
	}
	_viewDidAlreadyDisplay = true;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark IBAction's

- (IBAction)buttonCheckDidTouchUpInside:(id)sender {
	[MNSAudio playButtonPress];
	[self.delegate viewControllerPostLevelIsDone: self];
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.achievementStrings.count > 0 ? 5 : 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger result = 0;
	BOOL levelAchievements = self.achievementStrings.count > 0;
	if (!levelAchievements && section != 0) section++;
#if WORDFLICKCLASSROOM == TRUE
	if (section == 2 || section == 3) section = 4;
	else if (!levelAchievements && section == 1) section = 4;
#endif
	switch (section) {
		case 0:
			result = 3;
			break;
		case 1: {
			result = self.achievementStrings.count;
			break;
		} case 2:
			result = 4;
			break;
		case 3:
			result = 3;
			break;
		case 4:
			result = self.wordsAndPointsForLevel.count;
			break;
		default:
			result = 0;
			break;
	}
	return result;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 44.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	BOOL levelAchievements = [self.achievementStrings count] > 0;
	if (!levelAchievements && section != 0) section++;
#if WORDFLICKCLASSROOM == TRUE
	if (section == 2 || section == 3) section = 4;
	else if (!levelAchievements && section == 1) section = 4;
#endif
	return TitleForSection(section);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	CGRect resultFrame = CGRectMake(CGPointZero.x, CGPointZero.y, self.view.bounds.size.width, 44.0);
	UIView *header = [[UIView alloc] initWithFrame:resultFrame];
	header.backgroundColor = [UIColor clearColor];
	resultFrame.origin.x = resultFrame.origin.x + 20.0;
	resultFrame.size.width = resultFrame.size.width - 20.0;
	UILabel *label = [[UILabel alloc] initWithFrame:resultFrame];
	label.textAlignment = NSTextAlignmentLeft;
	label.textColor = [UIColor whiteColor];
	label.shadowColor = [UIColor grayColor];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:22.0000f];
	BOOL levelAchievements = self.achievementStrings.count > 0;
	if (!levelAchievements && section != 0) section++;
#if WORDFLICKCLASSROOM == TRUE
	if (section == 2 || section == 3) section = 4;
	else if (!levelAchievements && section == 1) section = 4;
#endif
	label.text = TitleForSection(section);
	[header addSubview:label];
	label = nil;
	return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	NSString *CellIdentifier = [@"TVCLevelStats" stringByAppendingString: [NSString stringWithFormat:@"%ld:%ld", (long)section, (long)row]];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	UITableViewCellStyle style = (section == 0 && row == 1) ? /*UITableViewCellStyleSubtitle*/UITableViewCellStyleValue1 : UITableViewCellStyleValue1;
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle: style
									  reuseIdentifier: CellIdentifier];
	}

	BOOL levelAchievements = self.achievementStrings.count > 0;
	if (!levelAchievements && section != 0) section++;
#if WORDFLICKCLASSROOM == TRUE
	if (section == 2 || section == 3) section = 4;
	else if (!levelAchievements && section == 1) section = 4;
#endif
	if (section == 0) {
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;

		switch (row){
			case 0: {
				MNSGame *game = [MNSUser CurrentUser].game;
				WFLevelStatistics *lastLevel = game.gameLevelArchive.lastObject;
				cell.imageView.image = nil;
				cell.textLabel.text = NSLocalizedString(@"Completed Level", @"A label that is next to the level number or name they just completed.");
				int64_t completedLevelNumber = [game isGameOver] ? [lastLevel levelNumberMinusOne] : [lastLevel levelNumber];
				cell.detailTextLabel.text = [numberFormatter stringFromNumber: @(completedLevelNumber)];
				[cell setAccessoryType:UITableViewCellAccessoryNone];
				break;
			} case 1: {
				MNSGame *game = [MNSUser CurrentUser].game;
				NSMutableArray *levelArchive = [game gameLevelArchive];
				WFLevelStatistics *level = [levelArchive lastObject];
				NSNumber *totalPoints = [NSNumber numberWithLongLong: level.totalPoints];
				NSNumber *goalPoints = [NSNumber numberWithLongLong: [level goal]];
				NSString *totalPointsString = [numberFormatter stringFromNumber:totalPoints];
				NSString *goalPointsString = [numberFormatter stringFromNumber:goalPoints];
				NSString *atPoints = NSLocalizedString(@"%@ points", @"A display of points.  For example: '100 points' where %@ is the number of points.");
				NSString *formatString = [[NSString alloc] initWithFormat:@"%@ / %@", atPoints, atPoints];
				NSString *detailLabel = [[NSString alloc] initWithFormat:formatString, totalPointsString, goalPointsString];
				cell.imageView.image = nil;
				cell.textLabel.text = NSLocalizedString(@"Points for Level", @"A label that is next to the number of points earned in the last level.");
				cell.detailTextLabel.text = detailLabel;
				cell.accessoryType = UITableViewCellAccessoryNone;
				detailLabel = nil;
				formatString = nil;
				break;
			} case 2: {
				MNSGame *game = [MNSUser CurrentUser].game;
				WFGameStatistics *gameArchive = [game statisticsGame];
				cell.imageView.image = nil;
				cell.textLabel.text = NSLocalizedString(@"Total Points", @"A label that is next to the number of points earned so far in the whole game.");
				NSString *detailFormat = NSLocalizedString(@"%@ points", @"A display of points.  For example: '100 points' where %@ is the number of points.");
				NSNumber *totalPoints = [NSNumber numberWithLongLong: gameArchive.totalPoints];
				NSString *pointsString = [numberFormatter stringFromNumber: totalPoints];
				cell.detailTextLabel.text = [NSString stringWithFormat:detailFormat, pointsString];
				cell.accessoryType = UITableViewCellAccessoryNone;
				break;
			} default: {
				break;
			}
		}
	
		numberFormatter = nil;
	} else if (section == 1) {
		NSArray <NSString *> *tweetableMessages = [MNSUser CurrentUser].game.gameLevelArchive.lastObject.tweetableMessages;
		NSString *tweetableMessage = [tweetableMessages objectAtIndex:row];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.textLabel.numberOfLines = 2;
		cell.textLabel.text = tweetableMessage;
		tweetableMessage = nil;
		cell.detailTextLabel.text = @"";
		cell.imageView.image = [UIImage imageNamed:@"UIImageIconSocial"];
		[cell setTag:row];
	} else if (section == 2) {
		switch (row){
			case 0: {
				
				NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
				[numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.accessoryType = UITableViewCellAccessoryNone;
				NSNumber *coinsToAward = [[NSNumber alloc] initWithInteger: 0];
				NSNumber *coinsToAwardSilver = [[NSNumber alloc] initWithInteger: 0];
				NSNumber *coinsToAwardGold = [[NSNumber alloc] initWithInteger: 0];
				[[[[MNSUser CurrentUser].game gameLevelArchive] lastObject] coinsForLevelChad:&coinsToAward silver:&coinsToAwardSilver gold:&coinsToAwardGold];
				//cell.imageView.image = [UIImage imageNamed:@"UIImageCoinChad29"];
				cell.textLabel.text = NSLocalizedString(@"Chad Tokens", @"Number of coins earned in level.");
				cell.detailTextLabel.text =  [numberFormatter stringFromNumber: coinsToAward];
				coinsToAward = nil;
				coinsToAwardSilver = nil;
				coinsToAwardGold = nil;
				numberFormatter = nil;

				break;
			}
			case 1: {
				NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
				numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.accessoryType = UITableViewCellAccessoryNone;

				NSNumber *coinsToAward = [[NSNumber alloc] initWithInteger: 0];
				NSNumber *coinsToAwardSilver = [[NSNumber alloc] initWithInteger: 0];
				NSNumber *coinsToAwardGold = [[NSNumber alloc] initWithInteger: 0];
				[[[[MNSUser CurrentUser].game gameLevelArchive] lastObject] coinsForLevelChad:&coinsToAward silver:&coinsToAwardSilver gold:&coinsToAwardGold];
				//cell.imageView.image = [UIImage imageNamed:@"UIImageCoinSilver29"];
				cell.textLabel.text = NSLocalizedString(@"Silver Tokens", @"Number of coins earned in level.");
				cell.detailTextLabel.text =  [numberFormatter stringFromNumber: coinsToAwardSilver];
				//cell.detailTextLabel.text =  [NSString stringWithFormat:@"%d/%d", [coinsToAwardSilver integerValue], kSilverTokensNeededToCreateGold];
				coinsToAward = nil;
				coinsToAwardSilver = nil;
				coinsToAwardGold = nil;
				numberFormatter = nil;
				
				break;
			}
			case 2: {
				NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
				numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.accessoryType = UITableViewCellAccessoryNone;

				NSNumber *coinsToAward = [[NSNumber alloc] initWithInteger: 0];
				NSNumber *coinsToAwardSilver = [[NSNumber alloc] initWithInteger: 0];
				NSNumber *coinsToAwardGold = [[NSNumber alloc] initWithInteger: 0];
				[[[[MNSUser CurrentUser].game gameLevelArchive] lastObject] coinsForLevelChad:&coinsToAward silver:&coinsToAwardSilver gold:&coinsToAwardGold];
				//cell.imageView.image = [UIImage imageNamed:@"UIImageCoinGold29"];
				cell.textLabel.text = NSLocalizedString(@"Gold Tokens", @"Number of coins earned in level.");
				cell.detailTextLabel.text =  [numberFormatter stringFromNumber: coinsToAwardGold];
				coinsToAward = nil;
				coinsToAwardSilver = nil;
				coinsToAwardGold = nil;
				numberFormatter = nil;
				break;
			} case 3: {
				cell.textLabel.text = NSLocalizedString(@"Loot Details", @"Details on in game loot.");
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.selectionStyle = UITableViewCellSelectionStyleGray;
				cell.detailTextLabel.text = @"";
				break;
			}
			default:
				break;
		}
	} else if (section == 3) {
		switch (row){
			case 0: {
				NSNumber *chadTokensCount = [NSNumber numberWithInteger: 0]; //[[MKStoreManager numberForKey:kUserClassConsumableSilverCoin] retain];
				NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
				numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.accessoryType = UITableViewCellAccessoryNone;
				//cell.imageView.image = [UIImage imageNamed:@"UIImageCoinChad29"];
				cell.textLabel.text = NSLocalizedString(@"Chad Tokens", @"Number of coins earned in level.");
				cell.detailTextLabel.text = [numberFormatter stringFromNumber: chadTokensCount];
				numberFormatter = nil;
				chadTokensCount = nil;
				break;
			}
			case 1: {
				NSNumber *silverTokensCount = [NSNumber numberWithInteger: 0]; //[[MKStoreManager numberForKey:kUserClassConsumableSilverCoin] retain];
				NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
				numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
				[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
				[cell setAccessoryType:UITableViewCellAccessoryNone];
				
				//cell.imageView.image = [UIImage imageNamed:@"UIImageCoinSilver29"];
				cell.textLabel.text = NSLocalizedString(@"Silver Tokens", @"Number of coins earned in level.");
				cell.detailTextLabel.text =  [numberFormatter stringFromNumber: silverTokensCount];
				numberFormatter = nil;
				silverTokensCount = nil;
				break;
			}
			case 2: {
				NSNumber *goldTokensCount = [NSNumber numberWithInteger: 0]; //[[MKStoreManager numberForKey:kUserClassConsumableGoldCoin] retain];
				NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
				[numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
				[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
				[cell setAccessoryType:UITableViewCellAccessoryNone];
				//cell.imageView.image = [UIImage imageNamed:@"UIImageCoinGold29"];
				cell.textLabel.text = NSLocalizedString(@"Gold Tokens", @"Number of coins earned in level.");
				cell.detailTextLabel.text = [numberFormatter stringFromNumber: goldTokensCount];
				numberFormatter = nil;
				goldTokensCount = nil;
				break;
			}
			default:
				break;
		}
	} else if (section == 4) {
		//Not used in Pre Level ScreensMUIGameScreenPreLevel
		//These words are only displayed after a level is complete.
		MTWordValue *wfl = [self.wordsAndPointsForLevel objectAtIndex: indexPath.row];
		cell.imageView.image = nil;
		cell.textLabel.text = wfl.kidFriendlyWord.capitalizedString;
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
		NSString *atPoints = NSLocalizedString(@"%@ points", @"A display of points.  For example: '100 points' where %@ is the number of points.");
		NSString *points = [numberFormatter stringFromNumber: wfl.points];
		NSString *detailText = [[NSString alloc] initWithFormat: atPoints, points];
		cell.detailTextLabel.text = detailText;
		detailText = nil;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
		numberFormatter = nil;
	}
	return cell;
}

- (void)tweetThatBitch:(NSInteger)messageid {
	NSArray <NSString *> *tweetableMessages = [MNSUser CurrentUser].game.gameLevelArchive.lastObject.tweetableMessages;
	NSString *tweetableMessage = [tweetableMessages objectAtIndex:messageid];
	NSMutableArray *nms = [[NSMutableArray alloc] initWithCapacity:tweetableMessages.count + 2];
	[nms addObjectsFromArray:tweetableMessages];
	NSURL *mySexyUrl2 = [[NSURL alloc] initWithString:@"http://itunes.apple.com/us/app/wordflick-pro/id335525516?mt=8"];
	NSURL *mySexyUrl = [[NSURL alloc] initWithString:@"https://www.facebook.com/Wordflick"];
	[nms addObject:mySexyUrl];
	[nms addObject:mySexyUrl2];
	
	UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:nms applicationActivities:nil];
	[self presentViewController:activityVC animated:YES completion:nil];
	nms = nil;
	activityVC = nil;
	mySexyUrl2 = nil;
	mySexyUrl = nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSInteger section = [indexPath section];
	BOOL levelAchievements = [[[[[MNSUser CurrentUser].game gameLevelArchive] lastObject] tweetableMessages] count] > 0;
	if (!levelAchievements && section != 0) section++;
	NSInteger path = [[tableView cellForRowAtIndexPath:indexPath] tag];
	switch (section) {
			case 1:
			[self tweetThatBitch:path];
			break;
		case 2: {
			
			switch ([indexPath row]) {
				case 3:
					[self performSegueWithIdentifier:@"segueLoot2" sender:nil];
					[MNSAudio playButtonPress];
					break;
				default:
					break;
			}
			break;
		}
		default:
			break;
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"segueLoot2"]) {
		MUIViewControllerLoot *targetViewController = [[segue.destinationViewController viewControllers] objectAtIndex:0];
		[targetViewController setDelegate: self];
		targetViewController = nil;
	} else if ([segue.identifier isEqualToString:@"segueFacebookChooseFriend"]) {
		[[[segue.destinationViewController viewControllers] objectAtIndex:0] setDelegate:self];
	} else if ([segue.identifier isEqualToString:@"segueTwitterChooseFriend"]) {
		NSString *twitterChallage = NSLocalizedString(@"I got %@ points on level %@ of Wordflick. Try to beat that.", @"Challenge to Twitter users.");
		
		twitterChallage = nil;
	}
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

- (void)viewControllerDidFinish:(id)sender {
	[MNSAudio playButtonPress];
	[self dismissViewControllerAnimated:YES completion:^{
		
	}];
}

- (void)viewControllerIsDone:(id)sender {
	[MNSAudio playButtonPress];
	[self dismissViewControllerAnimated:YES completion:^{
		
	}];
}

- (void)viewControllerDidCancel:(id)sender {
	[MNSAudio playButtonPress];
	[self dismissViewControllerAnimated:YES completion:^{
		
	}];
}

@end
