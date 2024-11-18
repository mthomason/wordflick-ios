//
//  MTFileController.h
//  Wordflick-Pro
//
//  Created by Michael on 12/23/19.
//  Copyright © 2019 Michael Thomason. All rights reserved.
//

#ifndef MTFileController_h
#define MTFileController_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTFileController : NSObject
	+ (NSURL * _Nullable)applicationSupportURLForFileName:(nonnull NSString *)filename;
	+ (NSURL * _Nullable)storedGameKitAchievementsForUser:(nonnull NSString *)playerID;
	+ (NSString * _Nullable)restartPlistDocumentDirectoryPath;
	+ (NSString * _Nullable)restartPlistApplicationBundlePath;
@end

NS_ASSUME_NONNULL_END

#endif
