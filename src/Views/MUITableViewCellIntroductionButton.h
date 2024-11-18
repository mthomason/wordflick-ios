//
//  MUITableViewCellIntroductionButton.h
//  wordPuzzle
//
//  Created by Michael Thomason on 7/1/10.
//  Copyright 2010 Michael Thomason. All rights reserved.
//

#ifndef MUITableViewCellIntroductionButton_h
#define MUITableViewCellIntroductionButton_h

#import <UIKit/UIKit.h>
#import "MUIButton.h"

@protocol MUITableViewCellIntroductionButtonDelegate <NSObject>
@optional
- (void)introductionButtonUserDidTouchUpInsideWithType:(NSInteger)type;
@end

@interface MUITableViewCellIntroductionButton : UITableViewCell

@property (nonatomic, assign) id <MUITableViewCellIntroductionButtonDelegate> delegate;
@property (nonatomic, assign) NSInteger type;

- (IBAction)pressButton;

@end

#endif
