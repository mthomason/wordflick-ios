//
//  WFIntroductionViewController.h
//  wordPuzzle
//
//  Created by Michael Thomason on 10/11/09.
//  Copyright 2019 Michael Thomason. All rights reserved.
//

#ifndef MUIViewControllerIntroduction_h
#define MUIViewControllerIntroduction_h

#import <UIKit/UIKit.h>
#import "MTWordNerdControllerProtocol.h"

#import "MUIViewControllerSettings.h"
#import "MTGameControllerProtocol.h"
#import "MTControllerCompletedProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface WFIntroductionViewController : UIViewController
	<MTControllerCompletedProtocol, MTGameControllerProtocol>

	@property (nonatomic, assign) id <MTWordNerdProtocol> _Nullable gameControllerDelegate;
	@property (nonatomic, retain) IBOutlet UITableView *menuTableView;
	@property (nonatomic, retain) IBOutlet UIView *menuContainerView;

@end

NS_ASSUME_NONNULL_END

#endif
