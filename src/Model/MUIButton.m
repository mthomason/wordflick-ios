//
//  MUIButton.m
//  wordPuzzle
//
//  Created by Michael Thomason on 7/2/10.
//  Copyright 2010 Michael Thomason. All rights reserved.
//

#import "MUIButton.h"

@interface MUIButton ()

@property (nonatomic, strong) UIView *backgroundView;

@end

@implementation MUIButton

- (instancetype)initWithCoder:(NSCoder *)coder {
	if (self = [super initWithCoder:coder]) {
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {

	}
	return self;
}

/*- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	[self.superview touchesBegan:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesCancelled:touches withEvent:event];	
	[self.superview touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];	
	[self.superview touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesMoved:touches withEvent:event];
	[self.superview touchesMoved:touches withEvent:event];
}*/

- (void)drawRect:(CGRect)rect {
	
	CAGradientLayer *gradientLayer = [CAGradientLayer layer];
	gradientLayer.frame = self.bounds;
	gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0].CGColor,
							 (__bridge id)[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0].CGColor,
							 (__bridge id)[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0].CGColor,
							 (__bridge id)[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0].CGColor];
	[self.layer addSublayer:gradientLayer];
	
	// Create a mask layer with the shuffle image
	UIImage *shuffleImage;
	if (@available(iOS 13.0, *)) {
		UIImageSymbolConfiguration *symbolConfiguration =
		[UIImageSymbolConfiguration configurationWithPointSize: 24.0
														weight: UIImageSymbolWeightBold
														 scale: UIImageSymbolScaleMedium];
		shuffleImage = [UIImage systemImageNamed:@"shuffle" withConfiguration:symbolConfiguration];
	} else {
		NSAssert(NO, @"Add a shuffle iamge here.");
		shuffleImage = [UIImage imageNamed:@"shuffle"];
	}
	CALayer *maskLayer = [CALayer layer];
	//maskLayer.frame = CGRectMake(0, 0, shuffleImage.size.width, shuffleImage.size.height);
	maskLayer.frame = CGRectMake((self.bounds.size.width - shuffleImage.size.width) / 2.0,
								 (self.bounds.size.height - shuffleImage.size.height) / 2.0,
								 shuffleImage.size.width, shuffleImage.size.height);

	maskLayer.contents = (__bridge id)shuffleImage.CGImage;
	self.layer.mask = maskLayer;

}
/*
- (void)drawRect:(CGRect)rect {
	// Create gradient
		NSArray *colors = @[(__bridge id)[UIColor colorWithRed:0.09 green:0.51 blue:0.98 alpha:1.0].CGColor,
							(__bridge id)[UIColor colorWithRed:0.05 green:0.32 blue:0.81 alpha:1.0].CGColor];
		CGFloat locations[] = {0.0, 1.0};
		CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);

		// Draw rounded rectangle
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextSaveGState(context);
		UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:8.0];
		[roundedRect addClip];
		CGContextDrawLinearGradient(context, gradient, CGPointZero, CGPointMake(0, self.bounds.size.height), 0);

		// Draw system image
//		UIImage *shuffleImage = [UIImage systemImageNamed:@"shuffle"];
//		CGRect shuffleRect = CGRectMake((self.bounds.size.width - shuffleImage.size.width) / 2.0,
//										(self.bounds.size.height - shuffleImage.size.height) / 2.0,
//										shuffleImage.size.width, shuffleImage.size.height);
//		[shuffleImage drawInRect:shuffleRect blendMode:kCGBlendModeDestinationIn alpha:1.0];

		CGContextRestoreGState(context);

		// Clean up
		CGGradientRelease(gradient);
	
	
	
	// Define the gradient colors
	UIColor *startColor = [UIColor colorWithRed:0.2 green:0.6 blue:0.8 alpha:1.0];
	UIColor *endColor = [UIColor colorWithRed:0.0 green:0.4 blue:0.6 alpha:1.0];

	// Create the gradient context
	//CGContextRef context = UIGraphicsGetCurrentContext();
	//CGGradientRef gradient;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	locations[0] = 0.0; locations[1] = 1.0; // {0.0, 1.0};
	colors = @[(__bridge id)startColor.CGColor, (__bridge id)endColor.CGColor];
	gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
	CGPoint startPoint = CGPointMake(0, 0);
	CGPoint endPoint = CGPointMake(0, self.bounds.size.height);
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);

	UIImage *shuffleImage;
	if (@available(iOS 13.0, *)) {
		UIImageSymbolConfiguration *symbolConfiguration =
		[UIImageSymbolConfiguration configurationWithPointSize: 24.0
														weight: UIImageSymbolWeightBold
														 scale: UIImageSymbolScaleMedium];
		shuffleImage = [UIImage systemImageNamed:@"shuffle" withConfiguration:symbolConfiguration];
	} else {
		NSAssert(NO, @"Add a shuffle iamge here.");
		shuffleImage = [UIImage imageNamed:@"shuffle"];
	}

	// Draw the shuffle indicator
	//UIFont *font = [UIFont systemFontOfSize:24.0];
	//NSAttributedString *shuffleString = [[NSAttributedString alloc] initWithString:@"\u21a9" attributes:@{NSFontAttributeName: font}];
	CGSize shuffleSize = [shuffleImage size];
	CGRect shuffleRect = CGRectMake((self.bounds.size.width - shuffleSize.width) / 2.0, (self.bounds.size.height - shuffleSize.height) / 2.0, shuffleSize.width, shuffleSize.height);
	//[shuffleString drawInRect:shuffleRect];

	//CGRect shuffleRect = CGRectMake((self.bounds.size.width - shuffleImage.size.width) / 2.0,
	//								(self.bounds.size.height - shuffleImage.size.height) / 2.0,
	//								shuffleImage.size.width, shuffleImage.size.height);
	
	[shuffleImage drawInRect: shuffleRect
				   blendMode: kCGBlendModeDestinationOut
					   alpha: 1.0];

	// Clean up
	CGGradientRelease(gradient);
	CGColorSpaceRelease(colorSpace);
}
*/
/*
- (void)drawRect:(CGRect)rect {
	
	CAGradientLayer *gradientLayer = [CAGradientLayer layer];
	gradientLayer.frame = self.bounds;
	gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0].CGColor,
							 (__bridge id)[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0].CGColor,
							 (__bridge id)[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0].CGColor,
							 (__bridge id)[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0].CGColor];
	[self.layer addSublayer:gradientLayer];
	
	// Create a mask layer with the shuffle image
	UIImage *shuffleImage;
	if (@available(iOS 13.0, *)) {
		UIImageSymbolConfiguration *symbolConfiguration =
		[UIImageSymbolConfiguration configurationWithPointSize: 24.0
														weight: UIImageSymbolWeightBold
														 scale: UIImageSymbolScaleMedium];
		shuffleImage = [UIImage systemImageNamed:@"shuffle" withConfiguration:symbolConfiguration];
	} else {
		NSAssert(NO, @"Add a shuffle iamge here.");
		shuffleImage = [UIImage imageNamed:@"shuffle"];
	}
	CALayer *maskLayer = [CALayer layer];
	//maskLayer.frame = CGRectMake(0, 0, shuffleImage.size.width, shuffleImage.size.height);
	maskLayer.frame = CGRectMake((self.bounds.size.width - shuffleImage.size.width) / 2.0,
								 (self.bounds.size.height - shuffleImage.size.height) / 2.0,
								 shuffleImage.size.width, shuffleImage.size.height);

	maskLayer.contents = (__bridge id)shuffleImage.CGImage;
	self.layer.mask = maskLayer;

}

*/

