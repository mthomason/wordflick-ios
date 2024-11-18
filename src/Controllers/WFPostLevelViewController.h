//
//  WFPostLevelViewController.h
//  wordPuzzle
//
//  Created by Michael Thomason on 7/14/09.
//  Copyright 2023 Michael Thomason. All rights reserved.
//

#ifndef MUIViewControllerPostLevel_h
#define MUIViewControllerPostLevel_h

#import "MTControllerCompletedProtocol.h"
#import "MTPostLevelControllerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class MTWordValue, MUIViewControllerTableViewHeader;

@interface WFPostLevelViewController : UIViewController
	<UITableViewDelegate, UITableViewDataSource, MTControllerCompletedProtocol>

@property (assign) id <MTPostLevelControllerProtocol> delegate;

- (IBAction)buttonCheckDidTouchUpInside:(id)sender;

@end

NS_ASSUME_NONNULL_END

#endif
