//
//  AppDelegate.m
//  Molo2
//
//  Created by Zhenan Hong on 8/6/13.
//  Copyright (c) 2013 Lean Develop. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
//    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController ;
//    navigationController.navigationBar.tintColor=[UIColor colorWithRed:90/255.0f green:90/255.0f blue:90/255.0f alpha:0.7];
    
    
    
    [Parse setApplicationId:@"qFY8A49IVhNH67vFQR1CX8kbqLqSEovb9wbvxij4"
                  clientKey:@"usAX5BNNS5gyGO4ANBwrv2gAHnvKyl7HPo7P59sG"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults objectForKey:@"deviceID"]){
        CFUUIDRef theUUID = CFUUIDCreate(kCFAllocatorDefault);
        NSString *uuid = [[NSString alloc]initWithFormat:@"%@", CFUUIDCreateString(kCFAllocatorDefault, theUUID)];
        [defaults setObject:uuid forKey:@"deviceID"];
        [defaults synchronize];
        
        PFObject *userReport = [PFObject objectWithClassName:@"Users"];
        [userReport setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceID"] forKey:@"deviceID"];
        [userReport setObject:[NSString stringWithFormat:@"%@%d",[self randomName], (NSInteger)arc4random() % 16] forKey:@"userName"];
        [userReport setObject:[[NSNumber alloc] initWithInt:0] forKey:@"score"];
        [userReport saveInBackground];
    }
   
    NSLog(@"device id: %@",[defaults objectForKey:@"deviceID"]);
    
    return YES;
}

-(NSString *) randomName
{
    NSString* name;
    NSArray* nameArr = [NSArray arrayWithObjects: @"Supperman", @"Spider-man", @"Hulk", @"Wolverine",
                        @"Iron Man", @"Thor", @"Mad Scientist", @"Super Mario", @"Batman",@"Mighty Mouse",@"Winnie the Pooh", @"Popeye",
                        nil];
    NSUInteger randomIndex = arc4random() % [nameArr count];
    name = [nameArr objectAtIndex: randomIndex];
    return name;
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    ViewController* viewController = (ViewController*)self.window.rootViewController;
    [viewController refresh];
    NSLog(@"app will enter foreground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
