//
//  MTPausePresentationController.m
//  Wordflick-Pro
//
//  Created by Michael on 1/11/20.
//  Copyright © 2020 Michael Thomason. All rights reserved.
//

#import "MTPausePresentationController.h"
#import "MUIViewControllerPauseScreen.h"
#import "WFGameViewController.h"
#import "WFGameView.h"
#import "MNSAudio.h"

#if ! __has_feature(objc_arc)
#warning The file requires ARC.  Compile with the -fobjc-arc flag.
#endif

@interface MTPausePresentationController () <UIViewControllerAnimatedTransitioning>
	@property (nonatomic, strong) UIView *presentationWrappingView;
	@property (nonatomic, strong) UIButton *dismissButton;
@end

@implementation MTPausePresentationController

- (void)dealloc {
	_presentationWrappingView = nil;
	_dismissButton = nil;
}

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
					   presentingViewController:(UIViewController *)presentingViewController {
	if (self = [super initWithPresentedViewController: presentedViewController
							 presentingViewController: presentingViewController]) {
		presentedViewController.modalPresentationStyle = UIModalPresentationCustom;
	}
	return self;
}

- (UIView*)presentedView {
	return self.presentationWrappingView;
}

- (void)presentationTransitionWillBegin {

	UIView *presentedViewControllerView = [super presentedView];

	MUIViewControllerPauseScreen *pauseViewController;
	pauseViewController = (MUIViewControllerPauseScreen *)self.presentedViewController;
	{
		UIView *presentationWrapperView = [[UIView alloc] initWithFrame:CGRectZero];
		presentationWrapperView.layer.shadowOpacity = 0.63f;
		presentationWrapperView.layer.shadowRadius = 17.f;
		self.presentationWrappingView = presentationWrapperView;
		
		// Add presentedViewControllerView -> presentationWrapperView.
		presentedViewControllerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		presentedViewControllerView.layer.borderColor = [UIColor grayColor].CGColor;
		presentedViewControllerView.layer.borderWidth = 2.f;
		[presentationWrapperView addSubview:presentedViewControllerView];
		
		// Create the dismiss button.
		UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
		dismissButton.tag = 434443;
		dismissButton.frame = CGRectMake(CGPointZero.x, CGPointZero.y, 54.0, 49.0);
		[dismissButton addTarget:self action:@selector(dismissButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[dismissButton setImage:nil forState:UIControlStateNormal];
		[dismissButton setImage:nil forState:UIControlStateDisabled];

		dismissButton.center = CGPointMake(CGPointZero.x + presentationWrapperView.bounds.size.width, CGPointZero.y + (dismissButton.bounds.size.height / 2.0));
		[presentationWrapperView addSubview:dismissButton];
		[pauseViewController.transitionCoordinator animateAlongsideTransition: NULL
																   completion: ^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
			dismissButton.center = CGPointMake(CGPointZero.x + presentationWrapperView.bounds.size.width - (dismissButton.frame.size.width / 2.0), CGPointZero.y + (dismissButton.bounds.size.height / 2.0) );
			[UIView beginAnimations:nil context:(__bridge void * _Nullable)(dismissButton)];
			[UIView setAnimationDuration:context.transitionDuration];
			[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:dismissButton cache:YES];
			[dismissButton setImage:[UIImage imageNamed:@"MUIButtonCheck"] forState:UIControlStateNormal];
			[UIView commitAnimations];
		}];
		
		self.dismissButton = dismissButton;
	}
}

#pragma mark -
#pragma mark Dismiss Button

- (IBAction)dismissButtonTapped:(UIButton*)sender {
	MUIViewControllerPauseScreen *pauseViewController;
	pauseViewController = (MUIViewControllerPauseScreen *)self.presentedViewController;
	[self.presentingViewController dismissViewControllerAnimated:YES completion:^{
		[pauseViewController.delegate pauseScreenDidResume];
		pauseViewController.delegate = nil;
		[MNSAudio playButtonPress];
	}];
}

#pragma mark -
#pragma mark Layout

- (void)viewWillTransitionToSize:(CGSize)size
	   withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
	
	self.presentationWrappingView.clipsToBounds = YES;
	self.presentationWrappingView.layer.shadowOpacity = 0.0f;
	self.presentationWrappingView.layer.shadowRadius = 0.0f;
	
	[coordinator animateAlongsideTransition: NULL
								 completion: ^(id<UIViewControllerTransitionCoordinatorContext> context) {
		self.presentationWrappingView.clipsToBounds = NO;
		self.presentationWrappingView.layer.shadowOpacity = 0.63f;
		self.presentationWrappingView.layer.shadowRadius = 17.0f;
	}];
}

- (CGSize)sizeForChildContentContainer:(id<UIContentContainer>)container
			   withParentContainerSize:(CGSize)parentSize {
	if (container == self.presentedViewController) {
		double width;
		if (parentSize.width <= 320.0) {
			width = parentSize.width;
		} else if (parentSize.width <= 480.0) {
			width = 320.0;
		} else {
			width = 420.0;
		}
		return CGSizeMake(width, (parentSize.height / (4.0 / 3.0)) + 60.0);
	} else {
		return [super sizeForChildContentContainer:container withParentContainerSize:parentSize];
	}
}

