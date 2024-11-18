//
//  MUIViewControllerPauseScreen.h
//  wordPuzzle
//
//  Created by Michael Thomason on 4/21/12.
//  Copyright (c) 2020 Michael Thomason. All rights reserved.
//

#ifndef MUIViewControllerPauseScreen_h
#define MUIViewControllerPauseScreen_h

#import <UIKit/UIKit.h>
#import "MTPauseScreenControllerProtocol.h"

@interface MUIViewControllerPauseScreen : UITableViewController <UITableViewDataSource>

	@property (nonatomic, assign) id <MTPauseScreenControllerProtocol> delegate;

@end

#endif
