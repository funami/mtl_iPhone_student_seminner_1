//
//  RootViewController.h
//  mtl-iphone-1
//
//  Created by Takao Funami on 11/12/11.
//  Copyright 2011 Recruit CO., LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchViewController.h"

@interface RootViewController : UITableViewController<SearchViewControllerDelegate,UISearchDisplayDelegate > {
	NSMutableArray *_items;
    
    //ネットからデータを取得するためのインスタンス変数
    NSMutableData *_receivedData;
    NSURLConnection *_connection;
    NSString *_url;
    int _start;
    NSDictionary *_currentMiddleArea;
    IBOutlet UILabel *_headerLabel;
}

#pragma mark -
#pragma mark Model
@property (nonatomic) int resultsAvailable;
@property (nonatomic,retain) NSArray *items;
@property (nonatomic, retain) NSMutableArray *filtereditems;

@property (nonatomic,retain) NSString *url;
@property (nonatomic,retain) NSDictionary *currentMiddleArea;

//WebAPIにたいして、データの取得を行う
- (void)requestAPI;

// 検索条件を設定、サンプルではエリアを指定できるようにした
-(void)editSearchParam:(id)sender;

@end
