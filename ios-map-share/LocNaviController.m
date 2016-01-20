//
//  LocNaviController.m
//  ios-map-share
//
//  Created by nick on 16/1/20.
//  Copyright © 2016年 nick. All rights reserved.
//

#import "LocNaviController.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "PageThirdMap.h"
#import "BaiduLocationMars.h"
#import "NaviAnnotation.h"

#import "RegexKitLite.h"

#define TOOLBAR_HEIGHT 40

//测试目标地址
#define GO_LATI 30.285978
#define GO_LONG 120.128977

static NSString* const testAnnotationIdentifier=@"testAnnotationIdentifier";

@interface LocNaviController()<MKMapViewDelegate,UIActionSheetDelegate>

@property (nonatomic,strong)MKMapView *map;

@property (nonatomic,strong)UIView *toolBar;
@property (nonatomic,strong)UIButton *closeBtn;

@property (nonatomic,assign)BOOL isLocation;
@property (nonatomic,assign)CLLocationCoordinate2D localCor;
@property (nonatomic,assign)CLLocationCoordinate2D naviCoor;
@property (nonatomic,strong)NSArray *routes;//ios6路线arr

@property (nonatomic,strong)NaviAnnotation *naviPoi;

@end

@implementation LocNaviController
#pragma mark - view life
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initMap];
    [self initToolBar];
    [self initClose];
    [self addNaviAnnotation];
}

#pragma mark - MKMapViewDelegate
//开启定位获取当前位置
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
    //确定当前位置的坐标
    _localCor=[userLocation coordinate];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (annotation==_naviPoi) {
        MKPinAnnotationView *newAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:testAnnotationIdentifier];
        newAnnotation.pinColor = MKPinAnnotationColorGreen;
        newAnnotation.animatesDrop = YES;
        newAnnotation.canShowCallout=YES;
        return newAnnotation;

    }else{
        return nil;
    }
}


#pragma mark - CLLocationManagerDelegate
//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
//{
//
//    [self showMapNavigationViewFormcurrentLatitude:newLocation.coordinate.latitude currentLongitute:newLocation.coordinate.longitude TotargetLatitude:_targetLatitude targetLongitute:_targetLongitute toName:_name];
//
//}
#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    NSString *btnTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if (buttonIndex == 0) {
        //起点
        MKMapItem *currentLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:_localCor addressDictionary:nil]];
        currentLocation.name = @"我的位置";
        
        //终点
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:_naviCoor addressDictionary:nil]];
        toLocation.name = @"目标地点";
        NSArray *items = [NSArray arrayWithObjects:currentLocation, toLocation, nil];
        NSDictionary *options = @{
                                  MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,
                                  MKLaunchOptionsMapTypeKey:
                                      [NSNumber numberWithInteger:MKMapTypeStandard],
                                  MKLaunchOptionsShowsTrafficKey:@YES
                                  };
        
        //打开苹果自身地图应用
        [MKMapItem openMapsWithItems:items launchOptions:options];
    }
    if ([btnTitle isEqualToString:@"google地图"]) {
        NSString *urlStr = [NSString stringWithFormat:@"comgooglemaps://?saddr=%.8f,%.8f&daddr=%.8f,%.8f&directionsmode=transit",_localCor.latitude,_localCor.longitude,_naviCoor.latitude,_naviCoor.longitude];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
    }
    else if ([btnTitle isEqualToString:@"高德地图"]){
        NSString *urlString = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=applicationName&sid=BGVIS1&slat=%f&slon=%f&sname=%@&did=BGVIS2&dlat=%f&dlon=%f&dname=%@&dev=0&m=0&t=0",_localCor.latitude,_localCor.longitude,@"我的位置",_naviCoor.latitude,_naviCoor.longitude,@"目标位置"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *r = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:r];
        
    }
    
    else if ([btnTitle isEqualToString:@"腾讯地图"]){
        
        NSString *urlStr = [NSString stringWithFormat:@"qqmap://map/routeplan?type=drive&fromcoord=%f,%f&tocoord=%f,%f&policy=1",_localCor.latitude,_localCor.longitude,_naviCoor.latitude,_naviCoor.longitude];
        NSURL *r = [NSURL URLWithString:urlStr];
        [[UIApplication sharedApplication] openURL:r];
    }
    else if([btnTitle isEqualToString:@"百度地图"])
    {
        double AdressLat,AdressLon;
        double NowLat,NowLon;
        
        bd_encrypt(_naviCoor.latitude,_naviCoor.longitude, &AdressLat, &AdressLon);
        bd_encrypt(_localCor.latitude,_localCor.longitude, &NowLat, &NowLon);
        NSString *stringURL = [NSString stringWithFormat:@"baidumap://map/direction?origin=%f,%f&destination=%f,%f&&mode=driving",NowLat,NowLon,AdressLat,AdressLon];
        NSURL *url = [NSURL URLWithString:stringURL];
        [[UIApplication sharedApplication] openURL:url];
    }else if([btnTitle isEqualToString:@"显示路线"])
    {
        [self drawRout];
    }
        
}
#pragma mark - Rout Draw Action >=iOS7

