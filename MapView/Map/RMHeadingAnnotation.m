//
//  RMHeadingAnnotation.m
//  MapView
//
//  Created by Ivan Pavlovic on 22/03/2013.
//
//

#import "RMHeadingAnnotation.h"

@implementation RMHeadingAnnotation

@synthesize heading = _heading;

- (BOOL)isUserLocationAnnotation {
    return YES;
}

@end
