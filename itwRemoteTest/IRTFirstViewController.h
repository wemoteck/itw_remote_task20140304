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

//This class is responsible of the unique view of the application.
//Only a map is displayed and no others interactions are established.
//
@interface IRTFirstViewController : UIViewController<MKMapViewDelegate>

//Manager of Core Data operations and network requests.
//Usually inside the application delegate.
@property (nonatomic, retain) IRTDataManager *dataManager;

//The map displayed.
@property (nonatomic, retain) IBOutlet MKMapView *mapView;

//Take already in base pin points and display them when the map appears.
-(void)firstImportPinPoints;

//Remove all present pin points when the map disappears.
-(void)removeAllPinPoints;

//Used by the data manager to send and allow new pin points to be displayed.
-(void)addPinPointsForNewTweets:(NSArray *)newTweets;

//Used by the data manager to send and allow old pin points to be removed.
-(void)removePinPointsForOldTweets:(NSArray *)oldTweetsId;

@end
