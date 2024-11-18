//
//  MUIViewGameTile.m
//  wordPuzzle
//
//  Created by Michael Thomason on 5/29/09.
//  Copyright 2019 Michael Thomason. All rights reserved.
//

#import "WFTileView.h"
#import <CoreText/CoreText.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreGraphics/CGPath.h>
#import "MNSAudio.h"
#import "MNSGame.h"
#import "MNSUser.h"
#import "MTWordValue.h"
#import "WFTileData.h"
#import "Constants.h"
#import "UIColor+Wordflick.h"

#define degreesToRadians(x) (M_PI * (x) / 180.0)
#define kAnimationRotateDeg 1.0
#define kAnimationTranslateX 2.0
#define kAnimationTranslateY 2.0

static inline double MTSquareRootOfWidthDividedInHalf(double);
static inline CGPoint MTCenterRect(CGRect);
static inline CGRect CircleInset(CGRect);
static inline double textLocationYoffset(CGRect);
static inline CGFloat pentagonPointX(double, double, double, double);
static inline CGFloat pentagonPointY(double, double, double, double);
static inline CGFloat fontSizeForHeight(CGFloat);
__attribute__((unused)) static inline CGPoint pentagonPoint(double, double, double, CGPoint);

static inline double MTSquareRootOfWidthDividedInHalf(double length) {
	return ((sqrt(M_PI) * (length / 2.0)) / 2.0);
}

