//
//  InfoViewController.h
//  Molo2
//
//  Created by Zhenan Hong on 8/6/13.
//  Copyright (c) 2013 Lean Develop. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UITableView *iTableView;
-(IBAction)goBack;
@end
