//
//  Dog.m
//  DoggieMorning
//
//  Created by Rajive Jain on 11/4/17.
//  Copyright © 2017 Rajive Jain. All rights reserved.
//

#import "Dog.h"

@implementation Dog

- (instancetype)initWithJson:(NSDictionary *)dogJson
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    BOOL hasId = (dogJson[@"id"] && dogJson[@"id"]) > 0;
    BOOL hasPreviewUrl = (dogJson[@"previewURL"] != [NSNull null]) && [dogJson[@"previewURL"] length] > 0;
    if (hasId && hasPreviewUrl) {
        self.dogImageId = [NSString stringWithFormat:@"%@", dogJson[@"id"]];
        self.previewURL = dogJson[@"previewURL"];
        return self;
    } else {
        return nil;
    }
    
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.previewURL = [aDecoder decodeObjectForKey:@"previewURL"];
    self.dogImageId = [aDecoder decodeObjectForKey:@"id"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.previewURL forKey:@"previewURL"];
    [aCoder encodeObject:self.dogImageId forKey:@"id"];
}

- (NSString *)fileName
{
    //test
    //self.previewURL = @"https://cdn.pixabay.com/photo/2017/10/26/12/34/fantasy-2890925_150.jpg";
    if ([self.previewURL length] > 0 && self.previewURL != nil)  {
        NSArray *components = [self.previewURL componentsSeparatedByString:@"/"];
        NSLog(@"%@", components);
        return [components lastObject];
    }
    return nil;
}

- (void)saveDog
{
    //temp
}

@end