static inline CGPoint MTCenterRect(CGRect rect) {
	return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

static inline CGRect CircleInset(CGRect rect) {
	return CGRectInset(rect, rect.size.width / (20.0f / 3.0f), rect.size.height / (20.0f / 3.0f));
}

static inline double textLocationYoffset(CGRect rect) { return rect.size.height * 0.17; } // Only tries to fill top.

static inline CGFloat pentagonPointX(double position, double radius, double angle, double centerX) {
	return radius * sinf((position * 4.0 * M_PI + angle) / 5.0) + centerX;
}

static inline CGFloat pentagonPointY(double position, double radius, double angle, double centerY) {
	return radius * cosf((position * 4.0 * M_PI + angle) / 5.0) + centerY;
}

static inline CGFloat fontSizeForHeight(CGFloat h) { return h * (2.0 / 3.0); }

__attribute__((unused)) static inline CGPoint pentagonPoint(double p, double r, double a, CGPoint c) {
	return CGPointMake(pentagonPointX(p, r, a, c.x), pentagonPointY(p, r, a, c.y));
}

@interface WFTileView() {
	CGRect _drawTextTextDrawingRect;
	CGRect _drawTileRectBorder;
	CGRect _auxRect;
	CGPoint _auxPoint0; CGPoint _auxPoint1; CGPoint _auxPoint2;
	CGPoint _drawTextLinearGradientStartPoint;
	CGPoint _drawTextLinearGradientEndPoint;
	CGPoint _drawCircleWhiteGradientEndPoint;
	CGSize _drawTextShadowOffset;
	CGSize _drawTileCornerRadius;
	NSRange _drawingTextRange;
}

@property (readwrite, assign) BOOL touched;
@property (readwrite, nonatomic, retain) NSMutableAttributedString *drawingText;

- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;

@end

@implementation WFTileView

#pragma mark - Static

static NSString * _fontIdentifierAmericanTypewriterCondensedBold;
static NSString * _fontIdentifierFuturaCondensedExtraBold;
static NSString * _fontIdentifierHelveticaNeueCondensedBlack;

static CGGradientRef _backgroundGradient[5];

static CGGradientRef _backgroundGradientTileBlack;
static CGGradientRef _backgroundGradientTileWhite;

static void setupDrawingText(WFTileView *object) {
	NSShadow *shadowForText = [[NSShadow alloc] init];
	shadowForText.shadowColor = [UIColor whiteColor];
	shadowForText.shadowBlurRadius = 1.0f;
	shadowForText.shadowOffset = CGSizeMake(-1.0f, -1.0f);
	
	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.alignment = NSTextAlignmentCenter;
	NSDictionary *attributes = @{
		NSParagraphStyleAttributeName: paragraphStyle,
		NSShadowAttributeName: shadowForText,
	};
	object->_drawingText = [[NSMutableAttributedString alloc] initWithString: @""
																  attributes: attributes];
}

static void drawCircle(WFTileView *tileView, UIBezierPath *circle, CGContextRef mainContext) {
	CGContextSaveGState(mainContext);
	CGContextRef dempleContext = UIGraphicsGetCurrentContext();
	[[UIColor darkGrayColor] setFill];
	CGContextAddPath(dempleContext, circle.CGPath);
	CGContextDrawPath(dempleContext, kCGPathFill);
	[circle addClip];
	
	tileView->_drawCircleWhiteGradientEndPoint.x = circle.bounds.origin.x;
	tileView->_drawCircleWhiteGradientEndPoint.y = circle.bounds.origin.y + circle.bounds.size.height;
	CGContextDrawLinearGradient(dempleContext,
								_backgroundGradientTileWhite,
								circle.bounds.origin,
								tileView->_drawCircleWhiteGradientEndPoint,
								kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
	CGContextRestoreGState(mainContext);
	CGContextSaveGState(mainContext);
	CGContextRef dropShadowContext = UIGraphicsGetCurrentContext();
	CGContextAddPath(dropShadowContext, circle.CGPath);
	if (!CGContextIsPathEmpty(dropShadowContext)) {
		CGContextClip(dropShadowContext);
	}
	CGContextAddPath(dropShadowContext, circle.CGPath);
	
	CGContextSetShadowWithColor(dropShadowContext, tileView->_drawTextShadowOffset, 3.0, [UIColor grayColor].CGColor);
	CGContextSetStrokeColorWithColor(dropShadowContext, [UIColor grayColor].CGColor);
	CGContextStrokePath(dropShadowContext);
	CGContextRestoreGState(mainContext);
}

static void setTileViewRectBorder(WFTileView *tileView, const CGRect *rect) {
	tileView->_drawTileRectBorder.origin.x = rect->origin.x + (tileView->_drawTextShadowOffset.width * 2.0);
	tileView->_drawTileRectBorder.origin.y = rect->origin.y + (tileView->_drawTextShadowOffset.height * 2.0);
	tileView->_drawTileRectBorder.size.width = rect->size.width - (tileView->_drawTextShadowOffset.width * 4.0);
	tileView->_drawTileRectBorder.size.height = rect->size.height - (tileView->_drawTextShadowOffset.height * 4.0);
}

static void initDrawingStructs(WFTileView *tileView) {
	tileView->_drawTextTextDrawingRect = CGRectZero;
	tileView->_drawTileRectBorder = CGRectZero;
	tileView->_auxRect = CGRectZero;
	tileView->_drawTileCornerRadius = CGSizeZero;
	tileView->_drawTextShadowOffset = CGSizeZero;
	tileView->_auxPoint0 = CGPointZero;
	tileView->_auxPoint1 = CGPointZero;
	tileView->_auxPoint2 = CGPointZero;
	tileView->_drawTextLinearGradientStartPoint = CGPointZero;
	tileView->_drawTextLinearGradientEndPoint = CGPointZero;
	tileView->_drawCircleWhiteGradientEndPoint = CGPointZero;
	tileView->_drawingTextRange = NSMakeRange(0, 0);
}

#pragma mark -
#pragma mark Init and Dealloc
 
- (void)dealloc {
	_delegate = nil;
	_dataSource = nil;
	_drawingText = nil;
}

+ (void)initialize {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		_fontIdentifierAmericanTypewriterCondensedBold = @"AmericanTypewriter-CondensedBold";
		_fontIdentifierFuturaCondensedExtraBold = @"Futura-CondensedExtraBold";
		_fontIdentifierHelveticaNeueCondensedBlack = @"HelveticaNeue-CondensedBlack";
		
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

		CGFloat colorsGray[20] = {
			181.0 / 255.0, 195.0 / 255.0, 203.0 / 255.0, 1.0,
			216.0 / 255.0, 225.0 / 255.0, 231.0 / 255.0, 1.0,
			181.0 / 255.0, 198.0 / 255.0, 208.0 / 255.0, 1.0,
			194.0 / 255.0, 212.0 / 255.0, 224.0 / 255.0, 1.0,
			214.0 / 255.0, 234.0 / 255.0, 247.0 / 255.0, 1.0
		};
		CGFloat colorStopsGray[5] = {0.0, 0.5, 0.5, 0.75, 1.0};
		_backgroundGradient[MNSTileExtraNormal] = CGGradientCreateWithColorComponents(colorSpace, colorsGray, colorStopsGray, 5);

		CGFloat colorsGreen[20] = {
			185.0 / 255.0, 206.0 / 255.0, 68.0 / 255.0, 1.0,
			168.0 / 255.0, 199.0 / 255.0, 50.0 / 255.0, 1.0,
			142.0 / 255.0, 185.0 / 255.0, 42.0 / 255.0, 1.0,
			114.0 / 255.0, 170.0 / 255.0, 0.0, 1.0,
			148.0 / 255.0, 197.0 / 255.0, 22.0 / 255.0, 1.0
		};
		CGFloat colorStopsGreen[5] = {0.0, 0.08, 0.5, 0.5, 0.96};
		_backgroundGradient[MNSTileExtraPoints] = CGGradientCreateWithColorComponents(colorSpace, colorsGreen, colorStopsGreen, 5);

		CGFloat colorsPurple[16] = {
			141.0 / 255.0, 67.0 / 255.0, 207.0 / 255.0, 1.0,
			195.0 / 255.0, 154.0 / 255.0, 232.0 / 255.0, 1.0,
			149.0 / 255.0, 76.0 / 255.0, 214.0 / 255.0, 1.0,
			171.0 / 255.0, 56.0 / 255.0, 211.0 / 255.0, 1.0
		};
		CGFloat colorStopsPurple[4] = {0.0, 0.5, 0.5, 1.0};
		_backgroundGradient[MNSTileExtraTime] = CGGradientCreateWithColorComponents(colorSpace, colorsPurple, colorStopsPurple, 4);

		CGFloat colorsRed[20] = {
			1.0, 88.0 / 255.0, 55.0 / 255.0, 1.0,
			247.0 / 255.0, 42.0 / 255.0, 12.0 / 255.0, 1.0,
			241.0 / 255.0, 111.0 / 255.0, 92.0 / 255.0, 1.0,
			215.0 / 255.0, 41.0 / 255.0, 23.0 / 255.0, 1.0,
			236.0 / 255.0, 60.0 / 255.0, 44.0 / 255.0, 1.0
		};
		CGFloat colorStopsRed[5] = {0.0, 0.26, 0.5, 0.5, 1.0};
		_backgroundGradient[MNSTileExtraShuffle] = CGGradientCreateWithColorComponents(colorSpace, colorsRed, colorStopsRed, 5);

		CGFloat colorsBlue[16] = {
			112.0 / 255.0, 182.0 / 255.0, 242.0 / 255.0, 1.0,
			84.0 / 255.0, 163.0 / 255.0, 238.0 / 255.0, 1.0,
			54.0 / 255.0, 112.0 / 144.0, 240.0 / 255.0, 1.0,
			26.0 / 255.0, 98.0 / 255.0, 219.0 / 255.0, 1.0
		};
		CGFloat colorStopsBlue[4] = {0.0, 0.5, 0.5, 1.0};
		_backgroundGradient[MNSTileExtraSpecial] = CGGradientCreateWithColorComponents(colorSpace, colorsBlue, colorStopsBlue, 4);

		CGFloat colorsBlack[16] = {
			175.0 / 255.0, 189.0 / 255.0, 192.0 / 255.0, 1.0,
			109.0 / 255.0, 118.0 / 255.0, 115.0 / 255.0, 1.0,
			10.0 / 255.0, 15.0 / 255.0, 11.0 / 255.0, 1.0,
			10.0 / 255.0, 8.0 / 255.0, 9.0 / 255.0, 1.0
		};
		CGFloat colorStopsBlack[4] = {0.0, 0.42, 0.43, 1.0};
		_backgroundGradientTileBlack = CGGradientCreateWithColorComponents(colorSpace, colorsBlack, colorStopsBlack, 4);

		CGFloat colorsWhite[20] = {
			225.0 / 255.0, 225.0 / 255.0, 225.0 / 255.0, 1.0,
			253.0 / 255.0, 253.0 / 255.0, 253.0 / 255.0, 1.0,
			237.0 / 255.0, 237.0 / 255.0, 237.0 / 255.0, 1.0,
			222.0 / 255.0, 222.0 / 255.0, 222.0 / 255.0, 1.0
		};
		CGFloat colorStopsWhite[5] = {0.0, 0.4, 0.6, 0.98, 1.0};
		_backgroundGradientTileWhite = CGGradientCreateWithColorComponents(colorSpace, colorsWhite, colorStopsWhite, 5);
		
		CGColorSpaceRelease(colorSpace);
	});
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		initDrawingStructs(self);
		setupDrawingText(self);
		self.touched = NO;
		self.removed = NO;
		self.backgroundColor = [UIColor clearColor];
		self.tileID = @(self.tag);
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	NSAssert(NO, @"Do not call this initalizer in code.");
	if (self = [super initWithFrame:frame]) {
		initDrawingStructs(self);
		self.removed = NO;
		self.tag = 35;
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame identifier:(NSInteger)identifier {
	if (self = [super initWithFrame:frame]) {
		initDrawingStructs(self);
		setupDrawingText(self);
		self.touched = NO;
		self.removed = NO;
		self.opaque = YES;
		self.backgroundColor = [UIColor clearColor];
		self.contentMode = UIViewContentModeCenter;

		self.tag = identifier;
		self.tileID = @(identifier);
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame tile:(WFTileData *)tile {
	if (self = [super initWithFrame:frame]) {
		initDrawingStructs(self);
		setupDrawingText(self);
		self.touched = NO;
		self.removed = NO;
		self.opaque = YES;
		self.backgroundColor = [UIColor clearColor];
		self.contentMode = UIViewContentModeCenter;
		self.tag = tile.tileID.integerValue;
		self.tileID = tile.tileID;
		tile.inPlay = YES;
	}
	return self;
}

- (NSNumber *)tileID {
	return _removed ? @(_tileID.integerValue + 200) : _tileID;
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(CGRect)rect {

	if (_removed || _dataSource == nil || _delegate == nil) return;

	__strong id <WFTileViewDataSource> dataSource = self.dataSource;
	
	//NSLog(@"Drawing tile with ID: (%@)", self.tileID);
	NSString *charToDisplay = [dataSource characterValueForTileView: self];
	if (charToDisplay == nil) return;
	
	//NSAssert([dataSource characterValueForTileView: self] != nil, @"Need a character to draw.");
	//if ([dataSource characterValueForTileView: self] == nil) {
	//	NSAssert([dataSource characterValueForTileView: self] == nil, @"Need a character to draw.");
	//}
	
	if ([dataSource hasInitalRotationForTileView: self]) {
		self.transform = CGAffineTransformMakeRotation([dataSource initalRotationAngleForTileView: self]);
	}
	
	_drawTextShadowOffset.width = rect.size.width / 80.0;
	_drawTextShadowOffset.height = rect.size.height / 80.0;

	setTileViewRectBorder(self, &rect);
	switch ([dataSource typeTypeForTileView: self]) {

		case MNSTileExtraPoints:
			[self drawSquaredCircleSymbolAtRect: _drawTileRectBorder withCharacter: charToDisplay];
			break;

		case MNSTileExtraTime:
			[self drawPentagonTile: rect withCharacter: charToDisplay];
			break;

		case MNSTileExtraShuffle:
			[self drawDiamondSymbolAtRect: _drawTileRectBorder withCharacter: charToDisplay];
			break;

		case MNSTileExtraSpecial:
			[self drawEopTile: _drawTileRectBorder withCharacter: charToDisplay];
			break;

		case MNSTileExtraNormal:
		default:
			[self drawNormalTileInRect: _drawTileRectBorder withCharacter: charToDisplay];
			break;
	}
}

- (void)drawText:(NSString *)text
		inCircle:(UIBezierPath *)circle
	   inContext:(CGContextRef)mainContext
	  inTextRect:(CGRect)textRect
	 textYoffset:(CGFloat)textLocationYoffset
 gradientYoffset:(CGFloat)gradientYoffset
		withFont:(UIFont *)font {

	CGContextSaveGState(mainContext);
	CGContextRef textContext = UIGraphicsGetCurrentContext();
	CGContextAddPath(textContext, circle.CGPath);

	if (!CGContextIsPathEmpty(textContext)) {
		CGContextClip(textContext);
	}

	CGContextSetTextDrawingMode(textContext, kCGTextClip);

	_drawingTextRange.length = _drawingText.length;
	[_drawingText replaceCharactersInRange: _drawingTextRange
								withString: text];

	_drawingTextRange.length = text.length;
	[_drawingText addAttribute: NSFontAttributeName
						 value: font
						 range: _drawingTextRange];

	CGRect glyphBounds = [_drawingText boundingRectWithSize: textRect.size
													options: NSStringDrawingUsesLineFragmentOrigin |
																NSStringDrawingTruncatesLastVisibleLine
													context: nil];

	glyphBounds.size.width = ceil(glyphBounds.size.width);
	glyphBounds.size.height = ceil(glyphBounds.size.height);
	_drawTextTextDrawingRect.origin.x = ((textRect.size.width - glyphBounds.size.width) / 2.0) + textRect.origin.x;
	_drawTextTextDrawingRect.origin.y = ((textRect.size.height - glyphBounds.size.height) / 2.0) + (-1.0 * textRect.origin.y) + (textLocationYoffset / 2.0);
	_drawTextTextDrawingRect.size = glyphBounds.size;
	[_drawingText drawInRect: _drawTextTextDrawingRect];

	_drawTextLinearGradientStartPoint.x = textRect.origin.x + ((textRect.size.width - glyphBounds.size.width) / 2.0);
	_drawTextLinearGradientStartPoint.y = (textRect.origin.y + (((textRect.size.height - glyphBounds.size.height) / 2.0) + textLocationYoffset)) - (gradientYoffset * textRect.size.height);
	_drawTextLinearGradientEndPoint.x = textRect.origin.x + ((textRect.size.width - glyphBounds.size.width) / 2.0);
	_drawTextLinearGradientEndPoint.y = (textRect.origin.y + (((textRect.size.height - glyphBounds.size.height) / 2.0) + textLocationYoffset)) + glyphBounds.size.height;
	CGContextDrawLinearGradient(mainContext, _backgroundGradientTileBlack,
								_drawTextLinearGradientStartPoint, _drawTextLinearGradientEndPoint,
								kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
	CGContextRestoreGState(mainContext);
}

// MNSTileExtraNormal
- (void)drawNormalTileInRect:(CGRect)rect withCharacter:(NSString *)character {
	BOOL stylizedFont = [MNSUser CurrentUser].desiresStylizedFonts;

	//Get Main Context
	CGContextRef mainContext = UIGraphicsGetCurrentContext();
	
	//Draw Path
	_drawTileCornerRadius.width = _drawTileCornerRadius.height = rect.size.height / (14.0 / 3.0);
	UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect: _drawTileRectBorder
											   byRoundingCorners: UIRectCornerAllCorners
													 cornerRadii: _drawTileCornerRadius];

	//Add Shadow
	CGContextSetShadowWithColor(mainContext, _drawTextShadowOffset, 1.0, [UIColor grayColor].CGColor);
	CGContextBeginTransparencyLayer(mainContext, NULL);
	
	//Draw Tile
	CGContextSaveGState(mainContext);
	CGContextRef tileContext = UIGraphicsGetCurrentContext();

	//Set Dark Gray Fill
	[[UIColor darkGrayColor] setFill];

	//Add Path, Stroke, Restore Main Context, and then Clip
	CGContextAddPath(tileContext, path.CGPath);
	CGContextDrawPath(tileContext, kCGPathFill);
	CGContextRestoreGState(mainContext);
	[path addClip];

	
	CGContextSaveGState(mainContext);
	CGContextRef grayGradientContext = UIGraphicsGetCurrentContext();

	_auxPoint0.x = rect.origin.x; _auxPoint0.y = rect.origin.y + rect.size.height;
	CGContextDrawLinearGradient(grayGradientContext, _backgroundGradient[MNSTileExtraNormal],
								rect.origin, _auxPoint0,
								kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
	CGContextRestoreGState(mainContext);
	
	UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:
							stylizedFont ?
								CGRectInset(_drawTileRectBorder, (_drawTileRectBorder.size.width / 9.0), (_drawTileRectBorder.size.height / 9.0)) :
								CGRectInset(_drawTileRectBorder, (_drawTileRectBorder.size.width / (20.0 / 3.0)), (_drawTileRectBorder.size.height / (20.0 / 3.0)))];
	drawCircle(self, circle, mainContext);
	
	[self drawText: character
		  inCircle: circle
		 inContext: mainContext
		inTextRect: _drawTileRectBorder
	   textYoffset: stylizedFont ? rect.size.height * 0.17 : rect.size.height * 0.15
   gradientYoffset: 0.19
		  withFont: stylizedFont ? [UIFont fontWithName: _fontIdentifierAmericanTypewriterCondensedBold
												   size: fontSizeForHeight(rect.size.height)] :
								   [UIFont boldSystemFontOfSize: fontSizeForHeight(rect.size.height)]
	 ];

	CGContextEndTransparencyLayer(mainContext);
}

// MNSTileExtraPoints
- (void)drawSquaredCircleSymbolAtRect:(CGRect)rect withCharacter:(NSString *)character {

	//Get Main Context
	CGContextRef mainContext = UIGraphicsGetCurrentContext();

	//Draw Path
	UIBezierPath *path = [UIBezierPath bezierPath];
	_auxPoint0.x = CGRectGetMidX(rect); _auxPoint0.y = CGRectGetMidY(rect);		// Center point

	const CGFloat squareRootOfWidthDividedInHalf = MTSquareRootOfWidthDividedInHalf(rect.size.width);

	[path moveToPoint:			_auxPoint0];
	[path addArcWithCenter:		_auxPoint0
					radius:		(rect.size.width / 2.0)
				startAngle:		0.0
				  endAngle:		(2.0 * M_PI)
				 clockwise:		YES];
	[path moveToPoint:			_auxPoint0];

	_auxPoint1.x = _auxPoint0.x - squareRootOfWidthDividedInHalf;
	_auxPoint1.y = _auxPoint0.y - squareRootOfWidthDividedInHalf;
	[path moveToPoint:          _auxPoint1];

	_auxPoint1.x = _auxPoint0.x + squareRootOfWidthDividedInHalf;
	//_auxPoint1.y = _auxPoint0.y - squareRootOfWidthDividedInHalf;
	[path addLineToPoint:       _auxPoint1];

	//_auxPoint1.x = _auxPoint0.x + squareRootOfWidthDividedInHalf;
	_auxPoint1.y = _auxPoint0.y + squareRootOfWidthDividedInHalf;
	[path addLineToPoint:       _auxPoint1];

	_auxPoint1.x = _auxPoint0.x - squareRootOfWidthDividedInHalf;
	//_auxPoint1.y = _auxPoint0.y + squareRootOfWidthDividedInHalf;
	[path addLineToPoint:       _auxPoint1];

	//_auxPoint1.x = _auxPoint0.x - squareRootOfWidthDividedInHalf;
	_auxPoint1.y = _auxPoint0.y - squareRootOfWidthDividedInHalf;
	[path addLineToPoint:       _auxPoint1];
	[path closePath];
	
	//Add Shadow
	CGContextSetShadowWithColor(mainContext, _drawTextShadowOffset, 1.0, [UIColor grayColor].CGColor);
	CGContextBeginTransparencyLayer(mainContext, NULL);
	
	//Draw Tile
	CGContextSaveGState(mainContext);
	CGContextRef tileContext = UIGraphicsGetCurrentContext();
	
	//Set Dark Gray Fill
	[[UIColor darkGrayColor] setFill];
	
	//Add Path, Stroke, Restore Main Context, and then Clip
	CGContextAddPath(tileContext, path.CGPath);
	CGContextDrawPath(tileContext, kCGPathFill);
	CGContextRestoreGState(mainContext);
	[path addClip];
	
	CGContextSaveGState(mainContext);
	CGContextRef grayGradientContext = UIGraphicsGetCurrentContext();
	
	_auxPoint0.x = rect.origin.x; _auxPoint0.y = rect.origin.y + rect.size.height;
	CGContextDrawLinearGradient(grayGradientContext, _backgroundGradient[MNSTileExtraPoints],
								rect.origin, _auxPoint0,
								kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
	CGContextRestoreGState(mainContext);
	
	UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:
							CGRectInset(_drawTileRectBorder,
										_drawTileRectBorder.size.width / 13.0,
										_drawTileRectBorder.size.height / (26.0 / 3.0))];
	drawCircle(self, circle, mainContext);

	[self drawText: character
		  inCircle: circle
		 inContext: mainContext
		inTextRect: _drawTileRectBorder
	   textYoffset: rect.size.height * 0.17
   gradientYoffset: 0.21
		  withFont: [UIFont fontWithName: _fontIdentifierFuturaCondensedExtraBold
									size: fontSizeForHeight(rect.size.height)]];

	CGContextEndTransparencyLayer(mainContext);
}

// MNSTileExtraTime
- (void)drawPentagonTile:(CGRect)rect withCharacter:(NSString *)character {
	
	CGContextRef mainContext = UIGraphicsGetCurrentContext();

	static const CGFloat angle = 0.0;
	CGFloat radius = ceil(ceil(rect.size.height) / 2.0);

	//_auxPoint0 is the center point.
	_auxPoint0.x = rect.origin.x + (rect.size.width / 2.0);
	_auxPoint0.y = rect.origin.y + (rect.size.height / 2.0);

	UIBezierPath *path = [UIBezierPath bezierPath];
	
	_auxPoint1.x = sinf(angle * M_PI / 5.0) + _auxPoint0.x;
	_auxPoint1.y = radius * cosf(angle * M_PI / 5.0) + _auxPoint0.y;
	[path moveToPoint: _auxPoint1];
	
	_auxPoint1.x = pentagonPointX(3.0, radius, angle, _auxPoint0.x);
	_auxPoint1.y = pentagonPointY(3.0, radius, angle, _auxPoint0.y);
	[path addLineToPoint: _auxPoint1];

	_auxPoint1.x = pentagonPointX(1.0, radius, angle, _auxPoint0.x);
	_auxPoint1.y = pentagonPointY(1.0, radius, angle, _auxPoint0.y);
	[path addLineToPoint: _auxPoint1];

	_auxPoint1.x = pentagonPointX(4.0, radius, angle, _auxPoint0.x);
	_auxPoint1.y = pentagonPointY(4.0, radius, angle, _auxPoint0.y);
	[path addLineToPoint: _auxPoint1];

	_auxPoint1.x = pentagonPointX(2.0, radius, angle, _auxPoint0.x);
	_auxPoint1.y = pentagonPointY(2.0, radius, angle, _auxPoint0.y);
	[path addLineToPoint: _auxPoint1];

	_auxPoint1.x = sinf(angle * M_PI / 5.0) + _auxPoint0.x;
	_auxPoint1.y = radius * cosf(angle * M_PI / 5.0) + _auxPoint0.y;
	[path addLineToPoint: _auxPoint1];
	[path closePath];

	CGContextSetShadowWithColor(mainContext, _drawTextShadowOffset, 1.0, [UIColor grayColor].CGColor);
	CGContextBeginTransparencyLayer(mainContext, NULL);

	CGContextSaveGState(mainContext);
	CGContextRef tileContext = UIGraphicsGetCurrentContext();

	[[UIColor darkGrayColor] setFill];

	CGContextAddPath(tileContext, path.CGPath);
	CGContextDrawPath(tileContext, kCGPathFill);
	CGContextRestoreGState(mainContext);

	[path addClip];

	CGContextSaveGState(mainContext);
	CGContextRef grayGradientContext = UIGraphicsGetCurrentContext();

	_auxPoint0.x = self.bounds.origin.x;
	_auxPoint0.y = self.bounds.origin.y + self.bounds.size.height;
	CGContextDrawLinearGradient(grayGradientContext, _backgroundGradient[MNSTileExtraTime],
								self.bounds.origin, _auxPoint0,
								kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
	CGContextRestoreGState(mainContext);

	UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:
							CGRectInset(_drawTileRectBorder,
										_drawTileRectBorder.size.width / 4.4,
										_drawTileRectBorder.size.height / 8.0)];
	drawCircle(self, circle, mainContext);

	[self drawText: character
		  inCircle: circle
		 inContext: mainContext
		inTextRect: _drawTileRectBorder
	   textYoffset: rect.size.height * 0.17
   gradientYoffset: 0.21
		  withFont: [UIFont fontWithName: _fontIdentifierHelveticaNeueCondensedBlack
									size: fontSizeForHeight(_drawTileRectBorder.size.height)]];
	
	CGContextEndTransparencyLayer(mainContext);
}

// MNSTileExtraShuffle
- (void)drawDiamondSymbolAtRect:(CGRect)rect withCharacter:(NSString *)character {

	UIBezierPath *path = [UIBezierPath bezierPath];
	
	_auxPoint0.x = CGRectGetMidX(_drawTileRectBorder);
	_auxPoint0.y = CGRectGetMinY(_drawTileRectBorder);
	[path moveToPoint:		_auxPoint0];
	
	_auxPoint0.x = CGRectGetMaxX(_drawTileRectBorder);
	_auxPoint0.y = CGRectGetMidY(_drawTileRectBorder);
	
	_auxPoint1.x = _drawTileRectBorder.origin.x + ((_drawTileRectBorder.size.width * 3.0) / 6.0);
	_auxPoint1.y = _drawTileRectBorder.origin.y - ((_drawTileRectBorder.size.height * 1.0) / 12.0);

	_auxPoint2.x = _drawTileRectBorder.origin.x + ((_drawTileRectBorder.size.width * 13.0) / 12.0);
	_auxPoint2.y = _drawTileRectBorder.origin.y + ((_drawTileRectBorder.size.height * 3.0) / 6.0);

	[path addCurveToPoint: _auxPoint0 controlPoint1: _auxPoint1 controlPoint2: _auxPoint2];
	
	_auxPoint0.x = CGRectGetMidX(_drawTileRectBorder);
	_auxPoint0.y = CGRectGetMaxY(_drawTileRectBorder);
	
	_auxPoint1.x = _auxPoint2.x;
	_auxPoint1.y = _auxPoint2.y;

	_auxPoint2.x = _drawTileRectBorder.origin.x + ((_drawTileRectBorder.size.width * 3.0) / 6.0);
	_auxPoint2.y = _drawTileRectBorder.origin.y + ((_drawTileRectBorder.size.height * 13.0) / 12.0);

	[path addCurveToPoint: _auxPoint0 controlPoint1: _auxPoint1 controlPoint2: _auxPoint2];
	
	_auxPoint0.x = CGRectGetMinX(_drawTileRectBorder);
	_auxPoint0.y = CGRectGetMidY(_drawTileRectBorder);

	_auxPoint1.x = _auxPoint2.x;
	_auxPoint1.y = _auxPoint2.y;

	_auxPoint2.x = _drawTileRectBorder.origin.x - ((_drawTileRectBorder.size.width * 1.0) / 12.0);
	_auxPoint2.y = _drawTileRectBorder.origin.y + ((_drawTileRectBorder.size.height * 3.0) / 6.0);

	[path addCurveToPoint: _auxPoint0 controlPoint1: _auxPoint1 controlPoint2: _auxPoint2];
	
	_auxPoint0.x = CGRectGetMidX(_drawTileRectBorder);
	_auxPoint0.y = CGRectGetMinY(_drawTileRectBorder);

	_auxPoint1.x = _auxPoint2.x;
	_auxPoint1.y = _auxPoint2.y;

	_auxPoint2.x = _drawTileRectBorder.origin.x + ((_drawTileRectBorder.size.width * 3.0) / 6.0);
	_auxPoint2.y = _drawTileRectBorder.origin.y - ((_drawTileRectBorder.size.height * 1.0) / 12.0);

	[path addCurveToPoint: _auxPoint0 controlPoint1: _auxPoint1 controlPoint2: _auxPoint2];
	
	[path closePath];

	_auxPoint0 = self.bounds.origin;
	_auxPoint1.x = self.bounds.origin.x;
	_auxPoint1.y = self.bounds.origin.y + self.bounds.size.height;
	
	CGContextRef mainContext = UIGraphicsGetCurrentContext();
	CGContextSetShadowWithColor(mainContext, _drawTextShadowOffset, 1.0, [UIColor grayColor].CGColor);
	CGContextBeginTransparencyLayer(mainContext, NULL);
	CGContextSaveGState(mainContext);
	CGContextRef tileContext = UIGraphicsGetCurrentContext();
	CGContextAddPath(tileContext, path.CGPath);
	CGContextDrawPath(tileContext, kCGPathFill);
	CGContextRestoreGState(mainContext);
	
	[path addClip];
	
	CGContextSaveGState(mainContext);
	
	CGContextRef grayGradientContext = UIGraphicsGetCurrentContext();

	CGContextDrawLinearGradient(grayGradientContext, _backgroundGradient[MNSTileExtraShuffle],
								_auxPoint0, _auxPoint1, 0);
	CGContextRestoreGState(grayGradientContext);

	UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:CircleInset(_drawTileRectBorder)];
	drawCircle(self, circle, mainContext);

	[self drawText: character
		  inCircle: circle
		 inContext: mainContext
		inTextRect: _drawTileRectBorder
	   textYoffset: textLocationYoffset(_drawTileRectBorder)
   gradientYoffset: 0.21
		  withFont: [UIFont fontWithName: _fontIdentifierHelveticaNeueCondensedBlack
									size: fontSizeForHeight(rect.size.height)]];
	CGContextEndTransparencyLayer(mainContext);
}

// MNSTileExtraSpecial
- (void)drawEopTile:(CGRect)rect withCharacter:(NSString *)character {
	CGContextRef mainContext = UIGraphicsGetCurrentContext();
	
	UIBezierPath *path = [UIBezierPath bezierPath];
	path.lineJoinStyle = kCGLineJoinRound;
	path.lineCapStyle = kCGLineCapRound;
	
	//EOP1 CGPointMake(rect.origin.x + (rect.size.width / 3.0f), rect.origin.y);
	_auxPoint0.x = _drawTileRectBorder.origin.x + (_drawTileRectBorder.size.width / 3.0f);
	_auxPoint0.y = _drawTileRectBorder.origin.y;
	[path moveToPoint:      _auxPoint0];
	
	//EOP2
	_auxPoint1.x = _drawTileRectBorder.origin.x + ((2.0f * _drawTileRectBorder.size.width) / 3.0f);
	_auxPoint1.y = _drawTileRectBorder.origin.y;
	[path addLineToPoint:   _auxPoint1];

	//EOP3
	_auxPoint1.x = _drawTileRectBorder.origin.x + _drawTileRectBorder.size.width;
	_auxPoint1.y = _drawTileRectBorder.origin.y + _drawTileRectBorder.size.height;
	[path addLineToPoint:   _auxPoint1];

	//EOP4
	_auxPoint1.x = _drawTileRectBorder.origin.x;
	_auxPoint1.y = _drawTileRectBorder.origin.y + _drawTileRectBorder.size.height;
	[path addLineToPoint:   _auxPoint1];

	//EOP1 CGPointMake(rect.origin.x + (rect.size.width / 3.0f), rect.origin.y);
	[path addLineToPoint:   _auxPoint0];
	[path closePath];
	
	CGContextSetShadowWithColor(mainContext, _drawTextShadowOffset, 1.0, [UIColor grayColor].CGColor);
	CGContextBeginTransparencyLayer(mainContext, NULL);
	
	//Draw Tile
	CGContextSaveGState(mainContext);
	CGContextRef tileContext = UIGraphicsGetCurrentContext();

	[[UIColor darkGrayColor] setFill];

	CGContextAddPath(tileContext, path.CGPath);
	CGContextDrawPath(tileContext, kCGPathFill);

	CGContextRestoreGState(mainContext);
	
	[path addClip];
	
	CGContextSaveGState(mainContext);
	CGContextRef grayGradientContext = UIGraphicsGetCurrentContext();

	_auxPoint0.x = self.bounds.origin.x;
	_auxPoint0.y = self.bounds.origin.y + self.bounds.size.height;
	CGContextDrawLinearGradient(grayGradientContext,
								_backgroundGradient[MNSTileExtraSpecial],
								self.bounds.origin,
								_auxPoint0,
								kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
	CGContextRestoreGState(mainContext);
	
	UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(_drawTileRectBorder,
																			  _drawTileRectBorder.size.width / 4.4,
																			  _drawTileRectBorder.size.height / 8.0)];
	drawCircle(self, circle, mainContext);

	[self drawText: character
		  inCircle: circle
		 inContext: mainContext
		inTextRect: _drawTileRectBorder
	   textYoffset: rect.size.height * 0.17
   gradientYoffset: 0.21000000
		  withFont: [UIFont fontWithName: _fontIdentifierFuturaCondensedExtraBold
									size: fontSizeForHeight(rect.size.height)]];
	
	CGContextEndTransparencyLayer(mainContext);
}

+ (UIBezierPath *)bezierPathForDiamond2WithRect:(CGRect)rect __attribute__((unused)) {
	UIBezierPath *path = [UIBezierPath bezierPath];
	
	[path moveToPoint:      CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect))];
	
	[path addCurveToPoint:  CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect))
			controlPoint1:  CGPointMake(rect.origin.x + ((rect.size.width * 3.0) / 6.0), rect.origin.y - ((rect.size.height * 1.0) / 12.0))
			controlPoint2:  CGPointMake(rect.origin.x + ((rect.size.width * 13.0) / 12.0), rect.origin.y + ((rect.size.height * 3.0) / 6.0))];
	
	[path addCurveToPoint:  CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect))
			controlPoint1:  CGPointMake(rect.origin.x + ((rect.size.width * 13.0) / 12.0), rect.origin.y + ((rect.size.height * 3.0) / 6.0))
			controlPoint2:  CGPointMake(rect.origin.x + ((rect.size.width * 3.0) / 6.0), rect.origin.y + ((rect.size.height * 13.0) / 12.0))];
	
	[path addCurveToPoint:  CGPointMake(CGRectGetMinX(rect), CGRectGetMidY(rect))
			controlPoint1:  CGPointMake(rect.origin.x + ((rect.size.width * 3.0) / 6.0), rect.origin.y + ((rect.size.height * 13.0) / 12.0))
			controlPoint2:  CGPointMake(rect.origin.x - ((rect.size.width * 1.0) / 12.0), rect.origin.y + ((rect.size.height * 3.0) / 6.0))];
	
	[path addCurveToPoint:  CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect))
			controlPoint1:  CGPointMake(rect.origin.x - ((rect.size.width * 1.0) / 12.0), rect.origin.y + ((rect.size.height * 3.0) / 6.0))
			controlPoint2:  CGPointMake(rect.origin.x + ((rect.size.width * 3.0) / 6.0), rect.origin.y - ((rect.size.height * 1.0) / 12.0))];
	
	[path closePath];
	return path;
}

