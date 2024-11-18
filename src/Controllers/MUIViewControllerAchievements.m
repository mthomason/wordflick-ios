//
//  MUIViewControllerAchievements.m
//  wordPuzzle
//
//  Created by Michael Thomason on 3/21/12.
//  Copyright (c) 2014 Michael Thomason. All rights reserved.
//

#import "MUIViewControllerAchievements.h"
#import "MUITableViewControllerAchievements.h"

@interface MUIViewControllerAchievements ()

@property (retain) MUITableViewControllerAchievements *tableViewControllerMain;

@end

@implementation MUIViewControllerAchievements

@synthesize viewMain = _viewMain;
@synthesize tableViewControllerMain = _tableViewControllerMain;

- (void)dealloc {
    _tableViewControllerMain = nil;
    _viewMain = nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
		MUITableViewControllerAchievements *tb1;
		tb1 = [[UIStoryboard storyboardWithName: @"Storyboard"
										 bundle: nil]
				instantiateViewControllerWithIdentifier:@"tableViewControllerAchievementsID"];
		[self setTableViewControllerMain: tb1];
		tb1 = nil;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.tableViewControllerMain.view.bounds = self.viewMain.frame;
	[self.viewMain addSubview: self.tableViewControllerMain.tableView];
}

@end