/*
- (void)drawRect:(CGRect)rect {
	// Create gradient
	
	NSArray *colors = @[(__bridge id)[UIColor colorWithRed:0.09 green:0.51 blue:0.98 alpha:1.0].CGColor,
						(__bridge id)[UIColor colorWithRed:0.05 green:0.32 blue:0.81 alpha:1.0].CGColor];
	CGFloat locations[] = {0.0, 1.0};
	CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);

	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextSetShadowWithColor(context, CGSizeMake(0.0, rect.size.width / 80.0), 1.0, [UIColor grayColor].CGColor);
	CGContextBeginTransparencyLayer(context, NULL);
	CGContextSaveGState(context);

	//UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:8.0];
	//[roundedRect addClip];
	CGContextDrawLinearGradient(context, gradient, CGPointZero, CGPointMake(0, self.bounds.size.height), 0);

	UIImage *shuffleImage;
	if (@available(iOS 13.0, *)) {
		UIImageSymbolConfiguration *symbolConfiguration =
		[UIImageSymbolConfiguration configurationWithPointSize: 24.0
														weight: UIImageSymbolWeightBold
														 scale: UIImageSymbolScaleMedium];
		shuffleImage = [UIImage systemImageNamed:@"shuffle" withConfiguration:symbolConfiguration];
	} else {
		NSAssert(NO, @"Add a shuffle iamge here.");
		shuffleImage = [UIImage imageNamed:@"shuffle"];
	}

	CGRect shuffleRect = CGRectMake((self.bounds.size.width - shuffleImage.size.width) / 2.0,
									(self.bounds.size.height - shuffleImage.size.height) / 2.0,
									shuffleImage.size.width, shuffleImage.size.height);
	
	[shuffleImage drawInRect: shuffleRect
				   blendMode: kCGBlendModeDestinationIn
					   alpha: 1.0];

	
	CGContextRef tileContext = UIGraphicsGetCurrentContext();
	
	UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:8.0];
	//[roundedRect addClip];
	CGContextDrawLinearGradient(tileContext, gradient, CGPointZero, CGPointMake(0, self.bounds.size.height), 0);

	// Draw system image
	//UITraitCollection *traitCollection = self.traitCollection;
	//traitCollection.legibilityWeight = UILegibilityWeightBold;
	//[UIImageConfiguration configurationWithTraitCollection: self.traitCollection];
	UIImageSymbolConfiguration *symbolConfiguration = [UIImageSymbolConfiguration configurationWithPointSize:24.0
																									  weight:UIImageSymbolWeightBold
																									   scale:UIImageSymbolScaleMedium];
	//CGRectGetMidX(<#CGRect rect#>)
	UIImage *shuffleImage = [UIImage systemImageNamed:@"shuffle" withConfiguration:symbolConfiguration];
	CGRect shuffleRect = CGRectMake((self.bounds.size.width - shuffleImage.size.width) / 2.0,
									(self.bounds.size.height - shuffleImage.size.height) / 2.0,
									shuffleImage.size.width, shuffleImage.size.height);
	
	[shuffleImage drawInRect: shuffleRect
				   blendMode: kCGBlendModeDestinationOut
					   alpha: 1.0];

	//CGContextSaveGState(context);

	colors = @[(__bridge id)[UIColor colorWithRed:1.00 green:1.00 blue:0.98 alpha:1.0].CGColor,
						(__bridge id)[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0].CGColor];
	locations[0] = 0.0;
	locations[1] = 1.0;
	//CGGradientRef gradientWhite = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);
	//CGContextDrawLinearGradient(context, gradientWhite, CGPointZero, CGPointMake(0, self.bounds.size.height), 0);

	//CGContextRestoreGState(context);

	CGContextRestoreGState(context);

	// Clean up
	CGGradientRelease(gradient);
}
*/

