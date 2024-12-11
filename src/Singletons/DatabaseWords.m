//
//  DatabaseWords.m
//  wordPuzzle
//
//  Created by Michael Thomason on 7/21/10.
//  Copyright 2019 Michael Thomason. All rights reserved.
//

#import "DatabaseWords.h"
#import "MTSqliteWrapper.h"
#import "MTLanguageType.h"

#import <mach/mach_time.h>

#define MAX_WORD_LEN_IN_DB 24

@implementation DatabaseWords

static bool _useCompressedDBWords;
static bool _isFirstAccess = true;
static unsigned long _wordCount;
static unsigned long _maxWordLength;
static MTLanguageType _languageType;
static NSArray <NSString *> *_letters;

static DatabaseWords *_sharedInstance = nil;

#pragma mark -
#pragma mark Static functions

inline static NSString *_randomLetter(void);
static bool searchBinary(const char *, int, int, int (^)(const char *, int));

inline static NSString *_randomLetter(void) {
	return _letters[arc4random_uniform((uint32_t)_letters.count)];
}

static bool searchBinary(const char *t, int low, int high, int (^cmp)(const char *, int)) {
	if (t == 0) return false;
	while (low <= high) {
		int ix = (low + high) / 2;
		int c = cmp(t, ix);
		if (c < 0) {
			high = ix - 1;
		} else if (c > 0) {
			low = ix + 1;
		} else {
			return true;
		}
	}
	//assert(false);
	return false;
}

__attribute__((unused))
static bool searchBinaryLegacy(const char *t, int low, int high, sqlite3_stmt **statement) {
	if (t == 0) return false;
	//char buff[_maxWordLength + 1];
	char *buff;
	while (low <= high) {
		int ix = (low + high) / 2;
		if (searchBinaryLegacyReadDB(ix, statement, &buff, _maxWordLength + 1) <= 0) return false;
		int cmp = sqlite3_stricmp(t, buff);
		if (cmp < 0) {
			high = ix - 1;
		} else if (cmp > 0) {
			low = ix + 1;
		} else {
			return true;
		}
	}
	return false;
}

__attribute__((unused))
static int searchBinaryLegacyReadDB(int ix, sqlite3_stmt **stmt, char **buff, unsigned long buff_len) {
	int rc = SQLITE_OK;
	rc = sqlite3_reset(*stmt);
	assert(rc == SQLITE_OK);
	rc = sqlite3_bind_int64(*stmt, 1, ix);
	assert(rc == SQLITE_OK);
	if (sqlite3_step(*stmt) != SQLITE_ROW) {
		rc = sqlite3_reset(*stmt);
		assert(rc == SQLITE_OK);
		buff = 0;
		return 0;
	}
	*buff = (char *)sqlite3_column_text(*stmt, 0);
	return sqlite3_column_bytes(*stmt, 0);
}

#pragma mark -
#pragma mark Singleton methods

+ (void)initialize {
	if (self == [DatabaseWords self]) {
		
		static dispatch_once_t _dispatchTokenSharedInstance;
		dispatch_once(&_dispatchTokenSharedInstance, ^{
			
			NSString *datPlist = [[NSBundle mainBundle] pathForResource:@"dat" ofType:@"plist"];
			NSDictionary *dictionaryWordCount = [[NSDictionary alloc] initWithContentsOfFile: datPlist];
			_maxWordLength = [dictionaryWordCount[@"m"] unsignedLongValue];
			_wordCount = [dictionaryWordCount[@"c"] unsignedLongValue];
			_languageType = [dictionaryWordCount[@"l"] unsignedShortValue];
			_useCompressedDBWords = [dictionaryWordCount[@"compressed"] boolValue] ? true : false;
			dictionaryWordCount = nil;
			
			NSString *lettersPlist = [[NSBundle mainBundle] pathForResource:@"letters" ofType:@"plist"];
			_letters = [[NSArray alloc] initWithContentsOfFile:lettersPlist];
			lettersPlist = nil;

			assert(_maxWordLength + 1 <= MAX_WORD_LEN_IN_DB + 1);
			
		});
	}
}

+ (instancetype)sharedInstance {
	static dispatch_once_t _dispatchTokenSharedInstance;
	dispatch_once(&_dispatchTokenSharedInstance, ^{
		_isFirstAccess = false;
		_sharedInstance = [[super allocWithZone:NULL] init];

		NSString *path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"dat"];
		MTSqliteWrapper *sqliteWrapper = [[MTSqliteWrapper alloc] initWithPath: path];
		[sqliteWrapper openDatabase:YES];
		_sharedInstance.database = sqliteWrapper;
		path = nil;
	});
	return _sharedInstance;
}