-(void)drawRout{
    MKPlacemark *fromPlacemark = [[MKPlacemark alloc] initWithCoordinate:_localCor addressDictionary:nil];
    MKPlacemark *toPlacemark   = [[MKPlacemark alloc] initWithCoordinate:_naviCoor addressDictionary:nil];
    MKMapItem *fromItem = [[MKMapItem alloc] initWithPlacemark:fromPlacemark];
    MKMapItem *toItem   = [[MKMapItem alloc] initWithPlacemark:toPlacemark];
    
    [_map removeOverlays:_map.overlays];
    
    if (ISIOS7) {//ios7采用系统绘制方法
        [_map removeOverlays:_map.overlays];
        [self drawDirectionsFrom:fromItem to:toItem];
    }else{//ios7以下借用google路径绘制方法
        if (_routes) {
            _routes = nil;
        }
        _routes = [self calculateRoutesFrom];
        [self updateRouteView];
        [self centerMap];
    }
}
-(void)drawDirectionsFrom:(MKMapItem *)from to:(MKMapItem *)to{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = from;
    request.destination = to;
    request.transportType = MKDirectionsTransportTypeWalking;
    if (ISIOS7) {
        request.requestsAlternateRoutes = YES;
    }
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    //ios7获取绘制路线的路径方法
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error:%@", error);
        }
        else {
            MKRoute *route = response.routes[0];
            [self.map addOverlay:route.polyline];
        }
    }];
}
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id<MKOverlay>)overlay{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.lineWidth = 5.0;
    renderer.strokeColor = [UIColor redColor];
    return renderer;
}
#pragma mark- Rout Draw Action iOS6~~iOS7
-(NSArray*)calculateRoutesFrom{
    NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%0.8f,%0.8f&daddr=%0.8f,%0.8f", _localCor.latitude, _localCor.longitude, _naviCoor.latitude, _naviCoor.longitude];
    NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
    NSString *apiResponse = [NSString stringWithContentsOfURL:apiUrl encoding:NSASCIIStringEncoding error:nil];
    
    NSString* encodedPoints = [apiResponse stringByMatching:@"points:\\\"([^\\\"]*)\\\"" capture:1L];
    return [self decodePolyLine:[encodedPoints mutableCopy]:_localCor to:_naviCoor];
}
//ios6 路线绘图，创建PolyLine
-(NSMutableArray *)decodePolyLine: (NSMutableString *)encoded :(CLLocationCoordinate2D)f to: (CLLocationCoordinate2D) t {
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, [encoded length])];
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger latV = 0;
    NSInteger lngV = 0;
    while (index < len) {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        latV += dlat;
        shift = 0;
        result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lngV += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:latV * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lngV * 1e-5];
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:loc];
    }
    CLLocation *first = [[CLLocation alloc] initWithLatitude:[[NSNumber numberWithFloat:f.latitude] floatValue] longitude:[[NSNumber numberWithFloat:f.longitude] floatValue] ];
    CLLocation *end = [[CLLocation alloc] initWithLatitude:[[NSNumber numberWithFloat:t.latitude] floatValue] longitude:[[NSNumber numberWithFloat:t.longitude] floatValue] ];
    [array insertObject:first atIndex:0];
    [array addObject:end];
    return array;
}
//ios6绘图结束后，定位路线中心
-(void)centerMap {
    MKCoordinateRegion region;
    
    CLLocationDegrees maxLat = -90;
    CLLocationDegrees maxLon = -180;
    CLLocationDegrees minLat = 90;
    CLLocationDegrees minLon = 180;
    for(int idx = 0; idx < _routes.count; idx++)
    {
        CLLocation* currentLocation = [_routes objectAtIndex:idx];
        if(currentLocation.coordinate.latitude > maxLat)
            maxLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.latitude < minLat)
            minLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.longitude > maxLon)
            maxLon = currentLocation.coordinate.longitude;
        if(currentLocation.coordinate.longitude < minLon)
            minLon = currentLocation.coordinate.longitude;
    }
    region.center.latitude     = (maxLat + minLat) / 2;
    region.center.longitude    = (maxLon + minLon) / 2;
    region.span.latitudeDelta  = maxLat - minLat + 0.018;
    region.span.longitudeDelta = maxLon - minLon + 0.018;
    
    [_map setRegion:region animated:YES];
}
-(void)updateRouteView {
    CLLocationCoordinate2D pointsToUse[[_routes count]];
    for (int i = 0; i < [_routes count]; i++) {
        CLLocationCoordinate2D coords;
        CLLocation *loc = [_routes objectAtIndex:i];
        coords.latitude = loc.coordinate.latitude;
        coords.longitude = loc.coordinate.longitude;
        pointsToUse[i] = coords;
    }
    MKPolyline *lineOne = [MKPolyline polylineWithCoordinates:pointsToUse count:[_routes count]];
    [_map addOverlay:lineOne];
}
-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay{
    if ([overlay isKindOfClass:[MKPolyline class]]){
        MKPolylineView *lineview=[[MKPolylineView alloc] initWithOverlay:overlay] ;
        //路线颜色
        lineview.strokeColor=[UIColor redColor];
        lineview.lineWidth = 5.0;
        return lineview;
    }
    return nil;
}
#pragma mark - event Action
//开始导航工作
-(void)naviLine
{
    NSArray *appListArr = [PageThirdMap checkHasOwnApp];
    NSString *sheetTitle = [NSString stringWithFormat:@"开始导航"];
    UIActionSheet *sheet;
    if ([appListArr count] == 1) {
        sheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:appListArr[0], nil];
    }else if ([appListArr count] == 2) {
        sheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:appListArr[0],appListArr[1], nil];
    }else if ([appListArr count] == 3){
        sheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:appListArr[0],appListArr[1],appListArr[2], nil];
    }else if ([appListArr count] == 4){
        sheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:appListArr[0],appListArr[1],appListArr[2],appListArr[3], nil];
    }else if ([appListArr count] == 5){
        sheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:appListArr[0],appListArr[1],appListArr[2],appListArr[3],appListArr[4], nil];
    }else if ([appListArr count] == 6){
    sheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:appListArr[0],appListArr[1],appListArr[2],appListArr[3],appListArr[4],appListArr[5], nil];
    }
    sheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [sheet showInView:self.view];

}
-(void)closeView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 测试添加目的地位置
-(void)addNaviAnnotation
{
    _naviPoi=[[NaviAnnotation alloc]initWithCoordinates:_naviCoor title:@"目的地" subTitle:@"xx街"];
    [_map addAnnotation:_naviPoi];
}