+ (UIBezierPath *)bezierPathForSquaredCircleWithRect:(CGRect)rect __attribute__((unused)) {
	UIBezierPath *path = [UIBezierPath bezierPath];
	CGPoint center = MTCenterRect(rect);
	CGPoint calcPoint = CGPointZero;
	const CGFloat squareRootOfWidthDividedInHalf = MTSquareRootOfWidthDividedInHalf(rect.size.width);

	[path moveToPoint:			center];
	[path addArcWithCenter:		center
					radius:		(rect.size.width / 2.0)
				startAngle:		0.0
				  endAngle:		(2.0 * M_PI)
				 clockwise:		YES];
	[path moveToPoint:			center];

	calcPoint.x = center.x - squareRootOfWidthDividedInHalf;
	calcPoint.y = center.y - squareRootOfWidthDividedInHalf;
	[path moveToPoint:          calcPoint];

	calcPoint.x = center.x + squareRootOfWidthDividedInHalf;
	calcPoint.y = center.y - squareRootOfWidthDividedInHalf;
	[path addLineToPoint:       calcPoint];

	calcPoint.x = center.x + squareRootOfWidthDividedInHalf;
	calcPoint.y = center.y + squareRootOfWidthDividedInHalf;
	[path addLineToPoint:       calcPoint];

	calcPoint.x = center.x - squareRootOfWidthDividedInHalf;
	calcPoint.y = center.y + squareRootOfWidthDividedInHalf;
	[path addLineToPoint:       calcPoint];

	calcPoint.x = center.x - squareRootOfWidthDividedInHalf;
	calcPoint.y = center.y - squareRootOfWidthDividedInHalf;
	[path addLineToPoint:       calcPoint];
	[path closePath];
	return path;
}