+ (instancetype)allocWithZone:(NSZone *)zone {
	return [self sharedInstance];
}

- (instancetype)init {
	if (_sharedInstance) return _sharedInstance;
	if (_isFirstAccess) [self doesNotRecognizeSelector:_cmd];
	self = [super init];
	return self;
}

- (void)dealloc {
	_database = nil;
}

- (id)mutableCopyWithZone:(struct _NSZone *)zone { return self; }

- (id)copyWithZone:(struct _NSZone *)zone { return self; }

- (MTLanguageType)language { return _languageType; }

- (NSUInteger)wordCount { return _wordCount; }

- (NSArray <NSString *> *)letters { return _letters; }

- (NSString *)randomLetter { return _letters[arc4random_uniform((uint32_t)_letters.count)]; }

- (NSString *)randomLetterAvoiding:(NSString *)avoid {
	uint_fast8_t ctr = 0;
	NSString *s = _randomLetter();
	while ([s isEqualToString:avoid] && ctr <= 2) {
		s = _randomLetter();
		ctr++;
	}
	return s;
}

- (BOOL)validateWord:(NSString *)word {
	if (word.length <= 0) {
		return NO;
	} else {
		BOOL result;
		__block sqlite3_stmt *statement = NULL;
		int sqlite3_rc = sqlite3_prepare_v2(_database->database,
											"SELECT b FROM a WHERE rowid = ?", -1, &statement, NULL);
		NSAssert(sqlite3_rc == SQLITE_OK, @"Binary search failed to prepair the statement.");
		int (^cmp_with_index)(const char *, int) = ^(const char *key, int ix) {
			int sqlite3_rc_comp = sqlite3_reset(statement);
			assert(sqlite3_rc_comp == SQLITE_OK);
			sqlite3_rc_comp = sqlite3_bind_int64(statement, 1, ix);
			assert(sqlite3_rc_comp == SQLITE_OK);
			sqlite3_rc_comp = sqlite3_step(statement);
			assert(sqlite3_rc_comp == SQLITE_ROW ||
				   sqlite3_rc_comp == SQLITE_DONE ||
				   sqlite3_rc_comp == SQLITE_OK);
			return sqlite3_stricmp(key, (const char *)sqlite3_column_text(statement, 0));
		};
		result = searchBinary(word.UTF8String, 1, (int)_wordCount, cmp_with_index) ? YES : NO;
		sqlite3_rc = sqlite3_finalize(statement);
		assert(sqlite3_rc == SQLITE_OK);
		return result;
	}
}

- (BOOL)validateWord2:(NSString *)word __attribute__((unused)) {
	if (word.length <= 0) {
		return NO;
	} else {
		uint64_t start, end, elapsed, elapsedNano;
		struct mach_timebase_info info;
		start = mach_absolute_time();
		
		BOOL result = NO;
		sqlite3_stmt *statement = NULL;
		//sqlite3_profile(_database->database, profile_callback2, NULL);
		int rc = sqlite3_prepare_v2(_database->database,
									"SELECT 1 FROM a WHERE b = ?", -1, &statement, NULL);
		NSAssert(rc == SQLITE_OK, @"Binary search failed to prepair the statement.");
		rc = sqlite3_bind_text(statement, 1, word.UTF8String, (int)word.length, SQLITE_STATIC);
		assert(rc == SQLITE_OK);
		rc = sqlite3_step(statement);
		assert(rc == SQLITE_ROW ||
			   rc == SQLITE_DONE ||
			   rc == SQLITE_OK);
		result = sqlite3_column_int(statement, 0) == 1 ? YES : NO;
		rc = sqlite3_finalize(statement);
		assert(rc == SQLITE_OK);
		
		end = mach_absolute_time();
		elapsed = end - start;
		mach_timebase_info(&info);
		elapsedNano = elapsed * info.numer / info.denom;
		NSLog(@"Function 2 took %llu nanoseconds to execute", elapsedNano);
		NSLog(@"Function 2 took %fs seconds of CPU time", elapsedNano / 1e9);
		return result;
	}
}

__attribute__((unused))
void profile_callback2(void *context, const char *sql, sqlite3_uint64 nsecs) {
	//NSLog(@"SQL2: %s took %llu nanoseconds", sql, nsecs);
}

@end
