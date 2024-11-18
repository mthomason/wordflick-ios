//
//  WFPauseButton.m
//  wordPuzzle
//
//  Created by Michael on 2/22/23.
//  Copyright © 2023 Michael Thomason. All rights reserved.
//

#import "WFPauseButton.h"

@implementation WFPauseButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithCoder:(NSCoder *)coder {
	if (self = [super initWithCoder:coder]) {
		UIImage *shuffleImage;
		if (@available(iOS 13.0, *)) {
			UIImageSymbolConfiguration *symbolConfiguration =
			[UIImageSymbolConfiguration configurationWithPointSize: 12.0
															weight: UIImageSymbolWeightBold
															 scale: UIImageSymbolScaleSmall];
			shuffleImage = [UIImage systemImageNamed:@"timer" withConfiguration:symbolConfiguration];
		} else {
			NSAssert(NO, @"Add a shuffle iamge here.");
			shuffleImage = [UIImage imageNamed:@"timer"];
		}
		CALayer *maskLayer = [CALayer layer];
		//maskLayer.frame = CGRectMake(0, 0, shuffleImage.size.width, shuffleImage.size.height);
		maskLayer.frame = CGRectMake(((self.bounds.size.width * (7.0/8.0))- shuffleImage.size.width) / 2.0,
									 (self.bounds.size.height - shuffleImage.size.height) / 2.0,
									 shuffleImage.size.width, shuffleImage.size.height);

		maskLayer.contents = (__bridge id)shuffleImage.CGImage;
		self.button.layer.mask = maskLayer;
		self.button.layer.shadowOpacity = 0.5;
		self.button.layer.shadowRadius = 1.0;
		self.button.layer.shadowOffset = CGSizeMake(1.0, -1.0);
		self.button.layer.shadowColor = [UIColor blackColor].CGColor;

	}
	return self;
}

- (WFButtonType)buttonType { return WFButtonTypePause; }
- (WFButtonColor)buttonColor { return WFButtonColorRed; }

+ (void)BackgroundGradient:(CGGradientRef _Nullable * _Nonnull)gradient alpha:(CGFloat)a {
	CGFloat colors[16] = {
		252.0 / 255.0, 90.0 / 255.0, 64.0 / 255.0, 1.0,
		239.0 / 255.0, 112.0 / 255.0, 96.0 / 255.0, 1.0,
		243.0 / 255.0, 44.0 / 255.0, 32.0 / 255.0, 1.0,
		232.0 / 255.0, 61.0 / 255.0, 51.0 / 255.0, 1.0
	};
	CGFloat colorStops[4] = {0.0, 0.5, 0.5, 1.0};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	*gradient = CGGradientCreateWithColorComponents(colorSpace, colors, colorStops, 4);
	CGColorSpaceRelease(colorSpace);
}

@end
