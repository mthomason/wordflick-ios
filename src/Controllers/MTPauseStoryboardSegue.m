//
//  MTPauseStoryboardSegue.m
//  Wordflick-Pro
//
//  Created by Michael on 1/11/20.
//  Copyright © 2020 Michael Thomason. All rights reserved.
//

#import "MTPauseStoryboardSegue.h"
#import "MTPausePresentationController.h"

#if ! __has_feature(objc_arc)
#warning The file requires ARC.  Compile with the -fobjc-arc flag.
#endif

@interface MTPauseStoryboardSegue()

@property (nonatomic, retain) MTPausePresentationController *presentationController;

@end

@implementation MTPauseStoryboardSegue

- (void)dealloc {
	_presentationController = nil;
}

- (instancetype)initWithIdentifier:(nullable NSString *)identifier source:(UIViewController *)source
					   destination:(UIViewController *)destination {
	if (self = [super initWithIdentifier:identifier source:source destination:destination]) {
		_presentationController =
			[[MTPausePresentationController alloc] initWithPresentedViewController: destination
														  presentingViewController: destination];
	}
	return self;
}


- (void)perform {
	self.destinationViewController.transitioningDelegate = _presentationController;
	[self.sourceViewController presentViewController: self.destinationViewController
											animated: YES
										  completion: NULL];
	
}

@end
