//
//  TableViewControllerPreLevel.h
//  wordPuzzle
//
//  Created by Michael Thomason on 3/25/12.
//  Copyright (c) 2023 Michael Thomason. All rights reserved.
//

#ifndef TableViewControllerPreLevel_h
#define TableViewControllerPreLevel_h

#import <UIKit/UIKit.h>

@interface TableViewControllerPreLevel : UITableViewController

	@property (nonatomic, retain) IBOutlet UILabel *labelGameName;
	@property (nonatomic, retain) IBOutlet UILabel *labelGameNameDetail;

	@property (nonatomic, retain) IBOutlet UILabel *labelLevelNumber;
	@property (nonatomic, retain) IBOutlet UILabel *labelLevelNumberDetail;

	@property (nonatomic, retain) IBOutlet UILabel *labelLevelName;
	@property (nonatomic, retain) IBOutlet UILabel *labelLevelNameDetail;

	@property (nonatomic, retain) IBOutlet UILabel *labelObjective;
	@property (nonatomic, retain) IBOutlet UILabel *labelObjectiveDetail;

	@property (nonatomic, retain) IBOutlet UILabel *labelTime;
	@property (nonatomic, retain) IBOutlet UILabel *labelTimeDetail;

	@property (nonatomic, retain) IBOutlet UILabel *labelShuffles;
	@property (nonatomic, retain) IBOutlet UILabel *labelShufflesDetail;

@end

#endif
