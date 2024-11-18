//
//  MTGameBoard.m
//  Wordflick-Pro
//
//  Created by Michael on 11/16/19.
//  Copyright © 2023 Michael Thomason. All rights reserved.
//

#import "MTGameBoard.h"
#import <Foundation/Foundation.h>

typedef NS_ENUM(int, MTDimension) {
	MTDimensionUnknown = 0,
	MTDimensionHorizontal = 1,
	MTDimensionVertical = 2
};

#pragma mark -

@interface MTGameBoard()

#pragma mark Properties

//@property (readwrite, nonatomic, assign) double tileLength;
@property (readwrite, nonatomic, assign) CGRect boardBounds;
@property (readwrite, nonatomic, copy) NSArray <NSValue *> *gamePieces;
@property (readwrite, nonatomic, assign) CGSize tileSize;

#pragma mark Functions Definations

static inline double SpacingLength(double, double, double);
static inline double GridItemInRectCenter(double, double, double, double);
static inline double GridItemInRectCenterConst(double, double, double, double, double);
static inline CGPoint centerPoint(UIUserInterfaceSizeClass, CGSize, CGSize, unsigned long, unsigned long, unsigned long);

static NSUInteger numberOfRows(const CGRect *);
static NSUInteger numberOfColumns(const CGRect *);

@end

#pragma mark -

@implementation MTGameBoard

#pragma mark Unused Static Functions

__attribute__((unused))
static inline
CGSize CGSizeMakeSquare(double l) { return CGSizeMake(l, l); }

__attribute__((unused))
static inline bool stagger(UIUserInterfaceSizeClass verticalSizeClass) {
	return verticalSizeClass == UIUserInterfaceSizeClassCompact;
}

#pragma mark Inline Static Functions

static inline
double SpacingLength(double tlen, double clen, double tctr) {
	return (clen - (tlen * tctr)) / (tctr + 1.0);
}

static inline
double GridItemInRectCenter(double ilen, double clen, double p, double t) {
	return SpacingLength(ilen,  clen,  t) + (p * (ilen +  SpacingLength(ilen,  clen,  t))) + (ilen  / 2.0);
}

static inline
double GridItemInRectCenterConst(double ilen, double alen, double clen, double p, double t) {
	return SpacingLength(ilen,  clen,  t) + (p * (ilen +  SpacingLength(ilen,  clen,  t))) + (alen  / 2.0);
}

static
NSUInteger numberOfRows(const CGRect *bounds) {
	return (bounds->size.width > bounds->size.height) ? 4 : 5;
}

static
NSUInteger numberOfColumns(const CGRect *bounds) {
	return (bounds->size.width > bounds->size.height) ? 5 : 4;
}

static inline
CGPoint CGPointCenterGridItemInRect(CGSize tile, CGSize container, NSInteger row, NSInteger rows, NSInteger col, NSInteger cols) {
	return CGPointMake(GridItemInRectCenter(tile.width, container.width, (double)col, (double)cols),
					   GridItemInRectCenter(tile.height, container.height, (double)row, (double)rows));
}

static inline
CGPoint CGPointCenterStaggerItemInRect(CGSize tile, CGSize container, NSInteger row, NSInteger rows, NSInteger col, NSInteger cols) {
	return CGPointMake(GridItemInRectCenter(tile.width,  container.width, (double)col, (double)cols) + (( (tile.width / 2.0) + (SpacingLength(tile.width,  container.width, (double)cols) / 2.0) ) / (((row % 2) == 0) ? 2.0 : -2.0)),
					   GridItemInRectCenterConst(MIN((tile.height), ((container.height / (double)rows) - 2.0)), tile.height, container.height, (double)row, (double)rows));
}

static inline int constrainedByDimension(const CGRect *bounds) {
	return (bounds->size.width > bounds->size.height) ? MTDimensionVertical : MTDimensionHorizontal;
}

static inline double constrainedLength(const CGRect *bounds) {
	return constrainedByDimension(bounds) == MTDimensionVertical ? bounds->size.height : bounds->size.width;
}

