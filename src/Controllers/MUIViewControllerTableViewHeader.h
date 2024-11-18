//
//  MUIViewControllerTableViewHeader.h
//  wordPuzzle
//
//  Created by Michael Thomason on 8/13/09.
//  Copyright 2009 Michael Thomason. All rights reserved.
//

#ifndef MUIViewControllerTableViewHeader_h
#define MUIViewControllerTableViewHeader_h

#import <UIKit/UIKit.h>

@interface MUIViewControllerTableViewHeader : UIViewController

    @property (strong) IBOutlet UILabel *myLabel;
    @property (copy) IBOutlet NSString *headerText;

    - (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil text:(NSString *)display;

@end

#endif
