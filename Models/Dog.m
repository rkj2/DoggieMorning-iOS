//
//  Dog.m
//  DoggieMorning
//
//  Created by Rajive Jain on 11/4/17.
//  Copyright © 2017 Rajive Jain. All rights reserved.
//

#import "Dog.h"

@implementation Dog

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.previewURL = [aDecoder decodeObjectForKey:@"previewURL"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.previewURL forKey:@"previewURL"];
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
@end
