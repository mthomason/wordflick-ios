//
//  MTUrlUtility.m
//  wordflick
//
//  Created by Michael on 10/18/23.
//  Copyright © 2023 Michael Thomason. All rights reserved.
//

#import "MTURLUtility.h"
#import <Foundation/Foundation.h>

@implementation MTURLUtility

+ (void)openURLString:(NSString *_Nonnull)urlString
		   completion:(URLOpenCompletion _Nullable)completion {
	if (urlString == nil) {
		@throw [NSError errorWithDomain: @"com.wordflick.urlutility"
								   code: 3
							   userInfo: @{NSLocalizedDescriptionKey: @"Invalid or unsupported URL"}];
	}
	NSURL *url = [NSURL URLWithString:urlString];
	if (url && [[UIApplication sharedApplication] canOpenURL:url]) {
		[[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
			if (success) {
				if (completion) completion(nil);
			} else {
				if (completion) completion([NSError errorWithDomain: @"com.wordflick.urlutility"
															   code: 1
														   userInfo: @{NSLocalizedDescriptionKey: @"Failed to open URL"}]);
			}
		}];
	} else {
		if (completion) completion([NSError errorWithDomain: @"com.wordflick.urlutility"
													   code: 2
												   userInfo: @{NSLocalizedDescriptionKey: @"Invalid or unsupported URL"}]);
	}
}

@end
