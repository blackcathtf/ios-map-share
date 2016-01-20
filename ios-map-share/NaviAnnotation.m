//
//  NaviAnnotation.m
//  ios-map-share
//
//  Created by nick on 16/1/20.
//  Copyright © 2016年 nick. All rights reserved.
//

#import "NaviAnnotation.h"


@implementation NaviAnnotation
-(id)initWithCoordinates:(CLLocationCoordinate2D)paramCoordinates title:(NSString *)paramTitle
                subTitle:(NSString *)paramSubitle
{
    self = [super init];
    if(self != nil)
    {
        _coordinate = paramCoordinates;
        _title = paramTitle;
        _subtitle = paramSubitle;
    }
    return self;
}

@end
