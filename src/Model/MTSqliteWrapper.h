//
//  Sqlite3Wrapper.h
//  wordPuzzle
//
//  Created by Michael Thomason on 7/22/09.
//  Copyright 2019 Michael Thomason. All rights reserved.
//

#ifndef MTSqliteWrapper_h
#define MTSqliteWrapper_h

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface MTSqliteWrapper : NSObject {
  @public
	sqlite3 *database;
}
	- (instancetype)initWithBundleName:(NSString *)bundleName writable:(BOOL)writable;
	- (instancetype)initWithPath:(NSString *)path;
	- (void)openDatabase;
	- (void)openDatabase:(BOOL)readonly;
	- (void)closeDatabase;
@end

#endif
