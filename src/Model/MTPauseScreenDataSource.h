//
//  MTPauseScreenDataSource.h
//  Wordflick-Pro
//
//  Created by Michael on 1/14/20.
//  Copyright © 2020 Michael Thomason. All rights reserved.
//

#ifndef MTPauseScreenDataSource_h
#define MTPauseScreenDataSource_h

#import <Foundation/Foundation.h>
#import "MTPauseScreenControllerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTPauseScreenDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>
	@property (nonatomic, assign) id <MTPauseScreenControllerProtocol> delegate;
@end

NS_ASSUME_NONNULL_END

#endif
