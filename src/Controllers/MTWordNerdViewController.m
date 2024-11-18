//
//  MTWordNerdViewController.m
//  Wordflick-Pro
//
//  Created by Michael on 1/5/20.
//  Copyright © 2020 Michael Thomason. All rights reserved.
//

#import "MTWordNerdViewController.h"
#import "MNSUser.h"
#import "MNSGame.h"
#import "MNSAudio.h"
#import "WFGameViewController.h"
#import "WFIntroductionViewController.h"
#import "MTPausePresentationController.h"

@interface MTWordNerdViewController () <MTGameControllerProtocol> {
	CGRect _toViewControllerBounds;
}

	@property (retain, nonatomic) IBOutlet UIView *topContainerView;
	@property (retain, nonatomic) IBOutlet UIView *bottomContainerView;
	@property (retain, nonatomic) IBOutlet NSLayoutConstraint *bottomContainerHeightLayoutConstraint;

@end

@implementation MTWordNerdViewController

- (void)dealloc {
	_topContainerView = nil;
	_bottomContainerView = nil;
	_bottomContainerHeightLayoutConstraint = nil;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	if (self = [super initWithCoder:coder]) {
		_toViewControllerBounds = CGRectZero;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.bottomContainerHeightLayoutConstraint.constant = 0;
	[self.bottomContainerView setNeedsLayout];
}

#pragma mark Game Delegate

- (void)gameIsOver:(id)sender {
	[MNSUser CurrentUser].game.delegate = nil;
	[self showIntroduction: sender];
}

#pragma mark

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
	[super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
	
	/*
	for (UIViewController *vc in self.childViewControllers) {
		if ([vc isKindOfClass:[MUIViewControllerGameWordPuzzle class]]) {
			[((MUIViewControllerGameWordPuzzle *)vc).gameView setNeedsLayout];
		}
	}

		[coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {

			
			//NSLog(@"  animateAlongsideTransition");
			UIViewController *fromViewController = [context viewControllerForKey: UITransitionContextFromViewControllerKey];
			//UIViewController *toViewController = [context viewControllerForKey: UITransitionContextToViewControllerKey];
			//UIView *fromView = [context viewForKey: UITransitionContextFromViewKey];
			//UIView *toView = [context viewForKey: UITransitionContextToViewKey];
			
			for (UIViewController *vc in fromViewController.childViewControllers) {
				if ([vc isKindOfClass:[MUIViewControllerGameWordPuzzle class]]) {
					[((MUIViewControllerGameWordPuzzle *)vc).gameView layoutIfNeeded];
				}
			}
			
			//NSLog(@" containerView:      %@", context.containerView);
			//NSLog(@" Is game background: %@", [context.containerView isKindOfClass:[MUIViewGameBackground class]] ? @"YES" : @"NO");
			//NSLog(@" fromViewController: %@", fromViewController);
			//NSLog(@" toViewController:   %@", toViewController);
			//NSLog(@" fromView:           %@", fromView);
			//NSLog(@" toView:             %@", toView);
			

		} completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) { }];
	*/
}

- (void)transitionFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
	if (fromVC == toVC) { return; }
	
	[fromVC willMoveToParentViewController:nil];
	[self addChildViewController:toVC];
	[self transitionFromViewController: fromVC toViewController: toVC
							  duration: 0.5
							   options: UIViewAnimationOptionTransitionCrossDissolve
							animations: ^{
		
							} completion:^(BOOL finished) {
								[toVC didMoveToParentViewController:self];
								[fromVC removeFromParentViewController];
							}];
}

- (void)showIntroduction:(WFGameViewController *)fromViewController {
	NSAssert([fromViewController isKindOfClass:[WFGameViewController class]],
			 @"Expected to show this from the game screen.");
	WFIntroductionViewController *toViewController =
				[[UIStoryboard storyboardWithName: @"Storyboard"
										   bundle: nil] instantiateViewControllerWithIdentifier: @"MTIntroductionViewControllerID"];
	_toViewControllerBounds.size = self.topContainerView.bounds.size;
	toViewController.view.bounds = _toViewControllerBounds;
	toViewController.view.center = self.topContainerView.center;
	toViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth |
											 UIViewAutoresizingFlexibleHeight;
	toViewController.gameControllerDelegate = self;
	
	[self transitionFromViewController:fromViewController toViewController:toViewController];

}

