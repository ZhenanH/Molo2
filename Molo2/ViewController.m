//
//  ViewController.m
//  Molo2
//
//  Created by Zhenan Hong on 8/6/13.
//  Copyright (c) 2013 Lean Develop. All rights reserved.
//

#import "ViewController.h"
#import "Business.h"
#import "MapViewAnnotation.h"
#import <Parse/Parse.h>

@interface ViewController ()

@end

@implementation ViewController
{
    CLLocation *location;
    BOOL didUpdated;
    int loadCount;
    NSURLConnection *connection;
    NSMutableData *jsonData;
    NSArray *jsonResults;
    Business *mBusiness;
    int dataPoints;
    int searchNearby;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.mTableView setSeparatorColor:[UIColor clearColor]];
    
    [self initializeMap];
    [self initializeLocationManager];
    [self initializeLocationUpdates];
	// Do any additional setup after loading the view, typically from a nib.
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    loadCount+=1;
    if(loadCount>1){
        [self refresh];
    }


    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    static NSString *CellIdentifier = @"PlaceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    Business *thisBusiness = [[Business alloc]init];
    thisBusiness.businessName = [[NSString alloc] initWithFormat:@"%@bid%@",[[jsonResults objectAtIndex:indexPath.row] objectForKey:@"name"],[[jsonResults objectAtIndex:indexPath.row] objectForKey:@"id"]];
    thisBusiness.parcelArray = [[jsonResults objectAtIndex:indexPath.row] objectForKey:@"polygon"];
    thisBusiness.centerLatitude = [[jsonResults objectAtIndex:indexPath.row] objectForKey:@"latitude"];
    thisBusiness.centerLongitude = [[jsonResults objectAtIndex:indexPath.row] objectForKey:@"longitude"];
    [thisBusiness getParcelString];
    
    //  [self drawBoundaryfromParcelPoints:thisBusiness];
    cell.textLabel.text = [NSString stringWithFormat:@"   %@", [self getReadableName:thisBusiness.businessName] ];
    cell.textLabel.font = [UIFont systemFontOfSize:12]; //Change this value to adjust size
   // cell.backgroundColor = [UIColor colorWithRed: 255/255.0f green: 255/255.0f blue: 255/255.0f alpha: 0.7];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.backgroundColor =[UIColor blackColor];
    cell.textLabel.opaque = NO;
    
    CGRect mFrame = cell.textLabel.frame;
    mFrame.size.width = 23;
    cell.textLabel.frame = mFrame;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 30;
}

-(void)tableAnimation:(NSString*)action
{

  
    if([action isEqualToString:@"down"]){
    
    CGRect Frame = self.mTableView.frame;
        
    Frame.size.height = dataPoints*30;
        if(dataPoints>=10)
            Frame.size.height = 10*30;
        
    Frame.origin.y = self.mTextView.frame.size.height+5;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5f];
    [self.mTableView setFrame:Frame];
    [UIView commitAnimations];
    }else{
        CGRect Frame = self.mTableView.frame;
        Frame.size.height = 0;
        Frame.origin.y = -100;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5f];
        [self.mTableView setFrame:Frame];
        [UIView commitAnimations];
    }
}

//******************************************************button UIs
-(void)switchMapType
{
    if(self.mapTypeSwitcher.selectedSegmentIndex == 1){
        self.mapView.mapType = MKMapTypeSatellite;
    }
    if(self.mapTypeSwitcher.selectedSegmentIndex == 0){
        self.mapView.mapType = MKMapTypeStandard;

    }
}

- (void)initializeMap {
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    self.mapView.delegate = self;
}

- (void)initializeLocationManager {
    // Check to ensure location services are enabled
    if(![CLLocationManager locationServicesEnabled]) {
        [self showAlertWithMessage:@"Location Services Error" : @"You need to enable location services to use this app."];
        return;
    }
    
    self.locationManager = [[CLLocationManager alloc] init];
}

