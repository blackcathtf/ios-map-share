//
//  PageThirdMap.m
//  ios-map-share
//
//  Created by nick on 16/1/18.
//  Copyright © 2016年 nick. All rights reserved.
//

#import "PageThirdMap.h"
#import <UIKit/UIKit.h>


@implementation PageThirdMap
/**
 *
 *
 *  @return NSArray 已经安装的地图app的数组
 */
+(NSArray *)checkHasOwnApp{
    NSMutableArray *appListArr = [[NSMutableArray alloc] initWithObjects:@"苹果原生地图",@"google地图",@"高德地图",@"百度地图",@"腾讯地图",@"显示路线", nil];
    return appListArr;
}
@end
