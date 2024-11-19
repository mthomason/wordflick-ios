//
//  CGGeometry-Extras.m
//  wordPuzzle
//
//  Created by Michael Thomason on 7/13/10.
//  Copyright 2010 Michael Thomason. All rights reserved.
//

#import "CGGeometry+Extras.h"

/*
 These functions were used for the animation geometry.
 They are now defined in WFGameViewController.
 */

__attribute__((unused)) static inline uint32_t IntervalForLevelKey(NSInteger);

__attribute__((unused)) static inline NSTimeInterval TimeIntervalForLevel(NSInteger);
__attribute__((unused)) static inline CGPoint CGCenterOfRect(CGRect);
__attribute__((unused)) static inline CGPoint CGPointRoundPointToGrid(CGPoint);
__attribute__((unused)) static inline CGPoint CGSlide(double, CGPoint, CGPoint);
__attribute__((unused)) static inline CGPoint CGYPlusDistance(CGPoint, CGPoint, long);
__attribute__((unused)) static inline CGPoint CGYInversePlusDistance(CGPoint, CGPoint, double);
__attribute__((unused)) static inline double CGDistance(CGPoint, CGPoint);
__attribute__((unused)) static inline CGFloat CGRateOfChange(CGPoint, CGPoint, NSTimeInterval, NSTimeInterval);

__attribute__((unused)) static inline double CGInterceptBySlopeUnused(CGPoint, double);
__attribute__((unused)) static inline double CGSlopeUnused(CGPoint, CGPoint);

__attribute__((unused)) static inline CGPoint CGCornerTopLeftPointInRect(CGRect frame);
__attribute__((unused)) static inline CGPoint CGCornerTopRightPointInRect(CGRect frame);
__attribute__((unused)) static inline CGPoint CGCornerBottomLeftPointInRect(CGRect frame);
__attribute__((unused)) static inline CGPoint CGCornerBottomRightPointInRect(CGRect frame);
__attribute__((unused)) static inline CGPoint CGEdgeTopPointInRect(CGRect frame);
__attribute__((unused)) static inline CGPoint CGEdgeRightPointInRect(CGRect frame);
__attribute__((unused)) static inline CGPoint CGEdgeBottomPointInRect(CGRect frame);
__attribute__((unused)) static inline CGPoint CGEdgeLeftPointInRect(CGRect frame);
__attribute__((unused)) static inline CGFloat CGFloatPointsForInches(CGFloat inches);
__attribute__((unused)) static inline CGFloat CGFloatInchesForPoints(CGFloat points);
__attribute__((unused)) static inline CGFloat CGFloatInchesForCentmeters(CGFloat centemeters);
__attribute__((unused)) static inline CGFloat CGFloatCentemetersForInches(CGFloat inches);

__attribute__((unused))
static inline uint32_t IntervalForLevelKey(NSInteger level) {
	return ceil( ((50.0) / ((double)level * 0.5)) );
}

__attribute__((unused))
static inline NSTimeInterval TimeIntervalForLevel(NSInteger level) {
	return (8.0 + (0.001 * ((double)arc4random_uniform(1000))) + ((double)arc4random_uniform( IntervalForLevelKey(level) )));
}

__attribute__((unused))
static inline CGPoint CGCenterOfRect(CGRect r) {
	return CGPointMake(r.origin.x + (r.size.width / 2.0), r.origin.y + (r.size.height / 2.0));
}

__attribute__((unused))
static inline CGPoint CGPointRoundPointToGrid(CGPoint point) {
	return CGPointMake(round(point.x / 10.0) * 10.0, round(point.y / 10.0) * 10.0);
}

__attribute__((unused))
static inline CGPoint CGSlide(double rateOfChange, CGPoint p1, CGPoint p2) {
	if (rateOfChange <= 0.0) {
		rateOfChange = 1.0;
	}
	CGPoint c = CGYInversePlusDistance(p1, p2, rateOfChange);
	if (!isnan(c.x) && !isnan(c.y)) {
		c.y = (-1.0) * (c.y);
	}
	return c;
}

__attribute__((unused))
static inline CGPoint CGYPlusDistance(CGPoint p1, CGPoint p2, long d) {
	CGPoint returnVal;
	long double m = CGSlopeUnused(p1, p2);
	long double b = CGInterceptBySlopeUnused(p2, m);
	BOOL movingUp;
	if (p1.y < p2.y) movingUp = YES;
	else movingUp = NO;
	
	long double x = p2.x;
	long double y = p2.y;
	
	if (d >= 0) {
		long double mPow2 = pow(m, 2.0);
		long double bPow2 = pow(b, 2.0);
		long double dPow2 = pow(d, 2.0);
		long double u = p2.x;
		long double v = p2.y;
		long double sqrtPart = 0.0;
		sqrtPart = (mPow2)*( ((-1.0)*(bPow2)) + ((dPow2)*(1+mPow2)) - (pow((((-1.0)*(m)*(u)) + v), 2.0)) + (b*(((-1.0)*(2.0)*(m)*(u))+((2.0)*(v)))) );
		if (!isnan(sqrtPart)) {
			if (movingUp) y = ((b)+((m)*(u))+((mPow2)*(v))+sqrt(sqrtPart)) / (1.0+mPow2);
			else y = ((b)+((m)*(u))+((mPow2)*(v))-sqrt(sqrtPart)) / (1.0+mPow2);
			
			x=(y-b)/m;
		}
		if (!isnan(x) && !isnan(y)) {
			returnVal.x = x;
			returnVal.y = y;
		} else {
			returnVal.x = p2.x;
			returnVal.y = p2.y;
		}
		return returnVal;
	} else {
		return CGPointZero;
	}
}

