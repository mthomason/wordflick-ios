//
//  MTSettingsDataSource.h
//  Wordflick-Pro
//
//  Created by Michael on 1/12/20.
//  Copyright © 2020 Michael Thomason. All rights reserved.
//

#ifndef MTSettingsDataSource_h
#define MTSettingsDataSource_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTSettingsDataSource : NSObject <UITableViewDataSource>
    - (NSNumber *)itemAtIndexPath:(NSIndexPath *)indexPath;
@end

NS_ASSUME_NONNULL_END

#endif
