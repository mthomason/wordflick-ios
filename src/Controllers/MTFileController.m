//
//  MTFileController.m
//  Wordflick-Pro
//
//  Created by Michael on 12/23/19.
//  Copyright © 2023 Michael Thomason. All rights reserved.
//

#import "MTFileController.h"
#import <Foundation/Foundation.h>

#if ! __has_feature(objc_arc)
#warning The file requires ARC.  Compile with the -fobjc-arc flag.
#endif

@implementation MTFileController

- (void)dealloc {
	NSAssert(false, @"Static function.  Do not allocate.");
}

- (instancetype)init {
	NSAssert(false, @"Static function.  Do not allocate.");
	if (self = [super init]) { }
	return self;
}

+ (NSURL * _Nullable)applicationSupportURLForFileName:(nonnull NSString *)filename {
	return [MTFileController urlForFile:filename directory:NSApplicationSupportDirectory];
}

+ (NSURL * _Nullable)urlForFile:(NSString *)filename directory:(NSSearchPathDirectory)directory {
	NSURL *applicationSupportDirectory = nil;
	
	NSURL *resultURL = nil;

	NSArray <NSURL *> *urls = [[NSFileManager defaultManager] URLsForDirectory: directory
																	 inDomains: NSUserDomainMask];
	for (NSURL *url in urls) {
		applicationSupportDirectory = [url URLByAppendingPathComponent: [NSBundle mainBundle].bundleIdentifier
														   isDirectory: YES];
		if (applicationSupportDirectory != nil) {
			BOOL directoryExist = [[NSFileManager defaultManager] createDirectoryAtURL: applicationSupportDirectory
														   withIntermediateDirectories: YES
																			attributes: nil
																				 error: nil];
			if (directoryExist) {
				resultURL =  [applicationSupportDirectory URLByAppendingPathComponent: filename
																		  isDirectory: NO];
				break;
			} else {
				applicationSupportDirectory = nil;
			}
		}
	}

	if (resultURL != nil) return resultURL;
	else return nil;
}

+ (NSURL * _Nullable)storedGameKitAchievementsForUser:(nonnull NSString *)playerID {
	NSString *userAch = [NSString stringWithFormat: @"%@.storedAchievements.plist", playerID];
	return [MTFileController applicationSupportURLForFileName: userAch];
}

+ (NSString * _Nullable)restartPlistDocumentDirectoryPath {
	return [MTFileController urlForFile:@"restart.plist" directory:NSApplicationSupportDirectory].path;
}

+ (NSString * _Nullable)restartPlistApplicationBundlePath {
	return [[NSBundle mainBundle] URLForResource:@"restart" withExtension:@"plist"].path;
}

@end
