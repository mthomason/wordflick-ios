//
//  MTGameBoard.h
//  Wordflick-Pro
//
//  Created by Michael on 11/16/19.
//  Copyright © 2023 Michael Thomason. All rights reserved.
//

#ifndef MTGameBoard_h
#define MTGameBoard_h

@interface MTGameBoard : NSObject
@property (readonly, nonatomic, assign) CGSize tileSize;
@property (readonly, nonatomic, copy) NSArray <NSValue *> *gamePieces;

- (instancetype)initWithBounds:(CGRect)bounds
			userInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom
			 verticalSizeClass:(UIUserInterfaceSizeClass)verticalSizeClass
		   horizontalSizeClass:(UIUserInterfaceSizeClass)horizontalSizeClass;

- (CGPoint)gamePieceCenter:(NSUInteger)position;

+ (CGRect)sizeOfTile:(CGRect)bounds
   verticalSizeClass:(UIUserInterfaceSizeClass)verticalSizeClass;

+ (double)tileLength:(const CGRect *)bounds
   verticalSizeClass:(UIUserInterfaceSizeClass)verticalSizeClass;

+ (CGPoint)centerLocationForBoard:(CGRect)bounds
						 tileSize:(CGSize)size
						 position:(NSUInteger)position
			   userInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom
				verticalSizeClass:(UIUserInterfaceSizeClass)verticalSizeClass
			  horizontalSizeClass:(UIUserInterfaceSizeClass)horizontalSizeClass;

@end

#endif /* MTGameBoard_h */
