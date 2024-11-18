//
//  MUIViewAboutOtherApps.m
//  wordPuzzle
//
//  Created by Michael Thomason on 6/29/10.
//  Copyright 2010 Michael Thomason. All rights reserved.
//
#import "MUIViewControllerAboutOtherApps.h"
#import "MTURLUtility.h"

@implementation MUIViewControllerAboutOtherApps

@synthesize uILabelHeader = _uILabelHeader;
@synthesize uIScrollView = _uIScrollView;
@synthesize uIButtonAppStoreLinkQuotationary = _uIButtonAppStoreLinkQuotationary;

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"didPresentAboutOtherApps" object:nil];
	_uILabelHeader = nil;
	_uIScrollView = nil;
	_uIButtonAppStoreLinkQuotationary = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self.uILabelHeader setTextColor:[UIColor gradientBlue]];
	[self.uIScrollView setContentSize:CGSizeMake(320.0000f, 424.0000f)];
	[self.uIScrollView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
	[self.uIButtonAppStoreLinkQuotationary setTitleColor:[UIColor gradientBlue]
												forState:UIControlStateHighlighted];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didPresentAboutOtherApps:)
												 name:@"didPresentAboutOtherApps" object:nil];
}

- (void)didPresentAboutOtherApps:(NSNotification *)notif {
	[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(flashScroller:)
								   userInfo:nil repeats:NO];
}

- (void)flashScroller:(id)sender {
	[self.uIScrollView flashScrollIndicators];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (IBAction)AppStoreLinkQuotationaryTouchUpInside {
#warning Update this URL.
	[MTURLUtility openURLString: @"itms-apps://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=306386514&mt=8"
					 completion: nil];
}

@end

