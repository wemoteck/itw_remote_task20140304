//
//  IRTDataManager.m
//  itwRemoteTest
//
//  Created by Frédéric ABRIOUX on 04/03/2014.
//  Copyright (c) 2014 Frédéric ABRIOUX. All rights reserved.
//

#import "IRTDataManager.h"

#import "IRTFirstViewController.h"

@implementation IRTDataManager

@synthesize mainContext = _mainContext;
@synthesize backgroundContext = _backgroundContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize streamingConnection;

//Initialize all aspects of Core Data Managements
- (id)init {
    
    self = [super init];
    if (self) {
        
        //Ensure propagation of events through processes
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSavePrivateQueueContext:)name:NSManagedObjectContextDidSaveNotification object:[self backgroundContext]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSaveMainQueueContext:) name:NSManagedObjectContextDidSaveNotification object:[self mainContext]];
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)contextDidSavePrivateQueueContext:(NSNotification *)notification {
    @synchronized(self) {
        [self.mainContext performBlock:^{
            [self.mainContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}

- (void)contextDidSaveMainQueueContext:(NSNotification *)notification {
    @synchronized(self) {
        [self.backgroundContext performBlock:^{
            [self.backgroundContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.mainContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)mainContext{
    if (_mainContext != nil) {
        return _mainContext;
    }
    
    _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _mainContext.parentContext = [self backgroundContext];
    
    return _mainContext;
}

// Parent context
- (NSManagedObjectContext *)backgroundContext{
    if (_backgroundContext != nil) {
        return _backgroundContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_backgroundContext setPersistentStoreCoordinator:coordinator];
    }
    return _backgroundContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CloseToMeet.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Twitter Streaming Related Code

//We check the application will have access to a Twitter account credentials.
- (BOOL)userHasAccessToTwitter {
    return [SLComposeViewController
            isAvailableForServiceType:SLServiceTypeTwitter];
}

- (void)startStreamingWithKeyword:(NSString *)aKeyword
{
    //First, we need to obtain the account instance for the user's Twitter account
    ACAccountStore *store = [[ACAccountStore alloc] init];
    ACAccountType *twitterAccountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    //  Request permission from the user to access the available Twitter accounts
    [store requestAccessToAccountsWithType:twitterAccountType
                                   options:nil
                                completion:^(BOOL granted, NSError *error) {
                                    if (!granted) {
                                        // The user rejected your request
                                        NSLog(@"User rejected access to the account.");
                                    }
                                    else {
                                        // Grab the available accounts
                                        NSArray *twitterAccounts = [store accountsWithAccountType:twitterAccountType];
                                        if ([twitterAccounts count] > 0) {
                                            ACAccount *account = [twitterAccounts lastObject];
                                            
                                            NSURL *url = [NSURL URLWithString:@"https://stream.twitter.com/1.1/statuses/filter.json"];
                                            NSDictionary *params = @{@"track" : aKeyword};
                                            
                                            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                                                    requestMethod:SLRequestMethodPOST
                                                                                              URL:url
                                                                                       parameters:params];
                                            
                                            [request setAccount:account];
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                streamingConnection = [NSURLConnection connectionWithRequest:[request preparedURLRequest] delegate:self];
                                                [streamingConnection start];
                                            });
                                        } // if ([twitterAccounts count] > 0)
                                    } // if (granted)
                                }];
}

-(void) launchTwitterStreamingRequestWithRecipient:(IRTFirstViewController *)vc{
    
    //Check Twitter Account Credentials access
    if ([self userHasAccessToTwitter]) {
        //Retain reference to the view controller to update
        viewController = vc;
        //Launch the streaming data import
        [self startStreamingWithKeyword:@"I"];
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //New data received are send in background to be analysed
    [self performSelectorInBackground:@selector(bgTreatmentNewData:) withObject:data];
    
}

-(void) stopTwitterStreamingRequest {
    //Stop the data import
    [streamingConnection cancel];
    //Remove the reference to the view to update
    viewController = nil;
}

-(void)bgTreatmentNewData:(NSData *)data {
    
    //We clean old tweets
    [self cleanTooOldTweets];
    
    //We convert imported data in readable string
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //According to the Twitter Documentation, each tweet is separated by the characters \r\n
    //and are not send in an array
    NSArray *splitRes = [dataString componentsSeparatedByString:@"\r\n"];
    
    NSMutableArray *res = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < splitRes.count; i++) {
        
        //conversion of each tweet data into a proper json dictionnary
        NSData *ndata = [[splitRes objectAtIndex:i] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:ndata options:0 error:nil];
        
        if (json) {
            //We import json dictionnary as a proper IRTTweet object
            [self.backgroundContext performBlockAndWait:^{
                IRTTweet *t = [IRTTweet loadFromJSON:json inManagedObjectContext:self.backgroundContext];
                if (t) {
                    //If no geographical coordinate are available, we do nothing
                    [self.backgroundContext save:nil];
                    [res addObject:t.twitterStringId];
                }
            }];
            
        }
    }
    
    if (viewController) {
        
        [self performSelectorOnMainThread:@selector(sendNewTwitterData:) withObject:res waitUntilDone:TRUE];
        
    }
    
    
}

-(void)sendNewTwitterData:(NSArray *)dataToImport{
    
    NSFetchRequest *request=[[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"IRTTweet" inManagedObjectContext:self.mainContext];
    //Selection of all tweeds recently imported but in the main context
    request.predicate = [NSPredicate predicateWithFormat:@"self.twitterStringId IN %@", dataToImport];
    NSArray *res = [self.mainContext executeFetchRequest:request error:nil];
    
    //send them to the view for updating the map.
    [viewController performSelectorOnMainThread:@selector(addPinPointsForNewTweets:) withObject:res waitUntilDone:TRUE];
    
}

-(NSArray *) getTweetsForMap{
    
    __block
    NSArray *res;
    
    //UI action = main thread
    //All tweets are returned.
    [self.mainContext performBlockAndWait:^{
        NSError *error = nil;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"IRTTweet"];
        [request setReturnsObjectsAsFaults:NO];
        [request setReturnsDistinctResults:TRUE];
        res = [self.mainContext executeFetchRequest:request error:&error];
        
    }];
    
    return res;
    
}

//In background, this function requests too old tweets and delete them.
-(void)cleanTooOldTweets{
    
    __block
    NSMutableArray *toDelete = [[NSMutableArray alloc] init];
    
    //Because deletion involves changes in data base, we do it with the background context
    [self.backgroundContext performBlockAndWait:^{
        NSFetchRequest *request=[[NSFetchRequest alloc] init];
        request.entity=[NSEntityDescription entityForName:@"IRTTweet" inManagedObjectContext:self.backgroundContext];
        //Too old means created before a date.
        request.predicate=[NSPredicate predicateWithFormat:@"creation < %@",[NSDate dateWithTimeIntervalSinceNow:-TOO_OLD_TO_STAY]];
        NSArray *res = [self.backgroundContext executeFetchRequest:request error:nil];
        
        for (int j = 0; j < res.count; j ++) {
            IRTTweet *tweetToDelete = [res objectAtIndex:j];
            [self.backgroundContext deleteObject:tweetToDelete];
            
            //We keep record of deleted tweets' ids in order to update pin points.
            [toDelete addObject:tweetToDelete.twitterStringId];
            
        }
        //We save the deletion.
        [self.backgroundContext save:nil];
    }];
    
    if (viewController) {
        //Update the map, UI action, main thread
        [viewController performSelectorOnMainThread:@selector(removePinPointsForOldTweets:) withObject:toDelete waitUntilDone:TRUE];
    }
    
}


@end
