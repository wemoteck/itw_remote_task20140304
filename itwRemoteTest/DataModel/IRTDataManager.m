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

- (id)init {
    
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSavePrivateQueueContext:)name:NSManagedObjectContextDidSaveNotification object:[self backgroundContext]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSaveMainQueueContext:) name:NSManagedObjectContextDidSaveNotification object:[self mainContext]];
        
        //appDelegate = (CTMAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        queue = [[NSOperationQueue alloc] init];
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)cleanUpRequests{
    [queue cancelAllOperations];
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
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
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

- (BOOL)userHasAccessToTwitter
{
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

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *splitRes = [dataString componentsSeparatedByString:@"\r\n"];
    
    for (int i = 0; i < splitRes.count; i++) {
        
        NSData *ndata = [[splitRes objectAtIndex:i] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:ndata options:0 error:nil];
        
        NSMutableArray *res = [[NSMutableArray alloc] init];
        
        if (json) {
            
            [self.backgroundContext performBlockAndWait:^{
                IRTTweet *t = [IRTTweet loadFromJSON:json inManagedObjectContext:self.backgroundContext];
                if (t) {
                    [self.backgroundContext save:nil];
                    [res addObject:t];
                }
            }];
            
            [self manageImportNewTwitterData:res];
            
        }
    }
    
}

-(void) launchTwitterStreamingRequestWithRecipient:(IRTFirstViewController *)vc{
    viewController = vc;
    [self startStreamingWithKeyword:@"I"];
}

-(void) stopTwitterStreamingRequest {
    viewController = nil;
    [streamingConnection cancel];
}

-(void)manageImportNewTwitterData:(NSArray *)dataToImport{
    if (viewController) {
        [viewController addPinPointsForNewTweets:dataToImport];
    }
}

-(NSArray *) getTweetsForMap{
    
    __block
    NSArray *res;
    
    [self.mainContext performBlockAndWait:^{
        NSError *error = nil;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"IRTTweet"];
        [request setReturnsObjectsAsFaults:NO];
        [request setReturnsDistinctResults:TRUE];
        //[request setSortDescriptors:[[NSArray alloc] initWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"idctm" ascending:FALSE], nil]];
        res = [self.mainContext executeFetchRequest:request error:&error];
        
    }];
    
    return res;
    
}

@end
