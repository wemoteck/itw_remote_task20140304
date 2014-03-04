//
//  IRTTweet.h
//  itwRemoteTest
//
//  Created by Frédéric ABRIOUX on 04/03/2014.
//  Copyright (c) 2014 Frédéric ABRIOUX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

//This class is a very simplified Core Data representation of a Tweet object.
//The full description could be find at https://dev.twitter.com/docs/platform-objects/tweets
//
@interface IRTTweet : NSManagedObject

//64 bits Integer representing the id of the Tweet in the Tweeter base.
//Should not be used as primary key. json key value = id
@property (nonatomic, retain) NSNumber * twitterId;

//Double representing the latitude of the Tweet if available.
//json key value = second object into array of the coordinates object.
//GeoJSON format.
@property (nonatomic, retain) NSNumber * latitude;

//Double representing the longitude of the Tweet if available.
//json key value = first object into array of the coordinates object.
//GeoJSON format.
@property (nonatomic, retain) NSNumber * longitude;

//Date the tweet was created, according to Twitter information.
//json key value = created_at
@property (nonatomic, retain) NSDate * creation;

//String representation of the id of the Tweet in the Tweeter base.
//json key value = id_str. Used here as a primary key.
@property (nonatomic, retain) NSString * twitterStringId;

//Text content of the Tweet.
//json key value = text
@property (nonatomic, retain) NSString * twContent;

//Returns an IRTTweet object from the json data issued by the Twitter API.
+(IRTTweet *)loadFromJSON:(NSDictionary *)json inManagedObjectContext:(NSManagedObjectContext *)moc;

//Returns an IRTTweet object from the local base based on the primary key passed in parameter.
//Returns nil if no IRTTweet was found with the primary key passed in parameter.
+(IRTTweet *)loadFromPrimaryKey:(NSNumber *)pk inManagedObjectContext:(NSManagedObjectContext *)moc;

//Convert the date representation from Twitter into a NSDate object.
+(NSDate *)dateFromUTCTimeStamp:(NSString *)dateString;

@end
