//
//  FNACustomAnnotation.m
//  twitterSample
//
//  Created by Funami Takao on 11/11/15.
//  Copyright (c) 2011年 Recruit. All rights reserved.
//

#import "FNACustomAnnotation.h"

@implementation FNACustomAnnotation
@synthesize coordinate = _coordinate;

- (id)initWithLocation:(CLLocationCoordinate2D)coord {
    self = [super init];
    if (self) {
        _coordinate = coord;
    }
    return self;
}



@end
