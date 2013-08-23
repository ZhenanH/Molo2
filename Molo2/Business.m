//
//  Bussiness.m
//  Molo
//
//  Created by Zhenan Hong on 2/28/13.
//  Copyright (c) 2013 Lean Develop. All rights reserved.
//

#import "Business.h"

@implementation Business


-(id)init{
    if((self=[super init])){

    }
    return self;
}


-(CLLocationCoordinate2D)getCircleFence
{
    CLLocationCoordinate2D geofence;
    geofence.latitude = [self.centerLatitude doubleValue];
    geofence.longitude = [self.centerLongitude doubleValue];
    return geofence;
}

-(NSArray*)getParcelPolygon
{
    NSArray *boundary = [self.boundaryPoints componentsSeparatedByString:@"|"];
    
    return boundary;
}

-(void)getParcelString
{
   self.boundaryPoints = @"";
    for(NSDictionary *point in self.parcelArray){
        if(![self.boundaryPoints isEqualToString:@""])
        self.boundaryPoints = [[NSString alloc] initWithFormat:@"%@|%@,%@",self.boundaryPoints,[point objectForKey:@"y"],[point objectForKey:@"x"]];
        else
        self.boundaryPoints = [[NSString alloc] initWithFormat:@"%@,%@",[point objectForKey:@"y"],[point objectForKey:@"x"]];
            
    }
    
}

-(BOOL)isPoint:(CLLocationCoordinate2D)point inArea:(Business*)thisBusiness inMapView:(MKMapView*)mapView
{
    NSArray* parcels = [thisBusiness getParcelPolygon];
    CLLocationCoordinate2D parcelPoints[[parcels count]];
    for(int i=0;i<[parcels count];i++){
        double lat = [[[parcels objectAtIndex:i] componentsSeparatedByString:@","][0] doubleValue];
        double lon = [[[parcels objectAtIndex:i] componentsSeparatedByString:@","][1] doubleValue];
        parcelPoints[i]=CLLocationCoordinate2DMake(lat,lon);
    }
    MKPolygon *region = [MKPolygon polygonWithCoordinates:parcelPoints count:[parcels count]];
    
    BOOL isInside = FALSE;
    
    MKPolygonView *polygonView = (MKPolygonView *)[mapView viewForOverlay:region];
    
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

-(MKPolygon*)getPolygonRegion
{
    
    NSArray* parcels = [self getParcelPolygon];
    CLLocationCoordinate2D parcelPoints[[parcels count]];
    for(int i=0;i<[parcels count];i++){
        double lat = [[[parcels objectAtIndex:i] componentsSeparatedByString:@","][0] doubleValue];
        double lon = [[[parcels objectAtIndex:i] componentsSeparatedByString:@","][1] doubleValue];
        parcelPoints[i]=CLLocationCoordinate2DMake(lat,lon);
    }
    MKPolygon *region = [MKPolygon polygonWithCoordinates:parcelPoints count:[parcels count]];
    
    return region;
}




@end
