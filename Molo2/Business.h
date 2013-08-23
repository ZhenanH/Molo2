//
//  Bussiness.h
//  Molo
//
//  Created by Zhenan Hong on 2/28/13.
//  Copyright (c) 2013 Lean Develop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Business : NSObject


@property (nonatomic, retain) NSArray * parcelArray;
@property (nonatomic, retain) NSString * boundaryPoints;
@property (nonatomic, retain) NSString * businessName;
@property (nonatomic, retain) NSNumber * visitCount;
@property (nonatomic, retain) NSNumber * nextLevelCost;
@property (nonatomic, retain) NSNumber * centerLatitude;
@property (nonatomic, retain) NSNumber * centerLongitude;

-(CLLocationCoordinate2D)getCircleFence;
-(NSArray*)getParcelPolygon;
-(void)getParcelString;
-(BOOL)isPoint:(CLLocationCoordinate2D)point inArea:(Business*)thisBusiness inMapView:(MKMapView*)mapView;
-(MKPolygon*)getPolygonRegion;
@end
