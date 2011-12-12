//
//  SearchViewController.h
//  mtl-iphone-1
//
//  Created by Funami Takao on 11/12/12.
//  Copyright (c) 2011年 Recruit. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchViewControllerDelegate <NSObject>

- (void)didFinishSearchParamsSelection:(NSDictionary *)params;
- (void)didCancelSearchParamsSelection;


@end

@interface SearchViewController : UITableViewController{
    NSArray *_sectionIndex;
}

@property (nonatomic,assign) id<SearchViewControllerDelegate> delegate;
@property (nonatomic,retain) NSDictionary *currentMiddleArea;
@property (nonatomic,retain,readonly) NSArray *sections;



@end
