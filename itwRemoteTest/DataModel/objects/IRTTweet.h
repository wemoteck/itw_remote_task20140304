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
@property (nonatomic, retain) NSNumber * twitterId;

//Double representing the latitude of the Tweet if available.
@property (nonatomic, retain) NSNumber * latitude;

//Double representing the longitude of the Tweet if available.
@property (nonatomic, retain) NSNumber * longitude;

//Date the tweet was created, according to Twitter information.
@property (nonatomic, retain) NSDate * creation;

//String representation of the id of the Tweet in the Tweeter base.
@property (nonatomic, retain) NSString * twitterStringId;

//Text content of the Tweet.
@property (nonatomic, retain) NSString * twContent;

/*  These function is not needed by the required implementation */
//+(NSDictionary *)getJSONFromObject:(IRTTweet *)object;

//Returns an IRTTweet object from the json data issued by the Twitter API.
+(IRTTweet *)loadFromJSON:(NSDictionary *)json inManagedObjectContext:(NSManagedObjectContext *)moc;

//Returns an IRTTweet object from the local base based on the primary key passed in parameter.
//Returns nil if no IRTTweet was found with the primary key passed in parameter.
+(IRTTweet *)loadFromPrimaryKey:(NSNumber *)pk inManagedObjectContext:(NSManagedObjectContext *)moc;

//Convert the date representation from Twitter into a NSDate object.
+(NSDate *)dateFromUTCTimeStamp:(NSString *)dateString;

@end
