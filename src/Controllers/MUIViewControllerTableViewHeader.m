//
//  MUIViewControllerTableViewHeader.m
//  wordPuzzle
//
//  Created by Michael Thomason on 8/13/09.
//  Copyright 2009 Michael Thomason. All rights reserved.
//

#import "MUIViewControllerTableViewHeader.h"
#import "UIColor+Wordflick.h"

@implementation MUIViewControllerTableViewHeader


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil text:(NSString *)display {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.headerText = display;
	}
	return self;
}

- (void)viewDidLoad {
	self.myLabel.text = self.headerText;
	self.myLabel.textColor = [UIColor gradientBlue];
	self.myLabel.shadowColor = [UIColor colorWithRed: 2.0f / 255.0f
											   green: 197.0f / 255.0f
												blue: 204.0f / 255.0f
											   alpha: 1.0f];
	[super viewDidLoad];
}

@end