- (void)initializeLocationUpdates {
    self.locationManager.desiredAccuracy = 50;
    //locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    self.locationManager.delegate = self;
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    

    
    if ([newLocation.timestamp timeIntervalSinceNow] < -10.0) {
        return;
    }
    
    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
    
    NSLog(@"new accuracy %f",newLocation.horizontalAccuracy);
    NSLog(@"accuracy %f",self.locationManager.desiredAccuracy);
    if (location == nil || oldLocation.horizontalAccuracy >= newLocation.horizontalAccuracy) {
        
        //lastLocationError = nil;
        location = newLocation;
        
        
        if (newLocation.horizontalAccuracy <= 100) {
            

            
            [self.locationManager stopUpdatingLocation];
            
            if(!didUpdated){
                didUpdated = true;
                NSLog(@"*** We're done ! %f %f",location.coordinate.latitude,location.coordinate.longitude);
                [self.mapView setCenterCoordinate:location.coordinate animated:YES];
                MKCoordinateRegion displayingRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000,1000 );
                [self.mapView setRegion:displayingRegion animated:YES];
                [self refresh];
            }
        }
    }
    
}

//web services

-(void)fetchLocationswithlat:(double)latitude lon:(double)longitude
{
   
    NSString* apiUrl = @"http://solocusp.com/molo/findbyparcel?latitude=%@&longitude=%@&limit=50";
    if(searchNearby ==1)
        apiUrl = @"http://solocusp.com/molo/findinout?latitude=%@&longitude=%@&limit=5";
    jsonData = [[NSMutableData alloc]init];
    
    NSString *lat = [[NSString alloc]initWithFormat:@"%f",latitude];
    NSString *lon = [[NSString alloc]initWithFormat:@"%f",longitude];
    //testing api http://solocusp.com/Test/rest/businessparcel/getNearbyBusinessNative?token=molo&lat=41.22631998&lon=-73.06241616&limit=50
    
    NSURL *url = [NSURL URLWithString:
                  [[NSString alloc] initWithFormat:apiUrl,lat,lon]];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
}

