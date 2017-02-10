//
//  ServerManager.m
//  Test
//
//  Created by Stepan Chegrenev on 14.07.16.
//  Copyright © 2016 Stepan Chegrenev. All rights reserved.
//

#import "ServerManager.h"
#import "AFNetworking.h"

@interface ServerManager ()

@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;

@end

@implementation ServerManager

+ (ServerManager*) sharedManager{
    
    static ServerManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ServerManager alloc] init];
    });
    
    return manager;
}

-(id)init {
    self = [super init];
    if (self) {
        
        NSURL *url = [NSURL URLWithString:@"http://api.fixer.io/"];
        
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
    }
    return self;
}

-(void) getCurrencysValueForValue:(NSString *) parameter
                         OnSucces:(void(^)(NSDictionary * values)) succes
                        onFailure:(void(^)(NSError *error, NSInteger statuscode)) failure {
    
    
    NSDictionary* params = @{@"base" : parameter};
    
    [self.sessionManager
     GET:@"latest"
     parameters:params
     progress:nil
     success:^(NSURLSessionDataTask *task, NSDictionary* responseObject) {
         
         NSDictionary* valuesDictionary = [responseObject objectForKey:@"rates"];
         if (succes) {
             succes(valuesDictionary);
         }
         
     }
     failure:^(NSURLSessionTask *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
         NSInteger statusCode = response.statusCode;
         
         if (failure) {
             failure(error, statusCode);
         }
         
     }];
}

@end
