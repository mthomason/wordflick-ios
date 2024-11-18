//
//  MUIViewLabelGlow.m
//  wordPuzzle
//
//  Created by Michael Thomason on 8/30/09.
//  Copyright 2020 Michael Thomason. All rights reserved.
//

#import "WFGlowLabelView.h"
#import <UIKit/UIKit.h>

#import "wordPuzzleAppDelegate.h"
#import "MNSMessage.h"
#import "UIColor+Wordflick.h"

@interface WFGlowLabelView () {
	CGRect _drawRect;
}
@property (nonatomic, copy) NSString *text;
@property (readwrite, nonatomic, retain) NSMutableDictionary *attributes;
@property (readwrite, nonatomic, assign) BOOL messageIsDisplaying;

@end

@implementation WFGlowLabelView

- (void)dealloc {
	_attributes = nil;
	_text = nil;
}

static void initalizeAllValues(WFGlowLabelView *object) {
	object->_drawRect = CGRectZero;
	object.backgroundColor = [UIColor clearColor];
	object.opaque = NO;
	object.hidden = NO;
	object.alpha = 0.0;
	object.messageIsDisplaying = NO;
	object.text = @"";

	UIFont *font = [UIFont boldSystemFontOfSize: 24.0];
	UIColor *textColor = [UIColor light];

	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.allowsDefaultTighteningForTruncation = YES;
	paragraphStyle.lineBreakMode = NSLineBreakByTruncatingMiddle;
	paragraphStyle.alignment = NSTextAlignmentCenter;

	NSShadow *shadowForText = [[NSShadow alloc] init];
	shadowForText.shadowColor = [UIColor highlight];
	shadowForText.shadowBlurRadius = CGSizeZero.width;
	shadowForText.shadowOffset = CGSizeZero;

	NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
									   font, NSFontAttributeName,
									   textColor, NSForegroundColorAttributeName,
									   shadowForText, NSShadowAttributeName,
									   paragraphStyle, NSParagraphStyleAttributeName, nil];
	object.attributes = attributes;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		initalizeAllValues(self);
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame setText:(NSString *)t andFontSize:(CGFloat)s {
	if (self = [super initWithFrame:frame]) {
		initalizeAllValues(self);
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		initalizeAllValues(self);
	}
	return self;
}

- (void)setFontSize:(CGFloat)fontSize {
	UIFont *font = [UIFont boldSystemFontOfSize:fontSize];
	[self.attributes setObject:font forKey:NSFontAttributeName];
}

- (CGFloat)fontSize {
	return ((UIFont *)[self.attributes objectForKey:NSFontAttributeName]).pointSize;
}

- (BOOL)displayMessage:(MNSMessage *)message
			completion:(void (^ __nullable)(BOOL finished))completion {

	if (self.messageIsDisplaying) return NO;

	self.messageIsDisplaying = YES;
	self.text = message.message;
	[self.attributes setObject: message.color forKey: NSForegroundColorAttributeName];

	self.transform = CGAffineTransformMakeScale((1.0 / 3.0) * 10.0, (1.0 / 3.0) * 10.0);
	
	[UIView animateWithDuration: 0.19191919 delay: 0.0 options: UIViewAnimationOptionCurveEaseIn animations:^{
		self.alpha = 1.0;
		self.transform = CGAffineTransformMakeScale(1.0, 1.0);
		[self setNeedsDisplay];
	} completion:^(BOOL finished) {
		if (finished) {
			self.text = @"";
			[UIView animateWithDuration:0.13131313 delay:0.6666 options:UIViewAnimationOptionCurveEaseOut animations:^{
				self.alpha = 0.0;
				self.transform = CGAffineTransformMakeScale(0.2, 0.2);
			} completion:^(BOOL finished) {
				if (finished) {
					self.messageIsDisplaying = NO;
					self.transform = CGAffineTransformMakeScale(1.0, 1.0);
					if (completion != nil) {
						completion(YES);
					}
				}
			}];
		}
	}];
	return YES;
}

- (void)drawRect:(CGRect)rect {
	if (_text.length == 0) return;
	_drawRect.size = rect.size;
	_drawRect.origin.x = rect.origin.x;
	_drawRect.origin.y = rect.origin.y + (rect.size.height / 7.0);
	[self.text drawInRect: _drawRect withAttributes: self.attributes];
}

@end