-(void)connection:(NSURLConnection*)conn didReceiveData:(NSData *)data
{
    [jsonData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection*)conn
{
    
    NSError *error = nil;
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSData *receivedDate = [jsonString dataUsingEncoding:NSASCIIStringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:receivedDate
                                                             options:kNilOptions
                                                               error:&error];
    
    jsonResults = [jsonDict objectForKey:@"data"];
    NSLog(@"%@", jsonResults);
    //handle inside parcel
    if(searchNearby!=1){
    if([[jsonDict objectForKey:@"statusMessage"] isEqualToString:@"success"]){
        
        bool hasDrawn = NO;

        dataPoints = [[jsonDict objectForKey:@"data"] count];
        
        NSLog(@"recieved data: %d",dataPoints);
        
        for(NSDictionary* b in [jsonDict objectForKey:@"data"]){
            Business *thisBusiness = [[Business alloc]init];
            thisBusiness.businessName = [[NSString alloc] initWithFormat:@"%@bid%@",[b objectForKey:@"name"],[b objectForKey:@"id"]];
            if([b objectForKey:@"polygon"])
                thisBusiness.parcelArray = [b objectForKey:@"polygon"];
            else
                thisBusiness.parcelArray= [[NSArray alloc]init];
            
            thisBusiness.centerLatitude = [b objectForKey:@"latitude"];
            thisBusiness.centerLongitude = [b objectForKey:@"longitude"];
            [thisBusiness getParcelString];
            
            
            
            if(!hasDrawn){
            [self drawBoundaryfromParcelPoints:thisBusiness];
                hasDrawn = YES;
            }
            
            
                
        }
        
       
        
        
       if(dataPoints == 1)
             [self setupReportWithMessage:[NSString stringWithFormat: @"Using BoA card to save 5%% at %@. Claim the offer?" , @"this business location"] withExtra:@"yes"];
        else if(dataPoints >=1)
            [self setupReportWithMessage:[NSString stringWithFormat: @"Using BoA card to save 3~5%% at  %@. Claim the offer?" , @"selected buesinesses in this mall"] withExtra:@"yes"];
          
        
         [self.mTableView reloadData];
        [self tableAnimation :@"down"];
       [self buttonAnimation:@"down"];
        
            }
    else{
               //[self showAlertWithMessage:@"": @"2"];
            [self setupReportWithMessage:[NSString stringWithFormat: @"You are not at a business location. Searching nearby%@" , @""] withExtra:@"no"];
        searchNearby = 1;
        [self fetchLocationswithlat:self.locationManager.location.coordinate.latitude lon:self.locationManager.location.coordinate.longitude];
        
       
        }
    }//handel nearby
    else{
        
        if([[jsonDict objectForKey:@"statusMessage"] isEqualToString:@"success"]){
            
            bool hasDrawn = NO;
            
           
            
            NSDictionary *b = [[jsonDict objectForKey:@"data"] objectForKey:@"business"];
                Business *thisBusiness = [[Business alloc]init];
                thisBusiness.businessName = [[NSString alloc] initWithFormat:@"%@bid%@",[b objectForKey:@"name"],[b objectForKey:@"id"]];
                if([b objectForKey:@"polygon"])
                    thisBusiness.parcelArray = [b objectForKey:@"polygon"];
                else
                    thisBusiness.parcelArray= [[NSArray alloc]init];
                
                thisBusiness.centerLatitude = [b objectForKey:@"latitude"];
                thisBusiness.centerLongitude = [b objectForKey:@"longitude"];
                [thisBusiness getParcelString];
            NSMutableArray *j = [[NSMutableArray alloc] init];
           [j addObject:b];
            jsonResults = j;
            dataPoints = 1;
                if(!hasDrawn){
                    [self drawBoundaryfromParcelPoints:thisBusiness];
                   
                    searchNearby = 0;
                    hasDrawn = YES;
                }
                
                
            
            
                                    
            [self.mTableView reloadData];
            [self tableAnimation :@"down"];
            [self buttonAnimation:@"down"];
            
        }
        else{
          
            
        }

    }
}

-(void)connection:(NSURLConnection*)conn didFailWithError:(NSError *)error
{
    connection = nil;
    jsonData = nil;
    NSString *errorString = [NSString stringWithFormat:@"Fetch failed: %@",[error localizedDescription]];
    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    [av show];
}

-(void)drawBoundaryfromParcelPoints:(Business*)thisBusiness
{
    mBusiness = thisBusiness;
    NSArray* parcels = [thisBusiness getParcelPolygon];
    CLLocationCoordinate2D parcelPoints[[parcels count]];
    for(int i=0;i<[parcels count];i++){
        double lat = [[[parcels objectAtIndex:i] componentsSeparatedByString:@","][0] doubleValue];
        double lon = [[[parcels objectAtIndex:i] componentsSeparatedByString:@","][1] doubleValue];
        parcelPoints[i]=CLLocationCoordinate2DMake(lat,lon);
    }
    MKPolygon *region = [MKPolygon polygonWithCoordinates:parcelPoints count:[parcels count]];
    
    //check if the overlay has been added already
    BOOL hasAdded = NO;
    for(MKPolygon *r in [self.mapView overlays]){
        if(r.boundingMapRect.size.width*r.boundingMapRect.size.height-region.boundingMapRect.size.height*region.boundingMapRect.size.width==0.0)
            hasAdded = YES;
    }
    
    if(!hasAdded&&searchNearby!=1)
        [self.mapView addOverlay:region];
    
    CLLocationCoordinate2D businessCenter;
    businessCenter.latitude = [thisBusiness.centerLatitude doubleValue];
    businessCenter.longitude = [thisBusiness.centerLongitude doubleValue];
    
    //add annotation
    MapViewAnnotation *newAnnotation = [[MapViewAnnotation alloc] initWithTitle:[self getReadableName:thisBusiness.businessName] andCoordinate:businessCenter];
	
    

    //zoom
    MKCoordinateRegion displayingRegion = MKCoordinateRegionMakeWithDistance(newAnnotation.coordinate, region.boundingMapRect.size.height/10, region.boundingMapRect.size.width/10);
    [self.mapView setRegion:[self.mapView regionThatFits:displayingRegion] animated:YES];
    
    if(searchNearby==1){
        [self.mapView addAnnotation:newAnnotation ];
        [self setupReportWithMessage:[NSString stringWithFormat: @"You are not at a business location. %@Use BoA card to save 3%%~5%% for the nearby business" , @""] withExtra:@"no"];
        MKCoordinateRegion displayingRegion = MKCoordinateRegionMakeWithDistance(newAnnotation.coordinate, 100, 100);
        [self.mapView setRegion:[self.mapView regionThatFits:displayingRegion] animated:YES];
    }
    
}

-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id )overlay{
    if([overlay isKindOfClass:[MKPolygon class]]){
        MKPolygonView *view = [[MKPolygonView alloc] initWithOverlay:overlay];
        view.lineWidth=1;
        view.strokeColor=[UIColor blueColor];
        view.fillColor=[[UIColor cyanColor] colorWithAlphaComponent:0.3];
        return view;
    }
    return nil;
}

