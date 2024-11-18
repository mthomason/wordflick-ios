//
//  viewPassthroughTouches.m
//  wordPuzzle
//
//  Created by Michael Thomason on 6/5/12.
//  Copyright (c) 2014 Michael Thomason. All rights reserved.
//

#import "MUIViewPassthroughTouches.h"

@implementation MUIViewPassthroughTouches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	//[super touchesBegan:touches withEvent:event];
	[self.nextResponder touchesBegan:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	//[super touchesCancelled:touches withEvent:event];
	[self.nextResponder touchesCancelled:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	//[super touchesMoved:touches withEvent:event];
	[self.nextResponder touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	//[super touchesEnded:touches withEvent:event];
	[self.nextResponder touchesEnded:touches withEvent:event];
}

@end

