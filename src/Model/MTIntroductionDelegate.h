//
//  MTIntroductionDelegate.h
//  Wordflick-Pro
//
//  Created by Michael on 1/4/20.
//  Copyright © 2020 Michael Thomason. All rights reserved.
//

#ifndef MTIntroductionDelegate_h
#define MTIntroductionDelegate_h

#import <Foundation/Foundation.h>
#import "MTGameActionProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTIntroductionDelegate : NSObject <UITableViewDelegate>

    - (instancetype)initGameActionDelegate:(id<MTGameActionProtocol>)gameActionDelegate;

@end

NS_ASSUME_NONNULL_END

#endif
