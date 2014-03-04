//
//  IRTTweet.m
//  itwRemoteTest
//
//  Created by Frédéric ABRIOUX on 04/03/2014.
//  Copyright (c) 2014 Frédéric ABRIOUX. All rights reserved.
//

#import "IRTTweet.h"


@implementation IRTTweet

@dynamic twitterId;//id
@dynamic latitude;//coordinates
@dynamic longitude;
@dynamic creation;//created_at
@dynamic twitterStringId;//id_str
@dynamic twContent;//text

+(IRTTweet *)loadFromJSON:(NSDictionary *)json inManagedObjectContext:(NSManagedObjectContext *)moc{
    
    IRTTweet *res;
    
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
    
    //Here, we treat the coordinates formatted as geoJSON
    NSDictionary *coordinates = [json objectForKey:@"coordinates"];
    if (coordinates) {
        NSString *coordinatesType = [coordinates objectForKey:@"type"];
        
        if (coordinatesType && [coordinatesType isEqualToString:@"Point"]) {
            
            NSArray *coordinate = [coordinates objectForKey:@"coordinates"];
            
            if (coordinate && coordinate.count == 2) {
                NSString *tempLongitude = [coordinate objectAtIndex:0];
                NSString *tempLatitude = [coordinate objectAtIndex:1];
                
                res.longitude = [[NSNumber alloc] initWithDouble:tempLongitude.doubleValue];
                res.latitude = [[NSNumber alloc] initWithDouble:tempLatitude.doubleValue];
            }
            
        }
        
    }
    
    return res;
    
    
}

+(IRTTweet *)loadFromPrimaryKey:(NSNumber *)pk inManagedObjectContext:(NSManagedObjectContext *)moc{
    IRTTweet *res;
    
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
    [dateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
    
    NSDate *timeStamp = [dateFormatter dateFromString:dateString];
    return timeStamp;
}

@end