__attribute__((unused))
static inline CGPoint CGYInversePlusDistance(CGPoint p1, CGPoint p2, double d) {
	CGPoint returnVal;
	long double m = -1.0 * CGSlopeUnused(p1, p2);
	long double b = CGInterceptBySlopeUnused(p2, m);
	BOOL movingUp;
	if (p1.y < p2.y) movingUp = YES;
	else movingUp = NO;
	
	long double x = p2.x;
	long double y = p2.y;
	
	if (d >= 0) {
		long double mPow2 = pow(m, 2.0);
		long double bPow2 = pow(b, 2.0);
		long double dPow2 = pow(d, 2.0);
		long double u = p2.x;
		long double v = p2.y;
		long double sqrtPart = 0.0;
		sqrtPart = (mPow2)*( ((-1.0)*(bPow2)) + ((dPow2)*(1.0+mPow2)) - (pow((((-1.0)*(m)*(u)) + v),2.0)) + (b*(((-1.0)*(2.0)*(m)*(u))+((2.0)*(v)))) );
		if (!isnan(sqrtPart)) {
			if (movingUp) y = ((b)+((m)*(u))+((mPow2)*(v))+sqrt(sqrtPart)) / (1.0+mPow2);
			else y = ((b)+((m)*(u))+((mPow2)*(v))-sqrt(sqrtPart)) / (1.0+mPow2);
			
			x = (y - b) / m;
		}
		if (!isnan(x) && !isnan(y)) {
			returnVal.x = x;
			returnVal.y = y;
		} else {
			returnVal.x = p2.x;
			returnVal.y = p2.y;
		}
		return returnVal;
	} else {
		return CGPointZero;
	}
}

__attribute__((unused))
static inline double CGDistance(CGPoint p1, CGPoint p2) {
	return sqrt( ( pow(((p2.x)-(p1.x)), 2.0) + pow(((p2.y)-(p1.y)), 2.0) ) );
}

__attribute__((unused))
static inline CGFloat CGRateOfChange(CGPoint p1, CGPoint p2, NSTimeInterval t1, NSTimeInterval t2) {
	if (t2 - t1 != 0) return (CGDistance(p1, p2) / ((t2 - t1) * 3));
	else return 0.0;
}

__attribute__((unused))
static inline double CGInterceptBySlopeUnused(CGPoint p2, double m) {
	return ( p2.y - (m * p2.x) );
}

__attribute__((unused))
static inline double CGSlopeUnused(CGPoint p1, CGPoint p2) {
	return ( ( p2.y - p1.y ) / ( p2.x - p1.x ) );
}

__attribute__((unused))
static inline CGPoint CGCornerTopLeftPointInRect(CGRect frame) {
	return CGPointMake(frame.origin.x, frame.origin.y);
}

__attribute__((unused))
static inline CGPoint CGCornerTopRightPointInRect(CGRect frame) {
	return CGPointMake(frame.origin.x + frame.size.width, frame.origin.y);
}

__attribute__((unused))
static inline CGPoint CGCornerBottomLeftPointInRect(CGRect frame) {
	return CGPointMake(frame.origin.x, frame.origin.y + frame.size.height);
}

__attribute__((unused))
static inline CGPoint CGCornerBottomRightPointInRect(CGRect frame) {
	return CGPointMake(frame.origin.x + frame.size.width, frame.origin.y + frame.size.height);
}

__attribute__((unused))
static inline CGPoint CGEdgeTopPointInRect(CGRect frame) {
	return CGPointMake(frame.origin.x + (frame.size.width / 2.0), frame.origin.y);
}

__attribute__((unused))
static inline CGPoint CGEdgeRightPointInRect(CGRect frame) {
	return CGPointMake(frame.origin.x + frame.size.width, frame.origin.y + (frame.size.height / 2.0));
}

__attribute__((unused))
static inline CGPoint CGEdgeBottomPointInRect(CGRect frame) {
	return CGPointMake(frame.origin.x + (frame.size.width / 2.0), frame.origin.y + frame.size.height);
}

__attribute__((unused))
static inline CGPoint CGEdgeLeftPointInRect(CGRect frame) {
	return CGPointMake(frame.origin.x, frame.origin.y + (frame.size.height / 2.0));
}

__attribute__((unused))
static inline CGFloat CGFloatPointsForInches(CGFloat inches) { return inches * 72.0; }

__attribute__((unused))
static inline CGFloat CGFloatInchesForPoints(CGFloat points) { return points / 72.0; }

__attribute__((unused))
static inline CGFloat CGFloatInchesForCentmeters(CGFloat centemeters) { return centemeters / 2.5400f; }

__attribute__((unused))
static inline CGFloat CGFloatCentemetersForInches(CGFloat inches) { return inches * 2.54; }