- (void)showGame:(MNSGameType)gameType animated:(BOOL)animated sender:(id)sender {
	NSAssert([sender isKindOfClass:[WFIntroductionViewController class]],
			 @"Expected to show this from the introduction screen.");
	WFIntroductionViewController *fromViewController = sender;
	WFGameViewController *toViewController;

	NSString *viewControllerID = @"MUIViewControllerGameWordPuzzle";
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
	toViewController = [storyboard instantiateViewControllerWithIdentifier: viewControllerID];
	toViewController.view.bounds = CGRectMake(CGPointZero.x, CGPointZero.y, self.topContainerView.bounds.size.width, self.topContainerView.bounds.size.height);
	toViewController.view.center = self.topContainerView.center;
	toViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	toViewController.delegate = self;
	MNSGame *game = [[MNSGame alloc] initWithType: gameType userID: @"" andStartingLevel: 1];
	game.delegate = toViewController;
	[MNSUser CurrentUser].game = game;
	//[game release];

	[MNSAudio playButtonPress];

	fromViewController.gameControllerDelegate = nil;
	[self transitionFromViewController:fromViewController toViewController:toViewController];
	/*
	[self addChildViewController:toViewController];
	[toViewController beginAppearanceTransition:YES animated:YES];
	[self.topContainerView addSubview: toViewController.view];

	toViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	
	if (!animated) {
		[toViewController endAppearanceTransition];
		[toViewController didMoveToParentViewController:self];
	} else {
		[UIView animateWithDuration:0.5000f animations: ^{
			toViewController.view.alpha = 1.0;
		} completion:^(BOOL finished) {
			if (finished) {
				[toViewController endAppearanceTransition];
				[toViewController didMoveToParentViewController: self];
			}
		}];
	}
	*/
	

}

- (void)showPause:(id)sender {
	
}

- (void)showSettings:(BOOL)animated sender:(id)sender {

	NSAssert([sender isKindOfClass:[UIViewController class]],
			 @"We expect sender to be a view controlller.");
	
	WFIntroductionViewController *fromViewController = sender;
	MUIViewControllerSettings *toViewController;
	toViewController = [[UIStoryboard storyboardWithName:@"Storyboard" bundle:nil]
						instantiateViewControllerWithIdentifier: @"MTSettingsControllerID"];
   
	toViewController.view.bounds = CGRectMake(CGPointZero.x, CGPointZero.y, fromViewController.menuTableView.bounds.size.width, fromViewController.menuTableView.bounds.size.height);
	toViewController.view.center = fromViewController.menuTableView.center;
	toViewController.view.alpha = animated ? 0.0 : 1.0;
	//toViewController.view bring
	toViewController.tableView.bounds = fromViewController.menuTableView.bounds;
	toViewController.tableView.center = fromViewController.menuTableView.center;
	
	//toViewController.presentationController = [[MTPausePresentationController alloc] init];
	
	[self addChildViewController:toViewController];
	[toViewController beginAppearanceTransition:YES animated:YES];

	//[fromViewController.menuContainerView addSubview:toViewController.tableView];
	[self.topContainerView addSubview: toViewController.tableView];

	if (!animated) {
		[toViewController endAppearanceTransition];
		[toViewController didMoveToParentViewController:self];
	} else {
		[UIView animateWithDuration:0.5000f animations: ^{
			toViewController.view.alpha = 1.0;
			toViewController.tableView.bounds = fromViewController.menuTableView.bounds;
			toViewController.tableView.center = fromViewController.menuTableView.center;
		} completion:^(BOOL finished) {
			if (finished) {
				[toViewController endAppearanceTransition];
				[toViewController didMoveToParentViewController: self];
			}
		}];
	}
		
}

- (IBSegueAction WFIntroductionViewController *)instantiateEmbedSegueMain:(NSCoder *)coder {
	WFIntroductionViewController *controller;
	controller = [[WFIntroductionViewController alloc] initWithCoder:coder];
	controller.gameControllerDelegate = self;
	return controller;
}

@end
