//
//  MUITableViewCellIntroductionButton.m
//  wordPuzzle
//
//  Created by Michael Thomason on 7/1/10.
//  Copyright 2010 Michael Thomason. All rights reserved.
//

#import "MUITableViewCellIntroductionButton.h"

@implementation MUITableViewCellIntroductionButton

- (void)dealloc {
	_delegate = nil;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

- (IBAction)pressButton {
	[_delegate introductionButtonUserDidTouchUpInsideWithType: _type];
}

@end
