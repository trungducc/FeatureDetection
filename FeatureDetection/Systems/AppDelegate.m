//
//  AppDelegate.m
//  FeatureDetection
//
//  Created by trungduc on 1/16/19.
//  Copyright © 2019 trungduc. All rights reserved.
//

#import "AppDelegate.h"

#import "CameraViewController.h"

@interface AppDelegate ()

// Initializes an instance of |CameraViewController| and makes it become the initial view controller.
- (void)setupInitialViewController;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupInitialViewController];

    return YES;
}

- (void)setupInitialViewController {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = [[CameraViewController alloc] init];
    [self.window makeKeyAndVisible];
}

@end