-(void)drawCircel:(Business*)thisBusiness
{
    CLLocationCoordinate2D businessCenter;
    businessCenter.latitude = [thisBusiness.centerLatitude doubleValue];
    businessCenter.longitude = [thisBusiness.centerLongitude doubleValue];
    MapViewAnnotation *newAnnotation = [[MapViewAnnotation alloc] initWithTitle:[self getReadableName:thisBusiness.businessName] andCoordinate:businessCenter];
	[self.mapView addAnnotation:newAnnotation ];
    self.mTextView.text = [NSString stringWithFormat: @"You are near %@, but no parcels for it" , [self getReadableName:thisBusiness.businessName]];
}

-(void)setupReportWithMessage:(NSString*)msg  withExtra:(NSString*)extra
{
    self.mTextView.text = msg;
    [self adjustTextView:self.mTextView];
    self.extra = extra;
    
}

-(void)adjustTextView: (UITextView*)mTextView{
    CGRect frame = mTextView.frame;
    frame.size.height = mTextView.contentSize.height;
    mTextView.frame = frame;

}




-(void)buttonAnimation:(NSString*) action {

    if([action isEqualToString:@"down"]){
        CGPoint newLeftCenter = CGPointMake( self.noButton.center.x, self.mTextView.frame.size.height+self.mTableView.frame.size.height+ 30);
        CGPoint newLeftCenter2 = CGPointMake( self.yesButton.center.x,self.mTextView.frame.size.height+self.mTableView.frame.size.height+ 30);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5f];
    self.noButton.center = newLeftCenter;
    self.yesButton.center = newLeftCenter2;
        [UIView commitAnimations];
 
    }
    else{
        CGPoint newLeftCenter = CGPointMake( self.noButton.center.x, -20);
        CGPoint newLeftCenter2 = CGPointMake( self.yesButton.center.x, -20);
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5f];
        self.noButton.center = newLeftCenter;
        self.yesButton.center = newLeftCenter2;
        [UIView commitAnimations];

    }
}

-(NSString*)getReadableName:(NSString*)name{
    // NSLog(@"%@",name);
    
    NSString *returnString = nil;
    NSRange start = [name rangeOfString:@"bid"];
    if (start.location != NSNotFound)
    {
        returnString = [name substringToIndex:start.location];
        
    }
    
    return returnString;
}

-(IBAction)refresh
{
    self.mTextView.text = [NSString stringWithFormat: @"Determining your location . . ."];
    [self.mapView removeAnnotations:[self.mapView annotations]];
    [self.mapView removeOverlays:[self.mapView overlays]];
    //[self fetchLocationswithlat:self.mapView.centerCoordinate.latitude lon:self.mapView.centerCoordinate.longitude];
    [self fetchLocationswithlat:self.locationManager.location.coordinate.latitude lon:self.locationManager.location.coordinate.longitude];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}


-(BOOL)isPoint:(CLLocationCoordinate2D)point inRegion:(MKPolygon*)region inMapView:(MKMapView*)mapView
{
    
    
    BOOL isInside = FALSE;
    
    // [mapView setVisibleMapRect:region.boundingMapRect];
    [mapView addOverlay:region];
    MKPolygonView *polygonView = (MKPolygonView *)[mapView viewForOverlay:region];
    //[mapView removeOverlay:region];
    MKMapPoint mapPoint = MKMapPointForCoordinate(point);
    
    CGPoint polygonViewPoint = [polygonView pointForMapPoint:mapPoint];
    
    BOOL mapCoordinateIsInPolygon = CGPathContainsPoint(polygonView.path, NULL, polygonViewPoint, NO);
    
    if (mapCoordinateIsInPolygon)
    {
        isInside = TRUE;
        //NSLog(@"%@'s boudary contains current location",thisBusiness.businessName);
        
    }
    
    
    
    
    return isInside;
}


