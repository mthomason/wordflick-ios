//
//  MUIViewAboutOtherApps.h
//  wordPuzzle
//
//  Created by Michael Thomason on 6/29/10.
//  Copyright 2019 Michael Thomason. All rights reserved.
//

#ifndef MUIViewControllerAboutOtherApps_h
#define MUIViewControllerAboutOtherApps_h

#import <UIKit/UIKit.h>
#import "UIColor+Wordflick.h"

@interface MUIViewControllerAboutOtherApps : UIViewController

	@property (nonatomic,retain) IBOutlet UILabel *uILabelHeader;
	@property (nonatomic,retain) IBOutlet UIScrollView *uIScrollView;
	@property (nonatomic,retain) IBOutlet UIButton *uIButtonAppStoreLinkQuotationary;

	- (IBAction)AppStoreLinkQuotationaryTouchUpInside;

@end

#endif
