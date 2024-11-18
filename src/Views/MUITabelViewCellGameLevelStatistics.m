//
//  labelsTwoTabelViewCellController.m
//  wordPuzzle
//
//  Created by Michael Thomason on 7/15/09.
//  Copyright 2009 Michael Thomason. All rights reserved.
//

#import "MUITabelViewCellGameLevelStatistics.h"
#import "UIColor+Wordflick.h"

@implementation MUITabelViewCellGameLevelStatistics

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	return [self initWithStyle: UITableViewCellStyleDefault
			   reuseIdentifier: reuseIdentifier
				   rightString: @""
						  font: [UIFont preferredFontForTextStyle: UIFontTextStyleTitle1]];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
		rightString:(NSString *)rs font:(UIFont *)f {
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		// Initialization code
		_rightLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - 158.0),
																0.2, (158.0 - 50.0), 40.0)];
		_rightLabel.textAlignment = NSTextAlignmentRight;
		_rightLabel.textColor = [UIColor cornflowerBlue];
		_rightLabel.font = f;
		self.backgroundColor = [UIColor clearColor];
		[self addSubview:_rightLabel];
	}
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	// Configure the view for the selected state
}

- (void)dealloc {
	_rightLabelFont = nil;
	_rightLabel = nil;
}

@end
