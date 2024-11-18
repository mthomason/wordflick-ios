//
//  MTAbortView.h
//  Wordflick-Pro
//
//  Created by Michael on 1/14/20.
//  Copyright © 2020 Michael Thomason. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTAbortView : UIView

@property (nonatomic, strong) IBOutlet UISwitch *saftySwitch;
@property (nonatomic, strong) IBOutlet UIButton *abortButton;

@end

NS_ASSUME_NONNULL_END
