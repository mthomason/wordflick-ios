//
//  DatabaseUsers.m
//  wordPuzzle
//
//  Created by Michael Thomason on 7/21/10.
//  Copyright 2010 Michael Thomason. All rights reserved.
//

#import "DatabaseUsers.h"
#import "MTSqliteWrapper.h"

@implementation DatabaseUsers

static bool _isFirstAccess = true;
static DatabaseUsers *_sharedInstance = nil;

#pragma mark -
#pragma mark Singleton methods

+ (instancetype)sharedInstance {
	static dispatch_once_t _dispatchToken;
	dispatch_once(&_dispatchToken, ^{
		_isFirstAccess = false;
		_sharedInstance = [[super allocWithZone:NULL] init];

		NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
		NSAssert(paths.count > 0, @"Expect some paths.");
		NSString *directoryPath = paths.firstObject;
		NSString *userDB = @"users.db";
		NSString *databasePath = [directoryPath stringByAppendingPathComponent: userDB];

		if (![[NSFileManager defaultManager] fileExistsAtPath:databasePath]) {
			NSString *bundleDirectoryPath = [[NSBundle mainBundle] resourcePath];
			NSString *bundleDatabasePath = [bundleDirectoryPath stringByAppendingPathComponent: userDB];
			NSError *fileCopyError;
			BOOL fileCopyResult = [[NSFileManager defaultManager] copyItemAtPath:bundleDatabasePath
																		  toPath:databasePath
																		   error:&fileCopyError];
			NSAssert(fileCopyResult, @"Failed to install the user database.");
		}

		MTSqliteWrapper *sqliteWrapper = [[MTSqliteWrapper alloc] initWithPath:databasePath];
		[sqliteWrapper openDatabase];
		_sharedInstance.database = sqliteWrapper;
		//[sqliteWrapper release];
	});
    return _sharedInstance;
}

+ (instancetype)allocWithZone:(NSZone *)zone {
	return [self sharedInstance];
}

- (void)dealloc {
	_database = nil;
}

- (instancetype)init {
	if (_sharedInstance) return _sharedInstance;
	if (_isFirstAccess) [self doesNotRecognizeSelector:_cmd];
	self = [super init];
	return self;
}

- (id)mutableCopyWithZone:(struct _NSZone *)zone { return self; }

- (id)copyWithZone:(struct _NSZone *)zone { return self; }

@end
