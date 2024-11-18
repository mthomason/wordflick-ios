//
//  MUIViewControllerGameOver.h
//  wordPuzzle
//
//  Created by Michael Thomason on 7/14/09.
//  Copyright 2019 Michael Thomason. All rights reserved.
//

#ifndef MUIViewControllerGameOver_h
#define MUIViewControllerGameOver_h

#import "MTGameOverControllerProtocol.h"

@class MTWordValue;

@interface MUIViewControllerGameOver : UIViewController <UITableViewDelegate, UITableViewDataSource>

	@property (assign) id <MUIViewControllerGameOverDelegate> delegate;
	@property (nonatomic, retain) IBOutlet UITableView *wordsTableView;
	@property (nonatomic, retain) IBOutlet UITableViewCell *uITableViewCellSalesPitch;
	@property (nonatomic, retain) IBOutlet UILabel *uILabelSalesPitch;
	@property (nonatomic, retain) IBOutlet UIButton *uiButtonITunesLink;
	@property (nonatomic, retain) IBOutlet UILabel *labelGameOver;
	@property (nonatomic, retain) NSArray <MTWordValue *> *wordForLevel;

	- (IBAction)buttonCheckDidTouchUpInside:(id)sender;

@end

#endif
