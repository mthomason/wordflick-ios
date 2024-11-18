//
//  MNSMessage.h
//  wordPuzzle
//
//  Created by Michael Thomason on 2/15/10.
//  Copyright 2010 Michael Thomason. All rights reserved.
//

#ifndef MNSMessage_h
#define MNSMessage_h

#import <Foundation/Foundation.h>
#import "MTMessageType.h"

@interface MNSMessage : NSObject

	@property (nonatomic, copy) NSString *message;
	@property (nonatomic, assign) MNSMessageType messageType;
	@property (weak, nonatomic, readonly) UIColor *color;

	- (instancetype)initWithString:(NSString *)string andType:(MNSMessageType)type;

@end

#endif
