//
//  ServerManager.h
//  Test
//
//  Created by Stepan Chegrenev on 14.07.16.
//  Copyright © 2016 Stepan Chegrenev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerManager : NSObject

+ (ServerManager*) sharedManager;

- (void) getCurrencysValueForValue:(NSString *) parameter
                          OnSucces:(void(^)(NSDictionary * values)) succes
                         onFailure:(void(^)(NSError *error, NSInteger statuscode)) failure;

@end
