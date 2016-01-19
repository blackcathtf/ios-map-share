//
//  LocChoseController.m
//  ios-map-share
//
//  Created by nick on 16/1/19.
//  Copyright © 2016年 nick. All rights reserved.
//

#import "LocChoseController.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "CLLocation+Mars.h"

#define PIN_H 46
#define PIN_W 28

#define LOCAL_BTN_H 40
#define LOCAL_BTN_W 40

//屏幕高度
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
//屏幕宽度
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

static NSString* const addressCellIdentifier=@"addressCellIdentifier";

@interface LocChoseController ()<MKMapViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong)CLGeocoder *geocoder;
@property (nonatomic,strong)CLLocationManager *locationManager;
@property (nonatomic,strong)MKMapView *map;
@property (nonatomic,strong)UIImageView *pinImg;
@property (nonatomic,strong)UIButton *localBtn;
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)UIButton *closeBtn;

@property (nonatomic,strong)NSArray *placeArray;
@property (nonatomic,assign)BOOL isLocation;
@property (nonatomic,assign)CLLocationCoordinate2D localCor;

@end

@implementation LocChoseController

#pragma mark - view life

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initMap];
    [self initLocationBtn];
    [self initPin];
    [self initTable];
    [self initClose];
    //    MKReverseGeocoder
    //    CLLocationManager
    //    CLGeocoder获取
}
#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CLPlacemark *placeMark=[_placeArray objectAtIndex:indexPath.row];
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:addressCellIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addressCellIdentifier];
    }
    cell.textLabel.text=placeMark.name;
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _placeArray.count;
}

#pragma mark - MKMapViewDelegate
//开启定位获取当前位置
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
    _localCor=[userLocation coordinate];
    //放大地图 并且锁定到当前位置
    if (_isLocation==NO) {
        // region 需要记录下 因为需要直接定位到当前位置
        MKCoordinateRegion localRegion=MKCoordinateRegionMakeWithDistance(_localCor, 1000, 1000);
        [_map setRegion:localRegion animated:YES];
        _isLocation=YES;
    }
}
//地图显示区域改变的时候进行调用进行 反地理编码获取 当前区域的周边的地理
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    CLLocationCoordinate2D centerCoor=mapView.centerCoordinate;
    [self reverseGeocode:centerCoor];
}
#pragma mark - CLLocationManagerDelegate

#pragma mark - Event Action
//反地理编码 根据坐标获取地理位置
-(void)reverseGeocode:(CLLocationCoordinate2D) centerCoor
{
    CLLocation *location=[[CLLocation alloc]initWithLatitude:centerCoor.latitude longitude:centerCoor.longitude];
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        NSLog(@"marks count==%ld",placemarks.count);
        if (error||placemarks.count==0) {
            NSLog(@"找不到坐标或者错误");
        }else{
            _placeArray=placemarks;
            [_tableView reloadData];
        }
    }];
}
//返回到当前的定位
-(void)backToLocal:(id)sender
{
    MKCoordinateRegion curRegion=_map.region;
    MKCoordinateRegion backRegion=MKCoordinateRegionMake(_localCor, curRegion.span);
    [_map setRegion:backRegion animated:YES];
}
-(void)closeView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - view setUp
-(void)initMap{
    
    _map=[[MKMapView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,400)];
    
    [self.view addSubview:_map];
    _map.mapType=MKMapTypeStandard;
    _map.delegate=self;
    _isLocation=NO;
    //开启地图定位
    [_map setShowsUserLocation:YES];
   
}
//初始化定位到当前的按钮
-(void)initLocationBtn
{
    if (_localBtn==nil) {
        _localBtn=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-LOCAL_BTN_W-10, 400-LOCAL_BTN_H-10, LOCAL_BTN_W, LOCAL_BTN_H)];
        [_localBtn setImage:[UIImage imageNamed:@"location_btn"] forState:UIControlStateNormal];
        [_localBtn addTarget:self action:@selector(backToLocal:) forControlEvents:UIControlEventTouchUpInside];
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

-(void)initTable{
    
    if (_tableView==nil) {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0,400, SCREEN_WIDTH, SCREEN_HEIGHT-400)];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        _tableView.tableFooterView=[[UIView alloc]init];
    }
    [self.view addSubview:_tableView];
}
#pragma mark - get & set
-(CLGeocoder*)geocoder{
    
    if(_geocoder==nil){
        _geocoder=[[CLGeocoder alloc]init];
    }
    return _geocoder;
}


@end
