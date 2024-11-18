//
//  MTSettingsDelegate.h
//  Wordflick-Pro
//
//  Created by Michael on 1/12/20.
//  Copyright © 2020 Michael Thomason. All rights reserved.
//

#ifndef MTSettingsDelegate_h
#define MTSettingsDelegate_h

#import <Foundation/Foundation.h>
#import "MTControllerCompletedProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface MTSettingsDelegate : NSObject <UITableViewDelegate>

    @property (nonatomic, assign) id <MTSettingsControllerCompletedProtocol> controllerDelegate;

@end

NS_ASSUME_NONNULL_END

#endif