static inline unsigned long constrainedCount(const CGRect *bounds, NSUInteger numcols, NSUInteger numrows) {
	return constrainedByDimension(bounds) == MTDimensionVertical ? numrows : numcols;
}

static inline double tileSpacing(const CGRect *bounds, NSUInteger numcols, NSUInteger numrows,
								 UIUserInterfaceSizeClass verticalSizeClass) {
	return constrainedLength(bounds) * (verticalSizeClass == UIUserInterfaceSizeClassCompact ?
										((1.0 / (double)constrainedCount(bounds, numcols, numrows)) * 1.5) :
										(1.0 / (double)constrainedCount(bounds, numcols, numrows))) * (1.0 / 8.0);
}

static inline double tileLength(const CGRect *bounds, NSUInteger numcols, NSUInteger numrows,
								UIUserInterfaceSizeClass verticalSizeClass) {
	return (constrainedLength(bounds) * (verticalSizeClass == UIUserInterfaceSizeClassCompact ?
										 ((1.0 / (double)constrainedCount(bounds, numcols, numrows)) * 1.5) :
										 (1.0 / (double)constrainedCount(bounds, numcols, numrows)))) - tileSpacing(bounds, numcols, numrows, verticalSizeClass);
}

static inline CGSize tileSize(const CGRect *bounds, NSUInteger numberOfColumns, NSUInteger numberOfRows, UIUserInterfaceSizeClass verticalSizeClass) {
	double l = tileLength(bounds, numberOfColumns, numberOfRows, verticalSizeClass);
	return CGSizeMake(l, l);
}

__attribute__((deprecated))
static inline
CGPoint centerPointOld(UIUserInterfaceSizeClass vertSizeClass,
					CGSize tileSize,
					CGSize gameBoardSize,
					unsigned long columnNumber,
					unsigned long numberOfRows,
					unsigned long remainingColumns,
					unsigned long numberOfColumns) {
	return vertSizeClass == UIUserInterfaceSizeClassCompact ?
							CGPointCenterStaggerItemInRect(tileSize, gameBoardSize, columnNumber, (double)numberOfRows, remainingColumns, numberOfColumns) :
							CGPointCenterGridItemInRect(tileSize, gameBoardSize, columnNumber, (double)numberOfRows, remainingColumns, numberOfColumns);
}

static inline
CGPoint centerPoint(UIUserInterfaceSizeClass vertSizeClass,
					CGSize tileSize,
					CGSize gameBoardSize,
					unsigned long pos,
					unsigned long numberOfRows,
					unsigned long numberOfColumns) {
	return vertSizeClass == UIUserInterfaceSizeClassCompact ?
							CGPointCenterStaggerItemInRect(tileSize, gameBoardSize, pos / numberOfColumns, (double)numberOfRows, pos % numberOfColumns, numberOfColumns) :
							CGPointCenterGridItemInRect(tileSize, gameBoardSize, pos / numberOfColumns, (double)numberOfRows, pos % numberOfColumns, numberOfColumns);
}

#pragma mark -
#pragma mark Static Methdos

+ (CGPoint)centerLocationForBoard:(CGRect)bounds
						 tileSize:(CGSize)size
						 position:(NSUInteger)position
			   userInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom
				verticalSizeClass:(UIUserInterfaceSizeClass)verticalSizeClass
			  horizontalSizeClass:(UIUserInterfaceSizeClass)horizontalSizeClass {
	return centerPoint(verticalSizeClass,
						size,
						bounds.size,
						position,
						numberOfRows(&bounds),
						numberOfColumns(&bounds));
}

+ (CGRect)sizeOfTile:(CGRect)bounds verticalSizeClass:(UIUserInterfaceSizeClass)verticalSizeClass {
	double l = tileLength(&bounds, numberOfColumns(&bounds), numberOfRows(&bounds), verticalSizeClass);
	return CGRectMake(CGPointZero.x, CGPointZero.y, l, l);
}

