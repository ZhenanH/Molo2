//
//  ViewController.h
//  Molo2
//
//  Created by Zhenan Hong on 8/6/13.
//  Copyright (c) 2013 Lean Develop. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *mapTypeSwitcher;
@property (strong, nonatomic) IBOutlet UITextView *mTextView;
@property (strong, nonatomic) IBOutlet UIButton *noButton;
@property (strong, nonatomic) IBOutlet UIButton *yesButton;
@property (strong, nonatomic) NSString *extra;
@property (strong, nonatomic) IBOutlet UITableView *mTableView;

-(IBAction)switchMapType;
-(IBAction)refresh;
-(IBAction)confirmYes;
-(IBAction)confirmNo;
-(IBAction)goForward;

@end
