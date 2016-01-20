//
//  BaiduLocationMars.h
//  ios-map-share
//
//  Created by nick on 16/1/20.
//  Copyright © 2016年 nick. All rights reserved.
//

#import <Foundation/Foundation.h>
void bd_decrypt(double bd_lat, double bd_lon, double *gg_lat, double *gg_lon);
void bd_encrypt(double gg_lat, double gg_lon, double *bd_lat, double *bd_lon);

@interface BaiduLocationMars : NSObject

@end
