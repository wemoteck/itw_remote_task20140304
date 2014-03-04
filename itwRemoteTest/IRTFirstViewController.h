//
//  IRTFirstViewController.h
//  itwRemoteTest
//
//  Created by Frédéric ABRIOUX on 04/03/2014.
//  Copyright (c) 2014 Frédéric ABRIOUX. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>

@class IRTDataManager;

@interface IRTFirstViewController : UIViewController<MKMapViewDelegate>

@property (nonatomic, retain) IRTDataManager *dataManager;

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

-(void)addPinPointsForNewTweets:(NSArray *)newTweets;

@end
