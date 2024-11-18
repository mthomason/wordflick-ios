//
//  Sqlite3Wrapper.m
//  wordPuzzle
//
//  Created by Michael Thomason on 7/22/09.
//  Copyright 2019 Michael Thomason. All rights reserved.
//

#import "MTSqliteWrapper.h"
#import <stdlib.h>
#import <zlib.h>
#import <assert.h>
#import "shoco.h"

#include <utime.h>

@interface MTSqliteWrapper () {
	bool _databaseIsWritable;
}
	@property (nonatomic, copy) NSString *databasePath;
@end

#pragma mark -
#pragma mark Sqlite3 (compress.c) zLib compress(X)

@implementation MTSqliteWrapper

/*
 See the following URL for origional details.
 https://www.sqlite.org/src/file/ext/misc/compress.c
*/

// If you use this function compressFunc again, uncommment the line below to make it static.
//static
__attribute__((unused))
void compressFunc(sqlite3_context *context, int argc, sqlite3_value **argv) {
	const unsigned char *pIn;
	unsigned char *pOut;
	unsigned int nIn;
	unsigned long int nOut;
	unsigned char x[8];
	int rc;
	int i, j;
	
	pIn = sqlite3_value_blob(argv[0]);
	nIn = sqlite3_value_bytes(argv[0]);
	nOut = 13 + nIn + (nIn+999)/1000;
	pOut = sqlite3_malloc64(nOut+5);
	for(i=4; i>=0; i--){
		x[i] = (nIn >> (7*(4-i)))&0x7f;
	}
	for(i=0; i<4 && x[i]==0; i++){}
	for(j=0; i<=4; i++, j++) pOut[j] = x[i];
	pOut[j-1] |= 0x80;
	rc = compress(&pOut[j], &nOut, pIn, nIn);
	if( rc==Z_OK ){
		sqlite3_result_blob64(context, pOut, nOut+j, sqlite3_free);
	}else{
		sqlite3_free(pOut);
	}
}


// If you use this function uncompressFunc again, uncommment the line below to make it static.
// This code was left in as
//static
__attribute__((unused))
void uncompressFunc(sqlite3_context *context, int argc, sqlite3_value **argv) {
	const unsigned char *pIn;
	unsigned char *pOut;
	unsigned int nIn;
	unsigned long int nOut;
	int rc;
	pIn = sqlite3_value_blob(argv[0]);
	nIn = sqlite3_value_bytes(argv[0]);
	nOut = 0;
	unsigned int i;
	for(i=0; i<nIn && i<5; i++){
		nOut = (nOut<<7) | (pIn[i]&0x7f);
		if( (pIn[i]&0x80)!=0 ){ i++; break; }
	}
	pOut = sqlite3_malloc64( nOut+1 );
	rc = uncompress(pOut, &nOut, &pIn[i], nIn-i);
	if( rc==Z_OK ){
		sqlite3_result_blob64(context, pOut, nOut, sqlite3_free);
	}else{
		sqlite3_free(pOut);
	}
}

static void CreateAndTestWordDatabases() {
	NSString *enOgDb = @"/Users/michael/Desktop/CompressedDbs/en.lproj/index.dat";
	NSString *enShDb = @"/Users/michael/Desktop/CompressedDbs/en.lproj/index.sa";
	[MTSqliteWrapper shocoCompressDatabase: enOgDb to: enShDb];
	[MTSqliteWrapper testShocoCompressedDatabase: enShDb];
	
	NSString *esOgDb = @"/Users/michael/Desktop/CompressedDbs/es.lproj/index.dat";
	NSString *esShDb = @"/Users/michael/Desktop/CompressedDbs/es.lproj/index.sa";
	[MTSqliteWrapper testDatabase: esOgDb];
	[MTSqliteWrapper shocoCompressDatabase: esOgDb to: esShDb];
	[MTSqliteWrapper testShocoCompressedDatabase: esShDb];
	
	NSString *frOgDb = @"/Users/michael/Desktop/CompressedDbs/fr.lproj/index.dat";
	NSString *frShDb = @"/Users/michael/Desktop/CompressedDbs/fr.lproj/index.sa";
	[MTSqliteWrapper testDatabase: frOgDb];
	[MTSqliteWrapper shocoCompressDatabase: frOgDb to: frShDb];
	[MTSqliteWrapper testShocoCompressedDatabase: frShDb];
	
	NSString *itOgDb = @"/Users/michael/Desktop/CompressedDbs/it.lproj/index.dat";
	NSString *itShDb = @"/Users/michael/Desktop/CompressedDbs/it.lproj/index.sa";
	[MTSqliteWrapper testDatabase: itOgDb];
	[MTSqliteWrapper shocoCompressDatabase: itOgDb to: itShDb];
	[MTSqliteWrapper testShocoCompressedDatabase: itShDb];
	
	NSString *nlOgDb = @"/Users/michael/Desktop/CompressedDbs/nl.lproj/index.dat";
	NSString *nlShDb = @"/Users/michael/Desktop/CompressedDbs/nl.lproj/index.sa";
	[MTSqliteWrapper testDatabase: nlOgDb];
	[MTSqliteWrapper shocoCompressDatabase: nlOgDb to: nlShDb];
	[MTSqliteWrapper testShocoCompressedDatabase: nlShDb];
}

