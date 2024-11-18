//
//  MUIViewControllerPreLevel.h
//  wordPuzzle
//
//  Created by Michael Thomason on 7/14/09.
//  Copyright 2009 Michael Thomason. All rights reserved.
//

#ifndef MUIViewControllerPreLevel_h
#define MUIViewControllerPreLevel_h

#import "MTPreLevelControllerProtocol.h"

@class MTWordValue;

@interface MUIViewControllerPreLevel : UIViewController
	<UITableViewDelegate, UITableViewDataSource>

	@property (nonatomic, assign) id <MTPreLevelControllerProtocol> delegate;
	@property (nonatomic, retain) IBOutlet UITableView *wordsTableView;
	@property (nonatomic, retain) IBOutlet UITableViewCell *uITableViewCellSalesPitch;
	@property (nonatomic, retain) IBOutlet UILabel *uILabelSalesPitch;
	@property (nonatomic, retain) IBOutlet UIButton *uiButtonITunesLink;
	@property (nonatomic, retain) IBOutlet UILabel *labelNextLevel;
	@property (nonatomic, retain) NSArray <MTWordValue *> *wordForLevel;

	- (IBAction)buttonCheckDidTouchUpInside:(id)sender;

@end

#endif
