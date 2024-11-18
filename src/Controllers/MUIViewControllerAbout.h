//
//  MUIViewControllerAbout.h
//  wordPuzzle
//
//  Created by Michael Thomason on 10/28/09.
//  Copyright 2020 Michael Thomason. All rights reserved.
//

#ifndef MUIViewControllerAbout_h
#define MUIViewControllerAbout_h

#import <MessageUI/MessageUI.h>
#import "MTControllerCompletedProtocol.h"

@interface MUIViewControllerAbout : UITableViewController
	<MFMailComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate,
		UINavigationControllerDelegate, MTControllerCompletedProtocol>

	@property(weak) id <MTControllerCompletedProtocol> delegate;

	@property (strong) IBOutlet UITableView *tableViewAbout;
	- (IBAction)doneButtonDidTouchUpInside:(id)sender;

@end

#endif