- (instancetype)initWithPath:(NSString *)path {
	if (self = [super init]) {
		_databaseIsWritable = false;	//Not used. Set to know so copy doesn't fail.
		_databasePath = [path copy];
	}
	return self;
}

- (instancetype)initWithBundleName:(NSString *)bundleName writable:(BOOL)writable {
	if (self = [super init]) {
		[self setDatabasePathWithBundleName:bundleName copyToWritableLocation:writable];
	}
	return self;
}

- (void)setDatabasePathWithBundleName:(NSString *)bundleName copyToWritableLocation:(BOOL)writable {
	if (writable) {
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSError *error;
		NSArray <NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
		NSString *filePath = [paths.firstObject stringByAppendingPathComponent:bundleName];
		BOOL success = [fileManager fileExistsAtPath:filePath];
		while (!success) {
			[fileManager removeItemAtPath:filePath error:nil];
			NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:bundleName];
			success = [fileManager copyItemAtPath: bundlePath toPath: filePath error:&error];
		}
		self.databasePath = filePath;
		_databaseIsWritable = true;
	} else {
		NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:bundleName];
		self.databasePath = bundlePath;
		_databaseIsWritable = false;
	}
}

- (void)openDatabase { [self openDatabase:YES]; }

- (void)openDatabase:(BOOL)readonly {
	int rc = sqlite3_open(_databasePath.UTF8String, &database);
	if (rc == SQLITE_OK) {
		rc = sqlite3_extended_result_codes(database, true);
		assert(rc == SQLITE_OK);
		if (readonly) {
			char* errorMessage;
			rc = sqlite3_exec(database, "PRAGMA journal_mode=OFF", NULL, NULL, &errorMessage);
			assert(rc == SQLITE_OK);
			rc = sqlite3_exec(database, "PRAGMA threads = 1", NULL, NULL, &errorMessage);
			assert(rc == SQLITE_OK);
		}
		//rc = sqlite3_create_function(database, "ZlibCompress", 1, SQLITE_UTF8, 0, &compressFunc, 0, 0);
		//if (rc == SQLITE_OK) {
		//    sqlite3_create_function(database, "ZlibUncompress", 1, SQLITE_UTF8, 0, uncompressFunc, 0, 0);
		//}
	} else {
		NSAssert1(0, @"%s", sqlite3_errmsg(database));
	}
}

- (void)closeDatabase {
	if (sqlite3_close(database) != SQLITE_OK) {
		NSAssert1(0, @"%s", sqlite3_errmsg(database));
	}
}

#pragma mark -
#pragma mark Functions to Create the Compressed Sqlite Database
#pragma mark These functions are for development.
#pragma mark These are not intended to be used in a software release.

+ (void)RunTestFunctions {
	CreateAndTestWordDatabases();
}

+ (void)testDatabase:(NSString *)path {
	sqlite3_stmt *statement;
	const char *query = "SELECT rowid, b FROM a";
	char *sql = sqlite3_mprintf(query);
	int i = 0;

	MTSqliteWrapper *db = [[MTSqliteWrapper alloc] initWithPath: path];
	[db openDatabase];

	if (sqlite3_prepare_v2(db->database, sql, -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			NSLog(@"%05d, %05d, %s", i, sqlite3_column_int(statement, 0), sqlite3_column_text(statement, 1));
			i++;
		}
	} else {
		NSLog(@"Caught %s", sqlite3_errmsg(db->database));
	}
	sqlite3_finalize(statement);
	sqlite3_free(sql);
	[db closeDatabase];
	db = nil;
}

+ (void)testShocoCompressedDatabase:(NSString *)path {
	sqlite3_stmt *statement;
	const char *query = "SELECT rowid, b FROM c";
	char *sql = sqlite3_mprintf(query);
	int i = 0;
	
	MTSqliteWrapper *db = [[MTSqliteWrapper alloc] initWithPath: path];
	[db openDatabase];
	
	if (sqlite3_prepare_v2(db->database, sql, -1, &statement, NULL) == SQLITE_OK) {
		
		char bufUncompressed[4096];
		while (sqlite3_step(statement) == SQLITE_ROW) {
			//NSString *s = [[NSString alloc] initWithCString:(const char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
			const void *compressed = sqlite3_column_blob(statement, 1);

			//NSLog(@"%05d, %05d, %s", i, sqlite3_column_int(statement, 0), sqlite3_column_blob(statement, 1));
			
			shoco_decompress((const char *)compressed, strlen((const char *)compressed), bufUncompressed, 4096);
			NSLog(@"Shoco test decompression: %05d, %05d, %s", i, sqlite3_column_int(statement, 0), bufUncompressed);

			//NSLog(@"Word: %@", [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)]);
			//[s release];
			i++;
		}
	} else {
		NSLog(@"Caught %s", sqlite3_errmsg(db->database));
	}
	sqlite3_finalize(statement);
	sqlite3_free(sql);
	[db closeDatabase];
	db = nil;
}

