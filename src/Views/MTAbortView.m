//
//  MTAbortView.m
//  Wordflick-Pro
//
//  Created by Michael on 1/14/20.
//  Copyright © 2020 Michael Thomason. All rights reserved.
//

#import "MTAbortView.h"

@implementation MTAbortView

- (IBAction)switchAbortLevelValueDidChange:(UISwitch *)sender {
	self.abortButton.enabled = sender.isOn;
}

@end
