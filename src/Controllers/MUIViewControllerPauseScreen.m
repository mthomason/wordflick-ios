//
//  MUIViewControllerPauseScreen.m
//  wordPuzzle
//
//  Created by Michael Thomason on 4/21/12.
//  Copyright (c) 2019 Michael Thomason. All rights reserved.
//

#import "MUIViewControllerPauseScreen.h"
#import <StoreKit/StoreKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MNSUser.h"
#import "MNSGame.h"
#import "WFLevelStatistics.h"
#import "MNSAudio.h"
#import "WFGameView.h"
#import "UIColor+Wordflick.h"
#import "MTPauseScreenDataSource.h"

@interface MUIViewControllerPauseScreen ()
	<UIAdaptivePresentationControllerDelegate, MTPauseScreenControllerProtocol>

	@property (nonatomic, retain) MTPauseScreenDataSource *pauseScreenDatasource;
	@property (nonatomic, retain) NSDictionary *dictionaryStoreProducts;
	@property (nonatomic, retain) IBOutlet UINavigationItem *navItemPaused;
	@property (nonatomic, retain) IBOutlet UIBarButtonItem *barButtonResume;
	@property (nonatomic, retain) IBOutlet UIView *viewActivityIndicatorHolder;
	@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

	- (IBAction)checkButtonDidTouchUpInside:(id)sender;
	- (IBAction)abortButtonDidTouchUpInside:(id)sender;

	- (IBAction)buyTenBonusShuffles:(id)sender;
	- (IBAction)buyThreeTimeBoosters:(id)sender;

	- (IBAction)sliderVolumeBackgroundMusicValueDidChange:(id)sender;
	- (IBAction)switchBackgroundMusicDidChange:(id)sender;
	- (IBAction)switchSoundEffectsDidChange:(id)sender;

@end

@implementation MUIViewControllerPauseScreen

