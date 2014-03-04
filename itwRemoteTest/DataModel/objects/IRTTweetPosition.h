//
//  IRTTweetPosition.h
//  itwRemoteTest
//
//  Created by Frédéric ABRIOUX on 04/03/2014.
//  Copyright (c) 2014 Frédéric ABRIOUX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

//This class is compliant with the MKAnnotation protocol.
//We use it to display one pin point for each tweet imported.
//
@interface IRTTweetPosition : NSObject <MKAnnotation> {
    NSString *_title;
    NSString *_subtitle;
    
    CLLocationCoordinate2D _coordinate;
}

//We add to the required fields a specific one.
//It will help us to update efficiently the map.
@property (nonatomic, retain) NSString *tweetId;

// Getters and setters
- (void)setTitle:(NSString *)title;
- (void)setSubtitle:(NSString *)subtitle;

@end
