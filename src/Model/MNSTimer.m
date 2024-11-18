//
//  MNSTimer.m
//  wordPuzzle
//
//  Created by Michael Thomason on 7/7/09.
//  Copyright 2019 Michael Thomason. All rights reserved.
//

#import "MNSTimer.h"
#import "wordPuzzleAppDelegate.h"
#import "MNSAudio.h"

@interface MNSTimer () {
	bool _justSpoke;
}
@property (nonatomic, retain) MNSAudio *audio;
@end

@implementation MNSTimer

#pragma mark -
#pragma mark Static Methods

+ (NSTimeInterval)standardTick { return 0.9600; }

#pragma mark -
#pragma mark Instance Methods

- (void)dealloc {
	_delegate = nil;
	_audio = nil;
}

- (nullable instancetype)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		_paused = [decoder decodeBoolForKey: NSStringFromSelector(@selector(isPaused))];
		_seconds = [decoder decodeIntegerForKey: NSStringFromSelector(@selector(seconds))];
		_justSpoke = false;
		_secondsCounterForLevel = [decoder decodeIntegerForKey: NSStringFromSelector(@selector(secondsCounterForLevel))];
		_audio = [[MNSAudio alloc] init];
		[self startTimer:  _seconds];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeInteger: _secondsCounterForLevel forKey: NSStringFromSelector(@selector(secondsCounterForLevel))];
	[encoder encodeInteger: _seconds forKey: NSStringFromSelector(@selector(seconds))];
	[encoder encodeBool: _paused forKey: NSStringFromSelector(@selector(isPaused))];
}

- (id)init {
	if (self = [super init]) {
		self.secondsCounterForLevel = 0;
		_paused = NO;
		self.secondsTimer = nil;
		_justSpoke = false;
		_audio = [[MNSAudio alloc] init];
	}
	return self;
}

- (void)startTimer:(long)s {
	[self setSeconds: s];
	[self allocTimer];
	[self.delegate setTime:self.seconds];
	_justSpoke = false;
}

- (void)extendTimer:(long)time {
	[self setSeconds: (self.seconds + time)];
	[self.delegate setTime:self.seconds];
}

- (long)pause {
	if (!self.isPaused) self.paused = YES;
	return self.seconds;
}

- (void)resume {
	if (self.isPaused) {
		self.paused = NO;
		if (self.seconds >= 0) {
			[self allocTimer];
		}
	}
}

- (void)allocTimer {
	[self deallocTimer];
	self.secondsTimer = [NSTimer scheduledTimerWithTimeInterval: [MNSTimer standardTick]
														 target: self
													   selector: @selector(timerTickSecond:)
													   userInfo: nil
														repeats: YES];
}

- (void)deallocTimer {
	if (self.secondsTimer != nil) {
		[self.secondsTimer invalidate];
		[self setSecondsTimer: nil];
	}
}

#pragma mark -
#pragma mark Timer Action Methods

- (void)timerTickSecond:(NSTimer *)timer {
	if (![self isPaused]) {
		self.seconds--;
		self.secondsCounterForLevel++;
		[self.delegate setTime:self.seconds];
	}
	switch (self.seconds + 1) {
		case 0:
			if (self.secondsTimer != nil && !self.isPaused) {
				[self.audio playTimeIsUp];
				[self deallocTimer];
				[self.delegate timeIsUp];
				[self pause];
			}
			break;
		case 15:
			if (!_justSpoke) [self.audio playFifteenSeconds];
			_justSpoke = true;
			break;
		case 30:
			if (!_justSpoke) [self.audio playThirtySeconds];
			_justSpoke = true;
			break;
		case 60:
			if (!_justSpoke) [self.audio playOneMinute];
			_justSpoke = true;
			break;
		case 120:
			if (!_justSpoke) [self.audio playTwoMinutes];
			_justSpoke = true;
			break;
		case 180:
			if (!_justSpoke) [self.audio playThreeMinutes];
			_justSpoke = true;
			break;
		default:
			_justSpoke = false;
			break;
	}
}


@end
