//
//  WebViewController.m
//  mtl-iphone-1
//
//  Created by Takao Funami on 11/12/11.
//  Copyright 2011 Recruit CO., LTD. All rights reserved.
//

#import "WebViewController.h"


@implementation WebViewController
@synthesize url = _url;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	[_activity startAnimating];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
	[_webView loadRequest:request]; 
}



- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[_webView release];
	_webView = nil;
	[_url release];
	_url = nil;
	[_activity release];
	_activity = nil;
}


- (void)dealloc {
	[_webView release];
	[_url release];
	[_activity release];
    [super dealloc];
}

#pragma mark -
#pragma mark UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[_activity stopAnimating];
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[_activity startAnimating];
}
@end
