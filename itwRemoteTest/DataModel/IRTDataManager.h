//
//  IRTDataManager.h
//  itwRemoteTest
//
//  Created by Frédéric ABRIOUX on 04/03/2014.
//  Copyright (c) 2014 Frédéric ABRIOUX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

#import "IRTTweet.h"
#import "IRTAppDelegate.h"

#define TOO_OLD_TO_STAY 5 //seconds

@class IRTFirstViewController;

@interface IRTDataManager : NSObject<NSURLConnectionDelegate>{
    
    NSOperationQueue *queue;
    IRTFirstViewController *viewController;
    
}

@property (readonly, strong, nonatomic) NSManagedObjectContext *mainContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext *backgroundContext;

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) NSURLConnection *streamingConnection;

- (void) saveContext;
- (NSURL *) applicationDocumentsDirectory;

-(void)cleanUpRequests;

- (BOOL) userHasAccessToTwitter;

- (void) startStreamingWithKeyword:(NSString *)aKeyword;

-(void) launchTwitterStreamingRequestWithRecipient:(IRTFirstViewController *)vc;

-(void) stopTwitterStreamingRequest;

-(void) manageImportNewTwitterData:(NSArray *)dataToImport;

-(NSArray *) getTweetsForMap;

-(void) cleanTooOldTweets;

-(void)sendNewTwitterData:(NSArray *)dataToImport;

@end
