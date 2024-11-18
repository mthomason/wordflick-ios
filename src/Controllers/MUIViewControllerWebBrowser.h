//
//  MUIViewControllerWebBrowser.h
//  wordPuzzle
//
//  Created by Michael Thomason on 11/14/09.
//  Copyright 2019 Michael Thomason. All rights reserved.
//

#ifndef MUIViewControllerWebBrowser_h
#define MUIViewControllerWebBrowser_h

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "wordPuzzleAppDelegate.h"
#import "MTControllerCompletedProtocol.h"

@interface MUIViewControllerWebBrowser : UIViewController
	<WKNavigationDelegate, WKUIDelegate>

	@property (assign) id <MTControllerCompletedProtocol> delegate;
	@property (nonatomic, strong) IBOutlet WKWebView *webViewMain;
	@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *uIActivityIndicatorView;
	@property (nonatomic, strong) NSURL *initalUrl;
	@property (nonatomic, copy) NSString *initalString;

- (IBAction)doneButtonDidTouchUpInside:(id)sender;

@end

#endif

/*
#ifndef MUIViewControllerWebBrowser_h
#define MUIViewControllerWebBrowser_h

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "wordPuzzleAppDelegate.h"
#import "MTControllerCompletedProtocol.h"

@interface MUIViewControllerWebBrowser : UIViewController
	<WKNavigationDelegate, WKUIDelegate>  // Replace UIWebViewDelegate with WKNavigationDelegate and WKUIDelegate

@property (assign) id <MTControllerCompletedProtocol> delegate;
@property (nonatomic, strong) IBOutlet WKWebView *webViewMain;  // Replace UIWebView with WKWebView and retain with strong
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *uIActivityIndicatorView;  // Replace retain with strong
@property (nonatomic, strong) NSURL *initalUrl;  // Replace retain with strong
@property (nonatomic, copy) NSString *initalString;

- (IBAction)doneButtonDidTouchUpInside:(id)sender;

@end

#endif
*/
