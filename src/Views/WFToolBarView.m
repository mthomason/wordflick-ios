//
//  WFToolBarView.m
//  wordPuzzle
//
//  Created by Michael Thomason on 4/6/12.
//  Copyright (c) 2023 Michael Thomason. All rights reserved.
//

#import "WFToolBarView.h"

@implementation WFToolBarView

- (void)awakeFromNib {
	self.backgroundColor = [UIColor colorWithWhite:0.0000f alpha:0.50000f];
	[super awakeFromNib];
}

/*
- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	[[UIColor colorWithWhite:0.0000f alpha:0.50000f] setFill];
	CGContextFillRect(context, rect);
}
*/

@end