+ (void)testZlibCompressedDatabase:(NSString *)path {
	sqlite3_stmt *statement;
	const char *query = "SELECT rowid, ZlibUncompress(b) FROM c";
	char *sql = sqlite3_mprintf(query);
	int i = 0;
	
	MTSqliteWrapper *db = [[MTSqliteWrapper alloc] initWithPath: path];
	[db openDatabase];
	
	if (sqlite3_prepare_v2(db->database, sql, -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			//NSString *s = [[NSString alloc] initWithCString:(const char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
			NSLog(@"%05d, %05d, %s", i, sqlite3_column_int(statement, 0), sqlite3_column_text(statement, 1));
			//NSLog(@"Word: %@", [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)]);
			//[s release];
			i++;
		}
	} else {
		NSLog(@"Caught %s", sqlite3_errmsg(db->database));
	}
	sqlite3_finalize(statement);
	sqlite3_free(sql);
	[db closeDatabase];
	db = nil;
}

//Uncompress table format: CREATE TABLE a (b TEXT);
//Compressed table format: CREATE TABLE a (b BLOB);

+ (void)shocoCompressDatabase:(NSString *)existingPath to:(NSString *)resultPath {
	NSAssert(existingPath != nil, @"Origin can't be null.");
	NSAssert(resultPath != nil, @"Destination can't be null.");
	NSAssert(![existingPath isEqualToString:resultPath], @"Origin can't be the same as the destination.");
	
	sqlite3_stmt *stmtSelect;
	sqlite3_stmt *stmtInsert;
	const char *querySelectUncompressed = "SELECT rowid, b FROM a";
	const char *queryCreateCompressed = "CREATE TABLE c (b BLOB)";
	const char *queryDropTable = "DROP TABLE IF EXISTS c";
	const char *queryInsertInto = "INSERT INTO c (b) VALUES (?)";
	const char *queryVacuum = "VACUUM";
	
	MTSqliteWrapper *inputDatabase = [[MTSqliteWrapper alloc] initWithPath: existingPath];
	MTSqliteWrapper *outputDatabase = [[MTSqliteWrapper alloc] initWithPath: resultPath];

	[inputDatabase openDatabase];
	[outputDatabase openDatabase];

	char *zErr;
	int rz = SQLITE_OK;

	//Drop table in the output location
	rz = sqlite3_exec(outputDatabase->database, queryDropTable, NULL, NULL, &zErr);
	NSAssert2(rz == SQLITE_OK, @"Drop table error (%s, %s).", zErr, sqlite3_errmsg(outputDatabase->database));

	//Create table in the output location
	rz = sqlite3_exec(outputDatabase->database, queryCreateCompressed, NULL, NULL, &zErr);
	NSAssert2(rz == SQLITE_OK, @"Create table error: (%s, %s).", zErr, sqlite3_errmsg(outputDatabase->database));

	int i = 0;

	if (sqlite3_prepare_v2(inputDatabase->database, querySelectUncompressed, -1, &stmtSelect, NULL) == SQLITE_OK) {
		char bufCompressed[4096];
		size_t sizeCompressed = 0;
		while (sqlite3_step(stmtSelect) == SQLITE_ROW) {
			const unsigned char *input = sqlite3_column_text(stmtSelect, 1);
			const char *zTail;
			sizeCompressed = shoco_compress((const char *)input, strlen((const char *)input), bufCompressed, 4096);
			// I know it doesn't have to be prepaired and finalized on each step, but this function
			//  is only used for building the compressed databases.  This is not used as part of the
			//  application.
			rz = sqlite3_prepare_v3(outputDatabase->database, queryInsertInto, (int)strlen(queryInsertInto), 0, &stmtInsert, &zTail);
			NSAssert3(rz == SQLITE_OK, @"Prepair error '%s' for query '%s' at '%s.'", sqlite3_errmsg(outputDatabase->database), queryInsertInto, zTail);
			rz = sqlite3_bind_blob(stmtInsert, 1, bufCompressed, (int)sizeCompressed, SQLITE_TRANSIENT);
			NSAssert2(rz == SQLITE_OK, @"Binding error '%s' for blob '%s.'", sqlite3_errmsg(outputDatabase->database), bufCompressed);
			NSLog(@"Shoco compression database: %06d %s", i, input);
			sqlite3_step(stmtInsert);
			sqlite3_finalize(stmtInsert);
			i++;
		}
	} else {
		NSLog(@"Caught %s", sqlite3_errmsg(inputDatabase->database));
	}
	sqlite3_finalize(stmtSelect);

	rz = sqlite3_exec(outputDatabase->database, queryVacuum, NULL, NULL, &zErr);
	NSAssert2(rz == SQLITE_OK, @"Create table error: (%s, %s).", zErr, sqlite3_errmsg(outputDatabase->database));

	[outputDatabase closeDatabase];
	[inputDatabase closeDatabase];
	outputDatabase = nil;
	inputDatabase = nil;
}