- (void)dealloc {
	_navItemPaused = nil;
	_barButtonResume = nil;
	_viewActivityIndicatorHolder = nil;
	_activityIndicator = nil;
	_pauseScreenDatasource = nil;
	_dictionaryStoreProducts = nil;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	if (self = [super initWithCoder:coder]) {
		MTPauseScreenDataSource *pauseScreenDatasource = [[MTPauseScreenDataSource alloc] init];
		self.pauseScreenDatasource = pauseScreenDatasource;
		self.pauseScreenDatasource.delegate = self;
		pauseScreenDatasource = nil;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.activityIndicator stopAnimating];
	
	WFGameView *bgView = [[WFGameView alloc] initWithFrame: self.tableView.bounds];
	[self.tableView setBackgroundView:bgView];
	bgView = nil;
	
	self.tableView.dataSource = self.pauseScreenDatasource;
	self.tableView.delegate = self.pauseScreenDatasource;

	self.tableView.backgroundView.backgroundColor = [UIColor patternUIImagePatternGearsBlue];
	[self.navItemPaused setTitle:NSLocalizedString(@"Paused", @"Paused Navigation Item Title")];
	[self.barButtonResume setTitle:NSLocalizedString(@"Resume", @"Resume bar button item, shown on paused screen.")];

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

#pragma mark -
#pragma mark Actions

- (void)showTransactionCompleteAlertForProduct:(NSString *)purchasedFeature {
	NSAssert(self.dictionaryStoreProducts != nil, @"This function expections a dictionary here.");

	SKProduct *product = [self.dictionaryStoreProducts objectForKey:purchasedFeature];
	NSString *formatStringLocalized = NSLocalizedString(@"The following item was purchased and crededited to your account: \"%@.\"", @"Purchase statement shown after inapp purchase.");
	NSString *alertTitle = NSLocalizedString(@"Transaction Complete", @"Alert message title to show after inapp purchase.");
	NSString *alertMessage = [NSString stringWithFormat:formatStringLocalized, product.localizedTitle];
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

- (void)showTransactionFailedAlert {
	NSString *alertTitle = NSLocalizedString(@"Transaction Failed", @"Alert message title to show after inapp purchase.");
	NSString *alertMessage = NSLocalizedString(@"The transaction failed.", @"Message to use when inapp purchase fails.");
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

- (void)setTransitioningDelegate:(id<UIViewControllerTransitioningDelegate>)transitioningDelegate {
	[super setTransitioningDelegate:transitioningDelegate];
	
	// For an adaptive presentation, the presentation controller's delegate
	// must be configured prior to invoking
	// -presentViewController:animated:completion:.  This ensures the
	// presentation is able to properly adapt if the initial presentation
	// environment is compact.
	self.presentationController.delegate = self;
}

- (void)pauseScreenDidAbortLevel {
	[self.delegate pauseScreenDidAbortLevel];
}

- (void)pauseScreenDidResume {
	[self dismissViewControllerAnimated:YES completion:^{
		[self.delegate pauseScreenDidResume];
		[MNSAudio playButtonPress];
	}];
}

- (IBAction)dismissButtonAction:(UIBarButtonItem *)sender {
	[self dismissViewControllerAnimated:YES completion:^{
		[self.delegate pauseScreenDidResume];
		self.delegate = nil;
		[MNSAudio playButtonPress];
	}];
}

- (IBAction)checkButtonDidTouchUpInside:(id)sender {
	[self dismissViewControllerAnimated:YES completion:^{
		[self.delegate pauseScreenDidResume];
		[MNSAudio playButtonPress];
	}];
}

- (IBAction)abortButtonDidTouchUpInside:(id)sender {
	[self.delegate pauseScreenDidAbortLevel];
}

- (IBAction)buyTenBonusShuffles:(id)sender {
	[MNSAudio playButtonPress];
	[self.activityIndicator startAnimating];
    /*
    [[MKStoreManager sharedManager] buyFeature: kProductConsumableShuffle10
                                    onComplete: ^(NSString *purchasedFeature, NSData*purchasedReceipt, NSArray* availableDownloads) {
                                        [MNSAudio playChimesPos];
                                        [self.activityIndicator stopAnimating];
                                        [sender setEnabled:YES];
                                        [self showTransactionCompleteAlertForProduct:purchasedFeature];
                                        
                                        [UIView animateWithDuration:1.5000f delay:0.0000f options:UIViewAnimationOptionCurveEaseIn animations:^{
                                            [[self tvcBonusShuffles] setBackgroundColor: [UIColor greenColor]];
                                        } completion:^(BOOL finished) {
                                            NSInteger bonusShuffles = [[MKStoreManager numberForKey:kProductConsumableShuffle] integerValue];
                                            [self.labelDetailBonusShuffles setText:[NSString stringWithFormat:@"%ld", (long)bonusShuffles]];
                                            [UIView animateWithDuration:1.5000f delay:0.0000f options:UIViewAnimationOptionCurveEaseOut animations:^{
                                                if (finished) [[self tvcBonusShuffles] setBackgroundColor: [UIColor whiteColor]];
                                            } completion:^(BOOL finished) { }];
                                        }];

                                    } onCancelled: ^{
                                        [MNSAudio playChimesNeg];
                                        [self.activityIndicator stopAnimating];
                                        [sender setEnabled:YES];
                                        [self showTransactionFailedAlert];

                                        [UIView animateWithDuration:1.5000f delay:0.0000f options:UIViewAnimationOptionCurveEaseIn animations:^{
                                            [[self tvcBonusShuffles] setBackgroundColor: [UIColor redColor]];
                                        } completion:^(BOOL finished) {
                                            NSInteger bonusShuffles = [[MKStoreManager numberForKey:kProductConsumableShuffle] integerValue];
                                            [self.labelDetailBonusShuffles setText:[NSString stringWithFormat:@"%ld", (long)bonusShuffles]];
                                            [UIView animateWithDuration:1.5000f delay:0.0000f options:UIViewAnimationOptionCurveEaseOut animations:^{
                                                if (finished) [[self tvcBonusShuffles] setBackgroundColor: [UIColor whiteColor]];
                                            } completion:^(BOOL finished) { }];
                                        }];

                                    }];
    */
}

- (IBAction)buyThreeTimeBoosters:(id)sender {
	[MNSAudio playButtonPress];
	[self.activityIndicator startAnimating];
    /*
    [[MKStoreManager sharedManager] buyFeature: kProductConsumableTimeBoosters3
                                    onComplete: ^(NSString *purchasedFeature, NSData*purchasedReceipt, NSArray* availableDownloads) {
                                        [MNSAudio playChimesPos];
                                        [self.activityIndicator stopAnimating];
                                        [sender setEnabled:YES];
                                        [self showTransactionCompleteAlertForProduct:purchasedFeature];
                                        
                                        [UIView animateWithDuration:1.5000f delay:0.0000f options:UIViewAnimationOptionCurveEaseIn animations:^{
                                            [[self tvcBonusTime] setBackgroundColor: [UIColor greenColor]];
                                        } completion:^(BOOL finished) {
                                            NSInteger bonusTime = [[MKStoreManager numberForKey:kProductConsumableTime] integerValue];
                                            [self.labelDetailBonusTime setText:[NSString stringWithFormat:@"%ld", (long)bonusTime]];
                                            [UIView animateWithDuration:1.5000f delay:0.0000f options:UIViewAnimationOptionCurveEaseOut animations:^{
                                                if (finished) [[self tvcBonusTime] setBackgroundColor: [UIColor whiteColor]];
                                            } completion:^(BOOL finished) { }];
                                        }];

                                    } onCancelled: ^{
                                        [MNSAudio playChimesNeg];
                                        [self.activityIndicator stopAnimating];
                                        [sender setEnabled:YES];
                                        [self showTransactionFailedAlert];
                                        [UIView animateWithDuration:1.5000f delay:0.0000f options:UIViewAnimationOptionCurveEaseIn animations:^{
                                            [[self tvcBonusTime] setBackgroundColor: [UIColor redColor]];
                                        } completion:^(BOOL finished) {
                                            NSInteger bonusTime = [[MKStoreManager numberForKey:kProductConsumableTime] integerValue];
                                            [self.labelDetailBonusTime setText:[NSString stringWithFormat:@"%ld", (long)bonusTime]];
                                            [UIView animateWithDuration:1.5000f delay:0.0000f options:UIViewAnimationOptionCurveEaseOut animations:^{
                                                if (finished) [[self tvcBonusTime] setBackgroundColor: [UIColor whiteColor]];
                                            } completion:^(BOOL finished) { }];
                                        }];

                                    }];
    */
}

- (IBAction)switchStylizedTilesValueDidChange:(id)sender {
	[MNSUser CurrentUser].desiresStylizedFonts = [sender isOn];
}

- (IBAction)sliderVolumeBackgroundMusicValueDidChange:(UISlider *)sender {
	[MNSUser CurrentUser].desiredVolume = sender.value;
}

- (IBAction)switchBackgroundMusicDidChange:(UISwitch *)sender {
	MNSUser *currentUser = [MNSUser CurrentUser];
	currentUser.desiresBackgroundMusic = sender.isOn;
#ifdef WORDNERD_BACKGROUND_MUSIC
	BOOL backgroundMusicEnabled = [MNSUser CurrentUser].desiresBackgroundMusic;
	self.sliderBackgroundMusic.enabled = backgroundMusicEnabled;
	if (backgroundMusicEnabled) {
		[[MNSUser CurrentUser].game playLevelSong];
	} else {
		[[MNSUser CurrentUser].game endAllSongs];
	}
#endif
	currentUser = nil;
}

- (IBAction)switchSoundEffectsDidChange:(UISwitch *)sender {
	[MNSUser CurrentUser].desiresSoundEffects = sender.isOn;
}

#pragma mark -
#pragma mark Table View Delegate



#pragma mark -
#pragma mark Table View Data Source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return NSLocalizedString(@"Level Status", @"Level Status");
			break;
		case 1:
			return NSLocalizedString(@"Level Aids", @"Level Aids");
			break;
		default:
			return @"";
			break;
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	CGRect resultFrame = CGRectMake(CGPointZero.x, CGPointZero.y, self.view.bounds.size.width, 44.0);
	UIView *resultView = [[UIView alloc] initWithFrame:resultFrame];
	resultFrame.origin.x = resultFrame.origin.x + 20.0;
	resultFrame.size.width = resultFrame.size.width - 20.0;
	UILabel *result = [[UILabel alloc] initWithFrame:resultFrame];
	resultView.backgroundColor = [UIColor clearColor];
	result.textAlignment = NSTextAlignmentLeft;
	result.textColor = [UIColor whiteColor];
	result.shadowColor = [UIColor grayColor];
	result.backgroundColor = [UIColor clearColor];
	result.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:22.0];
	
	switch (section) {
		case 0:
			result.text = NSLocalizedString(@"Level Status", @"Level Status");
			break;
		case 1:
			result.text = NSLocalizedString(@"Level Aids", @"Level Aids");
			break;
		default:
			result.text = @"";
			break;
	}
	
	[resultView addSubview:result];
	result = nil;
	return resultView;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

#pragma mark -
#pragma mark UIAdaptivePresentationControllerDelegate

//| ----------------------------------------------------------------------------
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
	return UIModalPresentationCustom;
}


//| ----------------------------------------------------------------------------
- (UIViewController*)presentationController:(UIPresentationController *)controller
 viewControllerForAdaptivePresentationStyle:(UIModalPresentationStyle)style {
	return [[UINavigationController alloc] initWithRootViewController:controller.presentedViewController];
}

@end
