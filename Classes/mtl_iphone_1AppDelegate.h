//
//  mtl_iphone_1AppDelegate.h
//  mtl-iphone-1
//
//  Created by Takao Funami on 11/12/11.
//  Copyright 2011 Recruit CO., LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface mtl_iphone_1AppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

