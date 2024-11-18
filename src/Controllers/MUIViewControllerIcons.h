//
//  MUIViewControllerIcons.h
//  wordPuzzle
//
//  Created by Michael Thomason on 6/5/12.
//  Copyright (c) 2019 Michael Thomason. All rights reserved.
//

#ifndef MUIViewControllerIcons_h
#define MUIViewControllerIcons_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface MUIViewControllerIcons : UIViewController

@property (nonatomic, retain) IBOutlet UIView *icon57;      //iPhone Icon
@property (nonatomic, retain) IBOutlet UIView *icon114;     //iPhone Icon @2x

@property (nonatomic, retain) IBOutlet UIView *icon72;      //iPad Icon
@property (nonatomic, retain) IBOutlet UIView *icon144;     //iPad Icon @2x

@property (nonatomic, retain) IBOutlet UIView *icon512;     //App Store Icon
@property (nonatomic, retain) IBOutlet UIView *icon1024;    //App Store Icon @2x

@property (nonatomic, retain) IBOutlet UIView *icon29;      //Spotlight Icon
@property (nonatomic, retain) IBOutlet UIView *icon58;      //Spotlight Icon @2x

@property (nonatomic, retain) IBOutlet UIView *icon40;
@property (nonatomic, retain) IBOutlet UIView *icon80;

@property (nonatomic, retain) IBOutlet UIView *icon60;
@property (nonatomic, retain) IBOutlet UIView *icon120;

@property (nonatomic, retain) IBOutlet UIView *icon76;
@property (nonatomic, retain) IBOutlet UIView *icon152;

@property (nonatomic, retain) IBOutlet UIView *icon50;      //Spotlight Icon iPad
@property (nonatomic, retain) IBOutlet UIView *icon100;     //Spotlight Icon iPad @2x

@property (nonatomic, retain) IBOutlet UIView *icon16;      //Facebook Icon
@property (nonatomic, retain) IBOutlet UIView *icon64;      //Facebook Icon
@property (nonatomic, retain) IBOutlet UIView *icon96;      //Facebook Icon
@property (nonatomic, retain) IBOutlet UIView *icon128;     //Facebook Icon

@property (nonatomic, retain) IBOutlet UIScrollView *scrollViewIcons;
@property (nonatomic, retain) IBOutlet UIView *logoInGame;
@property (nonatomic, retain) IBOutlet UILabel *labelClassroom;

@end

#endif