+ (UIBezierPath *)bezierPathForPentagonWithRect:(CGRect)rect
										 center:(CGPoint)center
										 radius:(CGFloat)radius
									   andAngle:(CGFloat)angle __attribute__((unused)) {
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:      CGPointMake(sinf(angle * M_PI / 5.0) + center.x,
										radius * cosf(angle * M_PI / 5.0) + center.y)];
	[path addLineToPoint:   pentagonPoint(3.0, radius, angle, center)];
	[path addLineToPoint:   pentagonPoint(1.0, radius, angle, center)];
	[path addLineToPoint:   pentagonPoint(4.0, radius, angle, center)];
	[path addLineToPoint:   pentagonPoint(2.0, radius, angle, center)];
	[path addLineToPoint:   CGPointMake(sinf(angle * M_PI / 5.0) + center.x,
										radius * cosf(angle * M_PI / 5.0) + center.y)];
	[path closePath];
	return path;
}

#pragma mark -
#pragma mark Gesture Recognizer Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
	   shouldReceiveTouch:(UITouch *)touch {
	return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
	shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
	return YES;
}

#pragma mark -
#pragma mark Pan Gesture event

- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		gestureRecognizer.view.layer.anchorPoint = CGPointMake([gestureRecognizer locationInView:gestureRecognizer.view].x / gestureRecognizer.view.bounds.size.width,
															   [gestureRecognizer locationInView:gestureRecognizer.view].y / gestureRecognizer.view.bounds.size.height);
		gestureRecognizer.view.center = [gestureRecognizer locationInView:gestureRecognizer.view.superview];
	}
}

- (void)startWobble:(NSInteger)count {
	//const double r = 0.5;
	self.transform = CGAffineTransformMakeRotation( degreesToRadians( (kAnimationRotateDeg * -1.0 ) - /*r*/ 0.5 ));  // starting point
	self.layer.anchorPoint = CGPointMake(0.5, 0.5);
	[UIView animateWithDuration: 0.35 delay: 0.0
						options: UIViewAnimationOptionAllowUserInteraction |
								 UIViewAnimationOptionRepeat |
								 UIViewAnimationOptionAutoreverse animations: ^{
		[UIView setAnimationRepeatCount:NSNotFound];
		self.transform = CGAffineTransformMakeRotation( degreesToRadians( kAnimationRotateDeg + /*r*/ 0.5 ));
	} completion: nil];
}

- (void)stopWobble {
	[self.layer removeAllAnimations];
	self.transform = CGAffineTransformIdentity;
}

- (void)animationDidStart:(NSString *)animationID context:(void *)context {
	[MNSAudio playFlipTileFlip];
}

#pragma mark -
#pragma mark Touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	[self.delegate tileViewTouchBegan: self];
	self.touched = YES;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesCancelled:touches withEvent:event];
	self.touched = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	self.touched = NO;
}

@end
