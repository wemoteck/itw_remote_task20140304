//
//  IRTFirstViewController.m
//  itwRemoteTest
//
//  Created by Frédéric ABRIOUX on 04/03/2014.
//  Copyright (c) 2014 Frédéric ABRIOUX. All rights reserved.
//

#import "IRTFirstViewController.h"

#import "IRTAppDelegate.h"
#import "IRTDataManager.h"

#import "IRTTweet.h"
#import "IRTTweetPosition.h"

@implementation IRTFirstViewController

@synthesize dataManager;
@synthesize mapView;

-(void) viewDidAppear:(BOOL)animated{
    
    //we add pin points already present in the base to the map.
    [self firstImportPinPoints];
    
}

-(void)firstImportPinPoints{
    
    //request managed by the dedicated class instance.
    NSArray *datas = [dataManager getTweetsForMap];
    
    for (int i = 0; i < datas.count; i++) {
        IRTTweet *tweet = [datas objectAtIndex:i];
        
        //we let the map object manage wich pin points displayed and others memory optimization.
        CLLocationCoordinate2D  ctrpoint;
        ctrpoint.latitude = tweet.latitude.doubleValue;
        ctrpoint.longitude = tweet.longitude.doubleValue;
        IRTTweetPosition *addAnnotation = [[IRTTweetPosition alloc] init];
        [addAnnotation setCoordinate:ctrpoint];
        //The Twitter String id is used to identify the pin point for update actions.
        [addAnnotation setTweetId:tweet.twitterStringId];
        //effectivily add the pin point to the map.
        [mapView addAnnotation:addAnnotation];
        
    }
    
}

-(void)removeAllPinPoints{
    //clear / clean the map content.
    [self.mapView removeAnnotations:self.mapView.annotations];
}

-(void)addPinPointsForNewTweets:(NSArray *)newTweets{
    
    //we add each tweet send by the manager
    for (int i = 0; i < newTweets.count; i++) {
        IRTTweet *tweet = [newTweets objectAtIndex:i];
        
        CLLocationCoordinate2D  ctrpoint;
        ctrpoint.latitude = tweet.latitude.doubleValue;
        ctrpoint.longitude = tweet.longitude.doubleValue;
        IRTTweetPosition *addAnnotation = [[IRTTweetPosition alloc] init];
        [addAnnotation setCoordinate:ctrpoint];
        [addAnnotation setTweetId:tweet.twitterStringId];
        [mapView addAnnotation:addAnnotation];
        
    }
}

-(void)removePinPointsForOldTweets:(NSArray *)oldTweetsId{
    
    //we remove each tweet deleted by the manager.
    for (int i = 0; i < oldTweetsId.count; i++) {
        
        NSString *tweetId = [oldTweetsId objectAtIndex:i];
        
        NSPredicate *predicate =
            [NSPredicate predicateWithFormat:@"self.tweetId = %@", tweetId];
        
        NSArray *tempDatas = [mapView.annotations filteredArrayUsingPredicate:predicate];
        for (int j = 0; j < tempDatas.count; j++) {
            IRTTweetPosition *annotationToRemove = (IRTTweetPosition *)[tempDatas objectAtIndex:j];
            [mapView removeAnnotation:annotationToRemove];
        }
        
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //we launch the import process.
    [dataManager launchTwitterStreamingRequestWithRecipient:self];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    //we stop the import of new data.
    [dataManager stopTwitterStreamingRequest];
    
    //we clean the map.
    [self removeAllPinPoints];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //we set-up the manager. usually done in the application delegate.
    dataManager = [[IRTDataManager alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark MKMapViewDelegate
//In this test, we do not provide any custom interaction with the map.

@end
