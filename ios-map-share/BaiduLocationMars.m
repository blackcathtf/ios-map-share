//
//  BaiduLocationMars.m
//  ios-map-share
//
//  Created by nick on 16/1/20.
//  Copyright © 2016年 nick. All rights reserved.
//

#import "BaiduLocationMars.h"
const double x_pi = 3.14159265358979324 * 3000.0 / 180.0;
//火星转百度坐标
void bd_encrypt(double gg_lat, double gg_lon, double *bd_lat, double *bd_lon)
{
    double x = gg_lon, y = gg_lat;
    double z = sqrt(x * x + y * y) + 0.00002 * sin(y * x_pi);
    double theta = atan2(y, x) + 0.000003 * cos(x * x_pi);
    *bd_lon = z * cos(theta) + 0.0065;
    *bd_lat = z * sin(theta) + 0.006;
}
//百度坐标转火星
void bd_decrypt(double bd_lat, double bd_lon, double *gg_lat, double *gg_lon)
{
    double x = bd_lon - 0.0065, y = bd_lat - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi);
    double theta = atan2(y, x) - 0.000003 * cos(x * x_pi);
    *gg_lon = z * cos(theta);
    *gg_lat = z * sin(theta);
}
@implementation BaiduLocationMars

@end