+ (double)tileLength:(const CGRect *)bounds verticalSizeClass:(UIUserInterfaceSizeClass)verticalSizeClass {
	return tileLength(bounds, numberOfColumns(bounds), numberOfRows(bounds), verticalSizeClass);
}

#pragma mark -
#pragma mark Standard Overrides

- (void)dealloc {
	_gamePieces = nil;
}

- (instancetype)initWithBounds:(CGRect)bounds
			userInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom
			 verticalSizeClass:(UIUserInterfaceSizeClass)verticalSizeClass
		   horizontalSizeClass:(UIUserInterfaceSizeClass)horizontalSizeClass {
	
	if (self = [super init]) {
		
		const NSUInteger totalGamePieces = 20;
		
		NSUInteger nrows = numberOfRows(&bounds);
		NSUInteger ncols = numberOfColumns(&bounds);
		
		_tileSize = CGSizeZero;
		_tileSize.width = tileLength(&bounds, ncols, nrows, verticalSizeClass);
		_tileSize.height = _tileSize.width;

		NSMutableArray <NSValue *> *gamePieces = [[NSMutableArray alloc] initWithCapacity: totalGamePieces];
		for (NSUInteger idx = 0; idx < totalGamePieces; idx++) {
			[gamePieces addObject:
			 [NSValue valueWithCGPoint: centerPoint(verticalSizeClass, self.tileSize,
													bounds.size, idx, nrows, ncols)]
			 ];
		}
		self.gamePieces = gamePieces;
		gamePieces = nil;
	}
	return self;
}

- (CGPoint)gamePieceCenter:(NSUInteger)position {
	NSAssert(position < self.gamePieces.count, @"Index error.");
	return [_gamePieces objectAtIndex:position].CGPointValue;
}

#pragma mark -
#pragma mark Unused

+ (CGPoint)centerLocationForBoard:(CGRect)bounds
						 position:(NSUInteger)position
			   userInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom
				verticalSizeClass:(UIUserInterfaceSizeClass)verticalSizeClass
			  horizontalSizeClass:(UIUserInterfaceSizeClass)horizontalSizeClass __attribute__((deprecated)) __attribute__((unused)) {
	return centerPointOld(verticalSizeClass,
						  tileSize(&bounds, numberOfColumns(&bounds), numberOfRows(&bounds), verticalSizeClass),
						  bounds.size, position / numberOfColumns(&bounds),
						  (double)numberOfRows(&bounds), position % numberOfColumns(&bounds),
						  numberOfColumns(&bounds));
}

+ (void)positionGameTile:(UIView * __strong *)view
				inBounds:(CGRect)bounds
				position:(NSUInteger)position
	  userInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom
	   verticalSizeClass:(UIUserInterfaceSizeClass)verticalSizeClass
	 horizontalSizeClass:(UIUserInterfaceSizeClass)horizontalSizeClass __attribute__((deprecated)) __attribute__((unused)) {
	(*view).bounds = CGRectMake(CGPointZero.x, CGPointZero.y,
								tileLength(&bounds, numberOfColumns(&bounds), numberOfRows(&bounds), verticalSizeClass),
								tileLength(&bounds, numberOfColumns(&bounds), numberOfRows(&bounds), verticalSizeClass));
	(*view).center = centerPointOld(verticalSizeClass,
									tileSize(&bounds, numberOfColumns(&bounds), numberOfRows(&bounds), verticalSizeClass),
									bounds.size, position / numberOfColumns(&bounds),
									(double)numberOfRows(&bounds),
									position % numberOfColumns(&bounds),
									numberOfColumns(&bounds));
}

+ (CGSize)tileSizeInGoalForGoalHeight:(double)h __attribute__((unused)) {
	NSAssert(h > 0.0, @"We expect the height to be greater than zero.");
	return CGSizeMake(h * (2.0f / 3.0f), h * (2.0f / 3.0f));
}

@end
