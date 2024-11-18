//
//  MTGameMenu.m
//  Wordflick-Pro
//
//  Created by Michael on 11/18/19.
//  Copyright © 2019 Michael Thomason. All rights reserved.
//

#import "WFMenuView.h"
#import "WFTileView.h"
#import "WFTileData.h"

@interface WFMenuView()

@property (nonatomic, strong) IBOutlet UIButton *volume;

@end

@implementation WFMenuView

- (void)awakeFromNib {
	
	if (@available(iOS 14.0, *)) {
		[self.volume setImage: [UIImage systemImageNamed:@"speaker.wave.3"]
					 forState: UIControlStateNormal];
	} else if (@available(iOS 13.0, *)) {
		[self.volume setImage: [UIImage systemImageNamed:@"speaker.3"]
					 forState: UIControlStateNormal];
	} else {
		[self.volume setImage: [UIImage imageNamed:@"speaker.wave.3"]
					 forState: UIControlStateNormal];
	}
	
	[super awakeFromNib];
	
}

@end
