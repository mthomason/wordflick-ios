//
//  MUIViewControllerWebBrowser.m
//  wordPuzzle
//
//  Created by Michael Thomason on 11/14/09.
//  Copyright 2009 Michael Thomason. All rights reserved.
//

#import "MUIViewControllerWebBrowser.h"
#import "MNSAudio.h"

@interface MUIViewControllerWebBrowser()
    @property (nonatomic, assign) BOOL loadFromUrl;
@end

@implementation MUIViewControllerWebBrowser

- (void)dealloc {
	_initalUrl = nil;
	_uIActivityIndicatorView = nil;
	_webViewMain = nil;
	_initalString = nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		_initalUrl = [[NSURL alloc] initWithString:@"https://www.everydayapps.com/"];
		[self setLoadFromUrl:YES];
	}
	return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		_initalUrl = [[NSURL alloc] initWithString:@"https://www.everydayapps.com/"];
		[self setLoadFromUrl:YES];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.webViewMain.navigationDelegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.webViewMain.backgroundColor = [UIColor clearColor];
	self.webViewMain.alpha = 0.0;
	self.webViewMain.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.webViewMain loadRequest:[NSURLRequest requestWithURL: self.initalUrl]];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
	[NSThread detachNewThreadSelector:@selector(showLoadingView) toTarget:self withObject:nil];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
	[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(showWebView) userInfo:nil repeats:NO];
	[NSThread detachNewThreadSelector:@selector(hideLoadingView) toTarget:self withObject:nil];
	[self.webViewMain.scrollView flashScrollIndicators];
}

- (void)showWebView {
	[UIView beginAnimations:@"web" context:nil];
	self.webViewMain.alpha = 1.0;
	[UIView commitAnimations];	
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
	[NSThread detachNewThreadSelector:@selector(hideLoadingView) toTarget:self withObject:nil];
	if (error.code != -999) {
		NSString *alertTitle = NSLocalizedString(@"Failed to load weblog.", @"Title for alert that the news blog failed to load.");
		NSString *alertMessage = NSLocalizedString(@"Internet connection not available. Enable wi-fi / 3g to post your scores to the server.", @"Tells user that the Internet connection is not available, and posting scores to the server requires Internet service.");
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
}

- (void) showLoadingView {
	[self.uIActivityIndicatorView startAnimating];
	[self.uIActivityIndicatorView setHidden: NO];
}

- (void) hideLoadingView {
	[self.uIActivityIndicatorView stopAnimating];
	[self.uIActivityIndicatorView setHidden: YES];
}

- (IBAction)doneButtonDidTouchUpInside:(id)sender {
	[MNSAudio playButtonPress];
	[[self delegate] viewControllerDidFinish: self];
}

@end
