//
//  BLocChoseController.m
//  ios-map-share
//
//  Created by nick on 16/1/19.
//  Copyright © 2016年 nick. All rights reserved.
//

#import "BLocChoseController.h"

#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入搜索功能所有的头文件

#define PIN_H 46
#define PIN_W 28

#define LOCAL_BTN_H 40
#define LOCAL_BTN_W 40

static NSString* const addressCellIdentifier=@"addressCellIdentifier";

@interface BLocChoseController()<BMKMapViewDelegate,BMKGeoCodeSearchDelegate,BMKLocationServiceDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) BMKMapView *map;
@property (nonatomic,strong) BMKGeoCodeSearch *geoCodeSearch;
@property (nonatomic,strong) BMKLocationService *locService;
@property (nonatomic,strong) BMKReverseGeoCodeOption *reverseGeoCodeOption;

@property (nonatomic,strong) UIImageView *pinImg;
@property (nonatomic,strong) UIButton *localBtn;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIButton *closeBtn;

@property (nonatomic,strong) NSArray *poiArray;
@property (nonatomic,assign) BOOL isLocation;
@property (nonatomic,assign) CLLocationCoordinate2D localCor;

@end

@implementation BLocChoseController

#pragma mark - view life
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initLocationService];
    [self initMap];
    [self initTable];
    [self initPin];
    [self initLocationBtn];
    [self initClose];
}
-(void)viewWillAppear:(BOOL)animated
{
    [_map viewWillAppear];
    _map.delegate=self;
    _geoCodeSearch.delegate=self;
    _locService.delegate = self;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [_map viewWillDisappear];
    _map.delegate = nil; //不用时，置nil
    _geoCodeSearch.delegate=nil;
    _locService.delegate = nil;
}
#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BMKPoiInfo *poiInfo=[_poiArray objectAtIndex:indexPath.row];
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:addressCellIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addressCellIdentifier];
    }
    cell.textLabel.text=poiInfo.name;
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _poiArray.count;
}
#pragma mark - BMKLocationServiceDelegate
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    _localCor=userLocation.location.coordinate;
    //设置地图中心为用户经纬度
    [_map updateLocationData:userLocation];
    if (_isLocation==NO) {
        _map.centerCoordinate =_localCor;
        _isLocation=YES;
    }
}
#pragma mark - BMKMapViewDelegate
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    //屏幕坐标转地图经纬度
    CLLocationCoordinate2D MapCoordinate=[_map convertPoint:_map.center toCoordinateFromView:_map];
    
    //需要逆地理编码的坐标位置
    self.reverseGeoCodeOption.reverseGeoPoint =  CLLocationCoordinate2DMake(MapCoordinate.latitude,MapCoordinate.longitude);
    [self.geoCodeSearch reverseGeoCode:self.reverseGeoCodeOption];
    
}
#pragma mark - BMKGeoCodeSearchDelegate
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    //获取周边用户信息
    if (error==BMK_SEARCH_NO_ERROR) {
        _poiArray=result.poiList;
        [_tableView reloadData];
    }else{
        NSLog(@"BMKSearchErrorCode: %u",error);
    }

}
#pragma mark - event Action
-(void)closeView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)backToLocal
{
    [_map setCenterCoordinate:_localCor animated:YES];
}
#pragma mark - init
-(void)initLocationService
{
    if (_locService==nil) {
        
        _locService = [[BMKLocationService alloc]init];
        
        [_locService setDesiredAccuracy:kCLLocationAccuracyBest];
    }
    
    _locService.delegate = self;
    
    [_locService startUserLocationService];
    
}
//初始化定位到当前的按钮
-(void)initLocationBtn
{
    if (_localBtn==nil) {
        _localBtn=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-LOCAL_BTN_W-10, 400-LOCAL_BTN_H-10, LOCAL_BTN_W, LOCAL_BTN_H)];
        [_localBtn setImage:[UIImage imageNamed:@"location_btn"] forState:UIControlStateNormal];
        [_localBtn addTarget:self action:@selector(backToLocal) forControlEvents:UIControlEventTouchUpInside];
    }
    [_map addSubview:_localBtn];
    
}
//初始化再中间的大头针
-(void)initPin{
    
    if (_pinImg==nil) {
        _pinImg=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, PIN_W, PIN_H)];
        _pinImg.center=CGPointMake(_map.center.x, _map.center.y-PIN_H/2);
        _pinImg.image=[UIImage imageNamed:@"location_ico"];
    }
    [_map addSubview:_pinImg];
}

-(void)initMap{
    
    _map=[[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,400)];
    
    [self.view addSubview:_map];
    _map.mapType=BMKMapTypeStandard;
    _map.delegate=self;
    _map.zoomLevel=19;

    _isLocation=NO;
    //开启地图定位
    [_map setShowsUserLocation:YES];
    
}
-(void)initTable{
    
    if (_tableView==nil) {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0,400, SCREEN_WIDTH, SCREEN_HEIGHT-400)];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        _tableView.tableFooterView=[[UIView alloc]init];
    }
    [self.view addSubview:_tableView];
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

#pragma mark - get &set
-(BMKGeoCodeSearch*)geoCodeSearch{
    if (_geoCodeSearch==nil) {
        //初始化地理编码类
        _geoCodeSearch = [[BMKGeoCodeSearch alloc]init];
        _geoCodeSearch.delegate = self;
    }
    return _geoCodeSearch;
}
-(BMKReverseGeoCodeOption*)reverseGeoCodeOption{
    if (_reverseGeoCodeOption==nil) {
        //初始化反地理编码类
        _reverseGeoCodeOption= [[BMKReverseGeoCodeOption alloc] init];
    }
    return _reverseGeoCodeOption;
}
@end