+ (void)zlibCompressDatabase:(NSString *)existingPath to:(NSString *)resultPath {
	NSAssert(existingPath != nil, @"Origin can't be null.");
	NSAssert(resultPath != nil, @"Destination can't be null.");
	NSAssert(![existingPath isEqualToString:resultPath], @"Origin can't be the same as the destination.");

	sqlite3_stmt *stmtSelect;
	sqlite3_stmt *stmtInsert;
	const char *querySelectUncompressed = "SELECT rowid, b FROM a";
	const char *queryCreateCompressed = "CREATE TABLE c (b BLOB)";
	const char *queryDropTable = "DROP TABLE IF EXISTS c";
	const char *queryInsertInto = "INSERT INTO c (b) VALUES (ZlibCompress(?))";
	const char *queryVacuum = "VACUUM";

	MTSqliteWrapper *inputDatabase = [[MTSqliteWrapper alloc] initWithPath: existingPath];
	MTSqliteWrapper *outputDatabase = [[MTSqliteWrapper alloc] initWithPath: resultPath];

	[inputDatabase openDatabase];
	[outputDatabase openDatabase];

	char *zErr;
	int rz = SQLITE_OK;

	//Drop table in the output location
	rz = sqlite3_exec(outputDatabase->database, queryDropTable, NULL, NULL, &zErr);
	NSAssert2(rz == SQLITE_OK, @"Drop table error (%s, %s).", zErr, sqlite3_errmsg(outputDatabase->database));
	
	//Create table in the output location
	rz = sqlite3_exec(outputDatabase->database, queryCreateCompressed, NULL, NULL, &zErr);
	NSAssert2(rz == SQLITE_OK, @"Create table error: (%s, %s).", zErr, sqlite3_errmsg(outputDatabase->database));

	int i = 0;

	if (sqlite3_prepare_v2(inputDatabase->database, querySelectUncompressed, -1, &stmtSelect, NULL) == SQLITE_OK) {
		while (sqlite3_step(stmtSelect) == SQLITE_ROW) {
			//NSString *s = [[NSString alloc] initWithCString:(const char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
			//NSLog(@"%05d, %05d, %s", i, sqlite3_column_int(stmtSelect, 0), sqlite3_column_text(stmtSelect, 1));
			//NSLog(@"Word: %@", [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)]);
			//[s release];
			i++;

			const char *zTail;
			char *sqlInsert = sqlite3_mprintf(queryInsertInto);

			rz = sqlite3_prepare_v3(outputDatabase->database, sqlInsert, (int)strlen(queryInsertInto), 0, &stmtInsert, &zTail);
			NSAssert3(rz == SQLITE_OK, @"Prepair error '%s' for query '%s' at '%s.'", sqlite3_errmsg(outputDatabase->database), queryInsertInto, zTail);

			const unsigned char *selectedText = sqlite3_column_text(stmtSelect, 1);

			rz = sqlite3_bind_text(stmtInsert, 1, (const char *)selectedText, (int)strlen((const char *)selectedText), SQLITE_TRANSIENT);
			NSAssert2(rz == SQLITE_OK, @"Binding error '%s' for text '%s.'", sqlite3_errmsg(outputDatabase->database), selectedText);

			sqlite3_step(stmtInsert);

			sqlite3_finalize(stmtInsert);
			sqlite3_free(sqlInsert);

		}
	} else {
		NSLog(@"Caught %s", sqlite3_errmsg(inputDatabase->database));
	}
	sqlite3_finalize(stmtSelect);

	rz = sqlite3_exec(outputDatabase->database, queryVacuum, NULL, NULL, &zErr);
	NSAssert2(rz == SQLITE_OK, @"Create table error: (%s, %s).", zErr, sqlite3_errmsg(outputDatabase->database));

	[outputDatabase closeDatabase];
	[inputDatabase closeDatabase];
	outputDatabase = nil;
	inputDatabase = nil;
}

@end
