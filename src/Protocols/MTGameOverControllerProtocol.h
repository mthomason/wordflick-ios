//
//  MTGameOverControllerProtocol.h
//  wordPuzzle
//
//  Created by Michael on 1/5/20.
//  Copyright © 2020 Michael Thomason. All rights reserved.
//

#ifndef MTGameOverControllerProtocol_h
#define MTGameOverControllerProtocol_h

@protocol MUIViewControllerGameOverDelegate <NSObject>
	- (void)viewControllerGameOverIsDone:(id)sender;
@end

#endif /* MTGameOverControllerProtocol_h */