/*
- (void)drawRect:(CGRect)rect {
	self.layer.cornerRadius = 50.0;

	// Draw the button background gradient
	UIColor *startColor = [UIColor colorWithRed:0.0 green:0.6 blue:1.0 alpha:1.0];
	UIColor *endColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.8 alpha:1.0];
	[self drawLinearGradientWithStartColor:startColor endColor:endColor];

	// Draw the system image centered in the button
	UIImage *shuffleImage = [UIImage systemImageNamed:@"shuffle"];
	CGRect imageRect = CGRectMake(0, 0, shuffleImage.size.width, shuffleImage.size.height);
	imageRect = CGRectOffset(imageRect, (self.bounds.size.width - imageRect.size.width) / 2,
							 (self.bounds.size.height - imageRect.size.height) / 2);
	[shuffleImage drawInRect:imageRect blendMode:kCGBlendModeDestinationOut alpha:1.0];
}

- (void)drawLinearGradientWithStartColor:(UIColor *)startColor endColor:(UIColor *)endColor {
	CGContextRef context = UIGraphicsGetCurrentContext();
	NSArray *colors = @[(__bridge id)startColor.CGColor, (__bridge id)endColor.CGColor];
	CGFloat locations[] = {0.0, 1.0};
	CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);
	CGContextDrawLinearGradient(context, gradient, CGPointZero, CGPointMake(0, self.bounds.size.height), 0);
	CGGradientRelease(gradient);
}
*/
/*
- (void)drawRect:(CGRect)rect {
	// Create a gradient layer
	CAGradientLayer *gradientLayer = [CAGradientLayer layer];
	gradientLayer.frame = self.bounds;
	gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:0.08 green:0.41 blue:0.85 alpha:1.0].CGColor,
							 (__bridge id)[UIColor colorWithRed:0.06 green:0.29 blue:0.61 alpha:1.0].CGColor,
							 (__bridge id)[UIColor colorWithRed:0.04 green:0.20 blue:0.42 alpha:1.0].CGColor,
							 (__bridge id)[UIColor colorWithRed:0.02 green:0.10 blue:0.21 alpha:1.0].CGColor];
	[self.layer addSublayer:gradientLayer];
	
	// Create a mask layer with the shuffle image
	UIImage *shuffleImage = [UIImage systemImageNamed:@"shuffle"];
	CALayer *maskLayer = [CALayer layer];
	maskLayer.frame = CGRectMake(0, 0, shuffleImage.size.width, shuffleImage.size.height);
	maskLayer.contents = (__bridge id)shuffleImage.CGImage;
	self.layer.mask = maskLayer;
	
	// Apply layer properties to create depth and texture
	self.layer.cornerRadius = 10.0;
	self.layer.shadowOpacity = 0.5;
	self.layer.shadowRadius = 5.0;
	self.layer.shadowOffset = CGSizeMake(0, 3);
	self.layer.shadowColor = [UIColor blackColor].CGColor;
}
*/
/*
- (void)drawRect:(CGRect)rect {
	self.layer.cornerRadius = 10.0;

	// Define the gradient colors
	UIColor *startColor = [UIColor colorWithRed:0.2 green:0.6 blue:0.8 alpha:1.0];
	UIColor *endColor = [UIColor colorWithRed:0.0 green:0.4 blue:0.6 alpha:1.0];

	// Create the gradient context
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGGradientRef gradient;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGFloat locations[] = {0.0, 1.0};
	NSArray *colors = @[(__bridge id)startColor.CGColor, (__bridge id)endColor.CGColor];
	gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
	CGPoint startPoint = CGPointMake(0, 0);
	CGPoint endPoint = CGPointMake(0, self.bounds.size.height);
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);

	// Draw the shuffle indicator
	NSAttributedString *shuffleString = [[NSAttributedString alloc] initWithString: @"\uf074" //@"\U0001F500"
																		attributes: @{ NSFontAttributeName: [UIFont systemFontOfSize:24.0] }];
	CGSize shuffleSize = [shuffleString size];
	CGRect shuffleRect = CGRectMake((self.bounds.size.width - shuffleSize.width) / 2, (self.bounds.size.height - shuffleSize.height) / 2, shuffleSize.width, shuffleSize.height);
	//[shuffleString drawInRect:shuffleRect];

	// Clean up
	CGGradientRelease(gradient);
	CGColorSpaceRelease(colorSpace);
}
*/
@end

