//
//  MTControllerCompletedProtocol.h
//  wordPuzzle
//
//  Created by Michael on 1/5/20.
//  Copyright © 2020 Michael Thomason. All rights reserved.
//

#ifndef MTControllerCompletedProtocol_h
#define MTControllerCompletedProtocol_h

@protocol MTControllerCompletedProtocol <NSObject>
    - (void)viewControllerDidFinish:(id)sender;
@end

@protocol MTSettingsControllerCompletedProtocol <NSObject>
    - (void)settingsControllerDidFinish:(id)sender;
@end

#endif /* MTControllerCompletedProtocol_h */
