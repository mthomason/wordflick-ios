//
//  StringNumberWrapper.m
//  wordPuzzle
//
//  Created by Michael Thomason on 7/14/09.
//  Copyright 2009 Michael Thomason. All rights reserved.
//

#import "MTWordValue.h"

@implementation MTWordValue

- (instancetype)init {
	if (self = [super init]) {
		_word = @"";
		_points = [[NSNumber alloc] initWithInteger: 0];
	}
	return self;
}

- (instancetype)initWithCString:(char *)word andInteger:(NSInteger)value {
	if (self = [super init]) {
		_word = [[NSString alloc] initWithCString:word encoding:NSUTF8StringEncoding];
		_points = [[NSNumber alloc] initWithInteger: value];
	}
	return self;
}

- (instancetype)initWithString:(NSString *)w andInteger:(NSInteger)i {
	if (self = [super init]) {
		_word = [w copy];
		_points = [[NSNumber alloc] initWithInteger: i];
	}
	return self;
}

- (instancetype)initWithString:(NSString *)w andNumber:(NSNumber *)n {
	if (self = [super init]) {
		_word = [w copy];
		_points = [n copy];
	}
	return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		self.word = [decoder decodeObjectForKey:@"w"];
		self.points = [decoder decodeObjectForKey:@"p"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:_word forKey:@"w"];
	[encoder encodeObject:_points forKey:@"p"];
}

- (NSString *)kidFriendlyWord {
	return [MTWordValue cleanString:self.word withSpanishCharacters:YES];
}

+ (NSString *)cleanString:(NSString *)displayString {
	return [MTWordValue cleanString:displayString withSpanishCharacters:NO];
}

+ (NSString *)cleanString:(NSString *)displayString withSpanishCharacters:(BOOL)spanishCharacters {
	NSMutableString *returnString = [[NSMutableString alloc] initWithString:displayString];
	NSRange searchRange = NSMakeRange(0, returnString.length);
	[returnString replaceOccurrencesOfString:@"shit" withString:@"####" options:NSCaseInsensitiveSearch range:searchRange];
	[returnString replaceOccurrencesOfString:@"piss" withString:@"****" options:NSCaseInsensitiveSearch range:searchRange];
	[returnString replaceOccurrencesOfString:@"fuck" withString:@"@!@!" options:NSCaseInsensitiveSearch range:searchRange];
	[returnString replaceOccurrencesOfString:@"cunt" withString:@"*%*%" options:NSCaseInsensitiveSearch range:searchRange];
	[returnString replaceOccurrencesOfString:@"nigger" withString:@"#%#%#%" options:NSCaseInsensitiveSearch range:searchRange];
	[returnString replaceOccurrencesOfString:@"cocksucker" withString:@"#^#^#^#^#^" options:NSCaseInsensitiveSearch range:searchRange];
	[returnString replaceOccurrencesOfString:@"motherfucker" withString:@"******######" options:NSCaseInsensitiveSearch range:searchRange];
	[returnString replaceOccurrencesOfString:@"tits" withString:@"*#*#" options:NSCaseInsensitiveSearch range:searchRange];
	if (spanishCharacters) {
		[MTWordValue cleanSpanishString:returnString];
	}
	return returnString;
}

+ (NSString *)cleanSpanishString:(NSString *)displayString {
	NSMutableString *returnString = [[NSMutableString alloc] initWithString:displayString];
	NSRange searchRange = NSMakeRange(0, returnString.length);
	NSInteger numberReplacements = 0;
	numberReplacements = [returnString replaceOccurrencesOfString:@"1" withString:@"CH" options:NSCaseInsensitiveSearch range:searchRange];
	if (numberReplacements == 0) {
		numberReplacements = [returnString replaceOccurrencesOfString:@"2" withString:@"LL" options:NSCaseInsensitiveSearch range:searchRange];
		if (numberReplacements == 0) {
			numberReplacements = [returnString replaceOccurrencesOfString:@"3" withString:@"RR" options:NSCaseInsensitiveSearch range:searchRange];
			if (numberReplacements == 0) {
				if ([displayString isEqualToString:@"4"]) {
					[returnString replaceOccurrencesOfString:@"4" withString:@"Ñ" options:NSCaseInsensitiveSearch range:searchRange];
				}
			}
		}
	}
	return returnString;
}

@end
