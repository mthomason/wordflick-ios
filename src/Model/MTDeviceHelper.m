//
//  MTDeviceHelper.m
//  Wordflick-Pro
//
//  Created by Michael on 1/5/20.
//  Copyright © 2020 Michael Thomason. All rights reserved.
//

#import "MTDeviceHelper.h"

@interface MTDeviceHelper ()

@end

@implementation MTDeviceHelper

+ (BOOL)OSSupportsSafeAreaLayoutGuide {
	return [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."].firstObject.intValue >= 13 &&
			[[UIDevice currentDevice].systemName.lowercaseString isEqualToString:@"ios"];
}

@end
