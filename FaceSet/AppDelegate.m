//
//  AppDelegate.m
//  FaceSet
//
//  Created by Wren on 3/23/15.
//  Copyright (c) 2015 Janardan Yri. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.

  self.window = [[UIWindow alloc] init];

  self.window.rootViewController = [[ViewController alloc] init];

  [self.window makeKeyAndVisible];

  return YES;
}

@end
