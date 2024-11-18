//
//  UIArrayDataSource.h
//  Wordflick-Pro
//
//  Created by Michael on 11/18/19.
//  Copyright © 2019 Michael Thomason. All rights reserved.
//


#ifndef MTIntroductionDataSource_h
#define MTIntroductionDataSource_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^MTTableViewCellConfigureBlock)(id cell, id item);

@interface MTIntroductionDataSource : NSObject <UITableViewDataSource>

	- (instancetype)init:(void (^ __nullable)(__kindof UITableViewCell *cell, id item))aConfigureCellBlock;
	- (NSNumber *)itemAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END

#endif