- (CGRect)frameOfPresentedViewInContainerView {
	CGRect containerViewBounds = self.containerView.bounds;
	CGSize presentedViewContentSize = [self sizeForChildContentContainer: self.presentedViewController
												 withParentContainerSize: containerViewBounds.size];
	CGRect frame;// = CGRectMake(CGRectGetMidX(containerViewBounds) - presentedViewContentSize.width / 2.0,
				 //             CGRectGetMidY(containerViewBounds) - presentedViewContentSize.height / 2.0,
				 //             presentedViewContentSize.width, presentedViewContentSize.height);
	bool frameset = false;
	for (UIViewController *vc in self.presentingViewController.childViewControllers) {
		if ([vc isKindOfClass:[WFGameViewController class]]) {
			frame = ((WFGameViewController *)vc).gameView.frame;
			frame.size = CGSizeMake(presentedViewContentSize.width, frame.size.height);
			frame.origin = CGPointMake((containerViewBounds.size.width - frame.size.width) / 2.0, frame.origin.y - 30.0);
			frameset = true;
			break;
		}
	}
	if (!frameset) frame = CGRectMake(CGRectGetMidX(containerViewBounds) - presentedViewContentSize.width / 2.0,
									  CGRectGetMidY(containerViewBounds) - presentedViewContentSize.height / 2.0,
									  presentedViewContentSize.width, presentedViewContentSize.height);;
	return CGRectInset(frame, -20.0, -20.0);
}

- (void)containerViewWillLayoutSubviews {
	[super containerViewWillLayoutSubviews];
	
	self.presentationWrappingView.frame = self.frameOfPresentedViewInContainerView;
	self.presentedViewController.view.frame = CGRectInset(self.presentationWrappingView.bounds, 20.0, 20.0);
	self.dismissButton.center = CGPointMake(CGRectGetMinX(self.presentedViewController.view.frame),
											CGRectGetMinY(self.presentedViewController.view.frame));
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
	return [transitionContext isAnimated] ? 0.35 : 0.0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
	UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	
	BOOL isPresenting = (fromViewController == self.presentingViewController);
	if (isPresenting) {
		UIView *containerView = transitionContext.containerView;
		
		UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
		UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
		
		CGRect toViewFinalFrame = [transitionContext finalFrameForViewController:toViewController];
		NSTimeInterval transitionDuration = [self transitionDuration:transitionContext];
		fromView.frame = [transitionContext finalFrameForViewController:fromViewController];
		toView.frame = CGRectMake(toViewFinalFrame.origin.x + fromViewController.view.bounds.size.width, toViewFinalFrame.origin.y, toViewFinalFrame.size.width, toViewFinalFrame.size.height);
		[containerView addSubview:toView];
		
		[UIView animateWithDuration:transitionDuration animations:^{
			toView.frame = toViewFinalFrame;
		} completion:^(BOOL finished) {
			[transitionContext completeTransition:!transitionContext.transitionWasCancelled];
		}];
		
	} else {
		UIView *containerView = transitionContext.containerView;
		UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
		CGRect fromViewControllerInitalFrame = [transitionContext initialFrameForViewController:fromViewController];
		CGRect toViewInitalFrame = CGRectMake(CGPointZero.x - containerView.bounds.size.width, fromViewControllerInitalFrame.origin.y, fromViewControllerInitalFrame.size.width, fromViewControllerInitalFrame.size.height);
		NSTimeInterval transitionDuration = [self transitionDuration:transitionContext];
		UIButton *dismissButton = nil;
		for (UIView *subview in fromView.subviews) {
			if ([subview isKindOfClass:[UIButton class]] && subview.tag == 434443) {
				dismissButton = (UIButton *)subview;
			}
		}
		[UIView beginAnimations:nil context:(__bridge void * _Nullable)(dismissButton)];
		[UIView setAnimationDuration:transitionDuration];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:dismissButton cache:YES];
		[dismissButton setEnabled:NO];
		[dismissButton setImage:nil forState:UIControlStateDisabled];
		[dismissButton setImage:nil forState:UIControlStateNormal];
		[UIView commitAnimations];
		
		[UIView animateWithDuration:transitionDuration animations:^{
				fromView.frame = toViewInitalFrame;
		} completion:^(BOOL finished) {
			[transitionContext completeTransition:!transitionContext.transitionWasCancelled];
			[fromView removeFromSuperview];
		}];
	}
	
}

#pragma mark -
#pragma mark UIViewControllerTransitioningDelegate

- (UIPresentationController*)presentationControllerForPresentedViewController:(UIViewController *)presented
													 presentingViewController:(UIViewController *)presenting
														 sourceViewController:(UIViewController *)source {
	NSAssert(self.presentedViewController == presented,
			 @"You didn't initialize %@ with the correct presentedViewController.  Expected %@, got %@.",
			 self, presented, self.presentedViewController);
	
	return self;
}


- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
																  presentingController:(UIViewController *)presenting
																	  sourceController:(UIViewController *)source {
	return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
	return self;
}

@end
