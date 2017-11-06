//
//  DMPhotoWebService.m
//  DoggieMorning
//
//  Created by Rajive Jain on 11/5/17.
//  Copyright © 2017 Rajive Jain. All rights reserved.
//

#import "DMPhotoWebService.h"

static NSString *const kScheme = @"https";
static NSString *const kHost = @"pixabay.com";
static NSString *const kPath = @"/api/";
static NSString *const kAPIKey = @"6936503-9a8fdba549da42ad9e802512b";

@implementation DMPhotoWebService

- (void)fetchAllDogs:(void (^)(NSArray *, NSError *))callback
{
//    NSURL *url = [self urlForDogPhotos];
    NSURL *url = [self urlForSearchTerm:@"dog"];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:
      ^(NSData *data, NSURLResponse *response, NSError *error) {
          NSLog(@"response: %@", response);
          if (error) {
              callback(nil, error);
          } else {
              id results = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
              if ([results isKindOfClass:[NSDictionary class]]) {
                  NSArray *dogs = results[@"hits"];
                  if (callback) {
                      callback(dogs, nil);
                  }
              }
          }
      }
      ] resume];
}

- (NSURL *)urlForSearchTerm:(NSString *)term
{
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = kScheme;
    components.host = kHost;
    components.path = kPath;
    NSURLQueryItem *keyItem = [NSURLQueryItem queryItemWithName:@"key" value:kAPIKey];
    NSURLQueryItem *dogItem = [NSURLQueryItem queryItemWithName:@"q" value: term];
    NSURLQueryItem *imageTypeItem = [NSURLQueryItem queryItemWithName:@"image_type" value:@"photo"];
    NSURLQueryItem *perPageItem = [NSURLQueryItem queryItemWithName:@"per_page" value:@"20"];
    NSURLQueryItem *pageItem = [NSURLQueryItem queryItemWithName:@"page" value:@"3"];
    components.queryItems = @[keyItem, dogItem, imageTypeItem, perPageItem, pageItem];
    return components.URL;
}

@end
