//
//  InfoViewController.m
//  Molo2
//
//  Created by Zhenan Hong on 8/6/13.
//  Copyright (c) 2013 Lean Develop. All rights reserved.
//

#import "InfoViewController.h"
#import <Parse/Parse.h>

@interface InfoViewController ()

@end

@implementation InfoViewController{
    NSArray *jsonResults;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationBar.topItem.title = @"User001";
    self.navigationBar.tintColor = [UIColor blackColor];
    [self getRank];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)goBack{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)getRank
{
    PFQuery *query = [PFQuery queryWithClassName:@"Users"];
   // [query whereKey:@"playerName" equalTo:@"Dan Stemkoski"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", objects.count);
            // Do something with the found objects
            jsonResults = objects;
            NSSortDescriptor* sorter = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO];
            NSArray* sortDescriptors = [NSArray arrayWithObject:sorter];
            jsonResults = [objects sortedArrayUsingDescriptors:sortDescriptors];
            [self.iTableView reloadData];
//            for (PFObject *object in objects) {
//                NSLog(@"%@", object.objectId);
//            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

//******************************************************table
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return [jsonResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UserCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
   
    //  [self drawBoundaryfromParcelPoints:thisBusiness];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [[jsonResults objectAtIndex:indexPath.row] objectForKey:@"userName"] ];
    cell.detailTextLabel.text =[NSString stringWithFormat:@"%@", [[jsonResults objectAtIndex:indexPath.row] objectForKey:@"score"] ];
    
    if([[[jsonResults objectAtIndex:indexPath.row] objectForKey:@"deviceID"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceID"]])
        self.navigationBar.topItem.title = cell.textLabel.text;

    return cell;
}
@end
