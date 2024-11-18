//
//  MUITableViewControllerAchievements.h
//  wordPuzzle
//
//  Created by Michael Thomason on 3/21/12.
//  Copyright (c) 2019 Michael Thomason. All rights reserved.
//

#ifndef MUITableViewControllerAchievements_h
#define MUITableViewControllerAchievements_h

#import <UIKit/UIKit.h>

@interface MUITableViewControllerAchievements : UITableViewController <UITableViewDelegate>

    @property (nonatomic, retain) IBOutlet UITableViewCell *tableViewCellAchievementTotalPoints;
    @property (nonatomic, retain) IBOutlet UITableViewCell *tableViewCellAchievementTotalPointsFromBonusTiles;
    @property (nonatomic, retain) IBOutlet UITableViewCell *tableViewCellAchievementTotalTime;

@end

#endif
