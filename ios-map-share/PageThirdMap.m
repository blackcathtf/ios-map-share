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
 *  根据手机里的地图app的安装数进行判断
 *
 *  @return NSArray 已经安装的地图app的数组
 */
+(NSArray *)checkHasOwnApp{
    NSArray *mapSchemeArr = @[@"comgooglemaps://",@"iosamap://navi",@"baidumap://map/",@"qqmap://"];
    
    NSMutableArray *appListArr = [[NSMutableArray alloc] initWithObjects:@"苹果原生地图", nil];
    
    for (int i = 0; i < [mapSchemeArr count]; i++) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[mapSchemeArr objectAtIndex:i]]]]) {
            if (i == 0) {
                [appListArr addObject:@"google地图"];
            }else if (i == 1){
                [appListArr addObject:@"高德地图"];
            }else if (i == 2){
                [appListArr addObject:@"百度地图"];
            }else if (i == 3){
                [appListArr addObject:@"腾讯地图"];
            }
        }
    }
    return appListArr;
}
@end
