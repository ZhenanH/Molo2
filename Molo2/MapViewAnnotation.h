//
//  MapViewAnnotation.h
//  Molo
//
//  Created by Zhenan Hong on 3/4/13.
//  Copyright (c) 2013 Lean Develop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapViewAnnotation : NSObject<MKAnnotation>

@property (nonatomic, retain) NSString *title;
@property CLLocationCoordinate2D coordinate;

- (id)initWithTitle:(NSString *)ttl andCoordinate:(CLLocationCoordinate2D)c2d;

@end