-(IBAction)confirmYes{
   
    self.mTextView.text = [NSString stringWithFormat: @"Your offer is claimed, just use your BoA card and the discount will appear in your bank statement!!!"];
    [self adjustTextView:self.mTextView];
    [self buttonAnimation:@"up" ];
    [self tableAnimation :@"up"];
    
    PFObject *userReport = [PFObject objectWithClassName:@"UserReport"];
    [userReport setObject:[[NSNumber alloc] initWithDouble: self.locationManager.location.coordinate.latitude] forKey:@"lat"];
    [userReport setObject:[[NSNumber alloc] initWithDouble: self.locationManager.location.coordinate.longitude] forKey:@"lng"];
    [userReport setObject:[NSString stringWithFormat:@"%@/yes", self.extra] forKey:@"report"];
    [userReport setObject:[[NSNumber alloc] initWithInt: dataPoints] forKey:@"overlap"];
    [userReport setObject:[[NSNumber alloc] initWithDouble: self.locationManager.location.horizontalAccuracy] forKey:@"accuracy"];
    [userReport setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceID"] forKey:@"deviceID"];

    
    if([self.extra isEqualToString:@"yes"]){
        [userReport setObject:mBusiness.businessName forKey:@"businessName"];
        [self gainScore:3];
    }
    else{
        [userReport setObject:@"n/a" forKey:@"businessName"];
         [self gainScore:1];
    }
    [userReport saveInBackground];
    self.extra = @"";
    
}


-(IBAction)confirmNo{

     self.mTextView.text = [NSString stringWithFormat: @"Sorry that you are not interested in the offer. Let us know how we can make it better."];
    [self adjustTextView:self.mTextView];
    [self buttonAnimation:@"up" ];
    [self tableAnimation :@"up"];
    PFObject *userReport = [PFObject objectWithClassName:@"UserReport"];
    [userReport setObject:[[NSNumber alloc] initWithDouble: self.locationManager.location.coordinate.latitude] forKey:@"lat"];
    [userReport setObject:[[NSNumber alloc] initWithDouble: self.locationManager.location.coordinate.longitude] forKey:@"lng"];
    [userReport setObject:[NSString stringWithFormat:@"%@/no", self.extra] forKey:@"report"];
    [userReport setObject:[[NSNumber alloc] initWithInt: dataPoints] forKey:@"overlap"];
    [userReport setObject:[[NSNumber alloc] initWithDouble: self.locationManager.location.horizontalAccuracy] forKey:@"accuracy"];
    [userReport setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceID"] forKey:@"deviceID"];
    if([self.extra isEqualToString:@"yes"]){
        [userReport setObject:mBusiness.businessName forKey:@"businessName"];
        [self gainScore:3];
    }
    else{
        [userReport setObject:@"n/a" forKey:@"businessName"];
        [self gainScore:1];
    }
    [userReport saveInBackground];
    

        
    self.extra = @"";
   
}

-(void)gainScore:(int) points{
    PFQuery *query = [PFQuery queryWithClassName:@"Users"];
    [query whereKey:@"deviceID" equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceID"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                NSNumber *number = [object objectForKey:@"score"];
                int value = [number intValue];
                number = [NSNumber numberWithInt:value + points];
                [object setObject:number forKey:@"score"];
                [object saveInBackground];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}


- (void)showAlertWithMessage:(NSString*)title :(NSString*)alertText {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:alertText
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
}


- (void)showReportOptions:(NSString*)title  {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:title
                                                      message:@""
                                                     delegate:nil
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:nil];
    
    [message addButtonWithTitle:@"Not in"];
    [message addButtonWithTitle:@"Button 3"];
    [message show];
}

-(IBAction)goForward
{
    [self buttonAnimation:@"up" ];
    [self tableAnimation :@"up"];
    
}




@end
