//
//  MUIViewControllerLoot.h
//  wordPuzzle
//
//  Created by Michael Thomason on 05/29/12.
//  Copyright 2023 Michael Thomason. All rights reserved.
//

#ifndef MUIViewControllerLoot_h
#define MUIViewControllerLoot_h

#import <UIKit/UIKit.h>
#import "MTControllerCompletedProtocol.h"

@interface MUIViewControllerLoot : UITableViewController
	<UITableViewDelegate>

	@property(weak) id <MTControllerCompletedProtocol> delegate;

	@property (nonatomic, strong) IBOutlet UILabel *labelGoldTokens;
	@property (nonatomic, strong) IBOutlet UILabel *labelSilverTokens;
	@property (nonatomic, strong) IBOutlet UILabel *labelChadTokens;

	@property (nonatomic, strong) IBOutlet UILabel *labelTimeBoosters;
	@property (nonatomic, strong) IBOutlet UILabel *labelShuffleBoosters;

	@property (nonatomic, strong) IBOutlet UILabel *labelGoldTokenCount;
	@property (nonatomic, strong) IBOutlet UILabel *labelSilverTokenCount;
	@property (nonatomic, strong) IBOutlet UILabel *labelChadTokenCount;

	@property (nonatomic, strong) IBOutlet UILabel *labelTimeBoosterCount;
	@property (nonatomic, strong) IBOutlet UILabel *labelShuffleBoosterCount;

	@property (nonatomic, strong) IBOutlet UINavigationItem *navigationItemLoot;

@end

#endif
