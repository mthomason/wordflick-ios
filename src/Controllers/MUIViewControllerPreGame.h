//
//  MUIViewControllerPreGame.h
//  wordPuzzle
//
//  Created by Michael Thomason on 4/21/12.
//  Copyright (c) 2023 Michael Thomason. All rights reserved.
//

#ifndef MUIViewControllerPreGame_h
#define MUIViewControllerPreGame_h

#import <UIKit/UIKit.h>
#import "WFGameViewController.h"
#import "MUITableViewCellIntroductionButton.h"
#import "MTGameControllerProtocol.h"
#import "MTGameType.h"

@interface MUIViewControllerPreGame : UIViewController
	<UITableViewDelegate, UITableViewDataSource, MTGameControllerProtocol>

	@property (nonatomic, assign) id <MTGameControllerProtocol> delegate;
	@property (nonatomic, assign) MNSGameType gametype;
	@property (nonatomic, retain) IBOutlet UITableView *tableViewMain;
	@property (nonatomic, retain) IBOutlet UIImageView *logoImage;
	@property (nonatomic, retain) IBOutlet UIView *storeBackgroundView;
	@property (nonatomic, retain) IBOutlet UILabel *labelGoldTokens;
	@property (nonatomic, retain) IBOutlet UILabel *labelSilverTokens;
	@property (nonatomic, retain) IBOutlet UILabel *labelChadTokens;
	@property (nonatomic, retain) IBOutlet UIButton *buttonQuit;
	@property (nonatomic, retain) IBOutlet UIButton *buttonStore;
	@property (nonatomic, retain) IBOutlet UIImageView *imageViewGoldCoin;

	- (IBAction)buttonQuitDidTouchUpInside:(id)sender;

@end

#endif
