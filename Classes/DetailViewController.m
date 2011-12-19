//
//  DetailViewController.m
//  mtl-iphone-1
//
//  Created by Takao Funami on 11/12/11.
//  Copyright 2011 Recruit CO., LTD. All rights reserved.
//

#import "DetailViewController.h"
#import "WebViewController.h"
#import "NSString+URLEncoding.h"
#import "FNACustomAnnotation.h"
/* 
#import <Twitter/TWTweetComposeViewController.h>
*/

@implementation DetailViewController

@synthesize item = _item;

#pragma mark -
#pragma mark Action

- (IBAction)showHotpepper:(id)sender{
	//ホットペッパーの詳細ページをWebViewで表示する
	WebViewController *webViewController = [[WebViewController alloc] init];
	webViewController.title = @"ホットペッパー";
	
	NSString *item_url = [[_item objectForKey:@"urls"] objectForKey:@"pc"];
	
	webViewController.url = item_url;
	[self.navigationController pushViewController:webViewController animated:YES];
	[webViewController release];
	
}

- (IBAction)showRoute:(id)sender{
	// このオブジェクトにまだ位置情報マネージャがなければ、 
	// 位置情報マネージャを作成する 
	if ([CLLocationManager locationServicesEnabled]){
		if (nil == _locationManager)
			_locationManager = [[CLLocationManager alloc] init];
		//測地結果は、随時delegateメソッドdidUpdateToLocationにて通知される
		CLLocation *location = _locationManager.location;
		NSString *url = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f(%@)&daddr=%@,%@(%@)&dirflg=r",
						 location.coordinate.latitude,
						 location.coordinate.longitude,
						 [@"現在地" urlEncodeUsingEncoding:NSUTF8StringEncoding],
						 [_item objectForKey:@"lat"] ,
						 [_item objectForKey:@"lng"] ,
						 [[_item objectForKey:@"name"] urlEncodeUsingEncoding:NSUTF8StringEncoding]];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];		
	}
}



- (IBAction)tweet:(id)sender{
	//Twitter連動を行う
	
	NSString *initialText = [NSString stringWithFormat:@"『%@』 - ",[_item objectForKey:@"name"]];
		
	WebViewController *webViewController = [[WebViewController alloc] init];
	webViewController.title = @"Tweet";
	
	NSString *item_url = [[_item objectForKey:@"urls"] objectForKey:@"pc"];
	NSString *url= [NSString stringWithFormat:@"https://twitter.com/intent/tweet?text=%@&url=%@",[initialText urlEncodeUsingEncoding:NSUTF8StringEncoding],[item_url urlEncodeUsingEncoding:NSUTF8StringEncoding]];
	
	NSLog(@"twi url:%@",url);
	
	webViewController.url = url;
	[self.navigationController pushViewController:webViewController animated:YES];
	[webViewController release];
		
}

#pragma mark - Map View Delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    /*
	 if (annotation == mapView.userLocation) {
	 return nil;
	 }
     */
    
    static NSString* identifier = @"Pin";
    if ([annotation isKindOfClass:[FNACustomAnnotation class]]) {
        MKPinAnnotationView *annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if(nil == annotationView) {
            annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
            annotationView.animatesDrop = YES;
            annotationView.canShowCallout = NO;
        } else {
            annotationView.annotation = annotation;
        }
        return annotationView;
    }
    return nil;
}
	

#pragma mark -
#pragma mark Model and View
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// configure view - ここで、お店の詳細を画面に表示させる
	// 各labelの表示内容を変更してみよう。　例えば、[_item objectForKey:@"name"]を [_item objectForKey:@"name_kana"]にかえてみる
	// 行のタイトルは、DetailViewController.xibを開いて変更しよう。
	_label01.text = [_item objectForKey:@"name"];
	_label02.text = [_item objectForKey:@"address"];
	_label03.text = [_item objectForKey:@"station_name"];
	_label04.text = [_item objectForKey:@"mobile_access"];
	_label05.text = [[_item objectForKey:@"genre"] objectForKey:@"name"];
	_label06.text = [[_item objectForKey:@"budget"] objectForKey:@"average"];
	_label07.text = [_item objectForKey:@"free_drink"]; 
	
	
	// タイトルをセット
	self.title = [_item objectForKey:@"name"];
	
	// 画像の表示
	[_photoImageView loadImageFromURL:[NSURL URLWithString:[[[_item objectForKey:@"photo"] objectForKey:@"pc"]objectForKey:@"m"]]];
	
	
	// Mapの表示
	CLLocationCoordinate2D co = CLLocationCoordinate2DMake([[_item objectForKey:@"lat"] floatValue], [[_item objectForKey:@"lng"] floatValue]);	
	MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
	MKCoordinateRegion cr = MKCoordinateRegionMake(co,span);
	[_mapView setRegion:cr animated:YES];
	
	FNACustomAnnotation* annotation = [[[FNACustomAnnotation alloc] initWithLocation:co] autorelease];
	[_mapView removeAnnotations:_mapView.annotations];
	[_mapView addAnnotation:annotation];
	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[_label01 release];
	_label01 = nil;
	[_label02 release];
	_label02 = nil;
	[_label03 release];
	_label03 = nil;
	[_label04 release];
	_label04 = nil;
	[_label05 release];
	_label05 = nil;
	[_label06 release];
	_label06 = nil;
	[_label07 release];
	_label07 = nil;
	[_mapView release];
	_mapView = nil;
	[_photoImageView release];
	_photoImageView = nil;
}


- (void)dealloc {
	[_label01 release];
	[_label02 release];
	[_label03 release];
	[_label04 release];
	[_label05 release];
	[_label06 release];
	[_label07 release];
	[_mapView release];
	[_photoImageView release];
	[_item release];
	[_locationManager release];
    [super dealloc];
}


@end
