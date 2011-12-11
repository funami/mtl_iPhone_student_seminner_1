//
//  DetailViewController.h
//  mtl-iphone-1
//
//  Created by Takao Funami on 11/12/11.
//  Copyright 2011 Recruit CO., LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AsyncImageView.h"


@interface DetailViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate> {
	IBOutlet UILabel *_label01;
	IBOutlet UILabel *_label02;
	IBOutlet UILabel *_label03;
	IBOutlet UILabel *_label04;
	IBOutlet UILabel *_label05;
	IBOutlet UILabel *_label06;
	IBOutlet UILabel *_label07;
	IBOutlet MKMapView *_mapView;
	IBOutlet AsyncImageView *_photoImageView;
	
	NSDictionary *_item;
	
	CLLocationManager *_locationManager;
	IBOutlet UIBarButtonItem *_showRouteButton;
	
}
@property (nonatomic,retain) NSDictionary *item;

- (IBAction)showHotpepper:(id)sender;
- (IBAction)showRoute:(id)sender;
- (IBAction)tweet:(id)sender;
@end
