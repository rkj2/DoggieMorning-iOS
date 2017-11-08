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
static NSString *const kPerPageItems = @"20";

@interface DMPhotoWebService()
@property (nonatomic) NSUInteger pageNumber;
@end

@implementation DMPhotoWebService

- (void)firstFetch: (void (^)(NSArray *, NSError *))callback
{
    self.pageNumber = 0;
    [self fetchMoreDogs:callback];
}

- (void)fetchMoreDogs:(void (^)(NSArray *, NSError *))callback
{
    if (self.pageNumber <= 0) {
        self.pageNumber = 1;
    } else {
        self.pageNumber = self.pageNumber + 1;
    }
    NSURL *url = [self urlForSearchTerm:@"dog"];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:
      ^(NSData *data, NSURLResponse *response, NSError *error) {
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
    
    // Keys can be made constants
    
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = kScheme;
    components.host = kHost;
    components.path = kPath;
    NSURLQueryItem *keyItem = [NSURLQueryItem queryItemWithName:@"key" value:kAPIKey];
    NSURLQueryItem *dogItem = [NSURLQueryItem queryItemWithName:@"q" value: term];
    NSURLQueryItem *imageTypeItem = [NSURLQueryItem queryItemWithName:@"image_type" value:@"photo"];
    NSURLQueryItem *perPageItem = [NSURLQueryItem queryItemWithName:@"per_page" value:kPerPageItems];
    NSString *page = [NSString stringWithFormat:@"%ld", (long)self.pageNumber];
    NSURLQueryItem *pageItem = [NSURLQueryItem queryItemWithName:@"page" value:page];
    components.queryItems = @[keyItem, dogItem, imageTypeItem, perPageItem, pageItem];
    return components.URL;
}

@end
