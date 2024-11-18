//
//  MTTileType.h
//  wordPuzzle
//
//  Created by Michael on 12/18/19.
//  Copyright © 2019 Michael Thomason. All rights reserved.
//

#ifndef MTTileType_h
#define MTTileType_h

typedef NS_ENUM(NSUInteger, MNSTileType) {
	MNSTileExtraNormal = 0,		// Gray Tile
	MNSTileExtraPoints = 1,		// Green Squared Circle Tile
	MNSTileExtraTime = 2,		// Purple Pentagon Tile
	MNSTileExtraShuffle = 3,	// Red Diamond Shape Tile
	MNSTileExtraSpecial = 4,	// Blue Eop Tile
};

#endif /* MTTileType_h */
