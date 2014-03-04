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
    
    NSArray *datas = [dataManager getTweetsForMap];
    
    for (int i = 0; i < datas.count; i++) {
        IRTTweet *tweet = [datas objectAtIndex:i];
        
        CLLocationCoordinate2D  ctrpoint;
        ctrpoint.latitude = tweet.latitude.doubleValue;
        ctrpoint.longitude = tweet.longitude.doubleValue;
        IRTTweetPosition *addAnnotation = [[IRTTweetPosition alloc] init];
        [addAnnotation setCoordinate:ctrpoint];
        [addAnnotation setTweetId:tweet.twitterStringId];
        [mapView addAnnotation:addAnnotation];
        
    }
    
}

-(void)addPinPointsForNewTweets:(NSArray *)newTweets{
    
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
    
    [dataManager launchTwitterStreamingRequestWithRecipient:self];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [dataManager stopTwitterStreamingRequest];
    [dataManager cleanUpRequests];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    dataManager = [[IRTDataManager alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark MKMapViewDelegate

@end