#pragma mark - init
-(void)initMap
{
    _map=[[MKMapView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,SCREEN_HEIGHT-TOOLBAR_HEIGHT)];
    
    [self.view addSubview:_map];
    _map.mapType=MKMapTypeStandard;
    _map.delegate=self;
    _isLocation=NO;
    //开启地图定位
    [_map setShowsUserLocation:YES];

    //放大地图 并且锁定到目标位置
    if (_isLocation==NO) {
        _naviCoor=CLLocationCoordinate2DMake(GO_LATI, GO_LONG);
        MKCoordinateRegion naviRegion=MKCoordinateRegionMakeWithDistance(_naviCoor, 1000, 1000);
        [_map setRegion:naviRegion animated:YES];
        _isLocation=YES;
    }
}
//底部导航
-(void)initToolBar
{

    _toolBar=[[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-TOOLBAR_HEIGHT, SCREEN_WIDTH, TOOLBAR_HEIGHT)];
    
    [self.view addSubview:_toolBar];
    
    UIButton *naviBtn=[[UIButton alloc]initWithFrame:CGRectMake(10, 0, TOOLBAR_HEIGHT, TOOLBAR_HEIGHT)];
    [naviBtn setTitle:@"导航" forState:UIControlStateNormal];
    [naviBtn addTarget:self action:@selector(naviLine) forControlEvents:UIControlEventTouchUpInside];
    
    [_toolBar addSubview:naviBtn];

}
//关闭view的按钮
-(void)initClose
{
    if (_closeBtn==nil) {
        _closeBtn=[[UIButton alloc]initWithFrame:CGRectMake(10, 20, 40, 40)];
        [_closeBtn setImage:[UIImage imageNamed:@"location_close"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    }
    [_map addSubview:_closeBtn];
}



@end
