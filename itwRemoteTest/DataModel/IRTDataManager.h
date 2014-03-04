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

//This is the life span value of Pin Point & Tweet.
#define TOO_OLD_TO_STAY 5 //in seconds

@class IRTFirstViewController;

//This class is responsible of all data exchange and manipulation.
//As well as network communication.
//In this project, there is only one request.
//The request is a streaming one, so this class need to implement
//NSURLConnectionDelegate.
//Usually, an instance of this call is created into the Application Delegate.
//Here, to simplify the process, we instanciated it into the view controller.
//
@interface IRTDataManager : NSObject<NSURLConnectionDelegate>{
    
    //As the only controller we need to update is the following,
    //we use a simple way and keep a track of it here.
    IRTFirstViewController *viewController;
    
}

//This context is used for all operations with UI.
@property (readonly, strong, nonatomic) NSManagedObjectContext *mainContext;
//This context is used for all background operations, resulting of network exchanges.
@property (readonly, strong, nonatomic) NSManagedObjectContext *backgroundContext;

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//This connection lives as long as the view controller is displayed.
@property (nonatomic, strong) NSURLConnection *streamingConnection;

- (void) saveContext;
- (NSURL *) applicationDocumentsDirectory;

//Regarding the low number of functionnalities here, we choose to use the direct
//integration between iOs and Twitter.
//We suppose the user of this application is aware I need to have a Twitter account
//connected to his iPhone.
- (BOOL) userHasAccessToTwitter;

//We launch the streaming request and the search word is given in parameter.
- (void) startStreamingWithKeyword:(NSString *)aKeyword;

//This function is called by the external View Controller who need to be updated.
-(void) launchTwitterStreamingRequestWithRecipient:(IRTFirstViewController *)vc;

//Close the connection.
-(void) stopTwitterStreamingRequest;

//End of treatment for tweets last imported.
-(void) manageImportNewTwitterData:(NSArray *)dataToImport;

//Main thread / UI results.
-(NSArray *) getTweetsForMap;

//Main thread / UI results.
-(void) cleanTooOldTweets;

//Bridge between Background and Main threads.
-(void)sendNewTwitterData:(NSArray *)dataToImport;

@end
