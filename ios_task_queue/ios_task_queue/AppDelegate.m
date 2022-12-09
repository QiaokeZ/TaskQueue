//
//  AppDelegate.m
//  ios_task_queue
//
//  Created by 鲁班七号 on 2022/12/9.
//

#import "AppDelegate.h"
#import "DownloadViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.backgroundColor = UIColor.blackColor;
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController: [DownloadViewController new]];
    [self.window makeKeyAndVisible];
    return YES;
}



@end
