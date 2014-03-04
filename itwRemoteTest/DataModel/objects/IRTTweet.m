//
//  IRTTweet.m
//  itwRemoteTest
//
//  Created by Frédéric ABRIOUX on 04/03/2014.
//  Copyright (c) 2014 Frédéric ABRIOUX. All rights reserved.
//

#import "IRTTweet.h"


@implementation IRTTweet

@dynamic twitterId;
@dynamic latitude;
@dynamic longitude;
@dynamic creation;
@dynamic twitterStringId;
@dynamic twContent;

+(IRTTweet *)loadFromJSON:(NSDictionary *)json inManagedObjectContext:(NSManagedObjectContext *)moc{
    
    IRTTweet *res;
    
    //We first check if the tweet has geographical coordinates as in this test
    //we only care to display a pinpoint on a map.
    NSDictionary *coordinates = [json objectForKey:@"coordinates"];
    
    if (! coordinates || [NSStringFromClass(coordinates.class) isEqualToString:@"NSNull"]) {
        return nil;
    }
    
    NSString *t = [json objectForKey:@"id"];
    NSNumber *twId = [NSNumber numberWithInteger:t.integerValue];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"IRTTweet"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", @"twitterId", twId]];
    
    NSArray *array = [moc executeFetchRequest:request error:NULL];
    
    if (array.count > 0){
        res = [array lastObject];
        for (int i = 0; i < array.count - 1; i++) {
            [moc deleteObject:[array objectAtIndex:i]];
        }
    }else{
        res = [NSEntityDescription insertNewObjectForEntityForName:@"IRTTweet" inManagedObjectContext:moc];
    }
    
    res.twitterId = [NSNumber numberWithInteger:t.integerValue];
    
    t = [json objectForKey:@"created_at"];
    if (t && t.length > 0) {
        res.creation = [self dateFromUTCTimeStamp:t];
    }
    
    res.twitterStringId = [json objectForKey:@"id_str"];
    
    res.twContent = [json objectForKey:@"text"];
    
    //We already know here this JSON object got latitude and longitude for us.
    NSString *coordinatesType = [coordinates objectForKey:@"type"];
    
    //We just check that a point is given and not another kind of geographical data.
    if (coordinatesType && [coordinatesType isEqualToString:@"Point"]) {
        
        NSArray *coordinate = [coordinates objectForKey:@"coordinates"];
        
        if (coordinate && coordinate.count == 2) {
            NSString *tempLongitude = [coordinate objectAtIndex:0];
            NSString *tempLatitude = [coordinate objectAtIndex:1];
            
            res.longitude = [[NSNumber alloc] initWithDouble:tempLongitude.doubleValue];
            res.latitude = [[NSNumber alloc] initWithDouble:tempLatitude.doubleValue];
        }
        
    }
    
    return res;
    
    
}

+(IRTTweet *)loadFromPrimaryKey:(NSNumber *)pk inManagedObjectContext:(NSManagedObjectContext *)moc{
    IRTTweet *res;
    
    //We do not use this function in this project, regarding its simplicity
    //and the manipulated object (in this case, object are not updated).
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"IRTTweet"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", @"twitterId", pk]];
    [request setReturnsObjectsAsFaults:FALSE];
    NSArray *array = [moc executeFetchRequest:request error:NULL];
    
    if (array.count > 0){
        res = [array lastObject];
    }else{
        res = nil;
    }
    
    return res;
}

+(NSDate *)dateFromUTCTimeStamp:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    //Format of the date returned by Twitter as specified into their documentation.
    [dateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
    
    NSDate *timeStamp = [dateFormatter dateFromString:dateString];
    return timeStamp;
}

@end
