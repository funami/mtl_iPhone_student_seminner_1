//
//  WebViewController.h
//  mtl-iphone-1
//
//  Created by Takao Funami on 11/12/11.
//  Copyright 2011 Recruit CO., LTD. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController<UIWebViewDelegate> {
	IBOutlet UIWebView *_webView;
	NSString *_url;
	IBOutlet UIActivityIndicatorView *_activity;
}
@property (nonatomic,retain) IBOutlet NSString *url;

@end
