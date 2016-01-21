//
//  AddressSearchController.m
//  ios-map-share
//
//  Created by nick on 16/1/21.
//  Copyright © 2016年 nick. All rights reserved.
//

#import "AddressSearchController.h"

#import <CoreLocation/CoreLocation.h>
#import <AddressBookUI/AddressBookUI.h>


static NSString * const addressTabelViewCellIdentifier = @"addressTabelViewCellIdentifier";

@interface AddressSearchController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>

@property (nonatomic,strong) UISearchBar *searchBar;
@property (nonatomic,strong) UISearchDisplayController *searchDisplayController;

@property (nonatomic,strong) CLGeocoder *geocoder;

@property (nonatomic,strong) NSArray *searchArray;

@end

@implementation AddressSearchController

#pragma mark - view life
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self initSearchBar];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    /**
     *  geocodeAddressDictionary 需要导入 addressbook
     *  kABPersonAddressProperty等属性可以进行搜索
     */
    [self.geocoder geocodeAddressDictionary:@{(NSString*)kABPersonAddressZIPKey:searchBar.text} completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error||placemarks.count==0) {
            NSLog(@"找不到坐标或者错误");
        }else{
            _searchArray=placemarks;
            [_searchDisplayController.searchResultsTableView reloadData];
        }
  
    }];
    
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _searchArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CLPlacemark *placemark=_searchArray[indexPath.row];
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:addressTabelViewCellIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addressTabelViewCellIdentifier];
    }
    cell.textLabel.text=placemark.name;
    return cell;
}

#pragma mark - init
-(void)initSearchBar{
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 44)];
    _searchBar.delegate=self;
    _searchBar.placeholder = @"输入关键字搜索";
    [self.view addSubview:_searchBar];
    //search display
    _searchDisplayController=[[UISearchDisplayController alloc]initWithSearchBar:_searchBar contentsController:self];
    _searchDisplayController.searchResultsDataSource=self;
    _searchDisplayController.searchResultsDelegate=self;
    
}

#pragma mark - get & set
-(CLGeocoder*)geocoder{
    
    if(_geocoder==nil){
        _geocoder=[[CLGeocoder alloc]init];
    }
    return _geocoder;
}
@end
