//
//  main.m
//  wordPuzzle
//
//  Created by Michael Thomason on 7/8/09.
//  Copyright Michael Thomason 2023. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "wordPuzzleAppDelegate.h"

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSString *delegateClassName = NSStringFromClass([wordPuzzleAppDelegate class]);
		return UIApplicationMain(argc, argv, nil, delegateClassName);
	}
}
