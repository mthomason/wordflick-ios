//
//  MNSMessage.m
//  wordPuzzle
//
//  Created by Michael Thomason on 2/15/10.
//  Copyright 2010 Michael Thomason. All rights reserved.
//

#import "MNSMessage.h"
#import "UIColor+Wordflick.h"

@implementation MNSMessage


- (instancetype)init {
	if (self = [super init]) {
		_message = [[NSString alloc] init];
		_messageType = MNSMessageFun;
	}
	return self;
}

- (instancetype)initWithString:(NSString *)string andType:(MNSMessageType)type {
	if (self = [super init]) {
		_message = [[NSString alloc] initWithString: string];
		_messageType = type;
	}
	return self;
}

- (UIColor *)color {
	switch (self.messageType) {
		case MNSMessageStandard:
			return [UIColor gradientBlue];
		case MNSMessageGreen:
			return [UIColor washedOutGreen];
		case MNSMessageBlue:
		case MNSMessageSpace:
			return [UIColor gradientBlue];
		case MNSMessageRed:
			return [UIColor washedOutRed];
		case MNSMessagePurple:
			return [UIColor washedOutPurple];
		case MNSMessageYellow:
			return [UIColor washedOutYellow];
		default:
			return [UIColor gradientBlue];
	}
}

@end
