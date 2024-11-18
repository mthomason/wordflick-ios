//
//  labelsTwoTabelViewCellController.h
//  wordPuzzle
//
//  Created by Michael Thomason on 7/15/09.
//  Copyright 2009 Michael Thomason. All rights reserved.
//

#ifndef MUITabelViewCellGameLevelStatistics_h
#define MUITabelViewCellGameLevelStatistics_h

#import <UIKit/UIKit.h>

@interface MUITabelViewCellGameLevelStatistics : UITableViewCell

@property (nonatomic, retain) UILabel *rightLabel;
@property (nonatomic, retain) UIFont *rightLabelFont;

- (instancetype)initWithStyle:(UITableViewCellStyle)style
			  reuseIdentifier:(NSString *)identifier
				  rightString:(NSString *)rs
						 font:(UIFont *)f;

@end

#endif
