//
//  RootViewController.h
//  mtl-iphone-1
//
//  Created by Takao Funami on 11/12/11.
//  Copyright 2011 Recruit CO., LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UITableViewController {
	NSArray *_items;
}

#pragma mark -
#pragma mark Model
@property (nonatomic) int resultsAvailable;
@property (nonatomic,retain,readonly) NSArray *items;
@end
